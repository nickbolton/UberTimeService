#import "_TCSTimerMetadata.h"

@interface TCSTimerMetadata : _TCSTimerMetadata {}

- (void)updateWithStartTime:(NSDate *)startTime
                    endTime:(NSDate *)endTime
                 adjustment:(NSTimeInterval)adjustment
              entityVersion:(int64_t)entityVersion
                   remoteId:(NSString *)remoteId
                 updateTime:(NSDate *)updateTime
              markAsUpdated:(BOOL)markAsUpdated;

@end
