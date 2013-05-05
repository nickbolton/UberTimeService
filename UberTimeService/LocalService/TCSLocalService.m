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

@interface TCSLocalService()

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
    }
    return self;
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

- (void)clearCache {
}

#pragma mark - Entity Primitives

- (BOOL)entityBoolValue:(id)entity forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSNumber *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    return value.boolValue;
}

- (NSInteger)entityIntegerValue:(id)entity forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSNumber *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    return value.integerValue;
}

- (CGFloat)entityFloatValue:(id)entity forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSNumber *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    return value.floatValue;
}

- (NSString *)entityStringValue:(id)entity forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSString *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    return value;
}

- (NSDate *)entityDateValue:(id)entity forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSDate *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    return value;
}

- (void)setEntity:(id)entity boolValue:(BOOL)value forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:@(value) forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity integerValue:(NSInteger)value forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:@(value) forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity floatValue:(CGFloat)value forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:@(value) forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity stringValue:(NSString *)value forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:value forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity dateValue:(NSDate *)value forKey:(NSString *)key {

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:value forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (id)entityIDForEntity:(id)entity {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;
    return managedObject.objectID;
}

- (TCSBaseEntity *)relation:(id)entity forKey:(NSString *)key andType:(Class)type error:(NSError **)error {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSManagedObject *value = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    TCSBaseEntity *wrappedEntity =
    [self wrapProviderEntity:value inType:type provider:self];

    return wrappedEntity;
}

- (void)setEntity:(id)entity relation:(id)relation forKey:(NSString *)key {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");
    NSAssert([relation isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:relation forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (NSArray *)toManyRelation:(id)entity forKey:(NSString *)key andType:(Class)type error:(NSError **)error {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    [managedObject willAccessValueForKey:key];
    NSSet *values = [managedObject valueForKey:key];
    [managedObject didAccessValueForKey:key];

    NSMutableArray *wrappedValues = [NSMutableArray array];

    for (NSManagedObject *child in values) {
        TCSBaseEntity *wrappedEntity =
        [self wrapProviderEntity:child inType:type provider:self];
        [wrappedValues addObject:wrappedEntity];
    }

    return wrappedValues;
}

- (void)setEntity:(id)entity toManyRelation:(NSArray *)entities forKey:(NSString *)key {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    NSMutableOrderedSet *values = [NSMutableOrderedSet orderedSetWithCapacity:entities.count];
    [values addObjectsFromArray:entities];

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:values forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity addParentRelation:(id)relation forKey:(NSString *)key {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setValue:relation forKey:key];
    [managedObject didChangeValueForKey:key];
}

- (void)setEntity:(id)entity removeParentRelationForKey:(NSString *)key {

    NSAssert([entity isKindOfClass:[NSManagedObject class]], @"Not an NSManagedObject class");

    NSManagedObject *managedObject = entity;

    [managedObject willChangeValueForKey:key];
    [managedObject setNilValueForKey:key];
    [managedObject didChangeValueForKey:key];
}

- (id)localServiceEntityFromWrapper:(TCSBaseEntity *)entity
                          inContext:(NSManagedObjectContext *)context {

    if (entity != nil) {
        NSManagedObject *providerEntity = entity.providerEntity;

        if (context == nil) {
            context = [self managedObjectContextForCurrentThread];
        }

        return
        [context
         existingObjectWithID:providerEntity.objectID
         error:NULL];
    }
    return nil;
}

- (void)updateWrappedEntityProviderInfo:(TCSBaseEntity *)wrappedEntity {

    if (wrappedEntity != nil) {
        NSManagedObject *managedObject = wrappedEntity.providerEntity;

        managedObject = (id)
        [[self managedObjectContextForCurrentThread]
         objectWithID:managedObject.objectID];

        wrappedEntity.providerEntity = managedObject;
    }
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    [self resetCoreDataStack];
    if (successBlock != nil) {
        successBlock();
    }
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

- (TCSLocalProject *)doCreateProjectWithName:(NSString *)name
                           filteredModifiers:(NSInteger)filteredModifiers
                                     keyCode:(NSInteger)keyCode
                                   modifiers:(NSInteger)modifiers
                                   inContext:(NSManagedObjectContext *)context {

    TCSLocalProject *localProject =
    [TCSLocalProject MR_createInContext:context];

    localProject.name = name;
    localProject.filteredModifiersValue = filteredModifiers;
    localProject.keyCodeValue = keyCode;
    localProject.modifiersValue = modifiers;

    return localProject;
}

- (void)createProjectWithName:(NSString *)name
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

    __block TCSLocalProject *localProject = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        localProject =
        [self
         doCreateProjectWithName:name
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

                localProject = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:localProject.objectID];

                TCSProject *project = (id)
                [self
                 wrapProviderEntity:localProject
                 inType:[TCSProject class]
                 provider:self];

                successBlock(project);
            }
        }
    }];
}

