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

NSString * const kTCSPushNotificationRemoteServiceProviderKey = @"remoteProvider";
NSString * const kTCSServicePrivateRemoteSyncCompletedNotification =
@"kTCSServicePrivateRemoteSyncCompletedNotification";
NSString * const kTCSServiceDataResetNotification = @"kTCSServiceDataResetNotification";

@interface TCSService()

@property (nonatomic, strong) TCSLocalService *localService;
@property (nonatomic, strong) NSMutableDictionary *remoteServiceProviders;
@property (nonatomic, readwrite) TCSTimer *activeTimer;

@end

@implementation TCSService

- (id)init
{
    self = [super init];
    if (self) {
        self.remoteServiceProviders = [NSMutableDictionary dictionary];
        self.localService = [TCSLocalService sharedInstance];
        [self updateActiveTimer];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(remoteSyncCompleted:)
         name:kTCSServicePrivateRemoteSyncCompletedNotification
         object:nil];

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationWillEnterForeground:)
         name:UIApplicationWillEnterForegroundNotification
         object:nil];

    }
    return self;
}

- (void)setDelegate:(id<TCSServiceDelegate>)delegate {
    _delegate = delegate;
    _localService.delegate = delegate;

    for (id <TCSServiceRemoteProvider> remoteProvider in _remoteServiceProviders.allValues) {
        remoteProvider.delegate = delegate;
    }
}

- (NSManagedObjectContext *)defaultLocalManagedObjectContext {
    return _localService.defaultLocalManagedObjectContext;
}

- (NSArray *)registeredRemoteProviders {
    static NSArray *sortDescriptors = nil;

    if (sortDescriptors == nil) {
        sortDescriptors =
        @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    }

    return
    [_remoteServiceProviders.allValues sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)registerSyncingRemoteServiceProvider:(Class)providerClass {

    id <TCSServiceSyncingRemoteProvider> serviceProvider =
    (id <TCSServiceSyncingRemoteProvider>)[providerClass sharedInstance];

    NSAssert([(NSObject *)serviceProvider conformsToProtocol:@protocol(TCSServiceSyncingRemoteProvider)],
             @"Class must conform to TCSServiceSyncingRemoteProvider protocol");

    _remoteServiceProviders[NSStringFromClass(providerClass)] = serviceProvider;
    _localService.syncingRemoteProvider = serviceProvider;
    serviceProvider.delegate = _delegate;
}

- (void)registerRemoteServiceProvider:(Class)providerClass {
    id <TCSServiceRemoteProvider> serviceProvider =
    (id <TCSServiceRemoteProvider>)[providerClass sharedInstance];

    NSAssert([(NSObject *)serviceProvider conformsToProtocol:@protocol(TCSServiceRemoteProvider)],
             @"Class must conform to TCSServiceRemoteProvider protocol");
    
    _remoteServiceProviders[NSStringFromClass(providerClass)] = serviceProvider;
    serviceProvider.delegate = _delegate;
}

- (NSObject <TCSServiceRemoteProvider> *)serviceProviderOfType:(Class)providerClass {
    return [self serviceProviderNamed:NSStringFromClass(providerClass)];
}

- (NSObject <TCSServiceRemoteProvider> *)serviceProviderNamed:(NSString *)providerName {
    NSObject <TCSServiceRemoteProvider> *remoteProvider =
    _remoteServiceProviders[providerName];

    if (remoteProvider == nil) {
        NSLog(@"WARN: no provider named: %@", providerName);
    }

    return remoteProvider;
}

- (NSDictionary *)providerInstanceMap {
    NSMutableDictionary *providerInstanceMap = [NSMutableDictionary dictionary];

    for (TCSProviderInstance *providerInstance in [self allProviderInstances]) {

        NSMutableArray *list = providerInstanceMap[providerInstance.type];

        if (list == nil) {
            list = [NSMutableArray array];
            providerInstanceMap[providerInstance.type] = list;
        }

        [list addObject:providerInstance];
    }
    return providerInstanceMap;
}

- (void)pollRemoteServicesForUpdates {

    BOOL anyProviderLoggedIn = NO;

    for (id <TCSServiceRemoteProvider> remoteProvider in _remoteServiceProviders.allValues) {
        anyProviderLoggedIn |= [remoteProvider isUserAuthenticated];
    }

    if (anyProviderLoggedIn) {
        [_delegate remoteSyncStarting];
    }

    BOOL isPolling = NO;


    NSDictionary *providerInstanceMap = [self providerInstanceMap];

    for (id <TCSServiceRemoteProvider> remoteProvider in _remoteServiceProviders.allValues) {

        NSArray *providerInstances = nil;

        if (remoteProvider != _localService.syncingRemoteProvider) {

            providerInstances =
            providerInstanceMap[NSStringFromClass([remoteProvider class])];
        }

        isPolling |= [remoteProvider pollForUpdates:providerInstances];

    }

    if (isPolling == NO && anyProviderLoggedIn) {
        [_delegate remoteSyncCompleted];
    }
}

- (void)pollRemoteServiceForUpdates:(NSString *)providerName {

    id <TCSServiceRemoteProvider> remoteProvider =
    [self serviceProviderNamed:providerName];

    NSDictionary *providerInstanceMap = [self providerInstanceMap];
    NSArray *providerInstances =
    providerInstanceMap[NSStringFromClass([remoteProvider class])];
    [remoteProvider pollForUpdates:providerInstances];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self pollRemoteServicesForUpdates];
}

