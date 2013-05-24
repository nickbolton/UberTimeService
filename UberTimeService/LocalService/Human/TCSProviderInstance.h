#import "_TCSProviderInstance.h"

@interface TCSProviderInstance : _TCSProviderInstance {}

- (void)updateWithName:(NSString *)name
               baseURL:(NSString *)baseURL
                  type:(NSString *)type
              username:(NSString *)username
              password:(NSString *)password
                userID:(NSString *)userID
         entityVersion:(int64_t)entityVersion
              remoteId:(NSString *)remoteId
            updateTime:(NSDate *)updateTime
         markAsUpdated:(BOOL)markAsUpdated;

@end