- (void)updateProject:(TCSProject *)project
               success:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock {

    NSAssert(project.serviceProvider == self, @"wrong service provider");

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localProject = (id)
        [self localServiceEntityFromWrapper:project inContext:localContext];

        if (localProject != nil) {
            localProject.name = project.name;
            localProject.colorValue = project.color;
            localProject.filteredModifiersValue = project.filteredModifiers;
            localProject.keyCodeValue = project.keyCode;
            localProject.modifiersValue = project.modifiers;
            localProject.orderValue = project.order;
            localProject.archivedValue = project.isArchived;
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

            [self updateWrappedEntityProviderInfo:project];

            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    NSAssert(project.serviceProvider == self, @"wrong service provider");

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localProject = (id)
        [self localServiceEntityFromWrapper:project inContext:localContext];

        if (localProject != nil) {
            [localProject MR_deleteInContext:localContext];
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

- (void)fetchProjectWithName:(NSString *)name
                     success:(void(^)(NSArray *projects))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        NSArray *localProjects =
        [TCSLocalProject
         MR_findByAttribute:@"name"
         withValue:name
         inContext:[self managedObjectContextForCurrentThread]];

        NSArray *result =
        [self
         wrapProviderEntities:localProjects
         inType:[TCSProject class]
         provider:self];

        successBlock(result);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchProjectWithID:(id)entityID
                   success:(void(^)(TCSProject *project))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        TCSLocalProject *localProject = (id)
        [[self managedObjectContextForCurrentThread]
         existingObjectWithID:entityID
         error:NULL];

        TCSProject *project = nil;

        if (localProject != nil) {
            project = (id)
            [self
             wrapProviderEntity:localProject
             inType:[TCSProject class]
             provider:self];
        }

        successBlock(project);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchProjects:(void(^)(NSArray *projects))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {
        
        NSArray *localProjects =
        [TCSLocalProject
         MR_findAllInContext:[self managedObjectContextForCurrentThread]];

        NSArray *result =
        [self
         wrapProviderEntities:localProjects
         inType:[TCSProject class]
         provider:self];

        successBlock(result);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

#pragma mark - Group Methods

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(group.serviceProvider == self, @"wrong service provider");

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalGroup *localGroup = (id)
        [self localServiceEntityFromWrapper:group inContext:localContext];

        if (localGroup != nil) {
            localGroup.name = group.name;
            localGroup.colorValue = group.color;
            localGroup.archivedValue = group.isArchived;
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

            [self updateWrappedEntityProviderInfo:group];
            
            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(group.serviceProvider == self, @"wrong service provider");

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localGroup = (id)
        [self localServiceEntityFromWrapper:group inContext:localContext];

        if (localGroup != nil) {
            [localGroup MR_deleteInContext:localContext];
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

- (void)fetchGroupWithID:(id)entityID
                 success:(void(^)(TCSGroup *group))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        TCSLocalGroup *localGroup = (id)
        [[self managedObjectContextForCurrentThread]
         existingObjectWithID:entityID
         error:NULL];

        TCSGroup *group = nil;

        if (localGroup != nil) {
            group = (id)
            [self
             wrapProviderEntity:localGroup
             inType:[TCSGroup class]
             provider:self];
        }

        successBlock(group);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchGroups:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        NSArray *localGroups =
        [TCSLocalGroup
         MR_findAllInContext:[self managedObjectContextForCurrentThread]];

        NSArray *result =
        [self
         wrapProviderEntities:localGroups
         inType:[TCSGroup class]
         provider:self];

        successBlock(result);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    __block TCSLocalGroup *localGroup = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localSourceProject = (id)
        [self localServiceEntityFromWrapper:sourceProject inContext:localContext];

        TCSLocalProject *localToProject = (id)
        [self localServiceEntityFromWrapper:toProject inContext:localContext];

        TCSLocalGroup *localGroupTarget =
        localToProject.parent.parent;

        localGroup = [TCSLocalGroup MR_createInContext:localContext];

        [localGroupTarget addChildrenObject:localGroup];

        localGroup.name = toProject.name;

        [self
         doMoveProject:localSourceProject
         toGroup:localGroup
         inContext:localContext];

        [localToProject MR_deleteInContext:localContext];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            toProject.providerEntity = nil;
            toProject.providerEntityID = nil;

            [self updateWrappedEntityProviderInfo:sourceProject];

            if (successBlock != nil) {

                localGroup = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:localGroup.objectID];

                TCSGroup *group = (id)
                [self
                 wrapProviderEntity:localGroup
                 inType:[TCSGroup class]
                 provider:self];

                successBlock(group);
            }
        }
    }];
}

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localSourceProject = (id)
        [self localServiceEntityFromWrapper:sourceProject inContext:localContext];

        TCSLocalGroup *localGroup = (id)
        [self localServiceEntityFromWrapper:group inContext:localContext];

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

            [self updateWrappedEntityProviderInfo:sourceProject];
            [self updateWrappedEntityProviderInfo:group];

            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)doMoveProject:(TCSLocalProject *)project
              toGroup:(TCSLocalGroup *)group
            inContext:(NSManagedObjectContext *)context {

    TCSLocalGroup *parent = project.parent;

    [parent removeChildrenObject:project];

    if (group != nil) {
        [group addChildrenObject:project];
    } else {
        project.parent = nil;
    }

    if (parent != nil && [parent.children count] == 0) {
        // demote to a project

        TCSLocalProject *demotedProject =
        [self
         doCreateProjectWithName:parent.name
         filteredModifiers:0
         keyCode:0
         modifiers:0
         inContext:context];
        
        demotedProject.archived = parent.archived;
        [parent.parent addChildrenObject:demotedProject];
        [parent.parent removeChildrenObject:parent];

        [parent MR_deleteInContext:context];
    }
}

