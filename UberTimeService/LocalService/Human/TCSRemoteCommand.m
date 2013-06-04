#import "TCSRemoteCommand.h"
#import "CoreData+MagicalRecord.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

NSString * const kTCSRemoteCommandMessageNotification = @"kTCSRemoteCommandMessageNotification";
NSString * const kTCSRemoteCommandMessageKey = @"remote-message";
NSString * const kTCSRemoteCommandObjectIdKey = @"object-id";
NSString * const kTCSRemoteCommandDataVersionKey = @"data-version";

@implementation TCSRemoteCommand

- (void)execute {

    if (self.executedValue == NO) {

        switch (self.typeValue) {
            case TCSRemoteCommandTypeMessage:
                [self postNotificationOfType:kTCSRemoteCommandMessageNotification];
                break;

            default:
                break;
        }

        self.executedValue = YES;
    }
}

+ (void)createRemoteObject:(TCSRemoteCommand *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    if (remoteProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSRemoteCommand class]],
                 @"Not a TCSRemoteCommand object");

        [(id <TCSServiceSyncingRemoteProvider>)remoteProvider
         createRemoteCommand:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (NSData *)payloadDataFromDictionary:(NSDictionary *)dictionary {

    NSError *error = nil;

    NSData *payloadData =
    [NSPropertyListSerialization
     dataWithPropertyList:dictionary
     format:NSPropertyListBinaryFormat_v1_0
     options:0
     error:&error];

    if (error != nil) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }

    return payloadData;
}

+ (TCSRemoteCommand *)messageRemoteCommand:(NSString *)message
                            remoteProvider:(NSString *)remoteProvider
                                 inContext:(NSManagedObjectContext *)managedObjectContext {

    TCSRemoteCommand *remoteCommand =
    [TCSRemoteCommand MR_createInContext:managedObjectContext];

    remoteCommand.typeValue = TCSRemoteCommandTypeMessage;
    remoteCommand.providerInstance = nil;
    remoteCommand.payload =
    [self
     payloadDataFromDictionary:@{
     kTCSRemoteCommandMessageKey : message,
     }];

    return remoteCommand;
}

+ (TCSRemoteCommand *)deleteObjectRemoteCommand:(NSString *)remoteObjectID
                                 remoteProvider:(NSString *)remoteProvider
                                      inContext:(NSManagedObjectContext *)managedObjectContext {

    TCSRemoteCommand *remoteCommand =
    [TCSRemoteCommand MR_createInContext:managedObjectContext];

    remoteCommand.typeValue = TCSRemoteCommandTypeDeleteObject;
    remoteCommand.providerInstance = nil;
    remoteCommand.payload =
    [self
     payloadDataFromDictionary:@{
     kTCSRemoteCommandObjectIdKey : remoteObjectID,
     }];

    return remoteCommand;
}

+ (TCSRemoteCommand *)resetDataRemoteCommand:(NSString *)remoteProvider
                                   inContext:(NSManagedObjectContext *)managedObjectContext {

    TCSRemoteCommand *remoteCommand =
    [TCSRemoteCommand MR_createInContext:managedObjectContext];

    remoteCommand.typeValue = TCSRemoteCommandTypeResetData;
    remoteCommand.providerInstance = nil;
    remoteCommand.payload =
    [self
     payloadDataFromDictionary:@{
     kTCSRemoteCommandDataVersionKey : @([TCSService sharedInstance].dataVersion),
    }];

    return remoteCommand;
}

- (NSDictionary *)payloadDictionary {

    NSError *error = nil;

    NSDictionary *payload =
    [NSPropertyListSerialization
     propertyListWithData:self.payload
     options:0
     format:NULL
     error:&error];

    if (error != nil) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }

    return payload;
}

- (void)postNotificationOfType:(NSString *)notificationName {

    NSDictionary *userInfo =
    [self payloadDictionary];

    if (userInfo != nil) {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:notificationName
         object:self
         userInfo:userInfo];
    }
}

@end
