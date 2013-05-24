#import "TCSCannedMessage.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSCannedMessage

+ (void)createRemoteObject:(TCSCannedMessage *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (remoteProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSCannedMessage class]],
                 @"Not a TCSCannedMessage object");

        [remoteProvider
         createCannedMessage:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSCannedMessage *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        if (remoteProvider != nil) {

            NSAssert([localEntity isKindOfClass:[TCSCannedMessage class]],
                     @"Not a TCSCannedMessage object");

            [remoteProvider
             updateCannedMessage:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

+ (void)deleteRemoteObject:(TCSCannedMessage *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSCannedMessage class]],
             @"Not a TCSCannedMessage object");

    if (successBlock != nil) {

        if (remoteProvider != nil) {

            [remoteProvider
             deleteCannedMessage:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

- (void)updateWithMessage:(NSString *)message
                    order:(NSInteger)order
            entityVersion:(int64_t)entityVersion
                 remoteId:(NSString *)remoteId
               updateTime:(NSDate *)updateTime
            markAsUpdated:(BOOL)markAsUpdated {

    self.message = [self nonNullValue:message];
    self.orderValue = order;
    
    [super
     updateWithEntityVersion:entityVersion
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
}

@end
