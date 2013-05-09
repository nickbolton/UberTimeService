//
//  TCSAggregatedTimeList.m
//  Timecop-iOS
//
//  Created by Nick Bolton on 6/4/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "TCSAggregatedTimeList.h"
#import "TCSDateRange.h"

@interface TCSAggregatedTimeList() {
    
    __block CGFloat _totalElapsedTimeInHours;
    __block NSTimeInterval _totalElapsedTime;
    __block NSTimeInterval _totalRawElapsedTime;
    __block NSMutableArray *_totalTimers;
    __block NSMutableArray *_timedEntities;
}

@property (nonatomic, strong) NSMutableArray *_aggregatedTimeList;

- (void)calculateTotalTimes;
@end

@implementation TCSAggregatedTimeList

- (id)initWithTimedEntities:(NSArray *)timedEntities 
               andDateRange:(TCSDateRange *)dateRange {
    self = [super initWithTimedEntity:nil dateRange:dateRange];
    
    if (self != nil) {
        self._aggregatedTimeList = [NSMutableArray array];
        self.dateRange = dateRange;
        _totalTimers = [NSMutableArray array];
        _timedEntities = [NSMutableArray array];
        
        _totalElapsedTimeInHours = -1.0f;
        _totalElapsedTime = -1.0f;
        _totalRawElapsedTime = -1.0f;
                
        for (TCSTimedEntity *timedEntity in timedEntities) {

            TCSAggregatedTime *aggregatedTime =
            [[TCSAggregatedTime alloc]
             initWithTimedEntity:timedEntity
             dateRange:dateRange];

            [self addAggregatedTime:aggregatedTime];
        }
    }

    return self;
}

- (void)addAggregatedTime:(TCSAggregatedTime *)aggregatedTime {
    [__aggregatedTimeList addObject:aggregatedTime];
    [_timedEntities addObject:aggregatedTime.timedEntity];
        
    for (TCSTimer *timer in aggregatedTime.timers) {
        if ([_totalTimers containsObject:timer] == NO) {
            [_totalTimers addObject:timer];
        }
    }
}

- (NSArray *)timedEntities {
    return _timedEntities;
}

- (NSArray *)aggregatedTimeList {
    return __aggregatedTimeList;
}

- (NSArray *)timers {
    return _totalTimers;
}

- (NSTimeInterval)rawElapsedTime {
    [self calculateTotalTimes];

    if (self.isTimePeriodActive) {
        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - self.recalculatedTimestamp;

        return _totalRawElapsedTime + timeSinceLastCalculated;
    }

    return _totalRawElapsedTime;    
}

- (NSTimeInterval)elapsedTime {
    [self calculateTotalTimes];

    if (self.isTimePeriodActive) {
        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - self.recalculatedTimestamp;

        return _totalElapsedTime + timeSinceLastCalculated;
    }

    return _totalElapsedTime;
}

- (CGFloat)elapsedTimeInHours {
    [self calculateTotalTimes];

    if (self.isTimePeriodActive) {
        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - self.recalculatedTimestamp;

        return _totalElapsedTimeInHours + (timeSinceLastCalculated / 3600.0f);
    }

    return _totalElapsedTimeInHours;
}

- (BOOL)containsTimer:(TCSTimer *)timer {
    
    for (TCSAggregatedTime *aggregatedTime in __aggregatedTimeList) {
        if ([aggregatedTime containsTimer:timer]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)calculateTotalTimes {
    if (_totalElapsedTime < 0.0f || 
        _totalElapsedTimeInHours < 0.0f || 
        _totalRawElapsedTime < 0.0f) {

        @synchronized (self) {
            self.recalculatedTimestamp = [NSDate timeIntervalSinceReferenceDate];

            _totalElapsedTime = 0.0f;
            _totalElapsedTimeInHours = 0.0f;
            _totalRawElapsedTime = 0.0f;

            for (TCSAggregatedTime *aggregatedTime in self.aggregatedTimeList) {
                _totalElapsedTimeInHours += aggregatedTime.elapsedTimeInHours;
                _totalElapsedTime += aggregatedTime.elapsedTime;
                _totalRawElapsedTime += aggregatedTime.rawElapsedTime;
            }
        }
    }
}

- (void)ensureTimeIsCalculated {
    for (TCSAggregatedTime *aggregatedTime in self.aggregatedTimeList) {
        [aggregatedTime ensureTimeIsCalculated];
    }
}

- (BOOL)isTimePeriodActive {
    
    for (TCSAggregatedTime *aggregatedTime in self.aggregatedTimeList) {
        if (aggregatedTime.isTimePeriodActive) {
            return YES;
        }
    }
    
    return NO;
}

- (void)refreshOnBackground:(BOOL)background
                 completion:(void(^)(TCSAggregatedTime *aggregatedTime))completionBlock {

    if (self.updating) return;
    
    _totalElapsedTimeInHours = 0.0f;
    _totalElapsedTime = 0.0f;
    _totalRawElapsedTime = 0.0f;
    [_totalTimers removeAllObjects];

    __block typeof(self) this = self;

    void (^executionBlock)(void) = ^{
        for (TCSAggregatedTime *aggregatedTime in this._aggregatedTimeList) {
            [aggregatedTime refreshOnBackground:NO completion:nil];

            [_totalTimers addObjectsFromArray:aggregatedTime.timers];
            _totalElapsedTimeInHours += aggregatedTime.elapsedTimeInHours;
            _totalElapsedTime += aggregatedTime.elapsedTime;
            _totalRawElapsedTime += aggregatedTime.rawElapsedTime;

            self.updating = NO;
        }

        self.recalculatedTimestamp = [NSDate timeIntervalSinceReferenceDate];

        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{

                if (completionBlock) {
                    completionBlock(this);
                }
            });
        }
    };

    if (background) {

        self.updating = YES;

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       executionBlock);
    } else {
        executionBlock();
    }
}

- (BOOL)containsComments {
    assert(NO);
}

- (NSArray *)sortedTimerCommentArray {
    assert(NO);
}

- (NSArray *)sortedTimerArray {
    assert(NO);
}

@end
