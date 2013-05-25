//
//  TCSLocalService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//

#import "TCSLocalService.h"
#import "TCSLocalServiceHeaders.h"
#import "CoreData+MagicalRecord.h"
#import "TCSService.h"
#import "NSDate+Utilities.h"
#import "NSArray+PBFoundation.h"
#import "NSNotification+PBFoundation.h"
#import "TCSBaseEntity.h"
#import "TCSServicePrivate.h"
#import "TCSCommon.h"

NSString * const kTCSLocalServiceUpdatedRemoteEntitiesNotification =
@"kTCSLocalServiceUpdatedRemoteEntitiesNotification";
NSString * const kTCSLocalServiceRemoteSyncCompletedNotification =
@"kTCSLocalServiceRemoteSyncCompletedNotification";
NSString * const kTCSLocalServiceUpdatedRemoteEntitiesKey = @"updated-entities";
NSString * const kTCSLocalServiceRemoteProviderNameKey = @"remote-provider-name";

@interface TCSLocalService() {

    BOOL _savingUpdates;
}

@property (nonatomic, strong) NSTimer *sweepTimer;

@end

@implementation TCSLocalService

- (id)init
{
    self = [super init];
    if (self) {

#if IntegrationTests
        [MagicalRecord setupCoreDataStackWithInMemoryStore];
#else
        [MagicalRecord setupCoreDataStackWithStoreNamed:@"TCSLocalService.data"];
#endif

#if TARGET_OS_IPHONE
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidEnterBackground:)
         name:UIApplicationDidEnterBackgroundNotification
         object:nil];
#endif

        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(handleUpdatedRemoteEntities:)
         name:kTCSLocalServiceUpdatedRemoteEntitiesNotification
         object:nil];

        self.sweepTimer =
        [NSTimer
         scheduledTimerWithTimeInterval:5.0f
         target:self
         selector:@selector(handleRemoteProviderSyncing:)
         userInfo:nil
         repeats:YES];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_sweepTimer invalidate];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (NSString *)providerNameForInstance:(TCSProviderInstance *)providerInstance {

    NSString *providerName = providerInstance.remoteProvider;

    if (providerName == nil) {
        providerName = _syncingRemoteProvider;
    }

    return providerName;
}

- (id <TCSServiceRemoteProvider>)remoteProviderForInstance:(TCSProviderInstance *)providerInstance {
    NSString *providerName = [self providerNameForInstance:providerInstance];
    return [[TCSService sharedInstance] serviceProviderNamed:providerName];
}

+ (NSManagedObjectID *)objectIDFromStringID:(NSString *)stringID {

    NSManagedObjectContext *context =
    [[self sharedInstance] managedObjectContextForCurrentThread];

    NSPersistentStoreCoordinator *coordinator =
    [context persistentStoreCoordinator];

    NSURL *url = [NSURL URLWithString:stringID];

    return [coordinator managedObjectIDForURIRepresentation:url];
}

+ (NSString *)stringIDFromObjectID:(NSManagedObjectID *)objectID {
    NSURL *uri = [objectID URIRepresentation];
    return uri.absoluteString;
}

- (void)resetCoreDataStack {
    [MagicalRecord cleanUp];

#if IntegrationTests
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
#else

    @synchronized ([NSThread mainThread]) {
        NSMutableDictionary *threadDict = [[NSThread mainThread] threadDictionary];

        [threadDict
         setObject:[NSMutableSet set]
         forKey:@"MagicalRecord_NSManagedObjectContextForThreadKeyRegistry"];
    }

    NSString *storeName = @"TCSLocalService.data";

    NSString *applicationSupportDir =
    [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];

    NSString *storeFile =
    [[applicationSupportDir stringByAppendingPathComponent:@"UberTimeService"]
     stringByAppendingPathComponent:storeName];

    if ([[NSFileManager defaultManager] fileExistsAtPath:storeFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:storeFile error:NULL];
    }

    [MagicalRecord setupCoreDataStackWithStoreNamed:storeName];
#endif
}

- (NSString *)name {
    return NSLocalizedString(@"Local", nil);
}

- (NSManagedObjectContext *)defaultLocalManagedObjectContext {
    return [NSManagedObjectContext MR_defaultContext];
}

- (NSManagedObjectContext *)managedObjectContextForCurrentThread {

    if ([NSThread isMainThread]) {
        return [NSManagedObjectContext MR_defaultContext];
    } else {

        NSMutableSet *threadRegistry = nil;

        @synchronized ([NSThread mainThread]) {
            NSMutableDictionary *mainThreadDict = [[NSThread mainThread] threadDictionary];

            threadRegistry =
            [mainThreadDict
             objectForKey:@"MagicalRecord_NSManagedObjectContextForThreadKeyRegistry"];
        }

        NSString *currentThreadKey = [[NSThread currentThread] description];

        NSMutableDictionary *threadDict = [[NSThread currentThread] threadDictionary];
		NSManagedObjectContext *threadContext = [threadDict objectForKey:@"MagicalRecord_NSManagedObjectContextForThreadKey"];
        if (threadContext == nil || [threadRegistry containsObject:currentThreadKey] == NO) {
			threadContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
			[threadDict setObject:threadContext forKey:@"MagicalRecord_NSManagedObjectContextForThreadKey"];
            [threadRegistry addObject:currentThreadKey];
		}

        return threadContext;
    }
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    [self resetCoreDataStack];

    [[NSNotificationCenter defaultCenter]
     postNotificationName:kTCSPreferencesDataResetNotification
     object:nil];
    
    if (successBlock != nil) {
        successBlock();
    }
}

#pragma mark - Remote Commands

- (void)executedRemoteCommand:(TCSRemoteCommand *)remoteCommand
                      success:(void(^)(void))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    if (_syncingRemoteProvider == nil) {
        NSLog(@"WARN : no sync remote provider registered");
        return;
    }

    [_syncingRemoteProvider
     executedRemoteCommand:remoteCommand
     success:successBlock
     failure:failureBlock];
}

