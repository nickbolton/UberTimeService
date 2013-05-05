//
//  TCSLocalProjectTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "TCSProjectTests.h"
#import "TCSService.h"

@interface TCSAAALocalProjectTests : TCSProjectTests { }

@end

@implementation TCSAAALocalProjectTests

- (void)setUpClass {

    [super setUpClass];

    self.serviceProvider = [self.service serviceProviderOfType:[TCSLocalService class]];
    [(TCSLocalService *)self.serviceProvider resetCoreDataStack];
}

- (void)testAAAADeleteAllProjects {
    [self deleteAllProjects:_cmd];
}

- (void)testAAALocalCreateProject {
    [self createProject:_cmd];
}

- (void)testBBBBLocalFetchAllProjects {
    [self fetchAllProjects:_cmd];
}

- (void)testCCCLocalFetchProjectByEntityID {
    [self fetchProjectByEntityID:_cmd];
}

- (void)testDDDLocalEditProject {
    [self editProject:_cmd];
}

- (void)testEEELocalDeleteProject {
    [self deleteProject:_cmd];
}

- (void)testZZZLocalFetchAllProjects {
    [self fetchAllProjects:_cmd];
}

@end
