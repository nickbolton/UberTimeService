//
//  TCSParseService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseService.h"
#import <Parse/Parse.h>
#import "TCSService.h"
#import "NSDate+Utilities.h"
#import "GCNetworkReachability.h"
#import "TCSParseTimedEntity.h"
#import "TCSParseGroup.h"
#import "TCSParseProject.h"
#import "TCSParseTimer.h"
#import "TCSParseCannedMessage.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@interface TCSParseService() {

    BOOL _holdUpdates;
}

@property (nonatomic, strong) GCNetworkReachability *reachability;
@property (nonatomic, getter = isConnected) BOOL connected;
@property (nonatomic, strong) NSMutableDictionary *bufferedUpdates;

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

    }
    return self;
}

- (NSString *)name {
    return NSLocalizedString(@"Parse", nil);
}

- (void)clearCache {

    if ([PFUser currentUser] != nil) {
        PFQuery *timerQuery = [TCSParseTimer query];
        [timerQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        PFQuery *projectQuery = [TCSParseProject query];
        [projectQuery whereKey:@"user" equalTo:[PFUser currentUser]];
        PFQuery *groupQuery = [TCSParseGroup query];
        [groupQuery whereKey:@"user" equalTo:[PFUser currentUser]];

        [timerQuery clearCachedResult];
        [projectQuery clearCachedResult];
        [groupQuery clearCachedResult];
    }
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

    [timerQuery findObjectsInBackgroundWithBlock:^(NSArray *timers, NSError *error) {

        [projectQuery findObjectsInBackgroundWithBlock:^(NSArray *projects, NSError *error) {

            [groupQuery findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {

                __block NSInteger asyncCount = timers.count + projects.count + groups.count;
                __block NSError *firstError = nil;

                if (asyncCount == 0) {
                    if (successBlock != nil) {
                        successBlock();
                    }
                    return;
                }

                void (^handleResposeBlock)(NSError *error) = ^(NSError *error) {
                    if (error != nil && error.code != kPFErrorObjectNotFound) {

                        @synchronized (self) {

                            if (firstError == nil) {
                                firstError = error;
                            }

                            asyncCount--;
                            if (asyncCount == 0) {
                                if (failureBlock != nil) {
                                    failureBlock(firstError);
                                }
                            }
                        }

                    } else {

                        @synchronized (self) {

                            asyncCount--;
                            if (asyncCount == 0) {
                                if (successBlock != nil) {
                                    successBlock();
                                }
                            }
                        }
                    }
                };

                for (TCSParseTimer *timer in timers) {
                    [timer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        handleResposeBlock(error);
                    }];
                }

                for (TCSParseProject *project in projects) {
                    [project deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        handleResposeBlock(error);
                    }];
                }

                for (TCSParseGroup *group in groups) {
                    [group deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        handleResposeBlock(error);
                    }];
                }
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

- (BOOL)isUserAuthenticated {
    return YES;
}

- (void)holdUpdates {
    _holdUpdates = YES;
}

- (BOOL)flushUpdates:(void(^)(NSDictionary *remoteIDMap))successBlock
             failure:(void(^)(NSError *error))failureBlock {

    if (_connected == NO) {
        return NO;
    }

    @synchronized (self) {

        if (_bufferedUpdates.count > 0) {

            NSMutableArray *updates = [NSMutableArray array];

            NSArray *objectIDs = _bufferedUpdates.allKeys;

            for (NSManagedObjectID *objectID in objectIDs) {
                [updates addObject:_bufferedUpdates[objectID]];
            }

            if (updates.count > 0) {

                [PFObject
                 saveAllInBackground:updates
                 block:^(BOOL succeeded, NSError *error) {

                     if (error != nil) {

                         if (failureBlock != nil) {
                             failureBlock(error);
                         }

                     } else {

                         if (successBlock != nil) {

                             NSMutableDictionary *result =
                             [NSMutableDictionary dictionary];

                             [objectIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                 TCSParseBaseEntity *entity = updates[idx];
                                 result[obj] = entity.objectId;
                             }];

                             successBlock(result);
                         }
                     }
                 }];
            }
        }

        [_bufferedUpdates removeAllObjects];
    }
    _holdUpdates = NO;

    return YES;
}

- (void)bufferParseObject:(TCSBaseEntity *)entity
                 objectID:(NSManagedObjectID *)objectID {

    @synchronized (self) {
        _bufferedUpdates[objectID] = entity;
    }
}

// Project

- (void)updateProjectProperties:(TCSParseProject *)parseProject
                        project:(TCSProject *)project {

    parseProject.name = [self safePropertyValue:project.name];
    parseProject.filteredModifiers = project.filteredModifiersValue;
    parseProject.keyCode = project.keyCodeValue;
    parseProject.modifiers = project.modifiersValue;
    parseProject.color = project.colorValue;
    parseProject.archived = project.archivedValue;
    parseProject.order = project.orderValue;
    parseProject.entityVersion = project.entityVersionValue;

    if (project.parent != nil) {
        NSAssert(project.parent.remoteId != nil, @"No remoteId for project parent");
        parseProject.parentID = project.parent.remoteId;
    } else {
        parseProject.parentID = [NSNull null];
    }
}

- (BOOL)createProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseProject *parseProject = [TCSParseProject object];
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseProject objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)updateProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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

    if (_holdUpdates) {
        [self bufferParseObject:parseProject objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)deleteProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    parseProject.softDeleted = YES;
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseProject objectID:objectID];
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
        }
    }];

    return YES;
}