#pragma mark - Timer Methods

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer))successBlock
                     failure:(void(^)(NSError *error))failureBlock {

    NSAssert(project.serviceProvider == self, @"wrong service provider");

    __block TCSLocalTimer *localTimer = nil;
    __block TCSLocalProject *localProject = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        localProject = (id)
        [localContext objectWithID:project.providerEntityID];
        
        localTimer = [TCSLocalTimer MR_createInContext:localContext];
        localTimer.startTime = [NSDate date];
        localTimer.project = localProject;

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }

        } else {

            if (successBlock != nil) {

                [self updateWrappedEntityProviderInfo:project];

                localTimer = (id)
                [[self managedObjectContextForCurrentThread]
                 objectWithID:localTimer.objectID];

                TCSTimer *timer = (id)
                [self
                 wrapProviderEntity:localTimer
                 inType:[TCSTimer class]
                 provider:self];
                
                successBlock(timer);
            }
        }
    }];
}

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(timer.serviceProvider == self, @"wrong service provider");

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalTimer *localTimer = (id)
        [self localServiceEntityFromWrapper:timer inContext:localContext];

        if (localTimer != nil) {
            localTimer.endTime = [NSDate date];
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

            [self updateWrappedEntityProviderInfo:timer];

            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(timer.serviceProvider == self, @"wrong service provider");

    __block NSError *localError = nil;

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalTimer *localTimer = (id)
        [self localServiceEntityFromWrapper:timer inContext:localContext];

        if (localTimer != nil) {
            localTimer.message = timer.message;
            localTimer.adjustmentValue = timer.adjustment;
            if (timer.endTime != nil && localTimer.endTime != nil) {
                localTimer.endTime = timer.endTime;
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

            [self updateWrappedEntityProviderInfo:timer];

            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(project.serviceProvider == self, @"wrong service provider");

    TCSProject *sourceProject = timer.project;
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        NSManagedObject *providerEntity = timer.providerEntity;

        NSError *error = nil;

        TCSLocalTimer *localTimer = (id)
        [localContext
         existingObjectWithID:providerEntity.objectID
         error:&error];

        if (error != nil) {
            if (failureBlock != nil) {
                failureBlock(error);
                return;
            }
        }

        NSAssert(localTimer != nil, @"localTimer is null");

        error = nil;
        providerEntity = project.providerEntity;

        TCSLocalProject *localProject = (id)
        [localContext
         existingObjectWithID:providerEntity.objectID
         error:&error];

        if (error != nil) {
            if (failureBlock != nil) {
                failureBlock(error);
                return;
            }
        }

        NSAssert(localProject != nil, @"localProject is null");

        localTimer.project = localProject;

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            [self updateWrappedEntityProviderInfo:timer];

            [self updateWrappedEntityProviderInfo:sourceProject];

            [self updateWrappedEntityProviderInfo:project];

            if (successBlock != nil) {
                successBlock();
            }
        }
    }];
}

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock {

    NSAssert(timer.serviceProvider == self, @"wrong service provider");

    __block NSMutableArray *rolledTimers = [NSMutableArray array];

    [rolledTimers addObject:timer];

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalProject *localProject = (id)
        [localContext
         existingObjectWithID:timer.project.providerEntityID
         error:NULL];

        TCSTimer *rollingTimer = timer;

        while (localProject != nil && rollingTimer != nil && rollingTimer.combinedTime > maxDuration) {

            NSDate *endDate =
            [rollingTimer.startTime dateByAddingTimeInterval:maxDuration];

            rollingTimer =
            [self
             doRolloverActiveTimer:rollingTimer
             localProject:localProject
             endDate:endDate];
            
            [rolledTimers addObject:rollingTimer];
        }

        NSMutableArray *temporaryObjects = [NSMutableArray array];
        NSMutableArray *temporaryLocalObjects = [NSMutableArray array];

        for (TCSTimer *t in rolledTimers) {
            TCSLocalTimer *lt = t.providerEntity;

            if (lt.objectID.isTemporaryID) {
                [temporaryLocalObjects addObject:lt];
                [temporaryObjects addObject:t];
            }
        }

        [localContext
         obtainPermanentIDsForObjects:temporaryLocalObjects
         error:NULL];

        [temporaryObjects
         enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

             TCSTimer *t = obj;
             TCSLocalTimer *lt = temporaryLocalObjects[idx];
             t.providerEntity = lt;
             t.providerEntityID = lt.objectID;
         }];

    } completion:^(BOOL success, NSError *error) {

        if (error != nil) {

            if (failureBlock != nil) {
                failureBlock(error);
            }
        } else {

            NSManagedObjectContext *moc =
            [self managedObjectContextForCurrentThread];

            for (TCSTimer *t in rolledTimers) {
                t.providerEntity =
                [moc existingObjectWithID:t.providerEntityID error:NULL];
            }

            if (successBlock != nil) {
                successBlock(rolledTimers);
            }
        }
    }];
}

