//
//  TCSParseService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseService.h"
#if TARGET_OS_IPHONE
#import <Parse/Parse.h>
#else
#import <ParseOSX/ParseOSX.h>
//#import <ParseOSX/PFFacebookUtils.h>
//#import <ParseOSX/PFTwitterUtils.h>
#endif
#import "TCSService.h"
#import "NSDate+Utilities.h"
#import "GCNetworkReachability.h"
#import "TCSParseTimedEntity.h"
#import "TCSParseGroup.h"
#import "TCSParseProject.h"
#import "TCSParseTimer.h"
#import "TCSParseProviderInstance.h"
#import "TCSParseCannedMessage.h"
#import "TCSParseRemoteCommand.h"
#import "TCSParseAppConfig.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"
#import "TCSParseSystemTime.h"
#import "AFHTTPRequestOperation.h"
#import "AFHTTPClient.h"

static inline NSError * TCSParseServiceWrapObjectNotFoundError(NSError *error) {
    if ([error.domain isEqualToString:@"Parse"]) {
        if (error.code == kPFErrorObjectNotFound) {
            error =
            [NSError
             errorWithCode:TCErrorCodeRemoteObjectNotFound
             message:error.localizedDescription];
        }
    }
    return error;
}

NSString * const kTCSParseLastPollingDateKey = @"parse-last-polling-date";
NSTimeInterval const kTCSParsePollingDateThreshold = 5.0f; // look back 5 sec

@interface TCSParseService() {

    BOOL _pollingForUpdates;
    
    NSTimeInterval _localTimeLastSystemTimeReceived;
}

@property (nonatomic, strong) GCNetworkReachability *reachability;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, strong) NSMutableDictionary *bufferedUpdates;
@property (nonatomic, strong) NSDate *lastPollingDate;
@property (nonatomic, strong) NSDate *systemTime;
@property (nonatomic, strong) NSTimer *systemTimeTimer;

@end

@implementation TCSParseService

- (id)init {
    self = [super init];
    if (self) {

        self.bufferedUpdates = [NSMutableDictionary dictionary];

        [TCSParseProject registerSubclass];
        [TCSParseGroup registerSubclass];
        [TCSParseTimer registerSubclass];
        [TCSParseCannedMessage registerSubclass];
        [TCSParseAppConfig registerSubclass];
        [TCSParseRemoteCommand registerSubclass];
        [TCSParseProviderInstance registerSubclass];

        [PFACL setDefaultACL:[PFACL ACL] withAccessForCurrentUser:YES];

        [Parse setApplicationId:@"jF4VaTdB8FrBuFp52WFr9DzU70X9PPBeB9anwRga"
                      clientKey:@"4nNUdTExe0QhkOzNO1WYbplDAgYIjoCxinNmHlTO"];

        [PFTwitterUtils initializeWithConsumerKey:nil  consumerSecret:nil];
        [PFFacebookUtils initializeFacebook];

        self.reachability = [GCNetworkReachability reachabilityWithHostName:@"api.parse.com"];

        [self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {

            // this block is called on the main thread
            switch (status) {
                case GCNetworkReachabilityStatusNotReachable:
                    NSLog(@"No connection");
                    _connected = NO;
                    break;
                case GCNetworkReachabilityStatusWWAN:
                case GCNetworkReachabilityStatusWiFi:
                    _connected = YES;
                    break;
            }
        }];


        self.lastPollingDate =
        [[NSUserDefaults standardUserDefaults]
         objectForKey:kTCSParseLastPollingDateKey];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [self updateSystemTime];
        });

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(updateSystemTime)
         name:UIApplicationWillEnterForegroundNotification
         object:nil];
    }

    return self;
}

- (NSString *)name {
    return NSLocalizedString(@"Parse", nil);
}

- (BOOL)canCreateEntities {
    return YES;
}

- (NSDate *)systemTime {
    if (_systemTime != nil) {
        NSTimeInterval timeSinceReceivedSystemTime =
        [NSDate timeIntervalSinceReferenceDate] - _localTimeLastSystemTimeReceived;
        
        return [_systemTime dateByAddingTimeInterval:timeSinceReceivedSystemTime];
    }

    return [NSDate date];
}

