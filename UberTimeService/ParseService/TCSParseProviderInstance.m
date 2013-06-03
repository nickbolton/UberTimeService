//
//  TCSParseProviderInstance.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseProviderInstance.h"
#if TARGET_OS_IPHONE
#import <Parse/PFObject+Subclass.h>
#else
#import <ParseOSX/PFObject+Subclass.h>
#endif

@implementation TCSParseProviderInstance

@dynamic baseURL;
@dynamic name;
@dynamic password;
@dynamic username;
@dynamic userID;
@dynamic remoteProvider;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (NSString *)utsBaseURL {
    return self.baseURL;
}

- (NSString *)utsName {
    return self.name;
}

- (NSString *)utsPassword {
    return self.password;
}

- (NSString *)utsUsername {
    return self.username;
}

- (NSString *)utsUserID {
    return self.userID;
}

- (NSString *)utsRemoteProvider {
    return self.remoteProvider;
}

@end