- (void)sendRemoteMessage:(NSString *)message
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError *error))failureBlock {

    if (_syncingRemoteProvider == nil) {
        NSLog(@"WARN : no sync remote provider registered");
        return;
    }

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSRemoteCommand *remoteCommand =
        [TCSRemoteCommand
         messageRemoteCommand:message
         remoteProvider:NSStringFromClass(_syncingRemoteProvider.class)
         inContext:localContext];

        [remoteCommand
         updateWithEntityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

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

- (void)sendDeleteObjectCommand:(NSString *)remoteObjectID
             withProvider:(NSString *)remoteProvider
                  success:(void(^)(void))successBlock
                  failure:(void(^)(NSError *error))failureBlock {

    if (remoteProvider == nil && _syncingRemoteProvider != nil) {
        remoteProvider = NSStringFromClass(_syncingRemoteProvider.class);
    }

    if (remoteProvider == nil) {
        NSLog(@"WARN : No remote provider specified");
        return;
    }

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSRemoteCommand *remoteCommand =
        [TCSRemoteCommand
         deleteObjectRemoteCommand:remoteObjectID
         remoteProvider:remoteProvider
         inContext:localContext];

        [remoteCommand
         updateWithEntityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

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

- (void)resetRemoteDataWithProvider:(NSString *)remoteProvider
                            success:(void(^)(void))successBlock
                            failure:(void(^)(NSError *error))failureBlock {

    if (remoteProvider == nil && _syncingRemoteProvider != nil) {
        remoteProvider = NSStringFromClass(_syncingRemoteProvider.class);
    }

    if (remoteProvider == nil) {
        NSLog(@"WARN : No remote provider specified");
        return;
    }

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSRemoteCommand *remoteCommand =
        [TCSRemoteCommand
         resetDataRemoteCommand:remoteProvider
         inContext:localContext];

        [remoteCommand
         updateWithEntityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

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

#pragma mark - Project Methods

- (void)createProjectWithName:(NSString *)name
             providerInstance:(TCSProviderInstance *)providerInstance
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    [self
     createProjectWithName:name
     providerInstance:providerInstance
     filteredModifiers:0
     keyCode:0
     modifiers:0
     success:successBlock
     failure:failureBlock];
}

- (TCSProject *)doCreateProjectWithName:(NSString *)name
                       providerInstance:(TCSProviderInstance *)providerInstance
                      filteredModifiers:(NSInteger)filteredModifiers
                                keyCode:(NSInteger)keyCode
                              modifiers:(NSInteger)modifiers
                              inContext:(NSManagedObjectContext *)context {

    TCSProject *project =
    [TCSProject MR_createInContext:context];

    project.providerInstance = providerInstance;

    project.metadata = [TCSTimedEntityMetadata MR_createInContext:context];
    project.metadata.providerInstance = nil;
    [project.metadata markEntityAsUpdated];

    [project
     updateWithName:name
     entityVersion:0
     remoteId:nil
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    return project;
}

- (void)createProjectWithName:(NSString *)name
             providerInstance:(TCSProviderInstance *)providerInstance
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    __block TCSProject *project = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        project =
        [self
         doCreateProjectWithName:name
         providerInstance:providerInstance
         filteredModifiers:filteredModifiers
         keyCode:keyCode
         modifiers:modifiers
         inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
            
        } else {

            if (successBlock != nil) {

                project = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:project.objectID];

                successBlock(project);
            }
        }
    }];
}

- (NSError *)doUpdateProject:(TCSProject *)project
                   inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;
    TCSProject *localProject =
    (id)[context existingObjectWithID:project.objectID error:&error];

    if (project.metadata.archivedValue && localProject.isActive) {

        TCSTimer *activeTimer =
        [[TCSService sharedInstance] activeTimer];

        activeTimer =
        (id)[context existingObjectWithID:activeTimer.objectID error:&error];

        if ([localProject.objectID isEqual:activeTimer.project.objectID]) {
            [self doStopTimer:activeTimer];
        }
    }

    [localProject
     updateWithName:project.name
     entityVersion:project.entityVersionValue
     remoteId:project.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    [localProject.metadata
     updateWithColor:project.metadata.colorValue
     archived:project.metadata.archivedValue
     filteredModifiers:project.metadata.filteredModifiersValue
     keyCode:project.metadata.keyCodeValue
     modifiers:project.metadata.modifiersValue
     order:project.metadata.orderValue
     entityVersion:project.metadata.entityVersionValue
     remoteId:project.metadata.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    return error;
}

- (void)updateProject:(TCSProject *)project
               success:(void(^)(TCSProject *updatedProject))successBlock
               failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        localError = [self doUpdateProject:project inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                TCSProject *updatedProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:project.objectID];

                successBlock(updatedProject);
            }
        }
    }];
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {


    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSProject *localProject = (id)
        (id)[localContext existingObjectWithID:project.objectID error:NULL];

        if (localProject != nil) {

            @synchronized (self) {
                [localProject markEntityAsDeleted];
                [localProject.metadata markEntityAsDeleted];

                for (TCSTimer *timer in localProject.timers) {
                    [timer markEntityAsDeleted];
                }
            }
        }

    } completion:^(BOOL success, NSError *error) {

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

- (TCSProject *)projectWithID:(id)entityID {

    TCSProject *project = (id)
    [[self managedObjectContextForCurrentThread]
     existingObjectWithID:entityID
     error:NULL];

    if (project.pendingRemoteDeleteValue) {
        project = nil;
    }

    return project;
}

- (NSArray *)projectsSortedByName:(BOOL)ignoreOrder archived:(BOOL)archived {

    NSComparator nameComparator = ^NSComparisonResult(id obj1, id obj2) {
        TCSTimedEntity *timedEntity1 = obj1;
        TCSTimedEntity *timedEntity2 = obj2;

        if ([obj1 isKindOfClass:[TCSProject class]] && [obj2 isKindOfClass:[TCSProject class]]) {
            TCSProject *p1 = obj1;
            TCSProject *p2 = obj2;

            if (ignoreOrder == NO) {
                NSInteger order1 = p1.metadata.orderValue;
                NSInteger order2 = p2.metadata.orderValue;

                if (order1 >= 0 || order2 >= 0) {
                    if (order1 < 0) {
                        return NSOrderedDescending;
                    }
                    if (order2 < 0) {
                        return NSOrderedAscending;
                    }
                    if (order1 != order2) {
                        return [p1.metadata.order compare:p2.metadata.order];
                    }
                }
            }
        }
        return [timedEntity1.name.lowercaseString compare:timedEntity2.name.lowercaseString];
    };

    NSArray *projects = [self allProjectsWithArchived:archived];

    return [projects sortedArrayUsingComparator:nameComparator];
}

- (NSArray *)projectsSortedByGroupAndName:(BOOL)ignoreOrder
                                 archived:(BOOL)archived {

    NSComparator nameComparator = ^NSComparisonResult(id obj1, id obj2) {
        TCSTimedEntity *timedEntity1 = obj1;
        TCSTimedEntity *timedEntity2 = obj2;
        TCSGroup *group1 = timedEntity1.parent;
        TCSGroup *group2 = timedEntity2.parent;

        if ([obj1 isKindOfClass:[TCSProject class]] && [obj2 isKindOfClass:[TCSProject class]]) {
            TCSProject *p1 = obj1;
            TCSProject *p2 = obj2;

            if (ignoreOrder == NO) {
                NSInteger order1 = p1.metadata.orderValue;
                NSInteger order2 = p2.metadata.orderValue;

                if (order1 >= 0 || order2 >= 0) {
                    if (order1 < 0) {
                        return NSOrderedDescending;
                    }
                    if (order2 < 0) {
                        return NSOrderedAscending;
                    }
                    if (order1 != order2) {
                        return [p1.metadata.order compare:p2.metadata.order];
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

    NSArray *projects = [self allProjectsWithArchived:archived];

    return [projects sortedArrayUsingComparator:nameComparator];
}

- (NSArray *)allProjects {
    return [self allProjectsInContext:[self managedObjectContextForCurrentThread]];
}

- (NSArray *)allProjectsInContext:(NSManagedObjectContext *)context {
    return
    [TCSProject
     MR_findByAttribute:@"pendingRemoteDelete"
     withValue:@NO
     inContext:context];
}

- (NSArray *)allProjectsWithArchived:(BOOL)archived {

    NSPredicate *predicate =
    [NSPredicate
     predicateWithFormat:@"pendingRemoteDelete = 0 and metadata.archived = %d",
     archived];

    NSArray *projects =
    [TCSProject
     MR_findAllWithPredicate:predicate
     inContext:[self managedObjectContextForCurrentThread]];

    return projects;
}

#pragma mark - Group Methods

- (NSError *)doUpdateGroup:(TCSGroup *)group
                 inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;

    TCSGroup *localGroup = (id)
    (id)[context existingObjectWithID:group.objectID error:&error];

    [localGroup
     updateWithName:group.name
     entityVersion:group.entityVersionValue
     remoteId:group.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    [localGroup.metadata
     updateWithColor:group.metadata.colorValue
     archived:group.metadata.archivedValue
     filteredModifiers:group.metadata.filteredModifiersValue
     keyCode:group.metadata.keyCodeValue
     modifiers:group.metadata.modifiersValue
     order:group.metadata.orderValue
     entityVersion:group.metadata.entityVersionValue
     remoteId:group.metadata.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    return error;
}

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        localError = [self doUpdateGroup:group inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                TCSGroup *updatedGroup = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:group.objectID];

                successBlock(updatedGroup);
            }
        }
    }];
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSGroup *localGroup = (id)
        (id)[localContext existingObjectWithID:group.objectID error:NULL];

        @synchronized (self) {
            if (localGroup != nil) {
                [localGroup markEntityAsDeleted];
                [localGroup.metadata markEntityAsDeleted];

                for (TCSTimedEntity *entity in localGroup.children) {
                    [entity markEntityAsDeleted];
                    [entity.metadata markEntityAsDeleted];
                }
            }
        }

    } completion:^(BOOL success, NSError *error) {

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

- (TCSGroup *)groupWithID:(id)entityID {
    TCSGroup *group = (id)
    [[self managedObjectContextForCurrentThread]
     existingObjectWithID:entityID
     error:NULL];

    if (group.pendingRemoteDeleteValue) {
        group = nil;
    }

    return group;
}

- (NSArray *)allGroups {
    return [self allGroupsInContext:[self managedObjectContextForCurrentThread]];
}

- (NSArray *)allGroupsInContext:(NSManagedObjectContext *)context {
    return
    [TCSGroup
     MR_findByAttribute:@"pendingRemoteDelete"
     withValue:@NO
     inContext:context];
}

- (NSArray *)topLevelEntitiesSortedByName:(BOOL)sortedByName {

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"parent = null AND pendingRemoteDelete = 0"];

    NSArray *entities =
    [TCSTimedEntity
     MR_findAllWithPredicate:predicate
     inContext:[self managedObjectContextForCurrentThread]];

    if (sortedByName) {

        NSComparator nameComparator = ^NSComparisonResult(id obj1, id obj2) {
            TCSTimedEntity *timedEntity1 = obj1;
            TCSTimedEntity *timedEntity2 = obj2;

            return [timedEntity1.name.lowercaseString compare:timedEntity2.name.lowercaseString];
        };

        return [entities sortedArrayUsingComparator:nameComparator];
    }

    return entities;
}

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *createdGroup, TCSProject *updatedSourceProject, TCSProject *updatedTargetProject))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    __block TCSGroup *group = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSProject *localSourceProject = (id)
        (id)[localContext existingObjectWithID:sourceProject.objectID error:NULL];

        TCSProject *localToProject = (id)
        (id)[localContext existingObjectWithID:toProject.objectID error:NULL];

        TCSGroup *groupTarget =
        localToProject.parent.parent;

        group = [TCSGroup MR_createInContext:localContext];

        [groupTarget addChildrenObject:group];

        group.name = toProject.name;
        group.providerInstance = localToProject.providerInstance;

        group.metadata = [TCSTimedEntityMetadata MR_createInContext:localContext];
        group.metadata.providerInstance = nil;
        [group.metadata markEntityAsUpdated];

        [group markEntityAsUpdated];

        [self
         doMoveProject:localSourceProject
         toGroup:group
         inContext:localContext];

        [localToProject markEntityAsDeleted];
        [localToProject.metadata markEntityAsDeleted];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                group = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:group.objectID];

                TCSProject *updatedSourceProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:sourceProject.objectID];

                TCSProject *updatedTargetProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:toProject.objectID];

                successBlock(group, updatedSourceProject, updatedTargetProject);
            }
        }
    }];
}

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(TCSProject *updatedSourceProject, TCSGroup *updatedGroup))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSProject *localSourceProject =
        (id)[localContext existingObjectWithID:sourceProject.objectID error:NULL];

        TCSGroup *localGroup = nil;

        if (group != nil) {
            localGroup =
            (id)[localContext existingObjectWithID:group.objectID error:NULL];
        }

        [self
         doMoveProject:localSourceProject
         toGroup:localGroup
         inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                TCSProject *updatedSourceProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:sourceProject.objectID];

                TCSGroup *updatedGroup = nil;

                if (group != nil) {
                    updatedGroup = (id)
                    [[self managedObjectContextForCurrentThread]
                     objectWithID:group.objectID];
                }

                successBlock(updatedSourceProject, updatedGroup);
            }
        }
    }];
}

