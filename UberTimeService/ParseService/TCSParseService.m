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
#warning TODO : add NSError
            failureBlock(nil);
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

#pragma mark - Project Methods

- (void)createProjectWithName:(NSString *)name
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
    [self
     createProjectWithName:name
     filteredModifiers:0
     keyCode:0
     modifiers:0
     success:successBlock
     failure:failureBlock];
}

- (TCSParseProject *)doCreateProjectWithName:(NSString *)name
                           filteredModifiers:(NSInteger)filteredModifiers
                                     keyCode:(NSInteger)keyCode
                                   modifiers:(NSInteger)modifiers {

    TCSParseProject *parseProject = [TCSParseProject object];
    parseProject.name = name;
    parseProject.filteredModifiers = filteredModifiers;
    parseProject.keyCode = keyCode;
    parseProject.modifiers = modifiers;

    return parseProject;
}

- (void)createProjectWithName:(NSString *)name
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    TCSParseProject *parseProject =
    [self
     doCreateProjectWithName:name
     filteredModifiers:filteredModifiers
     keyCode:keyCode
     modifiers:modifiers];

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSProject *project = (id)
                [self
                 wrapProviderEntity:parseProject
                 inType:[TCSProject class]
                 provider:self];

                successBlock(project);
            }
        }
    };

    if (_connected) {

        [parseProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseProject saveEventually:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];
    }
}

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    TCSParseProject *parseProject = project.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {
        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseProject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseProject saveEventually:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];
    }
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    TCSParseProject *parseProject = project.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil && error.code != kPFErrorObjectNotFound) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            project.providerEntity = nil;
            project.providerEntityID = nil;

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseProject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseProject deleteEventually];
        executionBlock(nil);
    }
}

- (void)fetchProjectWithName:(NSString *)name
                     success:(void(^)(NSArray *projects))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseProject query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        [query whereKey:@"name" equalTo:name];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            if (error != nil) {

                if (failureBlock != nil) {
                    failureBlock(error);
                }
                
            } else {

                NSArray *result =
                [self
                 wrapProviderEntities:objects
                 inType:[TCSProject class]
                 provider:self];

                successBlock(result);
            }
        }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchProjectWithID:(id)entityID
                   success:(void(^)(TCSProject *project))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseProject query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         getObjectInBackgroundWithId:entityID
         block:^(PFObject *project, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 TCSProject *result = (id)
                 [self
                  wrapProviderEntity:project
                  inType:[TCSProject class]
                  provider:self];

                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchProjects:(void(^)(NSArray *projects))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseProject query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 NSArray *result =
                 [self
                  wrapProviderEntities:objects
                  inType:[TCSProject class]
                  provider:self];

                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Group Methods

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    TCSParseGroup *parseGroup = group.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseGroup saveEventually:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];
    }
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    TCSParseGroup *parseGroup = group.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil && error.code != kPFErrorObjectNotFound) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            group.providerEntity = nil;
            group.providerEntityID = nil;

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseGroup deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseGroup deleteEventually];
        executionBlock(nil);
    }
}

- (void)fetchGroupWithID:(id)entityID
                 success:(void(^)(TCSGroup *group))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseGroup query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         getObjectInBackgroundWithId:entityID
         block:^(PFObject *object, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 TCSGroup *result = (id)
                 [self
                  wrapProviderEntity:object
                  inType:[TCSGroup class]
                  provider:self];
                 
                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchGroups:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseGroup query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 NSArray *result =
                 [self
                  wrapProviderEntities:objects
                  inType:[TCSGroup class]
                  provider:self];
                 
                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Timer Methods

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    TCSParseTimer *parseTimer = timer.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseTimer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {

        [parseTimer saveEventually:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];
    }
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    TCSParseTimer *parseTimer = timer.providerEntity;

    void (^executionBlock)(NSError *error) = ^(NSError *error) {

        if (error != nil && error.code != kPFErrorObjectNotFound) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {
            
            timer.providerEntity = nil;
            timer.providerEntityID = nil;

            if (successBlock != nil) {
                successBlock();
            }
        }
    };

    if (_connected) {

        [parseTimer deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            executionBlock(error);
        }];

    } else {
        [parseTimer deleteEventually];
        executionBlock(nil);
    }
}

- (void)fetchTimerWithID:(id)entityID
                 success:(void(^)(TCSTimer *timer))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseTimer query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         getObjectInBackgroundWithId:entityID
         block:^(PFObject *object, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 TCSTimer *result = (id)
                 [self
                  wrapProviderEntity:object
                  inType:[TCSTimer class]
                  provider:self];

                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchTimersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                           now:(NSDate *)now
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        if (projects.count == 0) {
            successBlock(nil);
            return;
        }

        NSMutableArray *projectList = [NSMutableArray array];
        NSMutableArray *groupList = [NSMutableArray array];

        for (id obj in projects) {
            if ([obj isKindOfClass:[TCSParseGroup class]]) {
                [groupList addObject:obj];
            } else {
                [projectList addObject:obj];
            }
        }

        for (TCSParseGroup *group in groupList) {
            for (TCSParseProject *project in group.children) {
                if ([projectList containsObject:project] == NO) {
                    [projectList addObject:project];
                }
            }
        }

        NSPredicate *predicate;

        if ([fromDate isLessThanOrEqualTo:now]) {

            predicate =
            [NSPredicate predicateWithFormat:
             @"(project in %@) and ((startTime <= %@ and endTime >= %@) or (endTime = null and startTime <= %@))",
             projectList, toDate, fromDate, now];

        } else {

            predicate =
            [NSPredicate predicateWithFormat:
             @"(project in %@) and (startTime <= %@ and endTime >= %@)",
             projectList, toDate, fromDate];
        }

        NSString *className =
        NSStringFromClass([TCSParseTimer class]);
        PFQuery *query =
        [PFQuery
         queryWithClassName:className
         predicate:predicate];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];

        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 NSArray *result =
                 [self
                  wrapProviderEntities:objects
                  inType:[TCSTimer class]
                  provider:self];

                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchTimers:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        if ([PFUser currentUser] == nil) {
            if (failureBlock != nil) {
#warning TODO : add NSError
                failureBlock(nil);
            }
            return;
        }

        PFQuery *query = [TCSParseTimer query];
        [query whereKey:@"user" equalTo:[PFUser currentUser]];
        query.cachePolicy = kPFCachePolicyNetworkOnly;

        [query
         findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

             if (error != nil) {

                 if (failureBlock != nil) {
                     failureBlock(error);
                 }

             } else {

                 NSArray *result =
                 [self
                  wrapProviderEntities:objects
                  inType:[TCSTimer class]
                  provider:self];

                 successBlock(result);
             }
         }];
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
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