- (void)createAppConfig {

    if ([PFUser currentUser] == nil) return;

    NSString *version =
    [[[NSBundle mainBundle] infoDictionary]
     objectForKey:@"CFBundleShortVersionString"];
    NSArray *components = [version componentsSeparatedByString:@"."];

    TCSParseAppConfig *appConfig = [TCSParseAppConfig object];
    appConfig.instanceID = [NSString applicationInstanceId];
    appConfig.deviceID = [NSString deviceIdentifier];
    appConfig.appStartCount = 1;
    appConfig.majorVersion = components.count >= 1 ? [components[0] integerValue] : -1;
    appConfig.minorVersion = components.count >= 2 ? [components[1] integerValue] : -1;
    appConfig.buildVersion = components.count >= 3 ? [components[2] integerValue] : -1;
    appConfig.user = [PFUser currentUser];

    [appConfig saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        NSLog(@"Created AppConfig: %@", appConfig);
    }];

#if TARGET_OS_IPHONE
    // Saving the device's owner
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:[PFUser currentUser] forKey:@"owner"];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (error != nil) {
            NSLog(@"Error bind current user to installation: %@", error);
        }
    }];
#endif
}

- (void)updateAppConfig {

    if ([PFUser currentUser] == nil) return;

    PFQuery *query = [TCSParseAppConfig query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"instanceID" equalTo:[NSString applicationInstanceId]];
    query.cachePolicy = kPFCachePolicyNetworkOnly;

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (objects.count == 0) {
            [self createAppConfig];
            return;
        }

        if (objects.count > 1) {
            NSLog(@"Warn: multiple app config objects exist for user: %@", [PFUser currentUser]);
        }

        NSString *version =
        [[[NSBundle mainBundle] infoDictionary]
         objectForKey:@"CFBundleShortVersionString"];
        NSArray *components = [version componentsSeparatedByString:@"."];

        TCSParseAppConfig *appConfig = objects.firstObject;

        appConfig.appStartCount++;
        appConfig.majorVersion = components.count >= 1 ? [components[0] integerValue] : -1;
        appConfig.minorVersion = components.count >= 2 ? [components[1] integerValue] : -1;
        appConfig.buildVersion = components.count >= 3 ? [components[2] integerValue] : -1;
        appConfig.user = [PFUser currentUser];

        [appConfig saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"Updated AppConfig: %@", appConfig);
        }];
    }];

#if TARGET_OS_IPHONE
    // Saving the device's owner
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation setObject:[PFUser currentUser] forKey:@"owner"];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (error != nil) {
            NSLog(@"Error bind current user to installation: %@", error);
        }
    }];
#endif
}

- (void)clearCache {
}