- (void)doMoveProject:(TCSProject *)project
              toGroup:(TCSGroup *)group
            inContext:(NSManagedObjectContext *)context {

    TCSGroup *parent = project.parent;

    [parent removeChildrenObject:project];

    if (group != nil) {
        [group addChildrenObject:project];
    } else {
        project.parent = nil;
    }

    [group markEntityAsUpdated];
    [project markEntityAsUpdated];

    if (parent != nil && [parent.children count] == 0) {
        // demote to a project

        TCSProject *demotedProject =
        [self
         doCreateProjectWithName:parent.name
         providerInstance:parent.providerInstance
         filteredModifiers:0
         keyCode:0
         modifiers:0
         inContext:context];
        
        demotedProject.metadata.archived = parent.metadata.archived;
        [parent.parent addChildrenObject:demotedProject];
        [parent.parent removeChildrenObject:parent];

        [parent markEntityAsDeleted];
        [parent.metadata markEntityAsDeleted];

    } else {
        [parent markEntityAsUpdated];
    }
}

#pragma mark - Timer Methods

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    __block TCSTimer *timer = nil;
    __block TCSProject *updatedProject = nil;
    __block NSError *projectError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        updatedProject = (id)
        [localContext existingObjectWithID:project.objectID error:&projectError];

        timer = [TCSTimer MR_createInContext:localContext];
        timer.providerInstance = updatedProject.providerInstance;
        timer.project = updatedProject;

        [timer
         updateWithStartTime:[[TCSService sharedInstance] systemTime]
         endTime:nil
         adjustment:0.0f
         message:nil
         entityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

        if (projectError != nil) {

            if (failureBlock != nil) {
                failureBlock(projectError);
            }
            
        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                timer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];

                updatedProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:updatedProject.objectID];
                
                successBlock(timer, updatedProject);
            }
        }
    }];
}

- (void)createTimerForProject:(TCSProject *)project
                    startTime:(NSDate *)startTime
                     duration:(NSTimeInterval)duration
                      success:(void(^)(TCSTimer *timer, TCSProject *updatedProject))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    __block TCSTimer *timer = nil;
    __block TCSProject *updatedProject = nil;
    __block NSError *projectError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        updatedProject = (id)
        [localContext existingObjectWithID:project.objectID error:&projectError];

        timer = [TCSTimer MR_createInContext:localContext];
        timer.project = updatedProject;
        timer.providerInstance = updatedProject.providerInstance;

        [timer
         updateWithStartTime:startTime
         endTime:[startTime dateByAddingSeconds:duration]
         adjustment:0.0f
         message:nil
         entityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

        if (projectError != nil) {

            if (failureBlock != nil) {
                failureBlock(projectError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                timer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];

                updatedProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:updatedProject.objectID];
                
                successBlock(timer, updatedProject);
            }
        }
    }];
}

- (void)doStopTimer:(TCSTimer *)timer {
    if (timer != nil) {
        timer.endTime = [[TCSService sharedInstance] systemTime];

        if (timer.combinedTime < 5.0f) {
            timer.pendingRemoteDeleteValue = YES;
        }
        [timer markEntityAsUpdated];
    }
}

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(TCSTimer *updatedTimer))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSTimer *localTimer = (id)
        (id)[localContext existingObjectWithID:timer.objectID error:NULL];

        [self doStopTimer:localTimer];
        
    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSTimer *updatedTimer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];
                
                successBlock(updatedTimer);
            }
        }
    }];
}

- (NSError *)doUpdateTimer:(TCSTimer *)timer
                 inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;

    TCSTimer *localTimer = (id)
    (id)[context existingObjectWithID:timer.objectID error:NULL];

    if (localTimer != nil) {
        localTimer.message = timer.message;
        localTimer.adjustment= timer.adjustment;
        if (localTimer.endTime != nil && timer.endTime != nil) {
            localTimer.endTime = timer.endTime;
        }
        [localTimer markEntityAsUpdated];
    }

    return error;
}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(TCSTimer *updatedTimer))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        localError = [self doUpdateTimer:timer inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                TCSTimer *updatedTimer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];

                successBlock(updatedTimer);
            }
        }
    }];
}

- (NSError *)doMoveTimer:(TCSTimer *)timer
               toProject:(TCSProject *)project
               inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;

    TCSTimer *localTimer = (id)
    [context
     existingObjectWithID:timer.objectID
     error:&error];

    if (error != nil) {
        return error;
    }

    NSAssert(localTimer != nil, @"timer is null");

    TCSProject *localProject = (id)
    [context
     existingObjectWithID:project.objectID
     error:&error];

    if (error != nil) {
        return error;
    }

    NSAssert(localProject != nil, @"project is null");

    localTimer.project = localProject;

    [localTimer markEntityAsUpdated];
    [localProject markEntityAsUpdated];

    return nil;
}

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(TCSTimer *updatedTimer, TCSProject *updatedProject))successBlock
          failure:(void(^)(NSError *error))failureBlock {
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        NSError *error =
        [self doMoveTimer:timer toProject:project inContext:localContext];

        if (error != nil) {
            if (failureBlock != nil) {
                failureBlock(error);
                return;
            }
        }
        
    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                TCSTimer *updatedTimer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];

                TCSProject *updatedProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:project.objectID];

                successBlock(updatedTimer, updatedProject);
            }
        }
    }];
}

- (void)moveTimers:(NSArray *)timers
         toProject:(TCSProject *)project
           success:(void (^)(NSArray *, TCSProject *))successBlock
           failure:(void (^)(NSError *))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        for (TCSTimer *timer in timers) {
            NSError *error =
            [self doMoveTimer:timer toProject:project inContext:localContext];

            if (error != nil) {
                if (failureBlock != nil) {
                    failureBlock(error);
                    return;
                }
            }
        }

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                NSMutableArray *updatedTimers =
                [NSMutableArray arrayWithCapacity:timers.count];

                for (TCSTimer *timer in timers) {
                    TCSTimer *updatedTimer = (id)
                    [[self managedObjectContextForCurrentThread]
                     objectWithID:timer.objectID];
                    [updatedTimers addObject:updatedTimer];
                }

                TCSProject *updatedProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:project.objectID];

                successBlock(updatedTimers, updatedProject);
            }
        }
    }];
}

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    __block NSMutableArray *rolledTimers = [NSMutableArray array];

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSTimer *localTimer = (id)
        [localContext
         existingObjectWithID:timer.objectID
         error:NULL];

        TCSProject *localProject = (id)
        [localContext
         existingObjectWithID:timer.project.objectID
         error:NULL];

        [rolledTimers addObject:localTimer];

        TCSTimer *rollingTimer = localTimer;

        [rollingTimer markEntityAsUpdated];

        while (localProject != nil && rollingTimer != nil && rollingTimer.combinedTime > maxDuration) {

            NSDate *endDate =
            [rollingTimer.startTime dateByAddingTimeInterval:maxDuration];

            rollingTimer =
            [self
             doRolloverActiveTimer:rollingTimer
             project:localProject
             endDate:endDate];

            [rolledTimers addObject:rollingTimer];
        }

        NSMutableArray *temporaryLocalObjects = [NSMutableArray array];

        for (TCSTimer *t in rolledTimers) {

            [t markEntityAsUpdated];

            if (t.objectID.isTemporaryID) {
                [temporaryLocalObjects addObject:t];
            }
        }

        [localContext
         obtainPermanentIDsForObjects:temporaryLocalObjects
         error:NULL];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            NSManagedObjectContext *moc =
            [self managedObjectContextForCurrentThread];

            NSMutableArray *result = [NSMutableArray arrayWithCapacity:rolledTimers.count];

            for (TCSTimer *t in rolledTimers) {
                TCSTimer *updatedTimer =
                (id)[moc existingObjectWithID:t.objectID error:NULL];
                [result addObject:updatedTimer];
            }

            if (successBlock != nil) {
                successBlock(result);
            }
        }
    }];
}

- (TCSTimer *)doRolloverActiveTimer:(TCSTimer *)timer
                       project:(TCSProject *)project
                            endDate:(NSDate *)endDate {

    timer = (id)
    [project.managedObjectContext
     existingObjectWithID:timer.objectID
     error:NULL];

    NSDate *finalEndTime = timer.endTime;

    if (endDate == nil || [endDate isLessThan:timer.startTime]) {
        timer.endTime = [[TCSService sharedInstance] systemTime];
    } else {
        timer.endTime = endDate;
    }

    TCSTimer *rolledTimer =
    [TCSTimer MR_createInContext:project.managedObjectContext];
    rolledTimer.project = project;
    rolledTimer.providerInstance = project.providerInstance;

    [rolledTimer
     updateWithStartTime:timer.endTime
     endTime:finalEndTime
     adjustment:0.0f
     message:timer.message
     entityVersion:0
     remoteId:nil
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:NO];

    [project addTimersObject:rolledTimer];

    return rolledTimer;
}