- (void)sendRemoteMessage:(NSString *)message
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError *error))failureBlock {

    [_localService
     sendRemoteMessage:message
     success:successBlock
     failure:failureBlock];
}

- (void)resetRemoteDataWithProvider:(NSString *)remoteProvider
                            success:(void(^)(void))successBlock
                            failure:(void(^)(NSError *error))failureBlock {

    [_localService
     resetRemoteDataWithProvider:remoteProvider
     success:successBlock
     failure:failureBlock];
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {
    [_localService deleteAllData:successBlock failure:failureBlock];
}

- (void)updateAppConfig {
    [_localService.syncingRemoteProvider updateAppConfig];
}

- (NSDate *)systemTime {

    if (_localService.syncingRemoteProvider != nil) {
        return [_localService.syncingRemoteProvider systemTime];
    }

    return [NSDate date];
}

- (TCSTimer *)activeTimer {
    if (_activeTimer != nil) {
        return [self timerWithID:_activeTimer.objectID];
    }
    return nil;
}

- (void)updateActiveTimer {
    self.activeTimer = [_localService activeTimer];
}

- (void)remoteSyncCompleted:(NSNotification *)notification {

    NSArray *insertedTimers =
    [notification insertedManagedObjectsOfType:[TCSTimer class]];

    NSMutableArray *updatedTimers =
    [[notification updatedManagedObjectsOfType:[TCSTimer class]] mutableCopy];

    [updatedTimers addObjectsFromArray:
     [notification deletedManagedObjectsOfType:[TCSTimer class]]];

    for (TCSTimer *timer in updatedTimers) {

        if ([timer.objectID isEqual:self.activeTimer.objectID] && timer.endTime != nil) {
            self.activeTimer = nil;
        }
    }

    for (TCSTimer *timer in insertedTimers) {
        if (timer.endTime == nil) {
            if (self.activeTimer == nil) {
                self.activeTimer = timer;
            } else {
                if ([timer.updateTime isGreaterThan:self.activeTimer.updateTime]) {

                    [self
                     stopTimer:self.activeTimer
                     success:^(TCSTimer *updatedTimer) {

                         self.activeTimer = timer;

                     } failure:^(NSError *error) {
                         NSLog(@"Error: %@", error);
                     }];
                } else {

                    [self
                     stopTimer:timer
                     success:^(TCSTimer *updatedTimer) {
                     } failure:^(NSError *error) {
                         NSLog(@"Error: %@", error);
                     }];
                }
            }
        }
    }
}

#pragma mark - Remote Command

- (void)executedRemoteCommand:(TCSRemoteCommand *)remoteCommand
                      success:(void(^)(void))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
    [_localService
     executedRemoteCommand:remoteCommand
     success:successBlock
     failure:failureBlock];
}


