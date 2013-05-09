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
    }
    return self;
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

- (void)registerRemoteServiceProvider:(Class)providerClass {
    id <TCSServiceRemoteProvider> serviceProvider =
    (id <TCSServiceRemoteProvider>)[providerClass sharedInstance];

    NSAssert([(NSObject *)serviceProvider conformsToProtocol:@protocol(TCSServiceRemoteProvider)],
             @"Class must conform to TCSServiceRemoteProvider protocol");

    _remoteServiceProviders[NSStringFromClass(providerClass)] = serviceProvider;
}

- (id <TCSServiceRemoteProvider>)serviceProviderOfType:(Class)providerClass {
    return _remoteServiceProviders[NSStringFromClass(providerClass)];
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {
    [_localService deleteAllData:successBlock failure:failureBlock];
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
              success:(void(^)(void))successBlock
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

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder {
    return [_localService projectsSortedByName:ignoreOrder];
}

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder {
    return [_localService projectsSortedByGroupAndName:ignoreOrder];
}

#pragma mark - Group Methods

- (NSArray *)allGroups {
    return [_localService allGroups];
}

- (TCSGroup *)groupWithID:(NSManagedObjectID *)objectID {
    return [_localService groupWithID:objectID];
}

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
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
            success:(void(^)(void))successBlock
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