- (void)resumeTimer:(TCSTimer *)timer
          success:(void(^)(TCSTimer *updatedTimer))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSTimer *localTimer = (id)
        [localContext
         existingObjectWithID:timer.objectID
         error:NULL];

        NSDate *now = [[TCSService sharedInstance] systemTime];

        NSDate *virtualEndTime =
        [localTimer.startTime dateByAddingSeconds:localTimer.combinedTime];

        if (localTimer.endTime != nil &&
            [[virtualEndTime midnight] isEqualToDate:[now midnight]] &&
            [virtualEndTime isLessThanOrEqualTo:now]) {

            TCSTimer *activeTimer = [TCSService sharedInstance].activeTimer;
            [self doStopTimer:activeTimer];

            timer.endTime = nil;
            timer.adjustment = @(0);
            [timer markEntityAsUpdated];

            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:self forKey:@"project"];
        }
    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSTimer *updatedTimer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:timer.objectID];

                successBlock(updatedTimer);
            }
        }
    }];
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSTimer *localTimer = (id)
        (id)[localContext existingObjectWithID:timer.objectID error:NULL];

        if (localTimer != nil) {
            [localTimer markEntityAsDeleted];
        }

    } completion:^(BOOL success, NSError *error) {

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

- (void)deleteTimers:(NSArray *)timers
             success:(void(^)(void))successBlock
             failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        for (TCSTimer *timer in timers) {
            TCSTimer *localTimer = (id)
            (id)[localContext existingObjectWithID:timer.objectID error:NULL];

            if (localTimer != nil) {
                [localTimer markEntityAsDeleted];
            }
        }

    } completion:^(BOOL success, NSError *error) {

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

- (TCSTimer *)timerWithID:(id)entityID {

    TCSTimer *timer = (id)
    [[self managedObjectContextForCurrentThread]
     existingObjectWithID:entityID
     error:NULL];

    if (timer.pendingRemoteDeleteValue) {
        timer = nil;
    }

    return timer;
}

- (NSArray *)timersForProjects:(NSArray *)timedEntities
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
               sortByStartTime:(BOOL)sortByStartTime {

    if (fromDate == nil) {
        fromDate = [NSDate distantPast];
    }

    if (toDate == nil) {
        toDate = [NSDate distantFuture];
    }

    fromDate = [fromDate midnight];
    toDate = [toDate endOfDay];
    NSDate *now = [[TCSService sharedInstance] systemTime];

    static NSArray *sortDescriptors = nil;

    if (sortDescriptors == nil) {
        sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startTime" ascending:YES]];
    }

//    NSPredicate *p1 =
//    [NSPredicate predicateWithFormat:@"((project in %@) or (project.parent in %@))",
//     timedEntities, timedEntities];
//
//    NSArray *matchesProject =
//    [TCSTimer
//     MR_findAllWithPredicate:p1
//     inContext:[self managedObjectContextForCurrentThread]];
//
//    NSPredicate *p2 =
//    [NSPredicate predicateWithFormat:@"(startTime <= %@ and endTime >= %@)",
//     toDate, fromDate];
//
//    NSArray *stoppedTimer =
//    [TCSTimer
//     MR_findAllWithPredicate:p2
//     inContext:[self managedObjectContextForCurrentThread]];
//
//    NSPredicate *p3 =
//    [NSPredicate predicateWithFormat:@"(endTime = nil and startTime <= %@ and %@ >= %@)",
//     toDate, now, fromDate];
//
//    NSArray *activeTimer =
//    [TCSTimer
//     MR_findAllWithPredicate:p3
//     inContext:[self managedObjectContextForCurrentThread]];
//
//    NSLog(@"matchesProject: %@", matchesProject);
//    NSLog(@"stoppedTimers: %@", stoppedTimer);
//    NSLog(@"activeTimer: %@", activeTimer);

    NSPredicate * predicate =
    [NSPredicate predicateWithFormat:
     @"(pendingRemoteDelete = 0) and ((project in %@) or (project.parent in %@)) and ((startTime <= %@ and endTime >= %@) or (endTime = nil and startTime <= %@ and %@ >= %@))",
     timedEntities, timedEntities, toDate, fromDate, toDate, now, fromDate];

    NSArray *timers =
    [TCSTimer
     MR_findAllWithPredicate:predicate
     inContext:[self managedObjectContextForCurrentThread]];

    if (sortByStartTime) {
        return [timers sortedArrayUsingDescriptors:sortDescriptors];
    }

    return timers;
}

- (NSArray *)allTimers {
    return [self allTimersInContext:[self managedObjectContextForCurrentThread]];
}

- (NSArray *)allTimersInContext:(NSManagedObjectContext *)context {
    return
    [TCSTimer
     MR_findByAttribute:@"pendingRemoteDelete"
     withValue:@NO
     inContext:context];
}

- (NSArray *)allTimersSortedByStartTime:(BOOL)sortedByStartTime {

    if (sortedByStartTime) {
        return
        [TCSTimer
         MR_findByAttribute:@"pendingRemoteDelete"
         withValue:@NO
         andOrderBy:@"startTime"
         ascending:YES
         inContext:[self managedObjectContextForCurrentThread]];
    }

    return [self allTimers];
}

- (TCSTimer *)oldestTimer {
    NSArray *allTimers = [self allTimersSortedByStartTime:YES];
    return allTimers.firstObject;
}

- (TCSTimer *)activeTimer {

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"endTime = nil AND pendingRemoteDelete = 0"];

    NSArray *activeTimers =
    [TCSTimer
     MR_findAllWithPredicate:predicate
     inContext:[self managedObjectContextForCurrentThread]];

    if (activeTimers.count > 1) {
        NSLog(@"More than one active timer!");
    }

    NSInteger idx = 0;
    for (TCSTimer *timer in activeTimers) {
        if (idx > 0) {
            [self stopTimer:timer success:nil failure:nil];
        }
        idx++;
    }
    return activeTimers.firstObject;
}

- (void)updateEntities:(NSArray *)entities
               success:(void (^)(NSArray *updatedEntities))successBlock
               failure:(void (^)(NSError *))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        for (NSManagedObject *entity in entities) {

            if ([entity isKindOfClass:[TCSTimer class]]) {
                localError =
                [self doUpdateTimer:(id)entity inContext:localContext];
            } else if ([entity isKindOfClass:[TCSProject class]]) {
                localError =
                [self doUpdateProject:(id)entity inContext:localContext];
            } else if ([entity isKindOfClass:[TCSGroup class]]) {
                localError =
                [self doUpdateGroup:(id)entity inContext:localContext];
            } else if ([entity isKindOfClass:[TCSCannedMessage class]]) {
                localError =
                [self doUpdateCannedMessage:(id)entity inContext:localContext];
            }

            if (localError != nil) {
                break;
            }
        }

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            if (successBlock != nil) {

                NSMutableArray *updatedEntities =
                [NSMutableArray arrayWithCapacity:entities.count];

                for (NSManagedObject *entity in entities) {
                    NSManagedObject *updatedEntity =
                    [[self managedObjectContextForCurrentThread]
                     objectWithID:entity.objectID];
                    [updatedEntities addObject:updatedEntity];
                }

                successBlock(updatedEntities);
            }
        }
    }];
}

#pragma mark - Canned Messages

- (NSArray *)allCannedMessages {
    return
    [TCSCannedMessage
     MR_findByAttribute:@"pendingRemoteDelete"
     withValue:@NO
     andOrderBy:@"order"
     ascending:YES
     inContext:[self managedObjectContextForCurrentThread]];
}

- (TCSCannedMessage *)cannedMessageWithID:(NSManagedObjectID *)objectID {
    TCSCannedMessage *cannedMessage = (id)
    [[self managedObjectContextForCurrentThread]
     existingObjectWithID:objectID
     error:NULL];

    if (cannedMessage.pendingRemoteDeleteValue) {
        cannedMessage = nil;
    }

    return cannedMessage;
}

- (void)createCannedMessage:(NSString *)message
           providerInstance:(TCSProviderInstance *)providerInstance
                    success:(void(^)(TCSCannedMessage *cannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    __block TCSCannedMessage *cannedMessage = nil;
    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        NSPredicate *predicate =
        [NSPredicate predicateWithFormat:@"pendingRemoteDelete = 0"];

        TCSCannedMessage *lastCannedMessage =
        [TCSCannedMessage
         MR_findFirstWithPredicate:predicate
         sortedBy:@"order"
         ascending:NO
         inContext:localContext];

        NSInteger order = 0;

        if (lastCannedMessage != nil) {
            order = lastCannedMessage.orderValue + 1;
        }

        cannedMessage = [TCSCannedMessage MR_createInContext:localContext];
        cannedMessage.providerInstance = providerInstance;

        [cannedMessage
         updateWithMessage:message
         order:order
         entityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSCannedMessage *updatedCannedMessage = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:cannedMessage.objectID];
                
                successBlock(updatedCannedMessage);
            }
        }
    }];
}

- (void)reorderCannedMessage:(TCSCannedMessage *)cannedMessage
                       order:(NSInteger)order
                     success:(void(^)(void))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    NSInteger previousOrder = cannedMessage.orderValue;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        NSArray *orderedMessages =
        [TCSCannedMessage
         MR_findByAttribute:@"pendingRemoteDelete"
         withValue:@NO
         andOrderBy:@"order"
         ascending:YES
         inContext:localContext];

        TCSCannedMessage *localCannedMessage =
        (id)[localContext existingObjectWithID:cannedMessage.objectID error:&localError];

        for (TCSCannedMessage *message in orderedMessages) {
            if ([message.objectID isEqual:localCannedMessage.objectID]) {
                message.orderValue = order;
            } else if (message.orderValue >= previousOrder && message.orderValue <= order) {
                message.orderValue--;
            }
            [message markEntityAsUpdated];
        }

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

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

- (NSError *)doUpdateCannedMessage:(TCSCannedMessage *)cannedMessage
                 inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;

    TCSCannedMessage *localCannedMessage = (id)
    (id)[context existingObjectWithID:cannedMessage.objectID error:&error];

    [localCannedMessage
     updateWithMessage:cannedMessage.message
     order:cannedMessage.orderValue
     entityVersion:cannedMessage.entityVersionValue
     remoteId:cannedMessage.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    return error;
}

