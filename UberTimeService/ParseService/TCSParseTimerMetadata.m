//
//  TCSParseTimerMetadata.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/25/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimerMetadata.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseTimerMetadata

@dynamic startTime;
@dynamic endTime;
@dynamic adjustment;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (NSDate *)utsStartTime {
    return self.startTime;
}

- (NSDate *)utsEndTime {
    return self.endTime;
}

- (NSTimeInterval)utsAdjustment {
    return self.adjustment;
}

@end
