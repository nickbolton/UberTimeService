//
//  TCSLocalTimerTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimerTests.h"
#import "TCSService.h"
#import "TCSLocalService.h"

@interface TCSLocalTimerTests : TCSTimerTests { }

@end

@implementation TCSLocalTimerTests

- (void)setUpClass {

    [super setUpClass];

    [self.service registerServiceProvider:[TCSLocalService class]];
    self.serviceProvider = [self.service serviceProviderOfType:[TCSLocalService class]];

    [(TCSLocalService *)self.serviceProvider resetCoreDataStack];
}

- (void)testAAALocalCreateProject {
    [self createProject:_cmd];
}

- (void)testBBBLocalStartTimer {
    [self startTimer:_cmd];
}

- (void)testCCCLocalStopTimer {
    [self stopTimer:_cmd];
}

- (void)testDDDeditTimer {
    [self editTimer:_cmd];
}

- (void)testEEEmoveTimer {
    [self moveTimer:_cmd];
}

- (void)testFFFrollTimer {
    [self rollTimer:_cmd];
}

- (void)testGGGdeleteTimer {
    [self deleteTimer:_cmd];
}

@end