- (void)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(TCSCannedMessage *updatedCannedMessage))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        [self doUpdateCannedMessage:cannedMessage inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSCannedMessage *updatedCannedMessage = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:cannedMessage.objectID];

                successBlock(updatedCannedMessage);
            }
        }
    }];
}

- (void)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(void))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSCannedMessage *localCannedMessage = (id)
        (id)[localContext existingObjectWithID:cannedMessage.objectID error:NULL];

        if (localCannedMessage != nil) {
            [localCannedMessage markEntityAsDeleted];
        }

    } completion:^(BOOL success, NSError *error) {

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

#pragma mark - Provider Instance

- (NSArray *)allProviderInstances {
    return
    [TCSProviderInstance
     MR_findByAttribute:@"pendingRemoteDelete"
     withValue:@NO
     andOrderBy:@"name"
     ascending:YES
     inContext:[self managedObjectContextForCurrentThread]];
}

- (TCSProviderInstance *)providerInstanceWithID:(NSManagedObjectID *)objectID {
    TCSProviderInstance *remoteProvider = (id)
    [[self managedObjectContextForCurrentThread]
     existingObjectWithID:objectID
     error:NULL];

    if (remoteProvider.pendingRemoteDeleteValue) {
        remoteProvider = nil;
    }

    return remoteProvider;
}

- (void)createProviderInstance:(NSString *)name
                       baseURL:(NSString *)baseURL
                          type:(NSString *)type
                      username:(NSString *)username
                      password:(NSString *)password
                remoteProvider:(NSString *)remoteProvider
                       success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    if (_syncingRemoteProvider == nil) {
        NSLog(@"WARN : no syncing provider specified");
        return;

    }
    NSString *syncingProvider = NSStringFromClass(_syncingRemoteProvider.class);

    __block TCSProviderInstance *providerInstance = nil;
    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        providerInstance = [TCSProviderInstance MR_createInContext:localContext];
        providerInstance.remoteProvider = syncingProvider;

        [providerInstance
         updateWithName:name
         baseURL:baseURL
         type:type
         username:username
         password:password
         remoteProvider:remoteProvider
         userID:nil
         entityVersion:0
         remoteId:nil
         updateTime:[[TCSService sharedInstance] systemTime]
         markAsUpdated:YES];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSProviderInstance *updatedProviderInstance = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:providerInstance.objectID];
                
                successBlock(updatedProviderInstance);

                [self updateProviderInstanceUserIdIfNeeded:updatedProviderInstance];
            }
        }
    }];
}

- (void)updateProviderInstanceUserIdIfNeeded:(TCSProviderInstance *)providerInstance {

    id <TCSServiceRemoteProvider> remoteProvider =
    [self remoteProviderForInstance:providerInstance];

    if (remoteProvider != nil) {
        [remoteProvider
         updateProviderInstanceUserIdIfNeeded:providerInstance
         success:^(TCSProviderInstance *providerInstance) {

             if (providerInstance.userID != nil) {
                 [self
                  updateProviderInstance:providerInstance
                  success:nil
                  failure:^(NSError *error) {

                      if (error != nil) {
                          NSLog(@"Error: %@", error);
                      }
                  }];
             }

         } failure:^(NSError *error) {

             if (error != nil) {
                 NSLog(@"Error: %@", error);
             }
         }];

    } else {
        NSLog(@"WARN : no remote provider");
    }
}

- (NSError *)doUpdateProviderInstance:(TCSProviderInstance *)providerInstance
                            inContext:(NSManagedObjectContext *)context {

    NSError *error = nil;

    TCSProviderInstance *localProviderInstance = (id)
    (id)[context existingObjectWithID:providerInstance.objectID error:&error];

    [localProviderInstance
     updateWithName:providerInstance.name
     baseURL:providerInstance.baseURL
     type:providerInstance.type
     username:providerInstance.username
     password:providerInstance.password
     remoteProvider:providerInstance.remoteProvider
     userID:providerInstance.userID
     entityVersion:providerInstance.entityVersionValue
     remoteId:providerInstance.remoteId
     updateTime:[[TCSService sharedInstance] systemTime]
     markAsUpdated:YES];

    return error;
}

- (void)updateProviderInstance:(TCSProviderInstance *)providerInstance
                       success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        [self doUpdateProviderInstance:providerInstance inContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (localError != nil) {

            if (failureBlock != nil) {
                failureBlock(localError);
            }

        } else if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                TCSProviderInstance *updatedProviderInstance = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:providerInstance.objectID];

                successBlock(updatedProviderInstance);
            }
        }
    }];
}

- (void)deleteProviderInstance:(TCSProviderInstance *)providerInstance
                       success:(void(^)(void))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSProviderInstance *localProviderInstance = (id)
        (id)[localContext existingObjectWithID:providerInstance.objectID error:NULL];

        if (localProviderInstance != nil) {
            [localProviderInstance markEntityAsDeleted];
        }

    } completion:^(BOOL success, NSError *error) {

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

#pragma mark - Remote Handling

- (void)handleRemoteProviderSyncing:(NSTimer *)timer {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self handlePushingToRemoteProviders];
    });

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        NSLog(@"ZZZZ timers:");
//        NSArray *timers = [TCSTimer MR_findAll];
//        for (TCSTimer *timer in timers) {
//            NSLog(@"ZZZZ timer: %@", timer);
//        }
//    });
}

- (void)handlePushingToRemoteProviders {

    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"pending = 1"];

    NSArray *updates =
    [TCSBaseEntity
     MR_findAllWithPredicate:predicate
     inContext:[self managedObjectContextForCurrentThread]];

    if (updates.count > 0) {
        NSLog(@"updates: %@", updates);
    }

    @synchronized (self) {
        if (_savingUpdates) {
            return;
        }
    }

    NSMutableArray *createdEntities = [NSMutableArray array];

    for (TCSBaseEntity *entity in updates) {
        if (entity.remoteId == nil) {
            [createdEntities addObject:entity.objectID];
        }
    }

    _savingUpdates = updates.count > 0;

    NSMutableSet *remoteProviders = [NSMutableSet set];

    for (TCSBaseEntity *entity in updates) {

        id <TCSServiceRemoteProvider> remoteProvider =
        [self providerNameForInstance:entity.providerInstance];

        if (remoteProvider != nil) {

            [remoteProvider holdUpdates];

            [remoteProviders addObject:remoteProvider];

            if (entity.remoteId == nil) {

                [self
                 createRemoteEntity:entity
                 success:^(NSManagedObjectID *objectID, NSString *remoteID) {

                     NSAssert(NO, @"should not have saved yet");

                 } failure:^(NSError *error) {
                     NSLog(@"Error: %@", error);
                 }];

            } else if (entity.pendingRemoteDeleteValue) {

                if (entity.remoteId != nil) {

                    void (^executionBlock)(void) = ^{
                        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {

                            NSError *error = nil;

                            TCSBaseEntity *localEntity = (id)
                            [localContext existingObjectWithID:entity.objectID error:&error];

                            if (error != nil) {
                                NSLog(@"Error: %@", error);
                            } else {
                                [localEntity MR_deleteInContext:localContext];
                            }
                        }];
                    };

                    [self
                     deleteRemoteEntity:entity
                     success:^(NSManagedObjectID *objectID) {

                         executionBlock();

                     } failure:^(NSError *error) {
                         NSLog(@"Error: %@", error);

                         if ([error.domain isEqualToString:kTCErrorDomain]) {
                             if (error.code == TCErrorCodeRemoteObjectNotFound) {
                                 executionBlock();
                             }
                         }
                     }];
                }

            } else {

                [self
                 updateRemoteEntity:entity
                 success:^(NSManagedObjectID *objectID) {

                     NSAssert(NO, @"should not have saved yet");
                     
                 } failure:^(NSError *error) {
                     NSLog(@"Error: %@", error);
                 }];
            }
        }
    }

    if (remoteProviders.count > 0) {
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

        for (id <TCSServiceRemoteProvider> remoteProvider in remoteProviders) {

            dispatch_group_async(group, queue, ^{

                NSError *error;

                BOOL requestSent = NO;

                NSDictionary *remoteIDMap =
                [remoteProvider flushUpdates:&requestSent error:&error];

                if (requestSent) {

                    if (error != nil) {
                        NSLog(@"Error: %@", error);
                    } else {

                        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {

                            for (NSManagedObjectID *objectID in remoteIDMap) {

                                NSError *error = nil;

                                TCSBaseEntity *localEntity = (id)
                                [localContext existingObjectWithID:objectID error:&error];

                                if (error != nil) {
                                    NSLog(@"Error: %@", error);
                                } else {

                                    if (localEntity.pendingRemoteDeleteValue == NO ||
                                        [createdEntities containsObject:localEntity.objectID] == NO) {
                                        localEntity.pendingValue = NO;
                                    }
                                    
                                    localEntity.remoteId = remoteIDMap[objectID];
                                }
                            }
                            
                        }];
                    }
                }
            });
        }
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    }
    _savingUpdates = NO;
}

- (void)createRemoteEntity:(TCSBaseEntity *)entity
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    id <TCSServiceRemoteProvider> remoteProvider =
    [self remoteProviderForInstance:entity.providerInstance];

    [entity.class
     createRemoteObject:entity
     remoteProvider:remoteProvider
     success:^(NSManagedObjectID *objectID, NSString *remoteID) {

         NSLog(@"createdEntity: %@", entity);

         if (successBlock != nil) {
             successBlock(objectID, remoteID);
         }

     } failure:failureBlock];
}

