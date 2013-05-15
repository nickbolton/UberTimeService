//
//  TCSParseAppConfig.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Parse/Parse.h>

@interface TCSParseAppConfig : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic) NSString *deviceID;
@property (nonatomic) NSString *instanceID;
@property (nonatomic) NSInteger appStartCount;
@property (nonatomic) NSInteger majorVersion;
@property (nonatomic) NSInteger minorVersion;
@property (nonatomic) NSInteger buildVersion;
@property (nonatomic) PFUser *user;

@end