- (id)safePropertyValue:(id)value {
    return value != nil ? value : [NSNull null];
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) {
        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"User not logged in.")];

            failureBlock(error);
        }
        return;
    }
    
    [self clearCache];

    PFQuery *timerQuery = [TCSParseTimer query];
    [timerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    timerQuery.cachePolicy = kPFCachePolicyNetworkOnly;
    
    PFQuery *projectQuery = [TCSParseProject query];
    [projectQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    projectQuery.cachePolicy = kPFCachePolicyNetworkOnly;

    PFQuery *groupQuery = [TCSParseGroup query];
    [groupQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    groupQuery.cachePolicy = kPFCachePolicyNetworkOnly;

    PFQuery *cannedMessageQuery = [TCSParseCannedMessage query];
    [cannedMessageQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    cannedMessageQuery.cachePolicy = kPFCachePolicyNetworkOnly;

    [timerQuery findObjectsInBackgroundWithBlock:^(NSArray *timers, NSError *error) {

        [projectQuery findObjectsInBackgroundWithBlock:^(NSArray *projects, NSError *error) {

            [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {

                [cannedMessageQuery findObjectsInBackgroundWithBlock:^(NSArray *cannedMessages, NSError *error) {

                    if (timers.count + projects.count + groups.count + cannedMessages.count == 0) {
                        if (successBlock != nil) {
                            successBlock();
                        }
                        return;
                    }

                    __block NSError *firstError = nil;

                    dispatch_group_t group = dispatch_group_create();
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

                    for (TCSParseCannedMessage *cannedMessage in cannedMessages) {
                        dispatch_group_async(group, queue, ^{

                            NSError *error = nil;
                            [cannedMessage delete:&error];

                            if (error != nil && error.code != kPFErrorObjectNotFound && firstError == nil) {
                                firstError = error;
                            }
                        });
                    }

                    for (TCSParseTimer *timer in timers) {
                        dispatch_group_async(group, queue, ^{

                            NSError *error = nil;
                            [timer delete:&error];

                            if (error != nil && error.code != kPFErrorObjectNotFound && firstError == nil) {
                                firstError = error;
                            }
                        });
                    }

                    for (TCSParseProject *project in projects) {
                        dispatch_group_async(group, queue, ^{

                            NSError *error = nil;
                            [project delete:&error];

                            if (error != nil && error.code != kPFErrorObjectNotFound && firstError == nil) {
                                firstError = error;
                            }
                        });
                    }

                    for (TCSParseGroup *parseGroup in groups) {
                        dispatch_group_async(group, queue, ^{

                            NSError *error = nil;
                            [parseGroup delete:&error];

                            if (error != nil && error.code != kPFErrorObjectNotFound && firstError == nil) {
                                firstError = error;
                            }
                        });
                    }
                    
                    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                    
                    if (firstError != nil) {
                        if (failureBlock != nil) {
                            failureBlock(firstError);
                        }
                    } else {
                        if (successBlock != nil) {
                            successBlock();
                        }
                    }
                }];
            }];
        }];
    }];
}

#pragma mark - User Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] != nil) {
        if (successBlock != nil) {
            successBlock();
        }
        return;
    }

    [PFUser
     logInWithUsernameInBackground:username
     password:password
     block:^(PFUser *user, NSError *error) {

         if (error != nil) {
             if (failureBlock != nil) {
                 failureBlock(error);
             }
         } else {
             if (successBlock != nil) {
                 successBlock();
             }
         }
     }];
}

- (void)logoutUser:(void(^)(void))successBlock
           failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) {
        if (successBlock != nil) {
            successBlock();
        }
        return;
    }

    [PFUser logOut];

    if (successBlock != nil) {
        successBlock();
    }
}

- (BOOL)isUserAuthenticated:(TCSProviderInstance *)providerInstances {
    return [PFUser currentUser] != nil;
}

- (NSDictionary *)flushUpdates:(BOOL *)requestSent
                         error:(NSError **)error {

    // method needs to be synchronous because it's designed to be run in the background


    NSDictionary *remoteIDMap = nil;

    if (_connected == NO || [PFUser currentUser] == nil) {
        if (requestSent != NULL) {
            *requestSent = NO;
        }
        return nil;
    }

    @synchronized (self) {

        if (_bufferedUpdates.count > 0) {

            NSMutableArray *updates = [NSMutableArray array];

            NSArray *objectIDs = _bufferedUpdates.allKeys;

            for (NSManagedObjectID *objectID in objectIDs) {
                [updates addObject:_bufferedUpdates[objectID]];
            }

            if (updates.count > 0) {

                [PFObject saveAll:updates error:error];

                if (*error == nil) {

                    NSMutableDictionary * result =
                    [NSMutableDictionary dictionary];

                    NSInteger idx = 0;
                    for (NSManagedObjectID *objectID in objectIDs) {
                        TCSParseBaseEntity *entity = updates[idx++];
                        result[objectID] = entity.objectId;
                    };

                    remoteIDMap = result;

                    [self sendPushNotification];
                }
            }
        }

        [_bufferedUpdates removeAllObjects];
    }
    self.holdingUpdates = NO;

    if (requestSent != NULL) {
        *requestSent = YES;
    }
    return remoteIDMap;
}

- (void)bufferParseObject:(TCSBaseEntity *)entity
                 objectID:(NSManagedObjectID *)objectID {

    @synchronized (self) {
        _bufferedUpdates[objectID] = entity;
    }
}

- (void)sendPushNotification {

#if TARGET_OS_IPHONE
    if ([PFUser currentUser] == nil || [PFInstallation currentInstallation].deviceToken == nil) return;

    PFQuery *pushQuery = [PFInstallation query];
//    [pushQuery
//     whereKey:@"user"
//     equalTo:[PFUser currentUser]];
    [pushQuery
     whereKey:@"deviceToken"
     notEqualTo:[PFInstallation currentInstallation].deviceToken];

    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:
     @{
     kTCSServicRemoteProviderNameKey : NSStringFromClass([self class]),
     }];
    
    [push sendPushInBackground];
