//
//  TCSGroupTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSGroupTests.h"
#import "TCSProject.h"
#import "TCSGroup.h"
#import "TCSService.h"

@implementation TCSGroupTests

- (void)setUpClass {
    [super setUpClass];
    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.service = nil;
    self.project = nil;
    self.secondProject = nil;
    self.targetProject = nil;
    self.group = nil;
    self.remoteProvider = nil;
    [super tearDownClass];
}

- (void)createProjects:(SEL)selector {

    [self prepare];

    [self.service
     createProjectWithName:@"projectC"
     remoteProvider:self.remoteProvider
     success:^(TCSProject *project) {

         self.project = project;

         [self.service
          createProjectWithName:@"second project"
          remoteProvider:self.remoteProvider
          success:^(TCSProject *project) {

              self.secondProject = project;

              [self.service
               createProjectWithName:@"target project"
               remoteProvider:self.remoteProvider
               success:^(TCSProject *project) {

                   self.targetProject = project;

                   [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

               } failure:^(NSError *error) {
                   NSLog(@"ZZZ Error: %@", error);
                   [self notify:kGHUnitWaitStatusFailure forSelector:selector];
               }];

          } failure:^(NSError *error) {
              NSLog(@"ZZZ Error: %@", error);
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)moveProjectToGroup:(SEL)selector {

    [self prepare];

    [self.service
     moveProject:self.project
     toProject:self.targetProject
     success:^(TCSGroup *group, TCSProject *updatedSourceProject, TCSProject *updatedTargetProject) {

         self.group = group;

         TCSProject *fetchedProject =
         [self.service projectWithID:self.project.objectID];

         TCSGroup *fetchedGroup =
         [self.service groupWithID:self.group.objectID];

         GHAssertNotNil(fetchedProject.parent,
                        @"fetchedProject.parent is nil");
         GHAssertTrue(fetchedGroup.children.count == 1,
                      @"fetchedGroup.children.count (%d) != 1", fetchedGroup.children.count);

         GHAssertTrue([fetchedProject.parent.objectID isEqual:fetchedGroup.objectID],
                      @"fetchedProject.parent.objectID != fetchedGroup.objectID");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
         
     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)moveSecondProjectToGroup:(SEL)selector {

    [self prepare];

    [self.service
     moveProject:self.secondProject
     toGroup:self.group
     success:^(TCSProject *updatedProject, TCSGroup *updatedGroup) {

         TCSProject *fetchedProject =
         [self.service projectWithID:self.secondProject.objectID];

         TCSGroup *fetchedGroup =
         [self.service groupWithID:self.group.objectID];

         GHAssertNotNil(fetchedProject.parent,
                        @"fetchedProject.parent is nil");
         GHAssertTrue(fetchedGroup.children.count == 2,
                      @"fetchedGroup.children.count (%d) != 2", fetchedGroup.children.count);

         GHAssertTrue([fetchedProject.parent.objectID isEqual:fetchedGroup.objectID],
                      @"fetchedProject.parent.objectID != fetchedGroup.objectID");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)ungroupProject:(SEL)selector {

    [self prepare];

    [self.service
     moveProject:self.project
     toGroup:nil
     success:^(TCSProject *updatedProject, TCSGroup *updatedGroup) {

         TCSProject *fetchedProject =
         [self.service projectWithID:self.project.objectID];

         TCSGroup *fetchedGroup =
         [self.service groupWithID:self.group.objectID];

         GHAssertNil(fetchedProject.parent,
                     @"fetchedProject.parent is not nil");
         GHAssertTrue(fetchedGroup.children.count == 1,
                      @"fetchedGroup.children.count (%d) != 1", fetchedGroup.children.count);

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)ungroupSecondProject:(SEL)selector {

    [self prepare];

    [self.service
     moveProject:self.secondProject
     toGroup:nil
     success:^(TCSProject *updatedProject, TCSGroup *updatedGroup) {

         TCSProject *fetchedProject =
         [self.service projectWithID:self.secondProject.objectID];

         TCSGroup *fetchedGroup =
         [self.service groupWithID:self.group.objectID];

         GHAssertNil(fetchedProject.parent,
                     @"fetchedProject.parent is not nil");
         GHAssertNil(fetchedGroup,
                     @"fetchedGroup is not nil");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)editGroup:(SEL)selector {

    [self prepare];

    BOOL archived = YES;
    NSString *name = @"bababooey group";
    NSInteger color = 50;

    self.group.name = name;
    self.group.metadata.archivedValue = archived;
    self.group.metadata.colorValue = color;

    [self.service
     updateGroup:self.group
     success:^(TCSGroup *updatedGroup){

         GHAssertTrue(updatedGroup.metadata.archivedValue == archived,
                      @"group.archived (%d) != archived (%d)",
                      updatedGroup.metadata.archivedValue, archived);

         GHAssertTrue(updatedGroup.metadata.colorValue == color,
                      @"group.color (%d) != color (%d)",
                      updatedGroup.metadata.colorValue, color);

         GHAssertTrue([updatedGroup.name isEqualToString:name],
                      @"group.name (%@) != name (%@)",
                      updatedGroup.name, name);

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)deleteGroup:(SEL)selector {

    [self prepare];

    [self.service
     deleteGroup:self.group
     success:^{

         NSArray *groups = [self.service allGroups];

         GHAssertTrue(groups.count == 0, @"Group remains after deletion");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)deleteAllData:(SEL)selector {

    [self prepare];

    [self.service
     deleteAllData:^{

         NSArray *timers = [self.service allTimers];

         GHAssertTrue(timers.count == 0, @"Timer remains after delete all data");

         NSArray *projects = [self.service allProjects];

         GHAssertTrue(projects.count == 0, @"Project remains after delete all data");

         NSArray *groups = [self.service allGroups];

         GHAssertTrue(groups.count == 0, @"Group remains after delete all data");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

@end
