//
//  TCSDateFormatManager.m
//  UberTimeService
//
//  Created by Nick Bolton on 12/18/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import "TCSDateFormatManager.h"
#import "TCSCalendarManager.h"
#import "TCSTimer.h"

@interface TCSDateFormatManager()
@property (nonatomic, strong) NSDateFormatter *monthFormatter;
@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *timerFormatter;
@property (nonatomic, strong) NSDateFormatter *abbreviatedDayFormatter;

- (void)updateCurrentLocale;

#if TARGET_OS_IPHONE
- (void)applicationWillEnterForeground:(NSNotification *)notification;
#else
- (void)currentLocaleDidChange:(NSNotification *)notification;
#endif

@end

NSTimeInterval const kTCOneDayInSeconds = 60.0f * 60.0f * 24.0f;

@implementation TCSDateFormatManager

static dispatch_once_t predicate_;
static TCSDateFormatManager *sharedInstance_ = nil;

- (id)init {
    self = [super init];
    
    if (self != nil) {
        _showTimeSeparators = YES;
        self.monthFormatter = [[NSDateFormatter alloc] init];
        [_monthFormatter setDateFormat:NSLocalizedString(@"MMMM yyyy", nil)];
        self.dayFormatter = [[NSDateFormatter alloc] init];
        [_dayFormatter setDateFormat:NSLocalizedString(@"EEEE", nil)];
        self.abbreviatedDayFormatter = [[NSDateFormatter alloc] init];
        [_abbreviatedDayFormatter setDateFormat:NSLocalizedString(@"E", nil)];
        self.timerFormatter = [[NSDateFormatter alloc] init];
        [_timerFormatter setDateFormat:NSLocalizedString(@"hh:mm", nil)];
        
        [self updateCurrentLocale];

#if TARGET_OS_IPHONE

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification 
                                                   object:nil];        
#else
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(currentLocaleDidChange:)
                                                     name:NSCurrentLocaleDidChangeNotification 
                                                   object:nil];        
        
#endif
    }
    
    return self;
}

- (NSString *)formatDate:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatLongDate:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatWeek:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatDay:(NSDate *)date {
    NSMutableString *formattedDate = [NSMutableString string];
    if (date != nil) {
        [formattedDate appendFormat:@"%@ ", [_dayFormatter stringFromDate:date]];
        [formattedDate appendString:[NSDateFormatter localizedStringFromDate:date
                                                                   dateStyle:NSDateFormatterLongStyle
                                                                   timeStyle:NSDateFormatterNoStyle]];
    }
    return formattedDate;
}

- (NSString *)formatAbbreviatedDay:(NSDate *)date {
    return [_abbreviatedDayFormatter stringFromDate:date];
}

- (NSString *)formatDayShort:(NSDate *)date {
    NSMutableString *formattedDate = [NSMutableString string];
    
    if (date != nil) {
        [formattedDate appendFormat:@"%@ - ", [_dayFormatter stringFromDate:date]];
        [formattedDate appendString:[NSDateFormatter localizedStringFromDate:date
                                                                   dateStyle:NSDateFormatterShortStyle
                                                                   timeStyle:NSDateFormatterNoStyle]];
    }
    return formattedDate;
}

- (NSString *)formatMonthAndYear:(NSDate *)date {
    return [_monthFormatter stringFromDate:date];
}

- (NSString *)formatMonth:(NSDate *)date {
    
    NSCalendar *calendar = [[TCSCalendarManager sharedInstance] calendarForCurrentThread];
    NSDateComponents *dateComponents = [calendar components:NSMonthCalendarUnit
                                                   fromDate:date];

    NSArray *months = [_monthFormatter monthSymbols];
    return [months objectAtIndex:dateComponents.month-1];
}

- (NSString *)formatTime:(NSDate *)date includeSeconds:(BOOL)seconds {
    
    NSDateFormatterStyle timeStyle = seconds ? NSDateFormatterMediumStyle : NSDateFormatterShortStyle;
    
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterNoStyle
                                          timeStyle:timeStyle];
}

- (NSString *)formatShortTimeInterval:(NSTimeInterval)timeInterval 
                          withSeconds:(BOOL)withSeconds {
    return [self formatTimeInterval:timeInterval
                        withSeconds:withSeconds
                         shortStyle:YES];
}

- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval 
                     withSeconds:(BOOL)withSeconds {
    return [self formatTimeInterval:timeInterval
                        withSeconds:withSeconds
                         shortStyle:NO];
}

- (NSString *)formatTimeIntervalShort:(NSTimeInterval)timeInterval 
                          withSeconds:(BOOL)withSeconds {
    return [self formatTimeInterval:timeInterval
                        timerActive:NO
                        showSeconds:withSeconds
                    forceSeparators:YES];
}

- (NSString *)formatLongTimer:(TCSTimer *)timer {
    return [self formatTimeInterval:timer.combinedTime withSeconds:NO shortStyle:NO];
}

- (NSString *)formatLongTimer:(TCSTimer *)timer
                withDateRange:(TCSDateRange *)dateRange {
    return [self formatTimeInterval:[timer combinedTimeForDateRange:dateRange]
                                     withSeconds:NO
                                     shortStyle:NO];
}

- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval 
                     withSeconds:(BOOL)withSeconds
                      shortStyle:(BOOL)shortStyle {
    return [self
            formatTimeInterval:timeInterval
            withSeconds:withSeconds
            showSecondsIfLessThanOneMinute:NO
            shortStyle:shortStyle];
}

- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval
                     withSeconds:(BOOL)withSeconds
  showSecondsIfLessThanOneMinute:(BOOL)showSecondsIfLessThanOneMinute
                      shortStyle:(BOOL)shortStyle {

    NSString *secondLabel;
    NSString *secondPluralLabel;
    NSString *minuteLabel;
    NSString *minutePluralLabel;
    NSString *hourLabel;
    NSString *hourPluralLabel;
    
    if (shortStyle == YES) {
        secondLabel = NSLocalizedString(@"s", nil);
        secondPluralLabel = NSLocalizedString(@"s", nil);
        minuteLabel = NSLocalizedString(@"m", nil);
        minutePluralLabel = NSLocalizedString(@"m", nil);
        hourLabel = NSLocalizedString(@"h", nil);
        hourPluralLabel = NSLocalizedString(@"h", nil);
    } else {
        secondLabel = NSLocalizedString(@" second", nil);
        secondPluralLabel = NSLocalizedString(@" seconds", nil);
        minuteLabel = NSLocalizedString(@" minute", nil);
        minutePluralLabel = NSLocalizedString(@" minutes", nil);
        hourLabel = NSLocalizedString(@" hour", nil);
        hourPluralLabel = NSLocalizedString(@" hours", nil);
    }
    
    if (timeInterval == 0 && (withSeconds == YES || showSecondsIfLessThanOneMinute)) {
        return [NSString stringWithFormat:NSLocalizedString(@"%ld%@", nil), 0, secondPluralLabel];
    }
    
    if (timeInterval < 60) {

        if (showSecondsIfLessThanOneMinute) {
            if (timeInterval == 1.0f) {
                return [NSString stringWithFormat:NSLocalizedString(@"%.0f%@", nil), timeInterval, secondLabel];
            } else {
                return [NSString stringWithFormat:NSLocalizedString(@"%.0f%@", nil), timeInterval, secondPluralLabel];
            }
        }

        if (withSeconds == NO) {
            return [NSString stringWithFormat:NSLocalizedString(@"%ld%@", nil), 0, minutePluralLabel];
        }
    }
    
    NSMutableString *elapsedTimeString = [NSMutableString string];
    
    TCSDurationParts durationParts = [self durationTimePartForTimeInterval:timeInterval];
    
    NSInteger hours = durationParts.hours;
    NSInteger minutes = durationParts.minutes;
    NSInteger seconds = durationParts.seconds;
        
    if (withSeconds == NO) {

        // round minutes
        if (seconds >= 30) {
            minutes++;
        }
        
        if (minutes == 60) {
            minutes = 0;
            hours++;
        }
    }
    
    if (hours == 1) {
        [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), hours, hourLabel];
    } else if (hours > 1) {
        [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), hours, hourPluralLabel];
    }
    
    if (minutes > 0) {

        if ([elapsedTimeString length] > 0) {
            [elapsedTimeString appendString:@" "];
        }
        if (minutes == 1) {
            [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), minutes, minuteLabel];
        } else if (minutes > 1) {
            [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), minutes, minutePluralLabel];
        }
    }
    
    if (seconds > 0 && withSeconds == YES) {
        if ([elapsedTimeString length] > 0) {
            [elapsedTimeString appendString:@" "];
        }
        if (seconds == 1) {
            [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), seconds, secondLabel];
        } else if (seconds > 1) {
            [elapsedTimeString appendFormat:NSLocalizedString(@"%ld%@", nil), seconds, secondPluralLabel];
        }
    }
    
    return elapsedTimeString;
}

