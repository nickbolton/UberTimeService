//
//  TCSParseRemoteCommand.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/19/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseRemoteCommand.h"
#if TARGET_OS_IPHONE
#import <Parse/PFObject+Subclass.h>
#else
#import <ParseOSX/PFObject+Subclass.h>
#endif

@implementation TCSParseRemoteCommand

@dynamic payload;
@dynamic type;
@dynamic executedInstallations;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSRemoteCommand class];
}

- (NSData *)utsPayloadData {
    return self.payload;
}

- (NSInteger)utsType {
    return self.type;
}

@end
