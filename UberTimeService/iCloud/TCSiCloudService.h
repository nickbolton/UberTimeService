//
//  TCSiCloudService.h
//  Pods
//
//  Created by Nick Bolton on 10/31/13.
//
//

#import "TCSLocalService.h"

@interface TCSiCloudService : TCSLocalService

@property (nonatomic, getter = isEnabled) BOOL enabled;

+ (void)setStoreName:(NSString *)storeName;
+ (void)setContainerIdentifier:(NSString *)containerIdentifier;

+ (instancetype)sharedInstance;

- (void)fixCloudContent;
- (void)fixLocalContent;

@end
