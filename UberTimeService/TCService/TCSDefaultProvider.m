//
//  TCSDefaultProvider.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSDefaultProvider.h"
#import "TCSService.h"
#import "TCSServicePrivate.h"

@interface TCSDefaultProvider() {
}

@end

@implementation TCSDefaultProvider

- (NSString *)safeRemoteID:(id)remoteID {
    if ([remoteID isKindOfClass:[NSNumber class]]) {
        remoteID = [(NSNumber *)remoteID stringValue];
    } else if ([remoteID isKindOfClass:[NSString class]] == NO) {
        remoteID = [remoteID description];
    }

    if (remoteID == nil) {
        remoteID = [NSNull null];
    }
    
    return remoteID;
}

#pragma mark - User Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        successBlock();
    }
}

- (void)logoutUser:(void(^)(void))successBlock
           failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        successBlock();
    }
}

- (void)syncRemoteProvider:(void(^)(void))successBlock
                   failure:(void(^)(NSError *error))failureBlock {
    
}

- (BOOL)canCreateEntities {
    return NO;
}

- (BOOL)isUserAuthenticated:(TCSProviderInstance *)providerInstances {
    return NO;
}

- (BOOL)importProjectsAsArchived {
    return NO;
}

- (NSString *)timerProjectIDSeparator {
    return nil;
}

- (void)holdUpdates {
    self.holdingUpdates = YES;
}

- (void)updateProviderInstanceUserIdIfNeeded:(TCSProviderInstance *)providerInstance
                                       force:(BOOL)force
                                     success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                                     failure:(void(^)(NSError *error))failureBlock {
}

// Project

- (BOOL)createProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)updateProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)deleteProject:(TCSProject *)project
              success:(void(^)(NSManagedObjectID *objectID))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

// Group

- (BOOL)createGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)updateGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)deleteGroup:(TCSGroup *)group
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

// Timer

- (BOOL)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)deleteTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

// Canned Message

- (BOOL)createCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)updateCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {

    return NO;
}

- (BOOL)deleteCannedMessage:(TCSCannedMessage *)cannedMessage
                    success:(void(^)(NSManagedObjectID *objectID))successBlock
                    failure:(void(^)(NSError *error))failureBlock {
    return NO;
}

@end

@implementation TCSDefaultProviderBase

- (Class)utsLocalEntityType {
    return [TCSBaseEntity class];
}

- (void)setUtsRemoteID:(NSString *)utsRemoteID {
    _utsRemoteID = [self safeRemoteID:utsRemoteID];
}

- (NSString *)safeRemoteID:(id)remoteID {
    if ([remoteID isKindOfClass:[NSNumber class]]) {
        remoteID = [(NSNumber *)remoteID stringValue];
    } else if ([remoteID isKindOfClass:[NSString class]] == NO) {
        remoteID = [remoteID description];
    }
    return remoteID;
}

@end

@implementation TCSDefaultProviderTimedEntity

- (Class)utsLocalEntityType {
    return [TCSTimedEntity class];
}

- (void)setUtsParentID:(NSString *)utsParentID {
    _utsParentID = [self safeRemoteID:utsParentID];
}

@end

@implementation TCSDefaultProviderGroup

- (Class)utsLocalEntityType {
    return [TCSGroup class];
}

@end

@implementation TCSDefaultProviderProject

- (Class)utsLocalEntityType {
    return [TCSProject class];
}

@end

@implementation TCSDefaultProviderTimer

- (Class)utsLocalEntityType {
    return [TCSTimer class];
}

- (void)setUtsProjectID:(NSString *)utsProjectID {
    _utsProjectID = [self safeRemoteID:utsProjectID];
}

@end

@implementation TCSDefaultProviderBaseMetadata

- (Class)utsLocalEntityType {
    return [TCSBaseMetadataEntity class];
}

- (void)setUtsRelatedRemoteID:(NSString *)utsRelatedRemoteID {
    _utsRelatedRemoteID = [self safeRemoteID:utsRelatedRemoteID];
}

@end

@implementation TCSDefaultProviderTimedEntityMetadata

- (Class)utsLocalEntityType {
    return [TCSTimedEntityMetadata class];
}

@end

@implementation TCSDefaultProviderTimerMetadata

- (Class)utsLocalEntityType {
    return [TCSTimerMetadata class];
}

@end