//
//  TCSTimer.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimer.h"
#import "TCSProject.h"
#import "TCSDateRange.h"
#import "NSDate+Utilities.h"

@implementation TCSTimer

- (NSDate *)startTime {
    return [self providerDateValueForKey:@"startTime"];
}

- (void)setStartTime:(NSDate *)startTime {
    [self setProviderDateValue:startTime forKey:@"startTime"];
}

- (NSDate *)endTime {
    return [self providerDateValueForKey:@"endTime"];
}

- (void)setEndTime:(NSDate *)endTime {
    [self setProviderDateValue:endTime forKey:@"endTime"];
}

- (NSString *)message {
    return [self providerStringValueForKey:@"message"];
}

- (void)setMessage:(NSString *)message {
    [self setProviderStringValue:message forKey:@"message"];
}

- (NSTimeInterval)adjustment {
    return [self providerFloatValueForKey:@"adjustment"];
}

- (void)setAdjustment:(NSTimeInterval)adjustment {
    [self setProviderFloatValue:adjustment forKey:@"adjustment"];
}

- (TCSProject *)project {
    return (id)[self providerRelationForKey:@"project" andType:[TCSProject class]];
}

- (void)setProject:(TCSProject *)project {
    [self setProviderRelation:project forKey:@"project"];
}

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
    return MAX(0.0f, self.timeInterval + self.adjustment);
}

- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

    if (end == nil) {
        end = [NSDate date];
    }

    end = [end dateByAddingTimeInterval:self.adjustment];

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
