//
//  TCSParseCannedMessage.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseCannedMessage.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseCannedMessage

@dynamic message;
@dynamic order;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSCannedMessage class];
}

- (NSString *)utsMessage {
    return self.message;
}

- (NSInteger)utsOrder {
    return self.order;
}

@end
