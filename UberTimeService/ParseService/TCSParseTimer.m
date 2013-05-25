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

@dynamic message;
@dynamic projectID;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSTimer class];
}

- (NSString *)utsMessage {
    return self.message;
}

- (NSString *)utsProjectID {
    return self.projectID;
}

@end
