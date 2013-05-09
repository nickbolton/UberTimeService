//
//  TCSAggregatedTimeList.h
//  Timecop-iOS
//
//  Created by Nick Bolton on 6/4/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSAggregatedTime.h"

@class TCSDateRange;

@interface TCSAggregatedTimeList : TCSAggregatedTime

@property (nonatomic, readonly) NSArray *aggregatedTimeList;
@property (nonatomic, readonly) NSArray *timedEntities;

- (id)initWithTimedEntities:(NSArray *)timedEntities andDateRange:(TCSDateRange *)dateRange;

- (void)addAggregatedTime:(TCSAggregatedTime *)aggregatedTime;

@end
