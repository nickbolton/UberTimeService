#import "_TCSRemoteCommand.h"

typedef NS_ENUM(NSInteger, TCSRemoteCommandType) {

    TCSRemoteCommandTypeMessage = 0,
    TCSRemoteCommandTypeDeleteObject,
    TCSRemoteCommandTypeResetData,
};

extern NSString * const kTCSRemoteCommandMessageNotification;
extern NSString * const kTCSRemoteCommandMessageKey;
extern NSString * const kTCSRemoteCommandObjectIdKey;

@interface TCSRemoteCommand : _TCSRemoteCommand {}

- (void)execute;

+ (TCSRemoteCommand *)messageRemoteCommand:(NSString *)message
                            remoteProvider:(NSString *)remoteProvider
                                 inContext:(NSManagedObjectContext *)managedObjectContext;

+ (TCSRemoteCommand *)deleteObjectRemoteCommand:(NSString *)remoteObjectID
                                 remoteProvider:(NSString *)remoteProvider
                                      inContext:(NSManagedObjectContext *)managedObjectContext;

+ (TCSRemoteCommand *)resetDataRemoteCommand:(NSString *)remoteProvider
                                   inContext:(NSManagedObjectContext *)managedObjectContext;

- (NSDictionary *)payloadDictionary;

@end