// Group

- (void)updateGroupProperties:(TCSParseGroup *)parseGroup
                      group:(TCSGroup *)group {
    parseGroup.name = [self safePropertyValue:group.name];
    parseGroup.color = group.colorValue;
    parseGroup.archived = group.archivedValue;
    parseGroup.entityVersion = group.entityVersionValue;

    if (group.parent != nil) {
        NSAssert(group.parent.remoteId != nil, @"No remoteId for group parent");
        parseGroup.parentID = group.parent.remoteId;
    } else {
        parseGroup.parentID = [NSNull null];
    }
}

- (BOOL)createGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseGroup objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)updateGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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

    if (_holdUpdates) {
        [self bufferParseObject:parseGroup objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)deleteGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    parseGroup.softDeleted = YES;
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseGroup objectID:objectID];
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
        }
    }];

    return YES;
}

// Timer

- (void)updateTimerProperties:(TCSParseTimer *)parseTimer
                        timer:(TCSTimer *)timer {
    parseTimer.startTime = [self safePropertyValue:timer.startTime];
    parseTimer.endTime = [self safePropertyValue:timer.endTime];
    parseTimer.adjustment = timer.adjustmentValue;
    parseTimer.message = [self safePropertyValue:timer.message];
    parseTimer.entityVersion = timer.entityVersionValue;

    NSAssert(timer.project.remoteId != nil, @"No remoteId for timer project");
    parseTimer.projectID = timer.project.remoteId;
}

- (BOOL)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseTimer objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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

    if (_holdUpdates) {
        [self bufferParseObject:parseTimer objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)deleteTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    parseTimer.softDeleted = YES;
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseTimer objectID:objectID];
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
        }
    }];

    return YES;
}

// Canned Message

- (void)updateCannedMessageProperties:(TCSParseCannedMessage *)parseCannedMessage
                        cannedMessage:(TCSCannedMessage *)cannedMessage {
    parseCannedMessage.message = [self safePropertyValue:cannedMessage.message];
    parseCannedMessage.order = cannedMessage.orderValue;
    parseCannedMessage.entityVersion = cannedMessage.entityVersionValue;
}

- (BOOL)createCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseCannedMessage objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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

    if (_holdUpdates) {
        [self bufferParseObject:parseCannedMessage objectID:objectID];
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
        }
    }];

    return YES;
}

- (BOOL)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

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
    parseCannedMessage.softDeleted = YES;
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

    if (_holdUpdates) {
        [self bufferParseObject:parseCannedMessage objectID:objectID];
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
        }
    }];

    return YES;
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