- (void)updateRemoteEntity:(TCSBaseEntity *)entity
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    id <TCSServiceRemoteProvider> remoteProvider =
    [self remoteProviderForInstance:entity.providerInstance];

    [entity.class
     updateRemoteObject:entity
     remoteProvider:remoteProvider
     success:^(NSManagedObjectID *objectID) {

         NSLog(@"updatedEntity: %@", entity);

         if (successBlock != nil) {
             successBlock(objectID);
         }

     } failure:failureBlock];
}

- (void)deleteRemoteEntity:(TCSBaseEntity *)entity
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    id <TCSServiceRemoteProvider> remoteProvider =
    [self remoteProviderForInstance:entity.providerInstance];

    [entity.class
     deleteRemoteObject:entity
     remoteProvider:remoteProvider
     success:^(NSManagedObjectID *objectID) {

         NSLog(@"deletedEntity: %@", entity);

         [self
          sendDeleteObjectCommand:entity.remoteId
          withProvider:entity.providerInstance
          success:^{

              if (successBlock != nil) {
                  successBlock(objectID);
              }

          } failure:failureBlock];

     } failure:failureBlock];
}

#pragma mark - Remote Updates

- (void)handleUpdatedRemoteEntities:(NSNotification *)notification {
    
    NSString *providerName =
    notification.userInfo[kTCSLocalServiceRemoteProviderNameKey];

    NSArray *updatedEntities =
    notification.userInfo[kTCSLocalServiceUpdatedRemoteEntitiesKey];

    if (updatedEntities.count == 0) {
        [self.delegate remoteSyncCompleted];
        return;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        __block NSMutableDictionary *updates =
        [NSMutableDictionary dictionaryWithCapacity:3];

        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

            NSArray *sortedEntities =
            [updatedEntities
             sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

                 if ([obj1 conformsToProtocol:@protocol(TCSProvidedRemoteCommand)]) {
                     return NSOrderedAscending;
                 } else if ([obj1 conformsToProtocol:@protocol(TCSProvidedProviderInstance)]) {
                     return NSOrderedAscending;
                 } else if ([obj1 conformsToProtocol:@protocol(TCSProvidedGroup)]) {
                     return NSOrderedAscending;
                 } else if ([obj1 conformsToProtocol:@protocol(TCSProvidedProject)]) {
                     return NSOrderedAscending;
                 } else if ([obj1 conformsToProtocol:@protocol(TCSProvidedTimer)]) {
                     return NSOrderedAscending;
                 } else if ([obj1 conformsToProtocol:@protocol(TCSProvidedCannedMessage)]) {
                     return NSOrderedAscending;
                 }
                 return NSOrderedSame;
             }];

            NSMutableSet *remainingEntityIDs = [NSMutableSet set];
            for (id<TCSProvidedBaseEntity> obj in sortedEntities) {

                NSAssert([obj conformsToProtocol:@protocol(TCSProvidedBaseEntity)],
                         @"Entity doesn't conform to TCSProvidedBaseEntity");

                Class localType = obj.utsLocalEntityType;

                TCSBaseEntity *inserted = nil;
                TCSBaseEntity *updated = nil;
                NSArray *deleted = nil;
                TCSProviderInstance *providerInstance =
                [self providerInstanceWithID:obj.utsProviderInstanceID];

                if (localType == [TCSRemoteCommand class] && [obj conformsToProtocol:@protocol(TCSProvidedRemoteCommand)]) {
                    deleted =
                    [self
                     handleRemoteCommand:(id)obj
                     providerName:providerName
                     inContext:localContext];
                } else if (localType == [TCSProviderInstance class] && [obj conformsToProtocol:@protocol(TCSProvidedProviderInstance)]) {
                    [self
                     handleProviderInstanceUpdate:(id)obj
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                } else if (localType == [TCSGroup class] && [obj conformsToProtocol:@protocol(TCSProvidedGroup)]) {
                    [self
                     handleGroupUpdate:(id)obj
                     providerInstance:providerInstance
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                } else if (localType == [TCSProject class] && [obj conformsToProtocol:@protocol(TCSProvidedProject)]) {
                    [self
                     handleProjectUpdate:(id)obj
                     providerInstance:providerInstance
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                } else if (localType == [TCSTimer class] && [obj conformsToProtocol:@protocol(TCSProvidedTimer)]) {
                    [self
                     handlTimerUpdate:(id)obj
                     providerInstance:providerInstance
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                } else if (localType == [TCSCannedMessage class] && [obj conformsToProtocol:@protocol(TCSProvidedCannedMessage)]) {
                    [self
                     handleCannedMessageUpdate:(id)obj
                     providerInstance:providerInstance
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                } else if (localType == [TCSTimedEntityMetadata class] && [obj conformsToProtocol:@protocol(TCSProvidedTimedEntityMetadata)]) {
                    [self
                     handleTimedEntityMetadataUpdate:(id)obj
                     inserted:&inserted
                     updated:&updated
                     inContext:localContext];
                }

                if (inserted != nil) {
                    NSMutableArray *insertedObjects = updates[NSInsertedObjectsKey];
                    if (insertedObjects == nil) {
                        insertedObjects = [NSMutableArray array];
                        updates[NSInsertedObjectsKey] = insertedObjects;
                    }
                    [insertedObjects addObject:inserted];
                    [remainingEntityIDs addObject:inserted.objectID];
                }
                if (updated != nil) {
                    NSMutableArray *updatedObjects = updates[NSUpdatedObjectsKey];
                    if (updatedObjects == nil) {
                        updatedObjects = [NSMutableArray array];
                        updates[NSUpdatedObjectsKey] = updatedObjects;
                    }
                    [updatedObjects addObject:updated];
                    [remainingEntityIDs addObject:updated.objectID];
                }
                if (deleted != nil) {
                    NSMutableArray *deletedObjects = updates[NSDeletedObjectsKey];
                    if (deletedObjects == nil) {
                        deletedObjects = [NSMutableArray array];
                        updates[NSDeletedObjectsKey] = deletedObjects;
                    }
                    [deletedObjects addObjectsFromArray:deleted];
                }
            }

            id <TCSServiceRemoteProvider> remoteProvider =
            [[TCSService sharedInstance] serviceProviderNamed:providerName];

            if ([remoteProvider canCreateEntities] == NO) {

                for (TCSGroup *group in [self allGroupsInContext:localContext]) {

                    if ([providerName isEqual:group.providerInstance.remoteProvider]) {

                        if ([remainingEntityIDs containsObject:group.objectID] == NO) {
                            [group MR_deleteInContext:localContext];

                            NSMutableArray *deletedObjects = updates[NSDeletedObjectsKey];
                            if (deletedObjects == nil) {
                                deletedObjects = [NSMutableArray array];
                                updates[NSDeletedObjectsKey] = deletedObjects;
                            }
                            [deletedObjects addObjectsFromArray:group];
                        }
                    }
                }

                for (TCSProject *project in [self allProjectsInContext:localContext]) {

                    if ([providerName isEqual:project.providerInstance.remoteProvider]) {

                        if ([remainingEntityIDs containsObject:project.objectID] == NO) {
                            [project MR_deleteInContext:localContext];

                            NSMutableArray *deletedObjects = updates[NSDeletedObjectsKey];
                            if (deletedObjects == nil) {
                                deletedObjects = [NSMutableArray array];
                                updates[NSDeletedObjectsKey] = deletedObjects;
                            }
                            [deletedObjects addObject:project];
                        }
                    }
                }

                for (TCSTimer *timer in [self allTimersInContext:localContext]) {

                    if ([providerName isEqual:timer.providerInstance.remoteProvider]) {

                        if ([remainingEntityIDs containsObject:timer.objectID] == NO) {
                            [timer MR_deleteInContext:localContext];

                            NSMutableArray *deletedObjects = updates[NSDeletedObjectsKey];
                            if (deletedObjects == nil) {
                                deletedObjects = [NSMutableArray array];
                                updates[NSDeletedObjectsKey] = deletedObjects;
                            }
                            [deletedObjects addObject:timer];
                        }
                    }
                }
            }

        } completion:^(BOOL success, NSError *error) {

            if (error != nil) {
                NSLog(@"Error: %@", error);
            } else {
                if (updates.count > 0) {

                    NSArray *insertedObjects = updates[NSInsertedObjectsKey];
                    if (insertedObjects.count > 0) {
                        NSMutableArray *updatedInsertedObjects =
                        [NSMutableArray arrayWithCapacity:insertedObjects.count];

                        for (TCSBaseEntity *entity in insertedObjects) {

                            NSError *error = nil;

                            TCSBaseEntity *updatedEntity = (id)
                            [[NSManagedObjectContext MR_contextForCurrentThread]
                             existingObjectWithID:entity.objectID
                             error:&error];

                            if (error != nil) {
                                NSLog(@"Error: %@", error);
                            } else {
                                [updatedInsertedObjects addObject:updatedEntity];
                            }
                        }
                        updates[NSInsertedObjectsKey] = updatedInsertedObjects;
                    }

                    NSArray *updatedObjects = updates[NSUpdatedObjectsKey];
                    if (updatedObjects.count > 0) {
                        NSMutableArray *updatedUpdatedObjects =
                        [NSMutableArray arrayWithCapacity:updatedObjects.count];

                        for (TCSBaseEntity *entity in updatedObjects) {

                            NSError *error = nil;

                            TCSBaseEntity *updatedEntity = (id)
                            [[NSManagedObjectContext MR_contextForCurrentThread]
                             existingObjectWithID:entity.objectID
                             error:&error];

                            if (error != nil) {
                                NSLog(@"Error: %@", error);
                            } else {
                                [updatedUpdatedObjects addObject:updatedEntity];
                            }
                        }
                        updates[NSUpdatedObjectsKey] = updatedUpdatedObjects;
                    }

                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kTCSServicePrivateRemoteSyncCompletedNotification
                     object:self
                     userInfo:updates];

                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:kTCSLocalServiceRemoteSyncCompletedNotification
                     object:self
                     userInfo:updates];
                }
            }

            [self.delegate remoteSyncCompleted];
        }];
    });
}

