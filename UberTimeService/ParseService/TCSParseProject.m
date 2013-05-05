//
//  TCSParseProject.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseProject.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseProject

@dynamic filteredModifiers;
@dynamic keyCode;
@dynamic modifiers;
@dynamic order;
@dynamic timers;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
