//
//  TCSLocalService.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//
#import "TCSDefaultProvider.h"
#import "TCSService.h"
#import "TCSServicePrivate.h"

extern NSString * const kTCSLocalServiceUpdatedRemoteEntitiesNotification;
extern NSString * const kTCSLocalServiceRemoteSyncCompletedNotification;
extern NSString * const kTCSLocalServiceUpdatedRemoteEntitiesKey;
extern NSString * const kTCSLocalServiceRemoteProviderNameKey;

@interface TCSLocalService : TCSDefaultProvider <TCSServiceLocalService>

+ (instancetype)sharedInstance;

+ (NSManagedObjectID *)objectIDFromStringID:(NSString *)stringID;
+ (NSString *)stringIDFromObjectID:(NSManagedObjectID *)objectID;

- (void)resetCoreDataStack;

@end
