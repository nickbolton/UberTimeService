#import "_TCSBaseEntity.h"

@protocol TCSServiceRemoteProvider;

@interface TCSBaseEntity : _TCSBaseEntity {}

+ (void)createRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock;

+ (void)updateRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock;

+ (void)deleteRemoteObject:(TCSBaseEntity *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock;

- (void)updateWithEntityVersion:(int64_t)entityVersion
                  remoteDeleted:(BOOL)remoteDeleted
                       remoteId:(NSString *)remoteId
                     updateTime:(NSDate *)updateTime
                  markAsUpdated:(BOOL)markAsUpdated;

- (void)markEntityAsUpdated;
- (void)markEntityAsDeleted;
- (id)nonNullValue:(id)value;

@end
