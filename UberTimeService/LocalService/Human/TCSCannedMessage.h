#import "_TCSCannedMessage.h"

@interface TCSCannedMessage : _TCSCannedMessage {}

- (void)updateWithMessage:(NSString *)message
                    order:(NSInteger)order
            entityVersion:(int64_t)entityVersion
                 remoteId:(NSString *)remoteId
               updateTime:(NSDate *)updateTime
            markAsUpdated:(BOOL)markAsUpdated;
@end