- (TCSDurationParts)durationTimePartForTimeInterval:(NSTimeInterval)interval {
    
    NSTimeInterval timeInterval = round(interval);

    if (timeInterval <= 0.0f) {
        timeInterval = 0.0f;
    }
    
    TCSDurationParts durationParts;

    durationParts.hours =  timeInterval / 3600;
    timeInterval -= durationParts.hours * 3600;
    
    durationParts.minutes = timeInterval / 60;
    durationParts.seconds = timeInterval - durationParts.minutes * 60;

    return durationParts;
}

- (NSString *)formatTimestamp:(NSDate *)date {
    return [NSDateFormatter localizedStringFromDate:date
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)formatFullElapsedTime:(NSTimeInterval)elapsedTime {
    NSInteger days = elapsedTime / kTCOneDayInSeconds;

    NSTimeInterval seconds = elapsedTime - (days * kTCOneDayInSeconds);

    NSString *secondsText =
    [[TCSDateFormatManager sharedInstance]
     formatTimeInterval:seconds
     timerActive:NO
     showSeconds:YES
     forceSeparators:YES];

    NSString *elapsedTimeText;

    if (days == 1) {
        elapsedTimeText =
        [NSString stringWithFormat:NSLocalizedString(@"%d Day %@", nil), days, secondsText];
    } else if (days > 0) {
        elapsedTimeText =
        [NSString stringWithFormat:NSLocalizedString(@"%d Days %@", nil), days, secondsText];
    } else {
        elapsedTimeText = secondsText;
    }

    return elapsedTimeText;
}

- (NSString *)formatTimeInterval:(NSTimeInterval)interval timerActive:(BOOL)timerActive showSeconds:(BOOL)showSeconds forceSeparators:(BOOL)forceSeparators {
    
    NSTimeInterval timeInterval = round(interval);
    
    if (timeInterval <= 0.0f) {
        timeInterval = 0.0f;
    }

    if (showSeconds == NO && timeInterval < 60) {
        return [NSString stringWithFormat:NSLocalizedString(@"%.0fs", nil), timeInterval];
    }
    
    TCSDurationParts durationParts = [self durationTimePartForTimeInterval:interval];
    
    NSInteger hours = durationParts.hours;
    NSInteger minutes = durationParts.minutes;
    NSInteger seconds = durationParts.seconds;
    
    if (seconds < 0 || minutes < 0 || hours < 0) {
        NSLog(@"negative values!! elapsedTime: %f, hours: %d, minutes: %d, seconds: %d", interval, hours, minutes, seconds);
    }

    if (showSeconds == NO) {
        // round minutes
        if (seconds >= 30) {
            minutes++;
        }

        if (minutes == 60) {
            minutes = 0;
            hours++;
        }
    }

    if (timerActive == NO || _showTimeSeparators == YES || forceSeparators) {
        if (showSeconds == YES) {
            return [NSString stringWithFormat:@"%d:%02d:%02d", hours, minutes, seconds];
        } else {
            return [NSString stringWithFormat:@"%d:%02d", hours, minutes];
        }
    }
    
    if (showSeconds) {
        return [NSString stringWithFormat:@"%d %02d %02d", hours, minutes, seconds];
    } else {
        return [NSString stringWithFormat:@"%d %02d", hours, minutes];
    }
}

- (void)toggleTimerSeparators {
    _showTimeSeparators = !_showTimeSeparators;
}

- (void)updateCurrentLocale {
    _monthFormatter.locale = [NSLocale currentLocale];
    _dayFormatter.locale = [NSLocale currentLocale];
    _timerFormatter.locale = [NSLocale currentLocale];
    _abbreviatedDayFormatter.locale = [NSLocale currentLocale];
}

#if TARGET_OS_IPHONE

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    
    [self updateCurrentLocale];
}

#else

- (void)currentLocaleDidChange:(NSNotification *)notification {
    [self updateCurrentLocale];
}

#endif

#pragma mark - Singleton Methods

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSDateFormatManager alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
