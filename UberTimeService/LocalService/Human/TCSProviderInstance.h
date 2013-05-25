#import "_TCSProviderInstance.h"

@interface TCSProviderInstance : _TCSProviderInstance {}

- (void)updateWithName:(NSString *)name
               baseURL:(NSString *)baseURL
              username:(NSString *)username
              password:(NSString *)password
        remoteProvider:(NSString *)remoteProvider
                userID:(NSString *)userID
         entityVersion:(int64_t)entityVersion
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated;

@end
