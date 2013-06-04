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
                       remoteId:(NSString *)remoteId
                     updateTime:(NSDate *)updateTime
                  markAsUpdated:(BOOL)markAsUpdated {

    self.entityVersionValue = entityVersion;
    self.remoteId = [self nonNullValue:remoteId];
    self.updateTime = [self nonNullValue:updateTime];

    if (markAsUpdated) {
        [self markEntityAsUpdated];
    }
}

- (void)markEntityAsUpdated {
    self.entityVersionValue++;
    self.pendingValue =
    [[TCSService sharedInstance] serviceProviderNamed:self.providerInstance.remoteProvider] != nil;
}

- (void)markEntityAsDeleted {
    self.entityVersionValue++;
    self.pendingRemoteDeleteValue = YES;
    self.pendingValue =
    [[TCSService sharedInstance] serviceProviderNamed:self.providerInstance.remoteProvider] != nil;
}

- (id)nonNullValue:(id)value {
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

- (BOOL)isEntityCurrent {
    NSInteger dataVersion =
    [TCSService sharedInstance].dataVersion;
    return self.dataVersionValue == dataVersion;
}

@end