#endif
}

#pragma mark - Remote Command

- (void)updateRemoteCommandProperties:(TCSParseRemoteCommand *)parseRemoteCommand
                        remoteCommand:(TCSRemoteCommand *)remoteCommand {

    parseRemoteCommand.user = [PFUser currentUser];
    parseRemoteCommand.payload = [self safePropertyValue:remoteCommand.payload];
    parseRemoteCommand.type = remoteCommand.typeValue;
    parseRemoteCommand.instanceID = [NSString applicationInstanceId];
    parseRemoteCommand.entityVersion = remoteCommand.entityVersionValue;
    parseRemoteCommand.dataVersion = remoteCommand.dataVersionValue;
}

- (BOOL)createRemoteCommand:(TCSRemoteCommand *)remoteCommand
                    success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseRemoteCommand *parseRemoteCommand = [TCSParseRemoteCommand object];
    [self updateRemoteCommandProperties:parseRemoteCommand remoteCommand:remoteCommand];

    NSManagedObjectID *objectID = remoteCommand.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseRemoteCommand objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseRemoteCommand saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseRemoteCommand.objectId);
            }

            [self sendPushNotification];
        }
    }];
    
    return YES;
}

- (void)executedRemoteCommand:(TCSRemoteCommand *)remoteCommand
                      success:(void(^)(void))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
}

#pragma mark - Project

- (void)updateProjectProperties:(TCSParseProject *)parseProject
                        project:(TCSProject *)project {

    parseProject.name = [self safePropertyValue:project.name];
    parseProject.filteredModifiers = project.filteredModifiersValue;
    parseProject.keyCode = project.keyCodeValue;
    parseProject.modifiers = project.modifiersValue;
    parseProject.order = project.orderValue;
    parseProject.archived = project.archivedValue;
    parseProject.color = project.colorValue;
    parseProject.instanceID = [NSString applicationInstanceId];
    parseProject.entityVersion = project.entityVersionValue;
    parseProject.dataVersion = project.dataVersionValue;

    if (project.parent != nil) {
        NSAssert(project.parent.remoteId != nil, @"No remoteId for project parent");
        parseProject.parentID = project.parent.remoteId;
    } else {
        parseProject.parentID = (id)[NSNull null];
    }
}

- (BOOL)createProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.user = [PFUser currentUser];
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseProject objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseProject.objectId);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)updateProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (project.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for project update")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.objectId = project.remoteId;
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseProject objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)deleteProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (project.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for project delete")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.objectId = project.remoteId;

    NSManagedObjectID *objectID = project.objectID;

    if (_connected == NO) {
        return NO;
    }

    [parseProject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(TCSParseServiceWrapObjectNotFoundError(error));
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }
        }
    }];

    return YES;
}

#pragma mark - Group

- (void)updateGroupProperties:(TCSParseGroup *)parseGroup
                      group:(TCSGroup *)group {
    parseGroup.name = [self safePropertyValue:group.name];
    parseGroup.filteredModifiers = group.filteredModifiersValue;
    parseGroup.keyCode = group.keyCodeValue;
    parseGroup.modifiers = group.modifiersValue;
    parseGroup.order = group.orderValue;
    parseGroup.archived = group.archivedValue;
    parseGroup.color = group.colorValue;
    parseGroup.instanceID = [NSString applicationInstanceId];
    parseGroup.entityVersion = group.entityVersionValue;
    parseGroup.dataVersion = group.dataVersionValue;

    if (group.parent != nil) {
        NSAssert(group.parent.remoteId != nil, @"No remoteId for group parent");
        parseGroup.parentID = group.parent.remoteId;
    } else {
        parseGroup.parentID = (id)[NSNull null];
    }
}

- (BOOL)createGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    parseGroup.user = [PFUser currentUser];
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseGroup objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseGroup.objectId);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)updateGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (group.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for group update")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    parseGroup.objectId = group.remoteId;
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseGroup objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)deleteGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (group.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for group delete")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    parseGroup.objectId = group.remoteId;

    NSManagedObjectID *objectID = group.objectID;

    if (_connected == NO) {
        return NO;
    }

    [parseGroup deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(TCSParseServiceWrapObjectNotFoundError(error));
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }
        }
    }];

    return YES;
}

