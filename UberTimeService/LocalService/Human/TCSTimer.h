#import "_TCSTimer.h"

@class TCSDateRange;

@interface TCSTimer : _TCSTimer {}

- (NSTimeInterval)timeInterval;
- (NSTimeInterval)timeIntervalForDateRange:(TCSDateRange *)dateRange;
- (CGFloat)elapsedTimeInHours;
- (NSTimeInterval)combinedTime;
- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange;

+ (NSTimeInterval)combinedTimeForStartTime:(NSDate *)startTime
                                   endTime:(NSDate *)endDate
                                adjustment:(NSTimeInterval)adjustment;

@end
