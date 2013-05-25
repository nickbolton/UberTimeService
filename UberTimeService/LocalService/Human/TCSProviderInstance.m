#import "TCSProviderInstance.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSProviderInstance

+ (void)createRemoteObject:(TCSProviderInstance *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSAssert([syncingProvider conformsToProtocol:@protocol(TCSServiceSyncingRemoteProvider)],
             @"syncingProvider does not conform to TCSServiceSyncingRemoteProvider");

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (syncingProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSProviderInstance class]],
                 @"Not a TCSRemoteProvider object");

        [syncingProvider
         createProviderInstance:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSProviderInstance *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSAssert([syncingProvider conformsToProtocol:@protocol(TCSServiceSyncingRemoteProvider)],
             @"syncingProvider does not conform to TCSServiceSyncingRemoteProvider");

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            NSAssert([localEntity isKindOfClass:[TCSProviderInstance class]],
                     @"Not a TCSCannedMessage object");

            [syncingProvider
             updateProviderInstance:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

+ (void)deleteRemoteObject:(TCSProviderInstance *)localEntity
            remoteProvider:(NSObject <TCSServiceSyncingRemoteProvider> *)syncingProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSAssert([syncingProvider conformsToProtocol:@protocol(TCSServiceSyncingRemoteProvider)],
             @"syncingProvider does not conform to TCSServiceSyncingRemoteProvider");

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSProviderInstance class]],
             @"Not a TCSCannedMessage object");

    if (successBlock != nil) {

        if (syncingProvider != nil) {

            [syncingProvider
             deleteProviderInstance:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

- (void)updateWithName:(NSString *)name
               baseURL:(NSString *)baseURL
                  type:(NSString *)type
              username:(NSString *)username
              password:(NSString *)password
        remoteProvider:(NSString *)remoteProvider
                userID:(NSString *)userID
         entityVersion:(int64_t)entityVersion
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated {

    self.name = [self nonNullValue:name];
    self.baseURL = [self nonNullValue:baseURL];
    self.type = [self nonNullValue:type];
    self.username = [self nonNullValue:username];
    self.password = [self nonNullValue:password];
    self.userID = [self nonNullValue:userID];
    self.remoteProvider = [self nonNullValue:remoteProvider];
    self.providerInstance = nil;

    [super
     updateWithEntityVersion:entityVersion
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
    
}

@end
