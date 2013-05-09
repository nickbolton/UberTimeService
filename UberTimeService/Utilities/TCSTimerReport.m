//
//  TCSTimerReport.m
//  UberTimeService
//
//  Created by Nick Bolton on 3/31/13.
//  Copyright (c) 2013 Pixelbleed LLC. All rights reserved.
//

#import "TCSTimerReport.h"
#import "TCSDateRange.h"
#import "NSDate+Utilities.h"
#import "TCSTimerReportItem.h"
#import "TCSTimer.h"
#import "TCSProject.h"
#import "TCSService.h"

@interface TCSTimerReport()

@property (nonatomic, strong) NSMutableArray *availableDateRanges;
@property (nonatomic, readwrite) TCSTimerReportItem *totalReportItem;
@property (nonatomic, strong) NSMutableArray *dateRangeReportItems;
@property (nonatomic, strong) NSMutableArray *projectReportItems;

@end

@implementation TCSTimerReport

+ (TCSTimerReport *)timerReportForProjects:(NSArray *)projects
                                dateRanges:(NSArray *)dateRanges
                          filterEmptyItems:(BOOL)filterEmptyItems {

    return
    [[TCSTimerReport alloc]
     initWithProjects:projects
     andDateRanges:dateRanges
     filterEmptyItems:filterEmptyItems];
}

- (id)initWithProjects:(NSArray *)projects
         andDateRanges:(NSArray *)dateRanges
      filterEmptyItems:(BOOL)filterEmptyItems {

    self = [super init];
    if (self) {
        self.availableDateRanges = [NSMutableArray array];
        self.dateRangeReportItems = [NSMutableArray array];
        self.projectReportItems = [NSMutableArray array];

        [self
         buildReportFromProjects:projects
         andDateRanges:dateRanges
         filterEmptyItems:filterEmptyItems];
    }
    return self;
}

- (void)buildReportFromProjects:(NSArray *)projects
                  andDateRanges:(NSArray *)dateRanges
               filterEmptyItems:(BOOL)filterEmptyItems {

    NSDate *earliestDate = nil;
    NSDate *latestDate = nil;

    for (TCSDateRange *dateRange in dateRanges) {

        if (earliestDate == nil || [dateRange.startDate isLessThan:earliestDate]) {
            earliestDate = dateRange.startDate;
        }

        if (latestDate == nil || [dateRange.endDate isGreaterThan:latestDate]) {
            latestDate = dateRange.endDate;
        }
    }

    NSMutableSet *filteredProjects = [NSMutableSet set];

    NSArray *timers =
    [[TCSService sharedInstance]
     timersForProjects:projects
     fromDate:earliestDate
     toDate:latestDate
     sortByStartTime:YES];

    NSMutableDictionary *projectTimers = [NSMutableDictionary dictionary];

    for (TCSTimer *timer in timers) {

        NSString *projectKey =
        timer.project.objectID.URIRepresentation.absoluteString;

        NSMutableArray *timerList = projectTimers[projectKey];
        if (timerList == nil) {
            timerList = [NSMutableArray array];
            projectTimers[projectKey] = timerList;
        }

        [timerList addObject:timer];
    }

    NSTimeInterval elapsedTime = 0.0f;

    for (TCSDateRange *dateRange in dateRanges) {

        TCSTimerReportItem *reportItem =
        [self
         buildReportItem:dateRange
         projects:projects
         projectTimers:projectTimers
         filterEmptyItems:filterEmptyItems];

        if (reportItem != nil) {
            [_availableDateRanges addObject:dateRange];
            elapsedTime += reportItem.elapsedTime;

            for (TCSProject *project in reportItem.projects) {
                [filteredProjects addObject:project];
            }
        }
    }

    TCSDateRange *totalDateRange =
    [TCSDateRange dateRangeWithStartDate:earliestDate endDate:latestDate];

    self.totalReportItem =
    [TCSTimerReportItem
     reportItemWithProjects:filteredProjects.allObjects
     dateRange:totalDateRange
     elapsedTime:elapsedTime];
}

- (TCSTimerReportItem *)buildReportItem:(TCSDateRange *)dateRange
                               projects:(NSArray *)projects
                          projectTimers:(NSDictionary *)projectTimers
                       filterEmptyItems:(BOOL)filterEmptyItems {

    NSTimeInterval elapsedTime = 0.0f;

    NSMutableArray *projectsInReport = [NSMutableArray array];

    NSMutableDictionary *projectItems = [NSMutableDictionary dictionary];

    for (TCSProject *project in projects) {

        NSString *projectKey =
        project.objectID.URIRepresentation.absoluteString;

        NSArray *timers = projectTimers[projectKey];

        TCSTimerReportItem *reportItem =
        [self
         buildReportItem:dateRange
         project:project
         timers:timers
         filterEmptyItems:filterEmptyItems];

        if (filterEmptyItems == NO || reportItem.elapsedTime > 0.0f) {
            [projectsInReport addObject:project];

            projectItems[projectKey] = reportItem;
            elapsedTime += reportItem.elapsedTime;
        }
    }

    TCSTimerReportItem *reportItem = nil;

    if (filterEmptyItems == NO || elapsedTime > 0.0f) {

        [_projectReportItems addObject:projectItems];

        reportItem =
        [TCSTimerReportItem
         reportItemWithProjects:projectsInReport
         dateRange:dateRange
         elapsedTime:elapsedTime];

        [_dateRangeReportItems addObject:reportItem];
    }

    return reportItem;
}

- (TCSTimerReportItem *)buildReportItem:(TCSDateRange *)dateRange
                                project:(TCSProject *)project
                                 timers:(NSArray *)timers
                       filterEmptyItems:(BOOL)filterEmptyItems {

    NSTimeInterval elapsedTime = 0.0f;

    for (TCSTimer *timer in timers) {
        NSTimeInterval combinedTime = [timer combinedTimeForDateRange:dateRange];

        if (combinedTime > 0.0f) {
            elapsedTime += combinedTime;
        }
    }

    TCSTimerReportItem *reportItem = nil;

    if (filterEmptyItems == NO || elapsedTime > 0.0f) {

        NSArray *reportTimers = nil;
        
        if ([dateRange.startDate isEqualToDate:dateRange.endDate.midnight]) {
            reportTimers = timers;
        }

        reportItem =
        [TCSTimerReportItem
         reportItemWithProjects:@[project]
         dateRange:dateRange
         elapsedTime:elapsedTime
         timers:reportTimers];
    }

    return reportItem;
}

- (void)updateReport {

    [_totalReportItem updateActiveTime];

    for (TCSTimerReportItem *reportItem in _dateRangeReportItems) {
        [reportItem updateActiveTime];
    }

    for (NSDictionary *item in _projectReportItems) {
        for (TCSTimerReportItem *reportItem in item.allValues) {
            [reportItem updateActiveTime];
        }
    }
}

- (NSArray *)dateRanges {
    return _availableDateRanges;
}

- (TCSTimerReportItem *)reportItemForProject:(TCSProject *)project
                             dateRangeIndex:(NSInteger)idx {

    if (idx >= 0 && idx < _projectReportItems.count) {
        NSString *projectKey =
        project.objectID.URIRepresentation.absoluteString;
        NSDictionary *projectItems = _projectReportItems[idx];
        return projectItems[projectKey];
    }

    return nil;
}

- (TCSTimerReportItem *)totalReportItemForDateRangeIndex:(NSInteger)idx {
    if (idx >= 0 && idx < _dateRangeReportItems.count) {
        return _dateRangeReportItems[idx];
    }
    return nil;
}

@end
