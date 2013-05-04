//
//  NSDate+Utilities.m
//  UberTimeService
//
//  Created by Nick Bolton on 2/10/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import "NSDate+Utilities.h"
#import "TCSCalendarManager.h"

@implementation NSDate(Utilities)

#if TARGET_OS_IPHONE
- (BOOL)isGreaterThan:(id)object {
    NSComparisonResult result = [self compare:object];
    return result == NSOrderedDescending;
}

- (BOOL)isLessThan:(id)object {
    NSComparisonResult result = [self compare:object];
    return result == NSOrderedAscending;
}

- (BOOL)isGreaterThanOrEqualTo:(id)object {
    NSComparisonResult result = [self compare:object];
    return result == NSOrderedDescending || result == NSOrderedSame;
}

- (BOOL)isLessThanOrEqualTo:(id)object {
    NSComparisonResult result = [self compare:object];
    return result == NSOrderedAscending || result == NSOrderedSame;
}
#endif

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day {

    return [self dateWithYear:year
                        month:month
                          day:day
                        hours:0
                      minutes:0];
}

+ (NSDate *)dateWithYear:(NSInteger)year
                   month:(NSInteger)month
                     day:(NSInteger)day
                   hours:(NSInteger)hours
                 minutes:(NSInteger)minutes {

    NSCalendar *cal = [[TCSCalendarManager sharedInstance] calendarForCurrentThread];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:year];
    [dateComponents setMonth:month];
    [dateComponents setDay:day];
    [dateComponents setHour:hours];
    [dateComponents setMinute:minutes];

    return [cal dateFromComponents:dateComponents];
}

+ (TCSDateRange *)today {
    NSDate *now = [NSDate date];
    
    return [TCSDateRange dateRangeWithStartDate:now
                                       endDate:now];
}

- (NSInteger)valueForCalendarUnit:(NSCalendarUnit)calendarUnit {
    NSCalendar *cal = [[TCSCalendarManager sharedInstance] calendarForCurrentThread];
    NSDateComponents *dateComponents =
    [cal components:calendarUnit fromDate:self];

    NSInteger value = 0;

    switch (calendarUnit) {
        case NSYearCalendarUnit:
            value = dateComponents.year;
            break;

        case NSMonthCalendarUnit:
            value = dateComponents.month;
            break;

        case NSDayCalendarUnit:
            value = dateComponents.day;
            break;

        case NSHourCalendarUnit:
            value = dateComponents.hour;
            break;

        case NSMinuteCalendarUnit:
            value = dateComponents.minute;
            break;

        case NSSecondCalendarUnit:
            value = dateComponents.second;
            break;

        case NSWeekCalendarUnit:
            value = dateComponents.week;
            break;

        case NSWeekdayCalendarUnit:
            value = dateComponents.weekday;
            break;

        case NSWeekdayOrdinalCalendarUnit:
            value = dateComponents.weekdayOrdinal;
            break;

        case NSWeekOfMonthCalendarUnit:
            value = dateComponents.weekOfMonth;
            break;

        case NSWeekOfYearCalendarUnit:
            value = dateComponents.weekOfYear;
            break;
            
        default:
            break;
    }
    return value;
}

- (NSInteger)daysInBetweenDate:(NSDate *)date {
    
    NSTimeInterval lastDiff = [[date midnight] timeIntervalSinceNow];
    NSTimeInterval todaysDiff = [[self midnight] timeIntervalSinceNow];
    NSTimeInterval dateDiff = lastDiff - todaysDiff;
    return dateDiff / 86400;
}

- (BOOL)isWithinRange:(TCSDateRange *)dateRange {
    return
    [self isGreaterThanOrEqualTo:dateRange.startDate] &&
    [self isLessThanOrEqualTo:dateRange.endDate];
}

- (BOOL)isMidnight {
    NSDateComponents *dateComponents =
    [[[TCSCalendarManager sharedInstance] calendarForCurrentThread]
     components:NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:self];
    
    return (dateComponents.hour + dateComponents.minute + dateComponents.second) == 0;
}

- (TCSDateRange *)yesterday {
    NSDate *date = [self dateByAddingDays:-1];
    
    return [TCSDateRange dateRangeWithStartDate:date
                                       endDate:date];    
}

- (TCSDateRange *)tomorrow {
    NSDate *date = [self dateByAddingDays:1];
    
    return [TCSDateRange dateRangeWithStartDate:date
                                       endDate:date];    
}

