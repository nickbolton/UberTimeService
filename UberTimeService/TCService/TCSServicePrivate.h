//
//  TCSServicePrivate.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

@protocol TCSServiceProviderPrivate <NSObject>

@end

@protocol TCSServiceRemoteProvider <NSObject>

+ (id <TCSServiceRemoteProvider>)sharedInstance;

@property (nonatomic, readonly) NSString *name;

- (void)clearCache;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

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

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
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

- (void)createGroupWithName:(NSString *)name
                    success:(void(^)(TCSProject *project))successBlock
                    failure:(void(^)(NSError *error))failureBlock;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)fetchGroupWithID:(id)entityID
                 success:(void(^)(TCSGroup *group))successBlock
                 failure:(void(^)(NSError *error))failureBlock;

- (void)fetchGroups:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock;

// Timer

- (void)createTimer;

- (void)fetchTimerWithID:(id)entityID
                 success:(void(^)(TCSTimer *timer))successBlock
                 failure:(void(^)(NSError *error))failureBlock;

- (void)fetchTimers:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateEntities:(NSArray *)entities
               success:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock;

@end

@protocol TCSServiceLocalService <NSObject>

@property (nonatomic, strong) id <TCSServiceRemoteProvider> removeProvider;
@property (nonatomic, readonly) NSManagedObjectContext *defaultLocalManagedObjectContext;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)createProjectWithName:(NSString *)name
               remoteProvider:(NSString *)remoteProvider
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock;

- (void)createProjectWithName:(NSString *)name
               remoteProvider:(NSString *)remoteProvider
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock;

- (NSArray *)allProjects;

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder;

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder;

- (TCSProject *)projectWithID:(NSManagedObjectID *)objectID;

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group, TCSProject *updatedSourceProject, TCSProject *updatedTargetProject))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(TCSProject *updatedSourceProject, TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID;

- (NSArray *)allGroups;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimers:(NSArray *)timers
             success:(void(^)(void))successBlock
             failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateEntities:(NSArray *)entities
               success:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock;

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)createTimerForProject:(TCSProject *)project
                    startTime:(NSDate *)startTime
                     duration:(NSTimeInterval)duration
                      success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                      failure:(void(^)(NSError *error))failureBlock;

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(TCSTimer *updatedTimer))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(TCSTimer *updatedTimer, TCSProject *updatedProject))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)moveTimers:(NSArray *)timers
         toProject:(TCSProject *)project
           success:(void(^)(NSArray *updatedTimer, TCSProject *updatedProject))successBlock
           failure:(void(^)(NSError *error))failureBlock;

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (NSArray *)allTimers;
- (NSArray *)allTimersSortedByStartTime:(BOOL)sortedByStartTime;
- (TCSTimer *)oldestTimer;
- (TCSTimer *)activeTimer;
- (TCSTimer *)timerWithID:(NSManagedObjectID *)objectID;

- (NSArray *)timersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime;

@end