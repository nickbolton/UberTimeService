//
//  TCSService.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "TCSProject.h"
#import "TCSGroup.h"
#import "TCSTimer.h"

extern NSString * const kTCSServiceDataResetNotification;

@protocol TCSServiceProvider <NSObject>

+ (id <TCSServiceProvider>)sharedInstance;

@property (nonatomic, readonly) NSString *name;

- (void)clearCache;

// Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock;

- (void)logoutUser:(void(^)(void))successBlock
           failure:(void(^)(NSError *error))failureBlock;

- (BOOL)isUserAuthenticated;

// Project

- (void)createProjectWithName:(NSString *)name
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock;

- (void)createProjectWithName:(NSString *)name
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock;

- (void)fetchProjectWithName:(NSString *)name
                     success:(void(^)(NSArray *projects))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)fetchProjectWithID:(id)entityID
                     success:(void(^)(TCSProject *project))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)fetchProjects:(void(^)(NSArray *projects))successBlock
              failure:(void(^)(NSError *error))failureBlock;

// Group

- (void)fetchGroupWithID:(id)entityID
                 success:(void(^)(TCSGroup *group))successBlock
                 failure:(void(^)(NSError *error))failureBlock;

- (void)fetchGroups:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock;

// Timer

- (void)fetchTimerWithID:(id)entityID
                 success:(void(^)(TCSTimer *timer))successBlock
                 failure:(void(^)(NSError *error))failureBlock;

- (void)fetchTimers:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock;

@end

// import depends on protocol being defined already
#import "TCSDefaultProvider.h"
#import "TCSLocalService.h"

@interface TCSService : NSObject

+ (TCSService *)sharedInstance;

@property (nonatomic, readonly) TCSTimer *activeTimer;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Projects

- (void)clearCaches;

- (NSArray *)registeredServiceProviders;
- (void)registerServiceProvider:(Class)projectServiceClass;
- (id <TCSServiceProvider>)serviceProviderOfType:(Class)serviceProviderType;

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)fetchProjectsSortedByName:(NSArray *)serviceProviders
                      ignoreOrder:(BOOL)ignoreOrder
                          success:(void(^)(NSArray *projects))successBlock
                          failure:(void(^)(NSError *error))failureBlock;

- (void)fetchProjectsSortedByGroupAndName:(NSArray *)serviceProviders
                              ignoreOrder:(BOOL)ignoreOrder
                                  success:(void(^)(NSArray *projects))successBlock
                                  failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Groups

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Timers

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)fetchTimersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock;

@end
