//
//  TCAggregatedTime.m
//  UberTimeService
//
//  Created by Nick Bolton on 2/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import "TCSAggregatedTime.h"
#import "NSDate+Utilities.h"
#import "TCSDateFormatManager.h"
#import "TCSDateRange.h"
#import "TCSService.h"

@interface TCSAggregatedTime() {

    NSTimeInterval _elapsedTime;
    NSTimeInterval _rawElapsedTime;
    NSTimeInterval _recalculatedTimestamp;
}

@property (nonatomic, readwrite) NSArray *timers;

- (void)calculateElapsedTimes;

@end


@implementation TCSAggregatedTime 

- (id)initWithTimedEntity:(TCSTimedEntity *)timedEntity
                dateRange:(TCSDateRange *)dateRange {
    
    if ((self = [super init])) {
        self.timedEntity = timedEntity;;
        self.dateRange = dateRange;
        _elapsedTime = -1.0f;
        _rawElapsedTime = -1.0f;
    }
    
    return self;
}

- (id)initRootEntityWithApplications:(BOOL)applications
                           dateRange:(TCSDateRange *)dateRange {
    
    if ((self = [super init])) {
        self.timedEntity = nil;
        self.dateRange = dateRange;
        _elapsedTime = -1.0f;
        _rawElapsedTime = -1.0f;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    TCSAggregatedTime *aggregatedTime = [[TCSAggregatedTime alloc] init];
    aggregatedTime.timedEntity = self.timedEntity;
    aggregatedTime.dateRange = self.dateRange;
    aggregatedTime.selected = self.selected;
    aggregatedTime.expanded = self.expanded;
    return aggregatedTime;
}

- (NSDate *)startDate {
    return _dateRange.startDate;
}

- (NSDate *)endDate {
    return _dateRange.endDate;
}

- (BOOL)isEqual:(id)object {
    TCSAggregatedTime *that = object;
    
    if ([that isKindOfClass:[TCSAggregatedTime class]] == YES) {
        
        if (self.timedEntity != nil && that.timedEntity != nil) {
            return [self.timedEntity.objectID isEqual:that.timedEntity.objectID] &&
            [self.dateRange isEqual:that.dateRange];
        } else if (self.timedEntity != nil || that.timedEntity != nil) {
            return NO;
        } else {
            return [self.dateRange isEqual:that.dateRange];
        }
    }
    return NO;
}

- (BOOL)isEquivalent:(TCSAggregatedTime *)aggregatedTime {

    BOOL isEquivalent = [self isEqual:aggregatedTime] && self.timers.count == aggregatedTime.timers.count;

    if (isEquivalent) {

        for (NSInteger idx = 0; isEquivalent && idx < self.timers.count; idx++) {
            isEquivalent &= [self.timers[idx] isEquivalent:aggregatedTime.timers[idx]];
        }
    }

    return isEquivalent;
}

- (BOOL)containsTimer:(TCSTimer *)timer {

    for (TCSTimer *t in self.timers) {
        if ([t.objectID isEqual:timer.objectID]) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshOnBackground:(BOOL)background
                 completion:(void(^)(TCSAggregatedTime *aggregatedTime))completionBlock {

    __block typeof(self) this = self;

    void (^executionBlock)(void) = ^{
        [this calculateElapsedTimes];

        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{

                if (completionBlock) {
                    completionBlock(this);
                }

                _updating = NO;
            });
        }
    };

    if (background) {

        _updating = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       executionBlock);

    } else {
        executionBlock();
    }
}

- (CGFloat)elapsedTimeInHours {
    NSTimeInterval timeInterval = self.elapsedTime;
    CGFloat hours = timeInterval / 3600.0;
    return hours;
}

- (BOOL)isTimePeriodActive {
    
    TCSTimer *activeTimer;
    
    if (_timedEntity.active == YES ) {
        activeTimer = [TCSService sharedInstance].activeTimer;
        return [_dateRange.startDate isLessThanOrEqualTo:activeTimer.startTime] == YES &&
        [activeTimer.startTime isLessThanOrEqualTo:_dateRange.endDate] == YES;
    } else if (_timedEntity == nil) {
        TCSProject *activeProject = [TCSService sharedInstance].activeTimer.project;
        
        if (activeProject != nil) {
            activeTimer = [TCSService sharedInstance].activeTimer;
            if ([_dateRange.startDate isLessThanOrEqualTo:activeTimer.startTime] == YES &&
                [activeTimer.startTime isLessThanOrEqualTo:_dateRange.endDate] == YES) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)ensureTimeIsCalculated {
    if (_elapsedTime < 0) {
        [self calculateElapsedTimes];
    }
}

- (NSTimeInterval)elapsedTime {
    [self ensureTimeIsCalculated];

    if (self.isTimePeriodActive) {
        NSDate *now = [[TCSService sharedInstance] systemTime];
        NSTimeInterval timeSinceLastCalculated =
        [now timeIntervalSinceReferenceDate] - _recalculatedTimestamp;

        return _elapsedTime + timeSinceLastCalculated;
    }

    return _elapsedTime;
}

- (NSTimeInterval)rawElapsedTime {

    [self ensureTimeIsCalculated];

    if (self.isTimePeriodActive) {

        NSDate *now = [[TCSService sharedInstance] systemTime];

        NSTimeInterval timeSinceLastCalculated =
        [now timeIntervalSinceReferenceDate] - _recalculatedTimestamp;

        return _rawElapsedTime + timeSinceLastCalculated;
    }
    
    return _rawElapsedTime;
}

- (NSArray *)timers {
    [self ensureTimeIsCalculated];
    return _timers;
}

- (NSArray *)sortedTimerArray {    
    return [_timers sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TCSTimer *tc1 = obj1;
        TCSTimer *tc2 = obj2;
        return [tc1.startTime compare:tc2.startTime];
    }];
}
        
- (void)calculateElapsedTimes {

    self.timers = nil;

    NSDate *now = [[TCSService sharedInstance] systemTime];

    _recalculatedTimestamp = [now timeIntervalSinceReferenceDate];

    NSMutableArray *mutableTimerList;

    if (_timedEntity != nil) {
        mutableTimerList =
        [[[TCSService sharedInstance]
          timersForProjects:@[_timedEntity]
          fromDate:_dateRange.startDate
          toDate:_dateRange.endDate
          sortByStartTime:NO] mutableCopy];
    }

    _elapsedTime = 0.0f;
    _rawElapsedTime = 0.0f;

    NSInteger count = 0;
    NSMutableArray *timerIndexesToRemove = [NSMutableArray array];
    for (TCSTimer *timer in mutableTimerList) {

        NSTimeInterval combinedTime = [timer combinedTimeForDateRange:_dateRange];
        _rawElapsedTime += [timer timeIntervalForDateRange:_dateRange];
        _elapsedTime += combinedTime;

        if (timer.endTime != nil && combinedTime <= 0.0f) {
            [timerIndexesToRemove addObject:@(count)];
        }

        count++;
    }

    [timerIndexesToRemove
     enumerateObjectsWithOptions:NSEnumerationReverse
     usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         NSNumber *timerIndex = obj;
         [mutableTimerList removeObjectAtIndex:timerIndex.integerValue];
     }];

    self.timers = mutableTimerList;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%p) Entity: %@, timers: %@, startDate: %@, endDate: %@, rawTime: %.0f, totalTime: %.0f",
            self, [_timedEntity name], _timers, _dateRange.startDate, _dateRange.endDate, self.rawElapsedTime, self.elapsedTime];
}

@end
