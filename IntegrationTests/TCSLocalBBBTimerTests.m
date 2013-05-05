//
//  TCSLocalBBBTimerTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimerTests.h"
#import "TCSService.h"
#import "TCSLocalService.h"

@interface TCSLocalBBBTimerTests : TCSTimerTests { }

@end

@implementation TCSLocalBBBTimerTests

- (void)testAAALocalCreateProject {
    [self createProject:_cmd];
}

- (void)testBBBLocalStartTimer {
    [self startTimer:_cmd];
}

- (void)testCCCLocalStopTimer {
    [self stopTimer:_cmd];
}

- (void)testDDDDeleteTimer {
    [self deleteTimer:_cmd];
}

- (void)testEEELocalStartTimer {
    [self startTimer:_cmd];
}

- (void)testFFFLocalStartSecondTimer {
    [self startSecondTimer:_cmd];
}

- (void)testGGGLocalEditTimer {
    [self editTimer:_cmd];
}

- (void)testHHHLocalMoveTimer {
    [self moveTimer:_cmd];
}

- (void)testIIILocalRollTimer {
    [self rollTimer:_cmd];
}

- (void)testJJJLocalDeleteTimer {
    [self deleteTimer:_cmd];
}

@end
