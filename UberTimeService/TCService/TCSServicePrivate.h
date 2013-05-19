//
//  TCSServicePrivate.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

extern NSString * const kTCSServicePrivateRemoteSyncCompletedNotification;

@protocol TCSProvidedBaseEntity <NSObject>
@property (nonatomic, readonly) NSString *utsRemoteID;
@property (nonatomic, readonly) NSInteger utsEntityVersion;
@property (nonatomic, readonly) Class utsLocalEntityType;
@property (nonatomic, readonly) NSDate *utsUpdateTime;
@end

@protocol TCSProvidedTimedEntity <TCSProvidedBaseEntity>
@property (nonatomic, readonly) BOOL utsArchived;
@property (nonatomic, readonly) NSString *utsName;
@property (nonatomic, readonly) NSInteger utsColor;
@property (nonatomic, readonly) NSString *utsParentID;
@end

@protocol TCSProvidedGroup <TCSProvidedTimedEntity>
@end

@protocol TCSProvidedProject <TCSProvidedTimedEntity>
@property (nonatomic, readonly) NSInteger utsFilteredModifiers;
@property (nonatomic, readonly) NSInteger utsKeyCode;
@property (nonatomic, readonly) NSInteger utsModifiers;
@property (nonatomic, readonly) NSInteger utsOrder;
@end

@protocol TCSProvidedTimer <TCSProvidedBaseEntity>
@property (nonatomic, readonly) NSDate *utsStartTime;
@property (nonatomic, readonly) NSDate *utsEndTime;
@property (nonatomic, readonly) NSString *utsMessage;
@property (nonatomic, readonly) NSTimeInterval utsAdjustment;
@property (nonatomic, readonly) NSString *utsProjectID;
@end

@protocol TCSProvidedCannedMessage <TCSProvidedBaseEntity>
@property (nonatomic, readonly) NSString *utsMessage;
@property (nonatomic, readonly) NSInteger utsOrder;
@end

@protocol TCSProvidedRemoteCommand <TCSProvidedBaseEntity>
@property (nonatomic, readonly) NSData *utsPayloadData;
@property (nonatomic, readonly) NSInteger utsType;
@end

@protocol TCSServiceDelegate;
@protocol TCSServiceLocalService <NSObject>

@property (nonatomic, readonly) NSManagedObjectContext *defaultLocalManagedObjectContext;
@property (nonatomic, weak) id <TCSServiceDelegate> delegate;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)sendRemoteMessage:(NSString *)message
             withProvider:(NSString *)remoteProvider
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError *error))failureBlock;

- (void)resetRemoteDataWithProvider:(NSString *)remoteProvider
                            success:(void(^)(void))successBlock
                            failure:(void(^)(NSError *error))failureBlock;

- (void)executedRemoteCommand:(TCSRemoteCommand *)remoteCommand
                      success:(void(^)(void))successBlock
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
              success:(void(^)(TCSProject *updatedProject))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID;

- (NSArray *)allGroups;

- (NSArray *)topLevelEntitiesSortedByName:(BOOL)sortedByName;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)resumeTimer:(TCSTimer *)timer
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimers:(NSArray *)timers
             success:(void(^)(void))successBlock
             failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)updateEntities:(NSArray *)entities
               success:(void(^)(NSArray *updatedEntities))successBlock
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

- (NSArray *)allCannedMessages;

- (TCSCannedMessage *)cannedMessageWithID:(NSManagedObjectID *)objectID;

- (void)createCannedMessage:(NSString *)message
             remoteProvider:(NSString *)remoteProvider
                    success:(void(^)(TCSCannedMessage *cannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock;

- (void)reorderCannedMessage:(TCSCannedMessage *)cannedMessage
                       order:(NSInteger)order
                     success:(void(^)(void))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(TCSCannedMessage *updatedCannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock;

- (void)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(void))successBlock
                    failure:(void(^)(NSError *error))failureBlock;

@end