- (NSArray *)handleRemoteCommand:(id <TCSProvidedRemoteCommand>)providedRemoteCommand
                    providerName:(NSString *)providerName
                       inContext:(NSManagedObjectContext *)context {

    NSAssert(providedRemoteCommand.utsRemoteID != nil, @"group remoteID is nil");

    NSArray *entities =
    [TCSRemoteCommand
     MR_findByAttribute:@"remoteId"
     withValue:providedRemoteCommand.utsRemoteID
     inContext:context];

    if (entities.count > 0) {
        NSLog(@"SYNC: Warn: remote command already exists with remoteID: %@",
              providedRemoteCommand.utsRemoteID);
    }

    TCSRemoteCommand *remoteCommand =
    [TCSRemoteCommand MR_createInContext:context];

    remoteCommand.typeValue = providedRemoteCommand.utsType;
    remoteCommand.payload = providedRemoteCommand.utsPayloadData;

    NSArray *deletedEntities = nil;

    switch (remoteCommand.typeValue) {
        case TCSRemoteCommandTypeDeleteObject:
            deletedEntities = [self handleDeleteObjectCommand:remoteCommand inContext:context];
            break;

        case TCSRemoteCommandTypeResetData:
            deletedEntities = [self handleResetDataCommand:remoteCommand inContext:context];

        default:
            [remoteCommand execute];
            break;
    }

    NSLog(@"SYNC: executed new remote command: %@", remoteCommand);

    return deletedEntities;
}

- (NSArray *)handleDeleteObjectCommand:(TCSRemoteCommand *)remoteCommand
                        inContext:(NSManagedObjectContext *)context {

    NSDictionary *payload = [remoteCommand payloadDictionary];

    NSString *remoteObjectId = payload[kTCSRemoteCommandObjectIdKey];
    
    NSArray *entities =
    [TCSBaseEntity
     MR_findByAttribute:@"remoteId"
     withValue:remoteObjectId
     inContext:context];

    for (NSManagedObject *entity in entities) {
        [entity MR_deleteInContext:context];
        remoteCommand.executedValue = YES;
    }

    return entities;
}

- (NSArray *)handleResetDataCommand:(TCSRemoteCommand *)remoteCommand
                     inContext:(NSManagedObjectContext *)context {
    remoteCommand.executedValue = YES;
    return nil;
}

