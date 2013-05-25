#import "TCSTimerMetadata.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSTimerMetadata

+ (void)createRemoteObject:(TCSTimerMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (syncingProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSTimerMetadata class]],
                 @"Not a TCSTimerMetadata object");

        [syncingProvider
         createTimerMetadata:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSTimerMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            NSAssert([localEntity isKindOfClass:[TCSTimerMetadata class]],
                     @"Not a TCSTimedEntityMetadata object");

            [syncingProvider
             updateTimerMetadata:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

+ (void)deleteRemoteObject:(TCSTimerMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSTimerMetadata class]],
             @"Not a TCSTimerMetadata object");

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            [syncingProvider
             deleteTimerMetadata:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

- (void)updateWithStartTime:(NSDate *)startTime
                    endTime:(NSDate *)endTime
                 adjustment:(NSTimeInterval)adjustment
              entityVersion:(int64_t)entityVersion
                   remoteId:(NSString *)remoteId
                 updateTime:(NSDate *)updateTime
              markAsUpdated:(BOOL)markAsUpdated {

    self.startTime = [self nonNullValue:startTime];
    self.endTime = [self nonNullValue:endTime];
    self.adjustmentValue = adjustment;

    [super
     updateWithEntityVersion:entityVersion
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];

}

@end
