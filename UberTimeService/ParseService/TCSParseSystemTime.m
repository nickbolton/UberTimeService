//
//  TCSParseSystemTime.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseSystemTime.h"
#if TARGET_OS_IPHONE
#import <Parse/PFObject+Subclass.h>
#else
#import <ParseOSX/PFObject+Subclass.h>
#endif

@implementation TCSParseSystemTime

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
