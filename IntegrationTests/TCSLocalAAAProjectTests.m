//
//  TCSLocalAAAProjectTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "TCSProjectTests.h"
#import "TCSService.h"

@interface TCSLocalAAAProjectTests : TCSProjectTests { }

@end

@implementation TCSLocalAAAProjectTests

- (void)testAAAADeleteAllData {
    [self deleteAllData:_cmd];
}

- (void)testAAALocalCreateProject {
    [self createProject:_cmd];
}

- (void)testBBBBLocalFetchAllProjects {
    [self allProjects:_cmd];
}

- (void)testCCCLocalFetchProjectByEntityID {
    [self projectByEntityID:_cmd];
}

- (void)testDDDLocalEditProject {
    [self editProject:_cmd];
}

- (void)testEEELocalDeleteProject {
    [self deleteProject:_cmd];
}

- (void)testZZZLocalFetchAllProjects {
    [self allProjects:_cmd];
}

@end