- (TCSDateRange *)thisWeek {    
    return [self dateIntervalForTimePeriod:TimePeriod_ThisWeek];
}

- (TCSDateRange *)lastWeek {
    return [self dateIntervalForTimePeriod:TimePeriod_LastWeek];
}

- (TCSDateRange *)nextWeek {
    TCSDateRange *nextWeek = [self thisWeek];
    nextWeek.startDate = [nextWeek.startDate dateByAddingDays:7];
    nextWeek.endDate = [nextWeek.endDate dateByAddingDays:7];
    return nextWeek;
}

- (TCSDateRange *)thisMonth {
    return [self dateIntervalForTimePeriod:TimePeriod_ThisMonth];
}

- (TCSDateRange *)lastMonth {
    return [self dateIntervalForTimePeriod:TimePeriod_LastMonth];
}

- (TCSDateRange *)nextMonth {
    NSDateComponents *dateComponents;
    NSCalendar *cal = [[TCSCalendarManager sharedInstance] calendarForCurrentThread];
    dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:1];
    
    NSDate *nextMonthDate = [cal dateByAddingComponents:dateComponents
                                                 toDate:self
                                                options:0];
    return [nextMonthDate thisMonth];
}

- (TCSDateRange *)thisYear {
    return [self dateIntervalForTimePeriod:TimePeriod_ThisYear];
}

