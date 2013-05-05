//
//  TCSService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "TCSService.h"
#import "NSDate+Utilities.h"
#import "TCSServicePrivate.h"

NSString * const kTCSServiceDataResetNotification = @"kTCSServiceDataResetNotification";

@interface TCSService()

@property (nonatomic, strong) NSMutableDictionary *serviceProviders;
@property (nonatomic, readwrite) TCSTimer *activeTimer;

@end

@implementation TCSService

- (id)init
{
    self = [super init];
    if (self) {
        self.serviceProviders = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray *)registeredServiceProviders {

    static NSArray *sortDescriptors = nil;

    if (sortDescriptors == nil) {
        sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    }

    return
    [_serviceProviders.allValues sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)registerServiceProvider:(Class)projectServiceClass {

    id <TCSServiceProvider> serviceProvider =
    (id <TCSServiceProvider>)[projectServiceClass sharedInstance];

    NSAssert([serviceProvider conformsToProtocol:@protocol(TCSServiceProvider)],
             @"Class must conform to TCSServiceProvider protocol");

    NSAssert([serviceProvider conformsToProtocol:@protocol(TCSServiceProviderPrivate)],
             @"Class must conform to TCSServiceProviderPrivate protocol");

    _serviceProviders[NSStringFromClass(projectServiceClass)] = serviceProvider;
}

- (id <TCSServiceProvider>)serviceProviderOfType:(Class)projectServiceClass {
    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");
    return _serviceProviders[NSStringFromClass(projectServiceClass)];
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    __block NSInteger asyncCount = _serviceProviders.count;
    __block BOOL sentFailure = NO;    

    for (id <TCSServiceProvider> serviceProvider in _serviceProviders.allValues) {
        [(id <TCSServiceProviderPrivate>)serviceProvider
          deleteAllData:^{

              @synchronized (self) {

                  asyncCount--;
                  if (asyncCount == 0) {

                      [self clearCaches];

                      if (successBlock != nil) {
                          successBlock();
                      }

                      [[NSNotificationCenter defaultCenter]
                       postNotificationName:kTCSServiceDataResetNotification
                       object:self
                       userInfo:nil];
                  }
              }

          } failure:^(NSError *error) {

              if (sentFailure == NO) {
                  sentFailure = YES;
                  if (failureBlock != nil) {
                      failureBlock(error);
                  }
              }
          }];
    }
}

- (void)clearCaches {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    for (id <TCSServiceProvider> serviceProvider in _serviceProviders.allValues) {
        [serviceProvider clearCache];
    }
}

#pragma mark - Project Methods

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)project.serviceProvider
     updateProject:project
     success:successBlock
     failure:failureBlock];
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)project.serviceProvider
     deleteProject:project
     success:successBlock
     failure:failureBlock];
}

