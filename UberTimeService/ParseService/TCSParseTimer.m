//
//  TCSParseTimer.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimer.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseTimer

@dynamic startTime;
@dynamic endTime;
@dynamic message;
@dynamic adjustment;
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

- (NSString *)utsMessage {
    return self.message;
}

- (NSTimeInterval)utsAdjustment {
    return self.adjustment;
}

- (NSString *)utsProjectID {
    return self.projectID;
}

@end