- (void)handleGroupUpdate:(id <TCSProvidedGroup>)providedGroup
         providerInstance:(TCSProviderInstance *)providerInstance
                 inserted:(TCSBaseEntity **)inserted
                  updated:(TCSBaseEntity **)updated
                inContext:(NSManagedObjectContext *)context {

    NSAssert(providedGroup.utsRemoteID != nil, @"group remoteID is nil");

    NSArray *entities =
    [TCSGroup
     MR_findByAttribute:@"remoteId"
     withValue:providedGroup.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple groups exist with remoteID: %@",
              providedGroup.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSGroup *existingGroup = entities.firstObject;

    if (existingGroup != nil) {

        if (providedGroup.utsUpdateTime == nil ||
            existingGroup.updateTime == nil ||
            [providedGroup.utsUpdateTime isGreaterThan:existingGroup.updateTime]) {

            [existingGroup
             updateWithName:providedGroup.utsName
             entityVersion:providedGroup.utsEntityVersion
             remoteId:providedGroup.utsRemoteID
             updateTime:providedGroup.utsUpdateTime
             markAsUpdated:NO];

            *updated = existingGroup;

            NSLog(@"SYNC: updated existing group: %@", existingGroup);

        } else {
            NSLog(@"SYNC: group not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedGroup.utsEntityVersion, existingGroup);
        }

    } else {

        TCSGroup *group =
        [TCSGroup MR_createInContext:context];
        group.providerInstance = providerInstance;

        group.metadata = [TCSTimedEntityMetadata MR_createInContext:context];
        group.metadata.providerInstance = nil;
        [group.metadata markEntityAsUpdated];

        [group
         updateWithName:providedGroup.utsName
         entityVersion:providedGroup.utsEntityVersion
         remoteId:providedGroup.utsRemoteID
         updateTime:providedGroup.utsUpdateTime
         markAsUpdated:NO];

        *inserted = group;

        NSLog(@"SYNC: created new group: %@", group);
    }
}

- (void)handleProjectUpdate:(id <TCSProvidedProject>)providedProject
           providerInstance:(TCSProviderInstance *)providerInstance
                   inserted:(TCSBaseEntity **)inserted
                    updated:(TCSBaseEntity **)updated
                  inContext:(NSManagedObjectContext *)context {

    NSAssert(providedProject.utsRemoteID != nil, @"project remoteID is nil");

    NSArray *entities =
    [TCSProject
     MR_findByAttribute:@"remoteId"
     withValue:providedProject.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple projects exist with remoteID: %@",
          providedProject.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSProject *existingProject = entities.firstObject;

    TCSGroup *existingParent = nil;

    if (providedProject.utsParentID != nil) {

        entities =
        [TCSGroup
         MR_findByAttribute:@"remoteId"
         withValue:providedProject.utsParentID
         inContext:context];

        if (entities.count > 1) {
            NSLog(@"SYNC: Warn: multiple project.parents exist with remoteID: %@",
                  providedProject.utsParentID);
        }

        existingParent = entities.firstObject;
    }

    if (existingProject != nil) {

        if (providedProject.utsUpdateTime == nil ||
            existingProject.updateTime == nil ||
            [providedProject.utsUpdateTime isGreaterThan:existingProject.updateTime]) {

            [existingProject
             updateWithName:providedProject.utsName
             entityVersion:providedProject.utsEntityVersion
             remoteId:providedProject.utsRemoteID
             updateTime:providedProject.utsUpdateTime
             markAsUpdated:NO];

            existingProject.parent = existingParent;

            *updated = existingProject;

            NSLog(@"SYNC: updated existing project: %@", existingProject);
            
        } else {
            NSLog(@"SYNC: project not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedProject.utsEntityVersion, existingProject);
        }

    } else {

        id <TCSServiceRemoteProvider> remoteProvider =
        [self remoteProviderForInstance:providerInstance];

        TCSProject *project =
        [TCSProject MR_createInContext:context];
        project.providerInstance = providerInstance;

        project.metadata = [TCSTimedEntityMetadata MR_createInContext:context];
        project.metadata.providerInstance = nil;
        project.metadata.archivedValue = remoteProvider.importProjectsAsArchived;
        [project.metadata markEntityAsUpdated];

        [project
         updateWithName:providedProject.utsName
         entityVersion:providedProject.utsEntityVersion
         remoteId:providedProject.utsRemoteID
         updateTime:providedProject.utsUpdateTime
         markAsUpdated:NO];

        project.parent = existingParent;

        *inserted = project;
        
        NSLog(@"SYNC: created new project: %@", project);
    }
}

- (void)handlTimerUpdate:(id <TCSProvidedTimer>)providedTimer
        providerInstance:(TCSProviderInstance *)providerInstance
                inserted:(TCSBaseEntity **)inserted
                 updated:(TCSBaseEntity **)updated
               inContext:(NSManagedObjectContext *)context {

    NSAssert(providedTimer.utsRemoteID != nil, @"timer remoteID is nil");

    if (providedTimer.utsStartTime == nil) {
        NSLog(@"WARN : provided start time is missing: %@");
        return;
    }

    NSArray *entities =
    [TCSTimer
     MR_findByAttribute:@"remoteId"
     withValue:providedTimer.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple timers exist with remoteID: %@",
              providedTimer.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSTimer *existingTimer = entities.firstObject;

    TCSProject *existingProject = nil;

    if (providedTimer.utsProjectID != nil) {

        id <TCSServiceRemoteProvider> remoteProvider =
        [self remoteProviderForInstance:providerInstance];

        NSString *projectIDSeparator = [remoteProvider timerProjectIDSeparator];

        if (projectIDSeparator == nil) {

            entities =
            [TCSProject
             MR_findByAttribute:@"remoteId"
             withValue:providedTimer.utsProjectID
             inContext:context];

        } else {

            NSArray *idComponents =
            [providedTimer.utsProjectID
             componentsSeparatedByString:projectIDSeparator];

            if (idComponents.count == 2) {
                NSString *groupID = idComponents[0];
                NSString *projectID = idComponents[1];

                NSPredicate *predicate =
                [NSPredicate
                 predicateWithFormat:@"remoteId = %@ and parent.remoteId = %@",
                 projectID, groupID];

                NSLog(@"predicate: %@", predicate);

                entities =
                [TCSProject
                 MR_findAllWithPredicate:predicate inContext:context];
            } else {
                NSLog(@"WARN : utsProjectID '%@' not separated by %@ char",
                      providedTimer.utsProjectID, projectIDSeparator);
            }
        }

        if (entities.count > 1) {
            NSLog(@"SYNC: Warn: multiple timer.projects exist with remoteID: %@",
                  providedTimer.utsProjectID);
        }

        existingProject = entities.firstObject;
    }

    if (existingProject == nil) {
        NSLog(@"SYNC: Missing timer project!!! providerTimer: %@", providedTimer);
        [existingTimer markEntityAsDeleted];
        return;
    }

    if (existingTimer != nil) {

        if (providedTimer.utsUpdateTime == nil ||
            existingTimer.updateTime == nil ||
            [providedTimer.utsUpdateTime isGreaterThan:existingTimer.updateTime]) {

            [existingTimer
             updateWithStartTime:providedTimer.utsStartTime
             endTime:providedTimer.utsEndTime
             adjustment:providedTimer.utsAdjustment
             message:providedTimer.utsMessage
             entityVersion:providedTimer.utsEntityVersion
             remoteId:providedTimer.utsRemoteID
             updateTime:providedTimer.utsUpdateTime
             markAsUpdated:NO];

            existingTimer.project = existingProject;

            *updated = existingTimer;

            NSLog(@"SYNC: updated existing timer: %@", existingTimer);

        } else {
            NSLog(@"SYNC: timer not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedTimer.utsEntityVersion, existingTimer);
        }

    } else {

        TCSTimer *timer =
        [TCSTimer MR_createInContext:context];
        timer.providerInstance = providerInstance;

        [timer
         updateWithStartTime:providedTimer.utsStartTime
         endTime:providedTimer.utsEndTime
         adjustment:providedTimer.utsAdjustment
         message:providedTimer.utsMessage
         entityVersion:providedTimer.utsEntityVersion
         remoteId:providedTimer.utsRemoteID
         updateTime:providedTimer.utsUpdateTime
         markAsUpdated:NO];

        timer.project = existingProject;

        *inserted = timer;

        NSLog(@"SYNC: created new timer: %@", timer);
    }
}

- (void)handleCannedMessageUpdate:(id <TCSProvidedCannedMessage>)providedCannedMessage
                 providerInstance:(TCSProviderInstance *)providerInstance
                         inserted:(TCSBaseEntity **)inserted
                          updated:(TCSBaseEntity **)updated
                        inContext:(NSManagedObjectContext *)context {

    NSAssert(providedCannedMessage.utsRemoteID != nil, @"cannedMessage remoteID is nil");

    NSArray *entities =
    [TCSCannedMessage
     MR_findByAttribute:@"remoteId"
     withValue:providedCannedMessage.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple cannedMessages exist with remoteID: %@",
              providedCannedMessage.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSCannedMessage *existingCannedMessage = entities.firstObject;

    if (existingCannedMessage != nil) {

        if (providedCannedMessage.utsUpdateTime == nil ||
            existingCannedMessage.updateTime == nil ||
            [providedCannedMessage.utsUpdateTime isGreaterThan:existingCannedMessage.updateTime]) {

            [existingCannedMessage
             updateWithMessage:providedCannedMessage.utsMessage
             order:providedCannedMessage.utsOrder
             entityVersion:providedCannedMessage.utsEntityVersion
             remoteId:providedCannedMessage.utsRemoteID
             updateTime:providedCannedMessage.utsUpdateTime
             markAsUpdated:NO];

            *updated = existingCannedMessage;

            NSLog(@"SYNC: updated existing cannedMessage: %@", existingCannedMessage);

        } else {
            NSLog(@"SYNC: cannedMessage not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedCannedMessage.utsEntityVersion, existingCannedMessage);
        }

    } else {

        TCSCannedMessage *cannedMessage =
        [TCSCannedMessage MR_createInContext:context];
        cannedMessage.providerInstance = providerInstance;

        [cannedMessage
         updateWithMessage:providedCannedMessage.utsMessage
         order:providedCannedMessage.utsOrder
         entityVersion:providedCannedMessage.utsEntityVersion
         remoteId:providedCannedMessage.utsRemoteID
         updateTime:providedCannedMessage.utsUpdateTime
         markAsUpdated:NO];

        *inserted = cannedMessage;
        
        NSLog(@"SYNC: created new canned message: %@", cannedMessage);
    }
}

- (void)handleTimedEntityMetadataUpdate:(id <TCSProvidedTimedEntityMetadata>)providedTimedEntityMetadata
                               inserted:(TCSBaseEntity **)inserted
                                updated:(TCSBaseEntity **)updated
                              inContext:(NSManagedObjectContext *)context {

    NSAssert(providedTimedEntityMetadata.utsRemoteID != nil, @"timedEntityMetadata remoteID is nil");

    NSArray *entities =
    [TCSTimedEntityMetadata
     MR_findByAttribute:@"remoteId"
     withValue:providedTimedEntityMetadata.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple timedEntityMetadata exist with remoteID: %@",
              providedTimedEntityMetadata.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSTimedEntityMetadata *existingTimedEntityMetadata = entities.firstObject;

    if (existingTimedEntityMetadata != nil) {

        if (providedTimedEntityMetadata.utsUpdateTime == nil ||
            existingTimedEntityMetadata.updateTime == nil ||
            [providedTimedEntityMetadata.utsUpdateTime isGreaterThan:existingTimedEntityMetadata.updateTime]) {

            [existingTimedEntityMetadata
             updateWithColor:providedTimedEntityMetadata.utsColor
             archived:providedTimedEntityMetadata.utsArchived
             filteredModifiers:providedTimedEntityMetadata.utsFilteredModifiers
             keyCode:providedTimedEntityMetadata.utsKeyCode
             modifiers:providedTimedEntityMetadata.utsModifiers
             order:providedTimedEntityMetadata.utsOrder
             entityVersion:providedTimedEntityMetadata.utsEntityVersion
             remoteId:providedTimedEntityMetadata.utsRemoteID
             updateTime:providedTimedEntityMetadata.utsUpdateTime
             markAsUpdated:NO];

            *updated = existingTimedEntityMetadata;

            NSLog(@"SYNC: updated existing timedEntityMetadata: %@", existingTimedEntityMetadata);

        } else {
            NSLog(@"SYNC: timedEntityMetadata not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedTimedEntityMetadata.utsEntityVersion, existingTimedEntityMetadata);
        }

    } else {

        TCSTimedEntityMetadata *timedEntityMetadata =
        [TCSTimedEntityMetadata MR_createInContext:context];
        timedEntityMetadata.providerInstance = nil;

        [timedEntityMetadata
         updateWithColor:providedTimedEntityMetadata.utsColor
         archived:providedTimedEntityMetadata.utsArchived
         filteredModifiers:providedTimedEntityMetadata.utsFilteredModifiers
         keyCode:providedTimedEntityMetadata.utsKeyCode
         modifiers:providedTimedEntityMetadata.utsModifiers
         order:providedTimedEntityMetadata.utsOrder
         entityVersion:providedTimedEntityMetadata.utsEntityVersion
         remoteId:providedTimedEntityMetadata.utsRemoteID
         updateTime:providedTimedEntityMetadata.utsUpdateTime
         markAsUpdated:NO];

        *inserted = timedEntityMetadata;

        NSLog(@"SYNC: created new timedEntityMetadata: %@", timedEntityMetadata);
    }
}

- (void)handleProviderInstanceUpdate:(id <TCSProvidedProviderInstance>)providedProviderInstance
                            inserted:(TCSBaseEntity **)inserted
                             updated:(TCSBaseEntity **)updated
                           inContext:(NSManagedObjectContext *)context {

    NSAssert(providedProviderInstance.utsRemoteID != nil, @"remoteProvider remoteID is nil");

    NSArray *entities =
    [TCSProviderInstance
     MR_findByAttribute:@"remoteId"
     withValue:providedProviderInstance.utsRemoteID
     inContext:context];

    if (entities.count > 1) {
        NSLog(@"SYNC: Warn: multiple remoteProvider objects exist with remoteID: %@",
              providedProviderInstance.utsRemoteID);
    }

    *inserted = nil;
    *updated = nil;

    TCSProviderInstance *existingProviderInstance = entities.firstObject;

    if (existingProviderInstance != nil) {

        if (providedProviderInstance.utsUpdateTime == nil ||
            existingProviderInstance.updateTime == nil ||
            [providedProviderInstance.utsUpdateTime isGreaterThan:existingProviderInstance.updateTime]) {

            [existingProviderInstance
             updateWithName:providedProviderInstance.utsName
             baseURL:providedProviderInstance.utsBaseURL
             type:providedProviderInstance.utsType
             username:providedProviderInstance.utsUsername
             password:providedProviderInstance.utsPassword
             remoteProvider:providedProviderInstance.utsRemoteProvider
             userID:providedProviderInstance.utsUserID
             entityVersion:providedProviderInstance.utsEntityVersion
             remoteId:providedProviderInstance.utsRemoteID
             updateTime:providedProviderInstance.utsUpdateTime
             markAsUpdated:NO];

            *updated = existingProviderInstance;

            NSLog(@"SYNC: updated existing remoteProvider: %@", existingProviderInstance);

        } else {
            NSLog(@"SYNC: cannedMessage not updated because it has a entityVersion greater than or equal to (%d): %@",
                  providedProviderInstance.utsEntityVersion, existingProviderInstance);
        }

    } else {

        TCSProviderInstance *providerInstance =
        [TCSProviderInstance MR_createInContext:context];
        providerInstance.providerInstance = nil;

        [providerInstance
         updateWithName:providedProviderInstance.utsName
         baseURL:providedProviderInstance.utsBaseURL
         type:providedProviderInstance.utsType
         username:providedProviderInstance.utsUsername
         password:providedProviderInstance.utsPassword
         remoteProvider:providedProviderInstance.utsRemoteProvider
         userID:providedProviderInstance.utsUserID
         entityVersion:providedProviderInstance.utsEntityVersion
         remoteId:providedProviderInstance.utsRemoteID
         updateTime:providedProviderInstance.utsUpdateTime
         markAsUpdated:NO];

        *inserted = providerInstance;
        
        NSLog(@"SYNC: created new remoteProvider: %@", providerInstance);
    }
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static TCSLocalService *sharedInstance_ = nil;

+ (id)sharedInstance {

    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSLocalService alloc];
        sharedInstance_ = [sharedInstance_ init];
    });

    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
