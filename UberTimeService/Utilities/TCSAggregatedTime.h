//
//  TCSAggregatedTime.h
//  UberTimeService
//
//  Created by Nick Bolton on 2/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TCSProject;
@class TCSTimer;
@class TCSTimedEntity;
@class TCSDateRange;

@interface TCSAggregatedTime : NSObject <NSCopying>

@property (nonatomic, strong) TCSTimedEntity *timedEntity;
@property (nonatomic, strong) TCSDateRange *dateRange;
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
@property (nonatomic, readonly) NSArray *timers;
@property (nonatomic, readonly) NSTimeInterval elapsedTime;
@property (nonatomic, readonly) NSTimeInterval rawElapsedTime;
@property (nonatomic, readonly, getter = isTimePeriodActive) BOOL timePeriodActive;
@property (nonatomic) BOOL selected;
@property (nonatomic, getter = isUpdating) BOOL updating;
@property (nonatomic) BOOL expanded;
@property (nonatomic) NSTimeInterval recalculatedTimestamp;

- (id)initWithTimedEntity:(TCSTimedEntity *)timedEntity
                dateRange:(TCSDateRange *)dateRange;

- (id)initRootEntityWithApplications:(BOOL)applications
                dateRange:(TCSDateRange *)dateRange;

- (BOOL)isEquivalent:(TCSAggregatedTime *)aggregatedTime;

- (CGFloat)elapsedTimeInHours;
- (BOOL)containsTimer:(TCSTimer *)timer;
- (void)refreshOnBackground:(BOOL)background
                 completion:(void(^)(TCSAggregatedTime *aggregatedTime))completionBlock;
- (NSArray *)sortedTimerArray;
- (void)ensureTimeIsCalculated;

@end