#pragma mark - Timer

- (void)updateTimerProperties:(TCSParseTimer *)parseTimer
                        timer:(TCSTimer *)timer {

    parseTimer.startTime = [self safePropertyValue:timer.startTime];
    parseTimer.endTime = [self safePropertyValue:timer.endTime];
    parseTimer.adjustment = timer.adjustmentValue;
    parseTimer.message = [self safePropertyValue:timer.message];
    parseTimer.instanceID = [NSString applicationInstanceId];
    parseTimer.entityVersion = timer.entityVersionValue;
    parseTimer.dataVersion = timer.dataVersionValue;

    NSAssert(timer.project.remoteId != nil, @"No remoteId for timer project");
    parseTimer.projectID = timer.project.remoteId;
}

- (BOOL)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    parseTimer.user = [PFUser currentUser];
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseTimer objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseTimer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseTimer.objectId);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (timer.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for timer update")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    parseTimer.objectId = timer.remoteId;
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseTimer objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseTimer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)deleteTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (timer.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for timer delete")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    parseTimer.objectId = timer.remoteId;

    NSManagedObjectID *objectID = timer.objectID;

    if (_connected == NO) {
        return NO;
    }

    [parseTimer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(TCSParseServiceWrapObjectNotFoundError(error));
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }
        }
    }];

    return YES;
}

#pragma mark - Canned Message

- (void)updateCannedMessageProperties:(TCSParseCannedMessage *)parseCannedMessage
                        cannedMessage:(TCSCannedMessage *)cannedMessage {
    parseCannedMessage.message = [self safePropertyValue:cannedMessage.message];
    parseCannedMessage.order = cannedMessage.orderValue;
    parseCannedMessage.instanceID = [NSString applicationInstanceId];
    parseCannedMessage.entityVersion = cannedMessage.entityVersionValue;
    parseCannedMessage.dataVersion = cannedMessage.dataVersionValue;
}

- (BOOL)createCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    parseCannedMessage.user = [PFUser currentUser];
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseCannedMessage objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseCannedMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseCannedMessage.objectId);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (cannedMessage.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for cannedMessage update")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    parseCannedMessage.objectId = cannedMessage.remoteId;
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseCannedMessage objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseCannedMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (cannedMessage.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for cannedMessage delete")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    parseCannedMessage.objectId = cannedMessage.remoteId;

    NSManagedObjectID *objectID = cannedMessage.objectID;

    if (_connected == NO) {
        return NO;
    }

    [parseCannedMessage deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(TCSParseServiceWrapObjectNotFoundError(error));
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

#pragma mark - Remote Provider

- (void)updateProviderInstanceProperties:(TCSParseProviderInstance *)parseProviderInstance
                        providerInstance:(TCSProviderInstance *)providerInstance {
    parseProviderInstance.baseURL = [self safePropertyValue:providerInstance.baseURL];
    parseProviderInstance.name = [self safePropertyValue:providerInstance.name];
    parseProviderInstance.password = [self safePropertyValue:providerInstance.password];
    parseProviderInstance.remoteProvider = [self safePropertyValue:providerInstance.remoteProvider];
    parseProviderInstance.username = [self safePropertyValue:providerInstance.username];
    parseProviderInstance.userID = [self safePropertyValue:providerInstance.userID];
    parseProviderInstance.entityVersion = providerInstance.entityVersionValue;
    parseProviderInstance.dataVersion = providerInstance.dataVersionValue;
}

- (BOOL)createProviderInstance:(TCSProviderInstance *)providerInstance
                     success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    TCSParseProviderInstance *parseProviderInstance = [TCSParseProviderInstance object];
    parseProviderInstance.user = [PFUser currentUser];
    [self
     updateProviderInstanceProperties:parseProviderInstance
     providerInstance:providerInstance];

    NSManagedObjectID *objectID = providerInstance.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseProviderInstance objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseProviderInstance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID, parseProviderInstance.objectId);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)updateProviderInstance:(TCSProviderInstance *)providerInstance
                       success:(void(^)(NSManagedObjectID *objectID))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (providerInstance.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for providerInstance update")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseProviderInstance *parseProviderInstance = [TCSParseProviderInstance object];
    parseProviderInstance.objectId = providerInstance.remoteId;
    [self
     updateProviderInstanceProperties:parseProviderInstance
     providerInstance:providerInstance];

    NSManagedObjectID *objectID = providerInstance.objectID;

    if (self.isHoldingUpdates) {
        [self bufferParseObject:(id)parseProviderInstance objectID:objectID];
        return NO;
    }

    if (_connected == NO) {
        return NO;
    }

    [parseProviderInstance saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock(objectID);
            }

            [self sendPushNotification];
        }
    }];

    return YES;
}

