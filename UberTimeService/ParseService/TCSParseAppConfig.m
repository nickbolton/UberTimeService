//
//  TCSParseAppConfig.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseAppConfig.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseAppConfig

@dynamic deviceIdentifier;
@dynamic majorVersion;
@dynamic minorVersion;
@dynamic buildVersion;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

@end
