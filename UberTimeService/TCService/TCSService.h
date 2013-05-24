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
#import "TCSCannedMessage.h"
#import "TCSRemoteCommand.h"
#import "TCSProviderInstance.h"
#import "TCSTimedEntityMetadata.h"
#import "NSError+Utilities.h"

extern NSString * const kTCSPushNotificationRemoteServiceProviderKey;
extern NSString * const kTCSServiceDataResetNotification;

@protocol TCSServiceDelegate <NSObject>

- (void)remoteSyncStarting;
- (void)remoteSyncCompleted;

@end

@protocol TCSServiceRemoteProvider <NSObject>

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) BOOL canCreateEntities;
@property (nonatomic, weak) id <TCSServiceDelegate> delegate;

- (void)clearCache;
- (void)holdUpdates;
- (BOOL)pollForUpdates:(NSArray *)providerInstances;

// method needs to be synchronous because it's designed to be run in the background
- (NSDictionary *)flushUpdates:(BOOL *)requestSent
                         error:(NSError **)error;

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

- (BOOL)createProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (BOOL)updateProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (BOOL)deleteProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock;

// Group

- (BOOL)createGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)updateGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)deleteGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

// Timer

- (BOOL)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)deleteTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

// Canned Message

- (BOOL)createCannedMessage:(TCSCannedMessage *)cannedMessage
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)updateCannedMessage:(TCSCannedMessage *)cannedMessage
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (BOOL)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock;

@end

// import depends on protocol being defined already
#import "TCSDefaultProvider.h"
#import "TCSLocalService.h"

@interface TCSService : NSObject

+ (TCSService *)sharedInstance;

@property (nonatomic, readonly) TCSTimer *activeTimer;
@property (nonatomic, readonly) NSManagedObjectContext *defaultLocalManagedObjectContext;
@property (nonatomic, weak) id <TCSServiceDelegate> delegate;

- (NSDate *)systemTime;
- (void)updateAppConfig;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)sendRemoteMessage:(NSString *)message
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError *error))failureBlock;

- (void)resetRemoteDataWithProvider:(NSString *)remoteProvider
                            success:(void(^)(void))successBlock
                            failure:(void(^)(NSError *error))failureBlock;

#pragma mark - Projects

- (void)pollRemoteServicesForUpdates;
- (void)pollRemoteServiceForUpdates:(NSString *)providerName;

- (NSArray *)registeredRemoteProviders;
- (void)registerRemoteServiceProvider:(Class)providerClass;
- (void)registerSyncingRemoteServiceProvider:(Class)providerClass;
- (NSObject <TCSServiceRemoteProvider> *)serviceProviderOfType:(Class)providerClass;
- (NSObject <TCSServiceRemoteProvider> *)serviceProviderNamed:(NSString *)providerName;

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

- (void)updateProject:(TCSProject *)project
              success:(void(^)(TCSProject *updatedProject))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (NSArray *)allProjects;

- (NSArray *)allProjectsWithArchived:(BOOL)archived;

- (TCSProject *)projectWithID:(NSManagedObjectID *)objectID;

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder archived:(BOOL)archived;

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder
                                 archived:(BOOL)archived;

#pragma mark - Groups

- (NSArray *)topLevelEntitiesSortedByName:(BOOL)sortedByName;

- (NSArray *)allGroups;

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(TCSGroup *updatedGroup))successBlock
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
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)resumeTimer:(TCSTimer *)timer
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

#pragma mark - Canned Messages

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

#pragma mark - Provider Instance

- (NSArray *)allProviderInstances;

- (TCSProviderInstance *)providerInstanceWithID:(NSManagedObjectID *)objectID;

- (void)createProviderInstance:(NSString *)name
                       baseURL:(NSString *)baseURL
                          type:(NSString *)type
                      username:(NSString *)username
                      password:(NSString *)password
                       success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                       failure:(void(^)(NSError *error))failureBlock;

- (void)updateProviderInstance:(TCSProviderInstance *)providerInstance
                     success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProviderInstance:(TCSProviderInstance *)providerInstance
                     success:(void(^)(void))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

@end