- (BOOL)deleteProviderInstance:(TCSProviderInstance *)providerInstance
                       success:(void(^)(NSManagedObjectID *objectID))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    if ([PFUser currentUser] == nil) return NO;

    if (providerInstance.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for providerInstance delete")];

            failureBlock(error);
        }
        return NO;
    }

    TCSParseProviderInstance *parseProviderInstance = [TCSParseProviderInstance object];
    parseProviderInstance.objectId = providerInstance.remoteId;

    NSManagedObjectID *objectID = providerInstance.objectID;

    if (_connected == NO) {
        return NO;
    }

    [parseProviderInstance deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(TCSParseServiceWrapObjectNotFoundError(error));
            }
            
        } else {
            
            if (successBlock != nil) {
                successBlock(objectID);
            }
            
            [self sendPushNotification];
        }
    }];
    
    return YES;
}

#pragma mark - Update Polling

- (void)updateSystemTime {

    [_systemTimeTimer invalidate];
    self.systemTimeTimer = nil;

    NSLog(@"%s", __PRETTY_FUNCTION__);

    __block NSTimeInterval retryTime = 5.0f;
    
    if (_connected) {

        static NSString *baseRestURL = @"https://api.parse.com/1/";
        static NSString *parseAppID = @"jF4VaTdB8FrBuFp52WFr9DzU70X9PPBeB9anwRga";
        static NSString *parseRestApiKey = @"7JJUKmtlW0NQRoO3D5dDJU3teIxZ1NwGaxzhTBMd";

//        curl -v -X HEAD   -H "X-Parse-Application-Id: jF4VaTdB8FrBuFp52WFr9DzU70X9PPBeB9anwRga"   -H "X-Parse-REST-API-Key: 7JJUKmtlW0NQRoO3D5dDJU3teIxZ1NwGaxzhTBMd"   https://api.parse.com/1/classes/TCParseProject

        AFHTTPClient *httpClient =
        [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseRestURL]];

        [httpClient setDefaultHeader:@"X-Parse-Application-Id" value:parseAppID];
        [httpClient setDefaultHeader:@"X-Parse-REST-API-Key" value:parseRestApiKey];

        NSMutableURLRequest *request =
        [httpClient
         requestWithMethod:@"GET"
         path:@"classes/TCParseProject"
         parameters:nil];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

            NSHTTPURLResponse *response = operation.response;

            if (response.statusCode == 200) {
                NSLog(@"Date: %@", response.allHeaderFields[@"Date"]);

                // Wed, 05 Jun 2013 10:37:46 GMT

                static NSDateFormatter *dateFormatter = nil;

                if (dateFormatter == nil) {
                    dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
                }

                NSString *systemTimeValue = response.allHeaderFields[@"Date"];

                NSDate *systemTime =
                [dateFormatter dateFromString:systemTimeValue];

                if (systemTime != nil) {

                    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
                    _localTimeLastSystemTimeReceived = now;
                    _systemTime = systemTime;
                    retryTime = 3600.0f;

                    NSLog(@"Setting system time: %@", _systemTime);

                } else {

                    NSLog(@"%s WARN : system date not parsed from: %@", __PRETTY_FUNCTION__, systemTimeValue);

                    if (_systemTime == nil) {
                        retryTime = 10.0f;
                    } else {
                        retryTime = 30.0f;
                    }
                }

            } else {

                if (_systemTime == nil) {
                    retryTime = 10.0f;
                } else {
                    retryTime = 30.0f;
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.systemTimeTimer =
                [NSTimer
                 scheduledTimerWithTimeInterval:retryTime
                 target:self
                 selector:@selector(updateSystemTime)
                 userInfo:nil
                 repeats:NO];
            });

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);

            dispatch_async(dispatch_get_main_queue(), ^{
                self.systemTimeTimer =
                [NSTimer
                 scheduledTimerWithTimeInterval:retryTime
                 target:self
                 selector:@selector(updateSystemTime)
                 userInfo:nil
                 repeats:NO];
            });
        }];

        [operation start];
        
    } else {

        dispatch_async(dispatch_get_main_queue(), ^{
            self.systemTimeTimer =
            [NSTimer
             scheduledTimerWithTimeInterval:.1f
             target:self
             selector:@selector(updateSystemTime)
             userInfo:nil
             repeats:NO];
        });
    }
}

