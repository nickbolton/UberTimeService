//
//  TCSLocalGroupTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSGroupTests.h"
#import "TCSLocalService.h"

@interface TCSCCCLocalGroupTests : TCSGroupTests { }

@end

@implementation TCSCCCLocalGroupTests

- (void)setUpClass {
    [super setUpClass];
    self.serviceProvider = [self.service serviceProviderOfType:[TCSLocalService class]];
    [(TCSLocalService *)self.serviceProvider resetCoreDataStack];
}

- (void)testAAALocalCreateProjects {
    [self createProjects:_cmd];
}

- (void)testBBBLocalMoveProjectToGroup {
    [self moveProjectToGroup:_cmd];
}

- (void)testCCCLocalMoveSecondProjectToGroup {
    [self moveSecondProjectToGroup:_cmd];
}

- (void)testDDDLocalUngroupProject {
    [self ungroupProject:_cmd];
}

- (void)testEEELocalUngroupSecondProject {
    [self ungroupSecondProject:_cmd];
}

- (void)testFFFLocalDeleteAllData {
    [self deleteAllData:_cmd];
}

- (void)testGGGLocalCreateProjects {
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