- (NSDate *)endOfDay {
    return [self endOfDay:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSDate *)endOfDay:(NSCalendar *)cal {
    return [[[self dateByAddingDays:1 withCal:cal] midnight:cal] dateByAddingTimeInterval:-1];
}

- (NSInteger)dayOfTheWeek {
    return [self dayOfTheWeek:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSInteger)dayOfTheWeek:(NSCalendar *)cal {
    NSDateComponents *dateComponents = [cal components:NSWeekdayCalendarUnit fromDate:self];
    return [dateComponents weekday];
}

- (NSInteger)dayOfTheMonth {
    return [self dayOfTheMonth:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSInteger)dayOfTheMonth:(NSCalendar *)cal {
    NSDateComponents *dateComponents = [cal components:NSDayCalendarUnit fromDate:self];
    return [dateComponents day];
}

- (NSInteger)dayOfTheYear {
    return [self dayOfTheMonth:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSInteger)dayOfTheYear:(NSCalendar *)cal {
    return [cal ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:self];
}

- (NSDate *)dateByAddingDays:(NSInteger)days {
    return [self dateByAddingDays:days 
                          withCal:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSDate *)dateByAddingDays:(NSInteger)days withCal:(NSCalendar *)cal {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:days];
    NSDate *result = [cal dateByAddingComponents:dateComponents toDate:self options:0];
    return result;
}

- (NSDate *)dateByAddingSeconds:(NSTimeInterval)seconds {
    return [self dateByAddingSeconds:seconds 
                             withCal:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSDate *)dateByAddingSeconds:(NSTimeInterval)seconds withCal:(NSCalendar *)cal {
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setSecond:seconds];
    NSDate *result = [cal dateByAddingComponents:dateComponents toDate:self options:0];
    return result;
}

- (TCSDateRange *)dateIntervalForTimePeriod:(TimePeriod)timePeriod {    
    return [self dateIntervalForTimePeriod:timePeriod 
                                   withCal:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSDate *)midnight {
    return [self midnight:[[TCSCalendarManager sharedInstance] calendarForCurrentThread]];
}

- (NSDate *)midnight:(NSCalendar *)cal {
    NSDateComponents *dateComponents = 
        [cal components:NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit fromDate:self];
    return [cal dateFromComponents:dateComponents];
}

- (TCSDateRange *)dateIntervalForTimePeriod:(TimePeriod)timePeriod withCal:(NSCalendar *)cal {
    
    NSDate *fromDate, *toDate;
    NSDateComponents *dateComponents;
    NSInteger year;
    NSDate *now = [NSDate date];

    switch (timePeriod) {
        case TimePeriod_All:
        case TimePeriod_Archived:
            fromDate = [NSDate distantPast];
            toDate = [NSDate distantFuture];
            break;
        case TimePeriod_ThisWeek:
            fromDate = [self dateByAddingDays:(1-[self dayOfTheWeek:cal]) withCal:cal];
            toDate = [fromDate dateByAddingDays:6 withCal:cal];
            break;
        case TimePeriod_ThisMonth:
            fromDate = [self dateByAddingDays:(1-[self dayOfTheMonth:cal]) withCal:cal];
            dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setMonth:1];
            [dateComponents setDay:-1];
            toDate = [cal dateByAddingComponents:dateComponents toDate:fromDate options:0];
            break;
        case TimePeriod_ThisYear:
            fromDate = [self dateByAddingDays:(1-[self dayOfTheYear:cal]) withCal:cal];
            dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setYear:1];
            [dateComponents setDay:-1];
            toDate = [cal dateByAddingComponents:dateComponents toDate:fromDate options:0];
            break;            
        case TimePeriod_Yesterday:
            fromDate = toDate = [self dateByAddingDays:-1 withCal:cal];
            break;            
        case TimePeriod_LastWeek:
            toDate = [self dateByAddingDays:-[self dayOfTheWeek:cal] withCal:cal];
            fromDate = [toDate dateByAddingDays:-6];
            break;            
        case TimePeriod_LastMonth:
            toDate = [self dateByAddingDays:-[self dayOfTheMonth:cal] withCal:cal];
            dateComponents = [cal components:NSDayCalendarUnit fromDate:toDate];
            fromDate = [toDate dateByAddingDays:-([dateComponents day]-1) withCal:cal];
            break;            
        case TimePeriod_LastYear:
            dateComponents = [cal components:NSYearCalendarUnit fromDate:self];
            year = [dateComponents year] - 1;
            dateComponents = [[NSDateComponents alloc] init];
            [dateComponents setMonth:1];
            [dateComponents setDay:1];
            [dateComponents setYear:year];
            fromDate = [cal dateFromComponents:dateComponents];
            [dateComponents setMonth:12];
            [dateComponents setDay:31];
            toDate = [cal dateFromComponents:dateComponents];
            break;            
        case TimePeriod_PreviousWeek:
            toDate = self;
            fromDate = [toDate dateByAddingDays:-6 withCal:cal];
            break;            
        case TimePeriod_PreviousMonth:
            /*
            toDate = self;
            dateComponents = [[[NSDateComponents alloc] init] autorelease];
            [dateComponents setMonth:-1];
            fromDate = [cal dateByAddingComponents:dateComponents toDate:toDate options:0];
            toDate = [self dateByAddingDays:-1 withCal:cal];
             */
            toDate = self;
            fromDate = [toDate dateByAddingDays:-29 withCal:cal];
            break;            
        case TimePeriod_PreviousYear:
            /*
            toDate = self;
            dateComponents = [[[NSDateComponents alloc] init] autorelease];
            [dateComponents setYear:-1];
            fromDate = [cal dateByAddingComponents:dateComponents toDate:toDate options:0];
            toDate = [self dateByAddingDays:-1 withCal:cal];            
             */
            toDate = self;
            fromDate = [toDate dateByAddingDays:-364 withCal:cal];
            break;            
        default:
            fromDate = toDate = now;
            break;
    }
    
    return [TCSDateRange dateRangeWithStartDate:fromDate
                                       endDate:toDate];
}

+ (NSString *)labelForTimePeriod:(TimePeriod)timePeriod {
    
    NSString *label = nil;
    
    switch (timePeriod) {
        case TimePeriod_All:
            label = NSLocalizedString(@"all time", nil);
            break;
        case TimePeriod_Today:
            label = NSLocalizedString(@"today", nil);
            break;
        case TimePeriod_ThisWeek:
            label = NSLocalizedString(@"this week", nil);
            break;
        case TimePeriod_ThisMonth:
            label = NSLocalizedString(@"this month", nil);
            break;            
        case TimePeriod_ThisYear:
            label = NSLocalizedString(@"this year", nil);
            break;            
        case TimePeriod_Yesterday:
            label = NSLocalizedString(@"yesterday", nil);
            break;            
        case TimePeriod_LastWeek:
            label = NSLocalizedString(@"last week", nil);
            break;            
        case TimePeriod_LastMonth:
            label = NSLocalizedString(@"last month", nil);
            break;            
        case TimePeriod_LastYear:
            label = NSLocalizedString(@"last year", nil);
            break;            
        case TimePeriod_PreviousWeek:
            label = NSLocalizedString(@"previous week", nil);
            break;            
        case TimePeriod_PreviousMonth:
            label = NSLocalizedString(@"previous month", nil);
            break;            
        case TimePeriod_PreviousYear:
            label = NSLocalizedString(@"previous year", nil);
            break;            
    }
    
    return label;
}

@end
