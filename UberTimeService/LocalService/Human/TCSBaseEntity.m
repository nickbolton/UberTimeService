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

@end
