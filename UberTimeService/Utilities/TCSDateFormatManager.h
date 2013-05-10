//
//  TCSDateFormatManager.h
//  UberTimeService
//
//  Created by Nick Bolton on 12/18/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

@class TCSTimer;

typedef struct {
    
    NSInteger hours;
    NSInteger minutes;
    NSInteger seconds;
    
} TCSDurationParts;

@class TCSDateRange;

@interface TCSDateFormatManager : NSObject

+ (TCSDateFormatManager *) sharedInstance;

@property (nonatomic) BOOL showTimeSeparators;

- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval 
                     withSeconds:(BOOL)withSeconds;
- (NSString *)formatShortTimeInterval:(NSTimeInterval)timeInterval 
                     withSeconds:(BOOL)withSeconds;
- (NSString *)formatDate:(NSDate *)date;
- (NSString *)formatLongDate:(NSDate *)date;
- (NSString *)formatDay:(NSDate *)date;
- (NSString *)formatDayShort:(NSDate *)date;
- (NSString *)formatAbbreviatedDay:(NSDate *)date;
- (NSString *)formatWeek:(NSDate *)date;
- (NSString *)formatMonth:(NSDate *)date;
- (NSString *)formatMonthAndYear:(NSDate *)date;
- (NSString *)formatTime:(NSDate *)date includeSeconds:(BOOL)seconds;
- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval 
                     withSeconds:(BOOL)withSeconds
                      shortStyle:(BOOL)shortStyle;
- (NSString *)formatTimeIntervalShort:(NSTimeInterval)timeInterval 
                          withSeconds:(BOOL)withSeconds;
- (NSString *)formatTimestamp:(NSDate *)date;
- (NSString *)formatLongTimer:(TCSTimer *)timer;
- (NSString *)formatLongTimer:(TCSTimer *)timer
                withDateRange:(TCSDateRange *)dateRange;
- (NSString *)formatFullElapsedTime:(NSTimeInterval)elapsedTime;
- (NSString *)formatTimeInterval:(NSTimeInterval)interval
                     timerActive:(BOOL)timerActive 
                     showSeconds:(BOOL)showSeconds 
                 forceSeparators:(BOOL)forceSeparators;
- (NSString *)formatTimeInterval:(NSTimeInterval)timeInterval
                     withSeconds:(BOOL)withSeconds
  showSecondsIfLessThanOneMinute:(BOOL)showSecondsIfLessThanOneMinute
                      shortStyle:(BOOL)shortStyle;

- (TCSDurationParts)durationTimePartForTimeInterval:(NSTimeInterval)timeInterval;

- (void)toggleTimerSeparators;

@end
