//
//  TCSAggregatedTime.h
//  Timecop
//
//  Created by Nick Bolton on 2/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "TCTimer.h"

@class TCSProject;
@class TCSTimer;
@class TCSTimedEntity;
@class TCSDateRange;

@interface TCSAggregatedTime : NSObject <NSCopying>

@property (nonatomic, retain) TCSTimedEntity *timedEntity;
@property (nonatomic, assign) BOOL applications;
@property (nonatomic, retain) TCSDateRange *dateRange;
@property (nonatomic, readonly) NSDate *startDate;
@property (nonatomic, readonly) NSDate *endDate;
@property (nonatomic, retain, readonly) NSArray *timers;
@property (nonatomic, assign, readonly) NSTimeInterval elapsedTime;
@property (nonatomic, assign, readonly) NSTimeInterval rawElapsedTime;
@property (nonatomic, assign, readonly, getter = isTimePeriodActive) BOOL timePeriodActive;
@property (nonatomic, assign) BOOL selected;
@property (nonatomic, assign, getter = isUpdating) BOOL updating;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) NSTimeInterval recalculatedTimestamp;

- (id)initWithTimedEntity:(TCSTimedEntity *)timedEntity
                dateRange:(TCSDateRange *)dateRange;

- (id)initRootEntityWithApplications:(BOOL)applications
                dateRange:(TCSDateRange *)dateRange;

- (CGFloat)elapsedTimeInHours;
- (BOOL)containsTimer:(TCSTimer *)timer;
- (void)refreshOnBackground:(BOOL)background
                 completion:(void(^)(TCSAggregatedTime *aggregatedTime))completionBlock;
- (BOOL)containsComments;
- (NSArray *)sortedTimerCommentArray;
- (NSArray *)sortedTimerArray;
- (void)ensureTimeIsCalculated;

@end
