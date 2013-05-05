//
//  TCSParseAAAProjectTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "TCSProjectTests.h"
#import "TCSService.h"
#import "TCSParseService.h"

@interface TCSParseAAAProjectTests : TCSProjectTests { }

@end

@implementation TCSParseAAAProjectTests

- (void)setUpClass {
    [super setUpClass];
    self.serviceProvider = [self.service serviceProviderOfType:[TCSParseService class]];
}

- (void)testAAAParseCreateProject {
    [self createProject:_cmd];
}

- (void)testCCCParseFetchProjectByEntityID {
    [self fetchProjectByEntityID:_cmd];
}

- (void)testDDDParseEditProject {
    [self editProject:_cmd];
}

- (void)testEEEParseDeleteProject {
    [self deleteProject:_cmd];
}

- (void)testZZZParseFetchAllProjects {
    [self fetchAllProjects:_cmd];
}

@end