- (void)pollForUpdates:(TCSProviderInstance *)providerInstance
               success:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock {

//    NSLog(@"lastPollingDate: %@", _lastPollingDate);

    if (_pollingForUpdates) return;
    
    if ([PFUser currentUser] != nil) {

        _pollingForUpdates = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

            __block NSArray *remoteCommands = nil;
            __block NSArray *groups = nil;
            __block NSArray *projects = nil;
            __block NSArray *timers = nil;
            __block NSArray *cannedMessages = nil;

            dispatch_group_async(group, queue, ^{
                remoteCommands = [self fetchUpdatedObjectsOfType:[TCSParseRemoteCommand class]];
            });

            dispatch_group_async(group, queue, ^{
                groups = [self fetchUpdatedObjectsOfType:[TCSParseGroup class]];
            });

            dispatch_group_async(group, queue, ^{
                projects = [self fetchUpdatedObjectsOfType:[TCSParseProject class]];
            });

            dispatch_group_async(group, queue, ^{
                timers = [self fetchUpdatedObjectsOfType:[TCSParseTimer class]];
            });

            dispatch_group_async(group, queue, ^{
                cannedMessages = [self fetchUpdatedObjectsOfType:[TCSParseCannedMessage class]];
            });

            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

            NSMutableArray *updatedEntities = [NSMutableArray array];

            [updatedEntities addObjectsFromArray:remoteCommands];
            [updatedEntities addObjectsFromArray:groups];
            [updatedEntities addObjectsFromArray:projects];
            [updatedEntities addObjectsFromArray:timers];
            [updatedEntities addObjectsFromArray:cannedMessages];

            if (updatedEntities.count > 0) {

                BOOL updatePollingDate =
                [self.pollingDelegate
                 remoteProvider:self
                 updatePollingEntities:updatedEntities
                 providerName:NSStringFromClass([self class])];

                if (updatePollingDate) {
                    for (TCSParseBaseEntity *entity in updatedEntities) {
                        if (_lastPollingDate == nil || [entity.utsUpdateTime isGreaterThan:_lastPollingDate]) {
                            self.lastPollingDate =
                            entity.utsUpdateTime;
                        }
                    }

                    if (_lastPollingDate != nil) {
                        [[NSUserDefaults standardUserDefaults]
                         setObject:_lastPollingDate forKey:kTCSParseLastPollingDateKey];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }

                    if (successBlock != nil) {
                        successBlock();
                    }

                } else {

                    NSTimeInterval delayInSeconds = 5.0f;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self pollForUpdates:providerInstance success:successBlock failure:^(NSError *error) {

                            if (error != nil) {
                                NSLog(@"%s Error : %@", __PRETTY_FUNCTION__, error);
                            }
                        }];
                    });
                }
            }

            _pollingForUpdates = NO;
        });
    }
}

- (NSArray *)fetchUpdatedObjectsOfType:(Class)objectType {
    
    PFQuery *query = [objectType query];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    [query whereKey:@"instanceID" notEqualTo:[NSString applicationInstanceId]];
    query.cachePolicy = kPFCachePolicyNetworkOnly;

    if (_lastPollingDate != nil) {
        [query whereKey:@"updatedAt" greaterThan:_lastPollingDate];
    }

    NSError *error = nil;
    NSArray *results = [query findObjects:&error];

    if (error != nil) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }

    return results;
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static TCSParseService *sharedInstance_ = nil;

+ (id)sharedInstance {

    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSParseService alloc];
        sharedInstance_ = [sharedInstance_ init];
    });

    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
