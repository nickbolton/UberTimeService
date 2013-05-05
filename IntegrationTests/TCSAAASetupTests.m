//
//  TCSAAASetupTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/5/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "TCSService.h"
#import "TCSParseService.h"

@interface TCSAAASetupTests : GHAsyncTestCase {}

@property (nonatomic, strong) TCSService *service;

@end

@implementation TCSAAASetupTests

- (void)setUpClass {
    [super setUpClass];
    self.service = [TCSService sharedInstance];

    [_service registerServiceProvider:[TCSLocalService class]];
    [_service registerServiceProvider:[TCSParseService class]];

    
}

- (void)tearDownClass {
    self.service = nil;
    [super tearDownClass];
}

- (void)testAAAParseUserLogin {

    [self prepare];

    id <TCSServiceProvider> parseService =
    [_service serviceProviderOfType:[TCSParseService class]];
    
    [parseService
     authenticateUser:@"larvelljones"
     password:@"tqopklm1"
     success:^{

         GHAssertNotNil([PFUser currentUser], @"[PFUser currentUser] is nil");
         
         [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];

     } failure:^(NSError *error) {
         NSLog(@"Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)testBBBDeleteAllData {

    [self prepare];

    [self.service
     deleteAllData:^{

         [self notify:kGHUnitWaitStatusSuccess forSelector:_cmd];

     } failure:^(NSError *error) {
         NSLog(@"Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0f];
}

@end