- (TCSTimer *)doRolloverActiveTimer:(TCSTimer *)timer
                       localProject:(TCSLocalProject *)localProject
                            endDate:(NSDate *)endDate {

    TCSLocalTimer *localTimer = timer.providerEntity;

    localTimer = (id)
    [localProject.managedObjectContext
     existingObjectWithID:localTimer.objectID
     error:NULL];

    NSDate *finalEndTime = localTimer.endTime;

    if (endDate == nil || [endDate isLessThan:timer.startTime]) {
        localTimer.endTime = [NSDate date];
    } else {
        localTimer.endTime = endDate;
    }

    timer.providerEntity = localTimer;

    TCSLocalTimer *rolledTimer =
    [TCSLocalTimer MR_createInContext:localProject.managedObjectContext];
    rolledTimer.startTime = localTimer.endTime;
    rolledTimer.endTime = finalEndTime;
    rolledTimer.project = localProject;
    rolledTimer.message = localTimer.message;

    [localProject addTimersObject:rolledTimer];

    TCSTimer *result = (id)
    [self
     wrapProviderEntity:rolledTimer
     inType:[TCSTimer class]
     provider:self];

    return result;
}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSAssert(timer.serviceProvider == self, @"wrong service provider");

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {

        TCSLocalTimer *localTimer = (id)
        [self localServiceEntityFromWrapper:timer inContext:localContext];

        if (localTimer != nil) {
            [localTimer MR_deleteInContext:localContext];
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

- (void)fetchTimerWithID:(id)entityID
                 success:(void(^)(TCSTimer *timer))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        TCSLocalTimer *localTimer = (id)
        [[self managedObjectContextForCurrentThread]
         existingObjectWithID:entityID
         error:NULL];

        TCSTimer *wrappedTimer = (id)
        [self wrapProviderEntity:localTimer inType:[TCSTimer class] provider:self];

        successBlock(wrappedTimer);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchTimersForProjects:(NSArray *)timedEntities
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                           now:(NSDate *)now
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        NSPredicate * predicate =
        [NSPredicate predicateWithFormat:
         @"((project in %@) or (project.parent in %@)) and ((startTime <= %@ and endTime >= %@) or (endTime = nil and startTime <= %@ and %@ <= %@))",
         timedEntities, timedEntities, toDate, fromDate, now, fromDate, now];

        NSArray *timers =
        [TCSLocalTimer
         MR_findAllWithPredicate:predicate
         inContext:[self managedObjectContextForCurrentThread]];

        NSArray *wrappedResult =
        [self
         wrapProviderEntities:timers
         inType:[TCSTimer class]
         provider:self];

        successBlock(wrappedResult);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
    }
}

- (void)fetchTimers:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {

        NSArray *timers =
        [TCSLocalTimer
         MR_findAllInContext:[self managedObjectContextForCurrentThread]];

        NSArray *wrappedResult =
        [self
         wrapProviderEntities:timers
         inType:[TCSTimer class]
         provider:self];

        successBlock(wrappedResult);
    } else {
        NSLog(@"%s - Warning: called fetch method with no successBlock", __PRETTY_FUNCTION__);
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
