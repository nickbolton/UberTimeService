//
//  TCSParseGroup.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseGroup.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseGroup

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSGroup class];
}

@end