- (void)fetchProjectsSortedByName:(NSArray *)serviceProviders
                      ignoreOrder:(BOOL)ignoreOrder
                          success:(void(^)(NSArray *projects))successBlock
                          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    if (successBlock != nil) {

        NSComparator nameComparator = ^NSComparisonResult(id obj1, id obj2) {
            TCSTimedEntity *timedEntity1 = obj1;
            TCSTimedEntity *timedEntity2 = obj2;

            if ([obj1 isKindOfClass:[TCSProject class]] && [obj2 isKindOfClass:[TCSProject class]]) {
                TCSProject *p1 = obj1;
                TCSProject *p2 = obj2;

                if (ignoreOrder == NO) {
                    NSInteger order1 = p1.order;
                    NSInteger order2 = p2.order;

                    if (order1 >= 0 || order2 >= 0) {
                        if (order1 < 0) {
                            return NSOrderedDescending;
                        }
                        if (order2 < 0) {
                            return NSOrderedAscending;
                        }
                        if (order1 != order2) {
                            return [@(p1.order) compare:@(p2.order)];
                        }
                    }
                }
            }
            return [timedEntity1.name.lowercaseString compare:timedEntity2.name.lowercaseString];
        };

        NSMutableArray *projects = [NSMutableArray array];

        __block NSInteger asyncCount = serviceProviders.count;
        __block BOOL sentError = NO;

        for (NSString *serviceProviderName in serviceProviders) {

            id <TCSServiceProvider> serviceProvider =
            _serviceProviders[serviceProviderName];

            [serviceProvider fetchProjects:^(NSArray *result) {

                if (sentError == NO) {
                    @synchronized (self) {
                        [projects addObjectsFromArray:result];

                        asyncCount--;
                        if (asyncCount == 0) {
                            successBlock([projects sortedArrayUsingComparator:nameComparator]);
                        }
                    }
                }

            } failure:^(NSError *error) {

                if (sentError == NO) {
                    sentError = YES;

                    if (failureBlock != nil) {
                        failureBlock(error);
                    }
                }
            }];
        }
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchProjectsSortedByGroupAndName:(NSArray *)serviceProviders
                              ignoreOrder:(BOOL)ignoreOrder
                                  success:(void(^)(NSArray *projects))successBlock
                                  failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    if (successBlock != nil) {

        NSComparator nameComparator = ^NSComparisonResult(id obj1, id obj2) {
            TCSTimedEntity *timedEntity1 = obj1;
            TCSTimedEntity *timedEntity2 = obj2;
            TCSGroup *group1 = timedEntity1.parent;
            TCSGroup *group2 = timedEntity2.parent;

            if ([obj1 isKindOfClass:[TCSProject class]] && [obj2 isKindOfClass:[TCSProject class]]) {
                TCSProject *p1 = obj1;
                TCSProject *p2 = obj2;

                if (ignoreOrder == NO) {
                    NSInteger order1 = p1.order;
                    NSInteger order2 = p2.order;

                    if (order1 >= 0 || order2 >= 0) {
                        if (order1 < 0) {
                            return NSOrderedDescending;
                        }
                        if (order2 < 0) {
                            return NSOrderedAscending;
                        }
                        if (order1 != order2) {
                            return [@(p1.order) compare:@(p2.order)];
                        }
                    }
                }
            }

            if (group1 != nil && group2 != nil) {
                return [group1.name.lowercaseString compare:group2.name.lowercaseString];
            } else if (group1 != nil) {
                return NSOrderedDescending;
            } else if (group2 != nil) {
                return NSOrderedAscending;
            }
            
            return [timedEntity1.name.lowercaseString compare:timedEntity2.name.lowercaseString];
        };

        NSMutableArray *projects = [NSMutableArray array];

        __block NSInteger asyncCount = serviceProviders.count;
        __block BOOL sentError = NO;

        for (NSString *serviceProviderName in serviceProviders) {

            id <TCSServiceProvider> serviceProvider =
            _serviceProviders[serviceProviderName];

            [serviceProvider fetchProjects:^(NSArray *result) {

                if (sentError == NO) {
                    @synchronized (self) {
                        [projects addObjectsFromArray:result];

                        asyncCount--;
                        if (asyncCount == 0) {
                            successBlock([projects sortedArrayUsingComparator:nameComparator]);
                        }
                    }
                }

            } failure:^(NSError *error) {

                if (sentError == NO) {
                    sentError = YES;

                    if (failureBlock != nil) {
                        failureBlock(error);
                    }
                }
            }];
        }
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Group Methods

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)group.serviceProvider
     updateGroup:group
     success:successBlock
     failure:failureBlock];
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)group.serviceProvider
     deleteGroup:group
     success:successBlock
     failure:failureBlock];
}

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    if (sourceProject.serviceProvider == toProject.serviceProvider) {

        [(id <TCSServiceProviderPrivate>)sourceProject.serviceProvider
         moveProject:sourceProject
         toProject:toProject
         success:successBlock
         failure:failureBlock];

    } else {

#warning TODO : rollback??

        [(id <TCSServiceProviderPrivate>)toProject.serviceProvider
         moveProject:sourceProject
         toProject:toProject
         success:^(TCSGroup *group) {

             [self
              deleteProject:sourceProject
              success:^{

                  if (successBlock != nil) {
                      successBlock(group);
                  }

              } failure:failureBlock];
             
         } failure:failureBlock];
    }
}

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if ((sourceProject.serviceProvider == group.serviceProvider) ||
        (group == nil)) {

        [(id <TCSServiceProviderPrivate>)sourceProject.serviceProvider
         moveProject:sourceProject
         toGroup:group
         success:successBlock
         failure:failureBlock];

    } else {

#warning TODO : rollback??

        [(id <TCSServiceProviderPrivate>)group.serviceProvider
         moveProject:sourceProject
         toGroup:group
         success:^{

             [self
              deleteProject:sourceProject
              success:successBlock
              failure:failureBlock];

         } failure:failureBlock];
    }
}

