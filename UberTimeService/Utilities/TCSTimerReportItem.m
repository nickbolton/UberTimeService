//
//  TCSTimerReportItem.m
//  UberTimeService
//
//  Created by Nick Bolton on 3/31/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import "TCSTimerReportItem.h"
#import "TCSProject.h"
#import "TCSTimer.h"
#import "TCSService.h"
#import "NSDate+Utilities.h"

@interface TCSTimerReportItem() {

    NSTimeInterval _activeTimestamp;
}

@property (nonatomic, readwrite) NSArray *projects;
@property (nonatomic, readwrite) TCSDateRange *dateRange;
@property (nonatomic, readwrite) NSTimeInterval elapsedTime;

@end

@implementation TCSTimerReportItem

+ (TCSTimerReportItem *)reportItemWithProjects:(NSArray *)projects
                                     dateRange:(TCSDateRange *)dateRange
                                   elapsedTime:(NSTimeInterval)elapsedTime {

    return
    [[TCSTimerReportItem alloc]
     initWithProjects:projects
     dateRange:dateRange
     elapsedTime:elapsedTime];
}

- (id)initWithProjects:(NSArray *)projects
             dateRange:(TCSDateRange *)dateRange
           elapsedTime:(NSTimeInterval)elapsedTime {
    
    self = [super init];
    if (self) {
        self.projects = projects;
        self.dateRange = dateRange;
        self.elapsedTime = elapsedTime;

        _activeTimestamp = -1.0f;
        
        if (self.isActive) {
            _activeTimestamp = [NSDate timeIntervalSinceReferenceDate];
        }
    }
    return self;
}

- (BOOL)isActive {

    TCSTimer *activeTimer =
    [TCSService sharedInstance].activeTimer;

    if (activeTimer != nil) {

        NSDate *now = [[TCSService sharedInstance] systemTime];
        TCSProject *activeProject = activeTimer.project;

        for (TCSProject *project in _projects) {

//            NSLog(@"(1): %d", [project.objectID isEqual:activeProject.objectID]);
//            NSLog(@"(2): %d", activeTimer.endTime == nil);
//            NSLog(@"(3): %d", [activeTimer.startTime isLessThanOrEqualTo:_dateRange.endDate]);
//            NSLog(@"(4): %d", [now isGreaterThanOrEqualTo:_dateRange.startDate]);

            if ([project.objectID isEqual:activeProject.objectID] &&
                activeTimer.endTime == nil &&
                [activeTimer.startTime isLessThanOrEqualTo:_dateRange.endDate] &&
                [now isGreaterThanOrEqualTo:_dateRange.startDate]) {
                return YES;
            }
        }
    }

    return NO;
}

- (void)updateTimestamp {

    for (TCSProject *project in _projects) {
        if (project.isActive) {
            TCSTimer *activeTimer = [TCSService sharedInstance].activeTimer;
            _activeTimestamp = activeTimer.startTime.timeIntervalSinceReferenceDate;
        }
    }
}

- (void)updateActiveTime {

    if (self.isActive == NO) {

        if (_activeTimestamp >= 0.0f) {

            NSTimeInterval timeSinceLastCalculated =
            [NSDate timeIntervalSinceReferenceDate] - _activeTimestamp;

            _elapsedTime += timeSinceLastCalculated;
        }
        _activeTimestamp = -1.0f;
    } else if (_activeTimestamp < 0.0f) {
        [self updateTimestamp];
    }
}

- (NSTimeInterval)elapsedTime {

    if (self.isActive) {

        if (_activeTimestamp < 0.0f) {
            [self updateTimestamp];
        }

        NSTimeInterval timeSinceLastCalculated =
        [NSDate timeIntervalSinceReferenceDate] - _activeTimestamp;

        _elapsedTime += timeSinceLastCalculated;

        _activeTimestamp = [NSDate timeIntervalSinceReferenceDate];
    }

    return _elapsedTime;
}

@end
