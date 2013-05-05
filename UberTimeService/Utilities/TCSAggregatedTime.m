//
//  TCAggregatedTime.m
//  Timecop
//
//  Created by Nick Bolton on 2/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import "TCAggregatedTime.h"
#import "TCTimedEntity.h"
#import "TCGroup.h"
#import "TCProject.h"
#import "NSDate-Utilities.h"
#import "TCDataModelEntityManager.h"
#import "TCTimerComment.h"
#import "TCDateFormatManager.h"
#import "TCDateRange.h"

@interface TCAggregatedTime() {
    BOOL timePeriodActive_;
    NSTimeInterval elapsedTime_;
    NSTimeInterval rawElapsedTime_;
    NSArray *timers_;
}

- (void)calculateElapsedTimes;
@end


@implementation TCAggregatedTime 

@synthesize timedEntity = timedEntity_;
@synthesize applications = applications_;
@synthesize dateRange = dateRange_;
@synthesize expanded = expanded_;
@synthesize selected = selected_;
@synthesize recalculatedTimestamp = recalculatedTimestamp_;

- (id)initWithTimedEntity:(TCTimedEntity *)timedEntity
                dateRange:(TCDateRange *)dateRange {
    
    if ((self = [super init])) {
        self.timedEntity = timedEntity;;
        self.dateRange = dateRange;
        elapsedTime_ = -1.0f;
        rawElapsedTime_ = -1.0f;
        applications_ = NO;
    }
    
    return self;
}

- (id)initRootEntityWithApplications:(BOOL)applications
                           dateRange:(TCDateRange *)dateRange {
    
    if ((self = [super init])) {
        self.timedEntity = nil;
        applications_ = applications;
        self.dateRange = dateRange;
        elapsedTime_ = -1.0f;
        rawElapsedTime_ = -1.0f;
    }
    
    return self;
}

- (void)dealloc {
    [timedEntity_ release], timedEntity_ = nil;
    [dateRange_ release], dateRange_ = nil;
    [timers_ release], timers_ = nil;
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    TCAggregatedTime *aggregatedTime = [[TCAggregatedTime alloc] init];
    aggregatedTime.timedEntity = self.timedEntity;
    aggregatedTime.dateRange = self.dateRange;
    aggregatedTime.selected = self.selected;
    aggregatedTime.expanded = self.expanded;
    aggregatedTime.applications = self.applications;
    return aggregatedTime;
}

- (NSDate *)startDate {
    return dateRange_.startDate;
}

- (NSDate *)endDate {
    return dateRange_.endDate;
}

- (BOOL)isEqual:(id)object {
    TCAggregatedTime *that = object;
    
    if ([that isKindOfClass:[TCAggregatedTime class]] == YES) {
        
        if (self.timedEntity != nil && that.timedEntity != nil) {
            return [self.timedEntity.objectID isEqual:that.timedEntity.objectID] &&
            [self.dateRange isEqual:that.dateRange];
        } else if (self.timedEntity != nil || that.timedEntity != nil) {
            return NO;
        } else {
            return self.applications == that.applications &&
            [self.dateRange isEqual:that.dateRange];
        }
    }
    return NO;
}

- (BOOL)containsTimer:(TCTimer *)timer {    

    for (TCTimer *t in self.timers) {
        if ([t.objectID isEqual:timer.objectID]) {
            return YES;
        }
    }
    return NO;
}

