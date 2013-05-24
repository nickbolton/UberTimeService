#import "TCSTimedEntityMetadata.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSTimedEntityMetadata

+ (void)createRemoteObject:(TCSTimedEntityMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (syncingProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSTimedEntityMetadata class]],
                 @"Not a TCSTimedEntityMetadata object");

        [syncingProvider
         createTimedEntityMetadata:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSTimedEntityMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            NSAssert([localEntity isKindOfClass:[TCSTimedEntityMetadata class]],
                     @"Not a TCSTimedEntityMetadata object");
            
            [syncingProvider
             updateTimedEntityMetadata:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

+ (void)deleteRemoteObject:(TCSTimedEntityMetadata *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSTimedEntityMetadata class]],
             @"Not a TCSTimedEntityMetadata object");

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            [syncingProvider
             deleteTimedEntityMetadata:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

- (void)updateWithColor:(NSInteger)color
               archived:(BOOL)archived
      filteredModifiers:(NSInteger)filteredModifiers
                keyCode:(NSInteger)keyCode
              modifiers:(NSInteger)modifiers
                  order:(NSInteger)order
          entityVersion:(int64_t)entityVersion
               remoteId:(NSString *)remoteId
             updateTime:(NSDate *)updateTime
          markAsUpdated:(BOOL)markAsUpdated {

    self.colorValue = color;
    self.archivedValue = archived;
    self.filteredModifiersValue = filteredModifiers;
    self.keyCodeValue = keyCode;
    self.modifiersValue = modifiers;
    self.orderValue = order;

    [super
     updateWithEntityVersion:entityVersion
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
}

@end
