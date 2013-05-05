//
//  TCSTimerReport.h
//  UberTimeService
//
//  Created by Nick Bolton on 3/31/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TCSTimerReportItem;
@class TCSDateRange;
@class TCSProject;

@interface TCSTimerReport : NSObject

@property (nonatomic, readonly) NSArray *dateRanges;
@property (nonatomic, readonly) TCSTimerReportItem *totalReportItem;

+ (TCSTimerReport *)timerReportForProjects:(NSArray *)projects
                                dateRanges:(NSArray *)dateRanges
                          filterEmptyItems:(BOOL)filterEmptyItems;

- (TCSTimerReportItem *)reportItemForProject:(TCSProject *)project
                              dateRangeIndex:(NSInteger)idx;
- (TCSTimerReportItem *)totalReportItemForDateRangeIndex:(NSInteger)idx;

- (void)updateReport;

@end
