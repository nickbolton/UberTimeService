//
//  TCSTimer.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSBaseEntity.h"

@class TCSProject;
@class TCSDateRange;

@interface TCSTimer : TCSBaseEntity

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (nonatomic, strong) NSString *message;
@property (nonatomic) NSTimeInterval adjustment;

@property (nonatomic, strong) TCSProject *project;

- (NSTimeInterval)timeInterval;
- (NSTimeInterval)timeIntervalForDateRange:(TCSDateRange *)dateRange;
- (CGFloat)elapsedTimeInHours;
- (NSTimeInterval)combinedTime;
- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange;

+ (NSTimeInterval)combinedTimeForStartTime:(NSDate *)startTime
                                   endTime:(NSDate *)endDate
                                adjustment:(NSTimeInterval)adjustment;

@end
