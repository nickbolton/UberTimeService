//
//  TCSParseBBBTimerTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimerTests.h"
#import "TCSService.h"
#import "TCSParseService.h"

@interface TCSParseBBBTimerTests : TCSTimerTests { }

@end

@implementation TCSParseBBBTimerTests

- (void)setUpClass {
    [super setUpClass];
    [self.service registerRemoteServiceProvider:[TCSParseService class]];
    self.remoteProvider = NSStringFromClass([TCSParseService class]);
}

- (void)testAAAParseCreateProject {
    [self createProject:_cmd];
}

- (void)testBBBParseStartTimer {
    [self startTimer:_cmd];
}

- (void)testCCCParseStopTimer {
    [self stopTimer:_cmd];
}

- (void)testDDDParseEditTimer {
    [self editTimer:_cmd];
}

- (void)testEEEParseMoveTimer {
    [self moveTimer:_cmd];
}

- (void)testFFFParseRollTimer {
    [self rollTimer:_cmd];
}

- (void)testGGGParseDeleteTimer {
    [self deleteTimer:_cmd];
}

@end
