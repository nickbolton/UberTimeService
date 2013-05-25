#import "_TCSTimer.h"

@class TCSDateRange;

@interface TCSTimer : _TCSTimer {}

@property (nonatomic, getter = isEditing) BOOL editing;

- (NSTimeInterval)timeInterval;
- (NSTimeInterval)timeIntervalForDateRange:(TCSDateRange *)dateRange;
- (CGFloat)elapsedTimeInHours;
- (NSTimeInterval)combinedTime;
- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange;

+ (NSTimeInterval)combinedTimeForStartTime:(NSDate *)startTime
                                   endTime:(NSDate *)endDate
                                adjustment:(NSTimeInterval)adjustment;

- (void)updateWithMessage:(NSString *)message
            entityVersion:(int64_t)entityVersion
                 remoteId:(NSString *)remoteId
               updateTime:(NSDate *)updateTime
            markAsUpdated:(BOOL)markAsUpdated;

@end
