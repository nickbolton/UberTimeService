//
//  TCSiCloudService.h
//  Pods
//
//  Created by Nick Bolton on 10/31/13.
//
//

#import "TCSLocalService.h"

extern NSString * const kTCSiCloudServiceLocalStoreDeadNotification;
extern NSString * const kTCSiCloudServiceLocalStoreLoadedNotification;
extern NSString * const kTCSiCloudServiceCloudStoreKey;
extern NSString * const kTCSiCloudServiceUbiquityStoreErrorCauseKey;

@interface TCSiCloudService : TCSLocalService

@property (nonatomic, getter = isEnabled) BOOL enabled;

- (void)fixCloudContent;
- (void)fixLocalContent;

@end