- (void)refreshOnBackground:(BOOL)background
                 completion:(void(^)(TCAggregatedTime *aggregatedTime))completionBlock {

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
    
    TCTimer *activeTimer;
    
    if (timedEntity_.active == YES ) {
        activeTimer = timedEntity_.activeTimer;
        return [dateRange_.startDate isLessThanOrEqualTo:activeTimer.startTime] == YES &&
        [activeTimer.startTime isLessThanOrEqualTo:dateRange_.endDate] == YES;
    } else if (timedEntity_ == nil) {
        NSArray *activeProjects = [[TCDataModelEntityManager sharedInstance] activeProjects];
        if ([activeProjects count] > 0) {
            for (TCProject *project in activeProjects) {
                activeTimer = timedEntity_.activeTimer;
                if ([dateRange_.startDate isLessThanOrEqualTo:activeTimer.startTime] == YES &&
                    [activeTimer.startTime isLessThanOrEqualTo:dateRange_.endDate] == YES) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

- (void)ensureTimeIsCalculated {
    if (elapsedTime_ < 0) {
        [self calculateElapsedTimes];
    }
}

- (NSTimeInterval)elapsedTime {
    [self ensureTimeIsCalculated];

    if (self.isTimePeriodActive) {
        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - recalculatedTimestamp_;

        return elapsedTime_ + timeSinceLastCalculated;
    }

    return elapsedTime_;
}

- (NSTimeInterval)rawElapsedTime {

    [self ensureTimeIsCalculated];

    if (self.isTimePeriodActive) {
        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - recalculatedTimestamp_;

        return rawElapsedTime_ + timeSinceLastCalculated;
    }
    
    return rawElapsedTime_;
}

- (NSArray *)timers {
    [self ensureTimeIsCalculated];
    return timers_;
}

- (NSArray *)sortedTimerArray {    
    return [timers_ sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TCTimer *tc1 = obj1;
        TCTimer *tc2 = obj2;
        return [tc1.startTime compare:tc2.startTime];
    }];
}

- (NSArray *)sortedTimerCommentArray {
    NSMutableArray *content = [NSMutableArray array];
    TCTimerComment *timerComment;
    
    for (TCTimer *timer in timers_) {
        timerComment = [[TCTimerComment alloc] init];
        timerComment.timestamp = timer.startTime;
        timerComment.timestampString = [[TCDateFormatManager sharedInstance] formatTime:timer.startTime includeSeconds:YES];
        timerComment.comment = timer.message != nil ? timer.message : @"";
        [content addObject:timerComment];
        [timerComment release];
    }
    
    return [content sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        TCTimerComment *tc1 = obj1;
        TCTimerComment *tc2 = obj2;
        return [tc1.timestamp compare:tc2.timestamp];
    }];
}

- (BOOL)containsComments {
    
    for (TCTimer *timer in timers_) {
        if ([timer.message length] > 0) {
            return YES;
        }
    }
    
    return NO;
}

- (TCTimer *)singleTimerOwner {
    TCTimer *owner = nil;
    TCTimer *firstTimer = nil;
    
    for (TCTimer *timer in timers_) {
        if (firstTimer == nil) {
            firstTimer = timer;
        }
        if ([timer.message length] > 0 || timer.externalId != nil) {
            owner = timer;
            break;
        }
    }
    
    if (owner == nil) {
        owner = firstTimer;
    }
    
    return owner;
}
        
- (void)calculateElapsedTimes {

    [timers_ release], timers_ = nil;

    recalculatedTimestamp_ = [NSDate timeIntervalSinceReferenceDate];

    NSMutableArray *mutableTimerList;

    if (timedEntity_ != nil) {
        mutableTimerList = [[[TCDataModelEntityManager sharedInstance]
                             timersForEntity:timedEntity_
                             fromDate:dateRange_.startDate
                             toDate:dateRange_.endDate] mutableCopy];
    } else {
        mutableTimerList = [[[TCDataModelEntityManager sharedInstance]
                             timersForRootEntityWithApplications:applications_
                             fromDate:dateRange_.startDate
                             toDate:dateRange_.endDate] mutableCopy];
    }

    elapsedTime_ = 0.0f;
    rawElapsedTime_ = 0.0f;

    NSInteger count = 0;
    NSMutableArray *timerIndexesToRemove = [NSMutableArray array];
    for (TCTimer *timer in mutableTimerList) {

        NSTimeInterval combinedTime = [timer combinedTimeForDateRange:dateRange_];
        rawElapsedTime_ += [timer timeIntervalForDateRange:dateRange_];
        elapsedTime_ += combinedTime;

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

    timers_ = mutableTimerList;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(%p) Entity: %@, applications: %d, timers: %@, startDate: %@, endDate: %@, rawTime: %.0f, totalTime: %.0f",
            self, [timedEntity_ name], applications_, timers_, dateRange_.startDate, dateRange_.endDate, self.rawElapsedTime, self.elapsedTime];
}

@end
