//
//  TCSDateRange.m
//  Timecop
//
//  Created by Nick Bolton on 3/24/12.
//  Copyright (c) 2012 Pixelbleed LLC. All rights reserved.
//

#import "TCSDateRange.h"
#import "NSDate+Utilities.h"

@interface TCSDateRange()

@property (nonatomic) NSUInteger hashValue;

@end

@implementation TCSDateRange

+ (id)dateRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {    
    return
    [[TCSDateRange alloc]
     initWithStartDate:startDate
     endDate:endDate];
}

- (id)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    
    self = [super init];
    
    if (self != nil) {
        self.startDate = [startDate midnight];
        self.endDate = [endDate endOfDay];
        _hashValue = [self description].hash;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return [[TCSDateRange alloc]
            initWithStartDate:self.startDate
            endDate:self.endDate];
}

- (NSUInteger)hash {
    return _hashValue;
}

- (BOOL)isEqual:(id)object {
    TCSDateRange *that = object;
    
    if ([that isKindOfClass:[TCSDateRange class]] == YES) {
        return [self.startDate isEqualToDate:that.startDate] && [self.endDate isEqualToDate:self.endDate];
    }
    return NO;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ - %@", _startDate, _endDate];
}

- (BOOL)dateWithinRange:(NSDate *)date {
    return
    [date isGreaterThanOrEqualTo:_startDate] &&
    [date isLessThanOrEqualTo:_endDate];
}

@end