#pragma mark - Timer Methods

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    void (^executionBlock)(void) = ^{

        [(id <TCSServiceProviderPrivate>)project.serviceProvider
         startTimerForProject:project
         success:^(TCSTimer *timer) {

             self.activeTimer = timer;

             if (successBlock != nil) {
                 successBlock(timer);
             }
             
         } failure:failureBlock];
    };

    if (_activeTimer != nil) {

        [self
         stopTimer:_activeTimer
         success:executionBlock
         failure:failureBlock];
    } else {
        executionBlock();
    }
}

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)timer.serviceProvider
     stopTimer:timer
     success:^{

         self.activeTimer = nil;

         if (successBlock != nil) {
             successBlock();
         }
         
     } failure:failureBlock];
}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)timer.serviceProvider
     updateTimer:timer
     success:successBlock
     failure:failureBlock];
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    [(id <TCSServiceProviderPrivate>)timer.serviceProvider
     deleteTimer:timer
     success:successBlock
     failure:failureBlock];
}

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    if ([timer.project isEqual:project]) {
        return;
    }

    if (timer.serviceProvider == project.serviceProvider) {

        [(id <TCSServiceProviderPrivate>)timer.serviceProvider
         moveTimer:timer
         toProject:project
         success:successBlock
         failure:failureBlock];

    } else {

#warning TODO : rollback??

        NSDate *startTime = timer.startTime;
        NSDate *endTime = timer.endTime;
        NSTimeInterval adjustment = timer.adjustment;
        NSString *message = timer.message;

        [(id <TCSServiceProviderPrivate>)timer.serviceProvider
         deleteTimer:timer
         success:^{

             [(id <TCSServiceProviderPrivate>)project.serviceProvider
              startTimerForProject:project
              success:^(TCSTimer *localTimer) {

                  localTimer.startTime = startTime;
                  localTimer.endTime = endTime;
                  localTimer.adjustment = adjustment;
                  localTimer.message = message;

                  [(id <TCSServiceProviderPrivate>)localTimer.serviceProvider
                   updateTimer:localTimer
                   success:^{

                       timer.providerEntity = localTimer.providerEntity;
                       timer.providerEntityID = localTimer.providerEntityID;

                       if (successBlock != nil) {
                           successBlock();
                       }
                       
                   } failure:failureBlock];
                  
              } failure:failureBlock];

         } failure:failureBlock];
    }
}

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    BOOL isActive = [self.activeTimer isEqual:timer];

    if (successBlock != nil && timer.adjustment == 0) {

        [(id <TCSServiceProviderPrivate>)timer.serviceProvider
         rollTimer:timer
         maxDuration:maxDuration
         success:^(NSArray *rolledTimers) {

             if (isActive) {
                 self.activeTimer = rolledTimers.lastObject;
             }

             if (successBlock != nil) {
                 successBlock(rolledTimers);
             }

         } failure:failureBlock];
    }
}

- (void)fetchTimersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    NSAssert(_serviceProviders.count > 0, @"No service providers regsistered.");

    if (successBlock != nil) {

        if (projects.count == 0) {
            if (successBlock != nil) {
                successBlock(nil);
            }
            return;
        }

        if (fromDate == nil) {
            fromDate = [NSDate distantPast];
        }

        if (toDate == nil) {
            toDate = [NSDate distantFuture];
        }

        NSDate *from = [fromDate midnight];
        NSDate *to = [toDate endOfDay];
        NSDate *now = [NSDate date];

        static NSArray *sortDescriptors = nil;

        if (sortDescriptors == nil) {
            sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]];
        }

        NSMutableArray *timers = [NSMutableArray array];

        NSMutableDictionary *serviceProviders = [NSMutableDictionary dictionary];

        id <TCSServiceProvider> serviceProvider = nil;

        for (TCSProject *project in projects) {

            serviceProvider = project.serviceProvider;
            
            NSMutableArray *serviceProviderProjects =
            serviceProviders[project.serviceProvider.name];

            if (serviceProviderProjects == nil) {
                serviceProviderProjects = [NSMutableArray array];
                serviceProviders[project.serviceProvider.name] = serviceProviderProjects;
            }

            [serviceProviderProjects addObject:project.providerEntity];
        }

        __block NSInteger asyncCount = serviceProviders.count;
        __block BOOL sentError = NO;

        for (NSArray *projects in serviceProviders.allValues) {

            [(id <TCSServiceProviderPrivate>)serviceProvider
             fetchTimersForProjects:projects
             fromDate:from
             toDate:to
             now:now
             success:^(NSArray *result) {

                 if (sentError == NO) {
                     @synchronized (self) {
                         [timers addObjectsFromArray:result];

                         asyncCount--;
                         if (asyncCount == 0) {

                             NSArray *result;

                             if (sortByStartTime) {

                                 result =
                                 [timers sortedArrayUsingDescriptors:sortDescriptors];
                             } else {
                                 result = timers;
                             }

                             successBlock(result);
                         }
                     }
                 }

             } failure:^(NSError *error) {

                 if (sentError == NO) {
                     sentError = YES;

                     if (failureBlock != nil) {
                         failureBlock(error);
                     }
                 }
             }];
        }
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static TCSService *sharedInstance_ = nil;

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSService alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
