#import "TCSBaseEntity.h"

@implementation TCSBaseEntity

+ (void)createRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        return successBlock(nil, nil);
    }
}

+ (void)updateRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        return successBlock(nil);
    }
}

+ (void)deleteRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        return successBlock(nil);
    }
}

- (void)updateWithEntityVersion:(int64_t)entityVersion
                  remoteDeleted:(BOOL)remoteDeleted
                       remoteId:(NSString *)remoteId
                     updateTime:(NSDate *)updateTime
                  markAsUpdated:(BOOL)markAsUpdated {

    self.entityVersionValue = entityVersion;
    self.remoteDeletedValue = remoteDeleted;
    self.remoteId = remoteId;
    self.updateTime = updateTime;

    if (markAsUpdated) {
        [self markEntityAsUpdated];
    }
}

- (void)markEntityAsUpdated {
    self.entityVersionValue++;
    self.pendingValue =
    [[TCSService sharedInstance] serviceProviderNamed:self.remoteProvider] != nil;
}

- (void)markEntityAsDeleted {
    self.entityVersionValue++;
    self.remoteDeletedValue = YES;
    self.pendingValue =
    [[TCSService sharedInstance] serviceProviderNamed:self.remoteProvider] != nil;
}

@end