#pragma mark - Project Methods

- (void)createProjectWithName:(NSString *)name
               remoteProvider:(NSString *)remoteProvider
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
    [_localService
     createProjectWithName:name
     remoteProvider:remoteProvider
     success:successBlock
     failure:failureBlock];
}

- (void)createProjectWithName:(NSString *)name
               remoteProvider:(NSString *)remoteProvider
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    [_localService
     createProjectWithName:name
     remoteProvider:remoteProvider
     filteredModifiers:filteredModifiers
     keyCode:keyCode
     modifiers:modifiers
     success:successBlock
     failure:failureBlock];
}

- (void)updateProject:(TCSProject *)project
              success:(void(^)(TCSProject *updatedProject))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    [_localService updateProject:project success:successBlock failure:failureBlock];
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    [_localService deleteProject:project success:successBlock failure:failureBlock];
}

- (NSArray *)allProjects {
    return [_localService allProjects];
}

- (TCSProject *)projectWithID:(NSManagedObjectID *)objectID {
    return [_localService projectWithID:objectID];
}

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder archived:(BOOL)archived {
    return [_localService projectsSortedByName:ignoreOrder archived:archived];
}

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder
                                 archived:(BOOL)archived {
    return
    [_localService
     projectsSortedByGroupAndName:ignoreOrder
     archived:archived];
}

#pragma mark - Group Methods

- (NSArray *)allGroups {
    return [_localService allGroups];
}

- (NSArray *)topLevelEntitiesSortedByName:(BOOL)sortedByName {
    return [_localService topLevelEntitiesSortedByName:sortedByName];
}

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID {
    return [_localService groupWithID:objectID];
}

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [_localService updateGroup:group success:successBlock failure:failureBlock];
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [_localService deleteGroup:group success:successBlock failure:failureBlock];
}

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group, TCSProject *updatedSourceProject, TCSProject *updatedTargetProject))successBlock
            failure:(void(^)(NSError *error))failureBlock {

#warning TODO : rollback??

    [_localService
     moveProject:sourceProject
     toProject:toProject
     success:successBlock
     failure:failureBlock];
}

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(TCSProject *updatedSourceProject, TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock {

#warning TODO : rollback??
    
    [_localService
     moveProject:sourceProject
     toGroup:group
     success:successBlock
     failure:failureBlock];
}

#pragma mark - Timer Methods

- (NSArray *)allTimers {
    return [_localService allTimers];
}

- (NSArray *)allTimersSortedByStartTime:(BOOL)sortedByStartTime {
    return [_localService allTimersSortedByStartTime:sortedByStartTime];
}

- (TCSTimer *)oldestTimer {
    return [_localService oldestTimer];
}

- (TCSTimer *)timerWithID:(NSManagedObjectID *)objectID {
    return [_localService timerWithID:objectID];
}

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    void (^executionBlock)(void) = ^{

        [_localService
         startTimerForProject:project
         success:^(TCSTimer *timer, TCSProject *updatedProject) {

             self.activeTimer = timer;

             if (successBlock != nil) {
                 successBlock(timer, updatedProject);
             }
             
         } failure:failureBlock];
    };

    if (_activeTimer != nil) {
        [self
         stopTimer:_activeTimer
         success:^(TCSTimer *updatedTimer) {

             executionBlock();
         } failure:failureBlock];
    } else {
        executionBlock();
    }
}

- (void)resumeTimer:(TCSTimer *)timer
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [_localService
     resumeTimer:timer
     success:^(TCSTimer *updatedTimer) {

         self.activeTimer = updatedTimer;

         if (successBlock != nil) {
             successBlock(timer);
         }

     } failure:failureBlock];
}

- (void)createTimerForProject:(TCSProject *)project
                    startTime:(NSDate *)startTime
                     duration:(NSTimeInterval)duration
                      success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
    [_localService
     createTimerForProject:project
     startTime:startTime
     duration:duration
     success:successBlock
     failure:failureBlock];
}

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(TCSTimer *updatedTimer))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    [_localService
     stopTimer:timer
     success:^(TCSTimer *updatedTimer) {

         self.activeTimer = nil;

         if (successBlock != nil) {
             successBlock(updatedTimer);
         }
         
     } failure:failureBlock];
}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [_localService
     updateTimer:timer
     success:successBlock
     failure:failureBlock];
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [_localService
     deleteTimer:timer
     success:successBlock
     failure:failureBlock];
}

