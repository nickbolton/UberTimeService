#import "TCSTimer.h"
#import "TCSDateRange.h"
#import "NSDate+Utilities.h"

@implementation TCSTimer

@synthesize editing = _editing;

+ (NSTimeInterval)combinedTimeForStartTime:(NSDate *)startTime
                                   endTime:(NSDate *)endDate
                                adjustment:(NSTimeInterval)adjustment {

    NSTimeInterval timeInterval;

    if (endDate != nil) {
        timeInterval = [endDate timeIntervalSinceDate:startTime];
    } else {

        NSDate *currentTime = [NSDate date];
        timeInterval = [currentTime timeIntervalSinceDate:startTime];
    }

    return MAX(0.0f, timeInterval + adjustment);
}

- (NSTimeInterval)timeInterval {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

	if (end != nil) {
		return [end timeIntervalSinceDate:start];
	}

    NSDate *currentTime = [NSDate date];
    return [currentTime timeIntervalSinceDate:start];
}

- (NSTimeInterval)timeIntervalForDateRange:(TCSDateRange *)dateRange {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

    if (end == nil) {
        end = [NSDate date];
    }

    if ([start isLessThan:dateRange.startDate]) {
        start = dateRange.startDate;
    }

    if ([end isGreaterThan:dateRange.endDate]) {
        end = dateRange.endDate;
    }

    if ([end isLessThan:start]) {
        return 0.0f;
    }

    return [end timeIntervalSinceDate:start];
}

- (NSTimeInterval)combinedTime {
    return MAX(0.0f, self.timeInterval + self.adjustmentValue);
}

- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

    if (end == nil) {
        end = [NSDate date];
    }

    end = [end dateByAddingTimeInterval:self.adjustmentValue];

    if ([start isLessThan:dateRange.startDate]) {
        start = dateRange.startDate;
    }

    if ([end isGreaterThan:dateRange.endDate]) {
        end = dateRange.endDate;
    }

    if ([end isLessThan:start]) {
        return 0.0f;
    }

    return [end timeIntervalSinceDate:start];
}

- (CGFloat)elapsedTimeInHours {
    NSTimeInterval timeInterval = [self combinedTime];
    CGFloat hours = timeInterval / 3600.0;
    return hours;
}

@end
