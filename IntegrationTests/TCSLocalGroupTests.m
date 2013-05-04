//
//  TCSLocalGroupTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSGroupTests.h"
#import "TCSLocalService.h"

@interface TCSLocalGroupTests : TCSGroupTests { }

@end

@implementation TCSLocalGroupTests

- (void)setUpClass {

    [super setUpClass];

    [self.service registerServiceProvider:[TCSLocalService class]];
    self.serviceProvider = [self.service serviceProviderOfType:[TCSLocalService class]];

    [(TCSLocalService *)self.serviceProvider resetCoreDataStack];
}

- (void)testAAALocalCreateProjects {
    [self createProjects:_cmd];
}

- (void)testBBBmoveProjectToGroup {
    [self moveProjectToGroup:_cmd];
}

- (void)testCCCmoveSecondProjectToGroup {
    [self moveSecondProjectToGroup:_cmd];
}

- (void)testDDDungroupProject {
    [self ungroupProject:_cmd];
}

- (void)testEEEungroupSecondProject {
    [self ungroupSecondProject:_cmd];
}

- (void)testFFFcreateProjects {
    [(TCSLocalService *)self.serviceProvider resetCoreDataStack];
    self.group = nil;
    self.project = nil;
    self.secondProject = nil;
    self.targetProject = nil;
    [self createProjects:_cmd];
}

- (void)testGGGmoveProjectToGroup {
    [self moveProjectToGroup:_cmd];
}

- (void)testHHHeditGroup:(SEL)selector {
    [self editGroup:_cmd];

}

- (void)testIIIdeleteGroup:(SEL)selector {
    [self deleteGroup:_cmd];
}

@end
