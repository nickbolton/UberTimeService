//
//  TCSParseTimer.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimer.h"
#if TARGET_OS_IPHONE
#import <Parse/PFObject+Subclass.h>
#else
#import <ParseOSX/PFObject+Subclass.h>
#endif

@implementation TCSParseTimer

@dynamic startTime;
@dynamic endTime;
@dynamic adjustment;
@dynamic message;
@dynamic projectID;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSTimer class];
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

- (NSString *)utsMessage {
    return self.message;
}

- (NSString *)utsProjectID {
    return self.projectID;
}

- (BOOL)startTimeProvided {
    return YES;
}

- (NSTimeInterval)utsDuration {
    return 0.0f;
}

@end
