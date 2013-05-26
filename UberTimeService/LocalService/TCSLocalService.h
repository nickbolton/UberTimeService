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

extern NSString * const kTCSLocalServiceRemoteSyncCompletedNotification;

@interface TCSLocalService : TCSDefaultProvider <TCSServiceLocalService, TCSPollingDelegate>

+ (instancetype)sharedInstance;

@property (nonatomic, strong) id <TCSServiceSyncingRemoteProvider> syncingRemoteProvider;

+ (NSManagedObjectID *)objectIDFromStringID:(NSString *)stringID;
+ (NSString *)stringIDFromObjectID:(NSManagedObjectID *)objectID;

- (void)resetCoreDataStack;

@end
