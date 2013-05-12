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

@interface TCSParseService()

@property (nonatomic, strong) GCNetworkReachability *reachability;
@property (nonatomic, getter = isConnected) BOOL connected;

@end

@implementation TCSParseService

- (id)init {
    self = [super init];
    if (self) {

        [TCSParseGroup registerSubclass];
        [TCSParseProject registerSubclass];
        [TCSParseTimer registerSubclass];
        [Parse
         setApplicationId:@"jF4VaTdB8FrBuFp52WFr9DzU70X9PPBeB9anwRga"
         clientKey:@"4nNUdTExe0QhkOzNO1WYbplDAgYIjoCxinNmHlTO"];

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

// Project

- (void)updateProjectProperties:(TCSParseProject *)parseProject
                        project:(TCSProject *)project {

    parseProject.name = project.name;
    parseProject.filteredModifiers = project.filteredModifiersValue;
    parseProject.keyCode = project.keyCodeValue;
    parseProject.modifiers = project.modifiersValue;
    parseProject.color = project.colorValue;
    parseProject.archived = project.archivedValue;
    parseProject.order = project.orderValue;
}

- (void)createProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseProject *parseProject = [TCSParseProject object];
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

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
}

- (void)updateProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (project.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for project update")];

            failureBlock(error);
        }
        return;
    }

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.objectId = project.remoteId;
    [self updateProjectProperties:parseProject project:project];

    NSManagedObjectID *objectID = project.objectID;

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
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (project.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for project delete")];

            failureBlock(error);
        }
        return;
    }

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.objectId = project.remoteId;
    parseProject.softDeleted = YES;
    [self updateProjectProperties:parseProject project:project];

    [parseProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

// Group

- (void)updateGroupProperties:(TCSParseGroup *)parseGroup
                      group:(TCSGroup *)group {
    parseGroup.name = group.name;
    parseGroup.color = group.colorValue;
    parseGroup.archived = group.archivedValue;
}

- (void)createGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

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
}

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (group.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for group update")];

            failureBlock(error);
        }
        return;
    }

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    parseGroup.objectId = group.remoteId;
    [self updateGroupProperties:parseGroup group:group];

    NSManagedObjectID *objectID = group.objectID;

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
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (group.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for group delete")];

            failureBlock(error);
        }
        return;
    }

    TCSParseGroup *parseGroup = [TCSParseGroup object];
    parseGroup.objectId = group.remoteId;
    parseGroup.softDeleted = YES;
    [self updateGroupProperties:parseGroup group:group];

    [parseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

// Timer

- (void)updateTimerProperties:(TCSParseTimer *)parseTimer
                        timer:(TCSTimer *)timer {
    parseTimer.startTime = timer.startTime;
    parseTimer.endTime = timer.endTime;
    parseTimer.adjustment = timer.adjustmentValue;
    parseTimer.message = timer.message;
}

- (void)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

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
}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (timer.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for timer update")];

            failureBlock(error);
        }
        return;
    }

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    parseTimer.objectId = timer.remoteId;
    [self updateTimerProperties:parseTimer timer:timer];

    NSManagedObjectID *objectID = timer.objectID;

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
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (timer.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for timer delete")];

            failureBlock(error);
        }
        return;
    }

    TCSParseTimer *parseTimer = [TCSParseTimer object];
    parseTimer.objectId = timer.remoteId;
    parseTimer.softDeleted = YES;
    [self updateTimerProperties:parseTimer timer:timer];

    [parseTimer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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

// Canned Message

- (void)updateCannedMessageProperties:(TCSParseCannedMessage *)parseCannedMessage
                        cannedMessage:(TCSCannedMessage *)cannedMessage {
    parseCannedMessage.message = cannedMessage.message;
    parseCannedMessage.order = cannedMessage.orderValue;
}

- (void)createCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

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
}

- (void)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (cannedMessage.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for cannedMessage update")];

            failureBlock(error);
        }
        return;
    }

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    parseCannedMessage.objectId = cannedMessage.remoteId;
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    NSManagedObjectID *objectID = cannedMessage.objectID;

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
}

- (void)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(void))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (cannedMessage.remoteId.length == 0) {

        if (failureBlock != nil) {

            NSError *error =
            [NSError errorWithCode:0 message:TCSLoc(@"No remote ID for cannedMessage delete")];

            failureBlock(error);
        }
        return;
    }

    TCSParseCannedMessage *parseCannedMessage = [TCSParseCannedMessage object];
    parseCannedMessage.objectId = cannedMessage.remoteId;
    parseCannedMessage.softDeleted = YES;
    [self updateCannedMessageProperties:parseCannedMessage cannedMessage:cannedMessage];

    [parseCannedMessage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
