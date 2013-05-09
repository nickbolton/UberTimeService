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

@protocol TCSServiceRemoteProvider;

// import depends on protocol being defined already
#import "TCSDefaultProvider.h"
#import "TCSLocalService.h"

@interface TCSService : NSObject

+ (TCSService *)sharedInstance;

@property (nonatomic, readonly) TCSTimer *activeTimer;
@property (nonatomic, readonly) NSManagedObjectContext *defaultLocalManagedObjectContext;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Projects

- (NSArray *)registeredRemoteProviders;
- (void)registerRemoteServiceProvider:(Class)providerClass;
- (NSObject <TCSServiceRemoteProvider> *)serviceProviderOfType:(Class)providerClass;

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

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (NSArray *)allProjects;

- (TCSProject *)projectWithID:(NSManagedObjectID *)objectID;

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder;

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder;

#pragma mark - Groups

- (NSArray *)allGroups;

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group, TCSProject *updatedSourceProject, TCSProject *updatedTargetProject))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(TCSProject *updatedSourceProject, TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Timers

- (NSArray *)allTimers;
- (NSArray *)allTimersSortedByStartTime:(BOOL)sortedByStartTime;
- (TCSTimer *)oldestTimer;

- (TCSTimer *)timerWithID:(NSManagedObjectID *)objectID;

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(TCSTimer *updatedTimer))successBlock
          failure:(void(^)(NSError *error))failureBlock;


- (void)createTimerForProject:(TCSProject *)project
                    startTime:(NSDate *)startTime
                     duration:(NSTimeInterval)duration
                     success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
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

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimers:(NSArray *)timers
             success:(void(^)(void))successBlock
             failure:(void(^)(NSError *error))failureBlock;

- (NSArray *)timersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime;

@end
