//
//  TCSTimerReportItem.h
//  UberTimeService
//
//  Created by Nick Bolton on 3/31/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCSDateRange;

@interface TCSTimerReportItem : NSObject

@property (nonatomic, readonly) NSArray *projects;
@property (nonatomic, readonly) TCSDateRange *dateRange;
@property (nonatomic, readonly, getter = isActive) BOOL active;
@property (nonatomic, readonly) NSTimeInterval elapsedTime;
@property (nonatomic, readonly) NSArray *timers;

+ (TCSTimerReportItem *)reportItemWithProjects:(NSArray *)projects
                                     dateRange:(TCSDateRange *)dateRange
                                   elapsedTime:(NSTimeInterval)elapsedTime
                                        timers:(NSArray *)timers;

- (void)updateActiveTime;

@end
