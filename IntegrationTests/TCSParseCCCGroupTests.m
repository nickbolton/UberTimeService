//
//  TCSParseCCCGroupTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSGroupTests.h"
#import "TCSParseService.h"

@interface TCSParseCCCGroupTests : TCSGroupTests { }

@end

@implementation TCSParseCCCGroupTests

- (void)setUpClass {
    [super setUpClass];
    [self.service registerRemoteServiceProvider:[TCSParseService class]];
    self.remoteProvider = NSStringFromClass([TCSParseService class]);
}

- (void)testAAAParseCreateProjects {
    [self createProjects:_cmd];
}

- (void)testBBBParseMoveProjectToGroup {
    [self moveProjectToGroup:_cmd];
}

- (void)testCCCParseMoveSecondProjectToGroup {
    [self moveSecondProjectToGroup:_cmd];
}

- (void)testDDDParseUngroupProject {
    [self ungroupProject:_cmd];
}

- (void)testEEEParseUngroupSecondProject {
    [self ungroupSecondProject:_cmd];
}

- (void)testFFFLocalDeleteAllData {
    [self deleteAllData:_cmd];
}

- (void)testGGGParseCreateProjects {
    self.group = nil;
    self.project = nil;
    self.secondProject = nil;
    self.targetProject = nil;
    [self createProjects:_cmd];
}

- (void)testHHHLocalMoveProjectToGroup {
    [self moveProjectToGroup:_cmd];
}

- (void)testIIILocalEditGroup:(SEL)selector {
    [self editGroup:_cmd];

}

- (void)testJJJLocalDeleteGroup:(SEL)selector {
    [self deleteGroup:_cmd];
}

@end