- (void)deleteTimers:(NSArray *)timers
             success:(void(^)(void))successBlock
             failure:(void(^)(NSError *error))failureBlock {
    [_localService
     deleteTimers:timers
     success:successBlock
     failure:failureBlock];
}

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(TCSTimer *updatedTimer, TCSProject *updatedProject))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    if ([timer.project isEqual:project]) {
        return;
    }

#warning TODO : rollback??

    [_localService
     moveTimer:timer
     toProject:project
     success:successBlock
     failure:failureBlock];
}

- (void)moveTimers:(NSArray *)timers
         toProject:(TCSProject *)project
           success:(void(^)(NSArray *updatedTimer, TCSProject *updatedProject))successBlock
           failure:(void(^)(NSError *error))failureBlock {

#warning TODO : rollback??

    [_localService
     moveTimers:timers
     toProject:project
     success:successBlock
     failure:failureBlock];
}

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    BOOL isActive = [self.activeTimer isEqual:timer];

    if (successBlock != nil) {

        if (timer.adjustmentValue == 0) {
            [_localService
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
        } else {

            if (failureBlock != nil) {
#warning add NSError
                failureBlock(nil);
            }
        }
    }
}

- (NSArray *)timersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime {

    if (projects.count == 0) {
        return nil;
    }

    return
    [_localService
     timersForProjects:projects
     fromDate:fromDate
     toDate:toDate
     sortByStartTime:sortByStartTime];
}

#pragma mark - Canned Messages

- (NSArray *)allCannedMessages {
    return [_localService allCannedMessages];
}

- (TCSCannedMessage *)cannedMessageWithID:(NSManagedObjectID *)objectID {
    return [_localService cannedMessageWithID:objectID];
}

- (void)createCannedMessage:(NSString *)message
             remoteProvider:(NSString *)remoteProvider
                    success:(void(^)(TCSCannedMessage *cannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    [_localService
     createCannedMessage:message
     remoteProvider:remoteProvider
     success:successBlock
     failure:failureBlock];
}

- (void)reorderCannedMessage:(TCSCannedMessage *)cannedMessage
                       order:(NSInteger)order
                     success:(void(^)(void))successBlock
                     failure:(void(^)(NSError *error))failureBlock {
    [_localService
     reorderCannedMessage:cannedMessage
     order:order
     success:successBlock
     failure:failureBlock];
}

- (void)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(TCSCannedMessage *updatedCannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    [_localService
     updateCannedMessage:cannedMessage
     success:successBlock
     failure:failureBlock];
}

- (void)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(void))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    [_localService
     deleteCannedMessage:cannedMessage
     success:successBlock
     failure:failureBlock];
}

#pragma mark - Provider Instance

- (NSArray *)allProviderInstances {
    return [_localService allProviderInstances];
}

- (TCSProviderInstance *)providerInstanceWithID:(NSManagedObjectID *)objectID {
    return [_localService providerInstanceWithID:objectID];
}

- (void)createProviderInstance:(NSString *)name
                     baseURL:(NSString *)baseURL
                        type:(NSString *)type
                    username:(NSString *)username
                    password:(NSString *)password
                     success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                     failure:(void(^)(NSError *error))failureBlock {
    [_localService
     createProviderInstance:name
     baseURL:baseURL
     type:type
     username:username
     password:password
     success:successBlock
     failure:failureBlock];
}

- (void)updateProviderInstance:(TCSProviderInstance *)providerInstance
                     success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    [_localService
     updateProviderInstance:providerInstance
     success:successBlock
     failure:failureBlock];
}

- (void)deleteProviderInstance:(TCSProviderInstance *)providerInstance
                     success:(void(^)(void))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    [_localService
     deleteProviderInstance:providerInstance
     success:successBlock
     failure:failureBlock];
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
