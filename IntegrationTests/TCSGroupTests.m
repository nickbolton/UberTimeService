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
    self.serviceProvider = nil;
    self.service = nil;
    self.project = nil;
    self.secondProject = nil;
    self.targetProject = nil;
    self.group = nil;
}

- (void)createProjects:(SEL)selector {

    [self prepare];

    [self.serviceProvider
     createProjectWithName:@"projectC"
     success:^(TCSProject *project) {

         self.project = project;

         [self.serviceProvider
          createProjectWithName:@"second project"
          success:^(TCSProject *project) {

              self.secondProject = project;

              [self.serviceProvider
               createProjectWithName:@"target project"
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
     success:^(TCSGroup *group) {

         self.group = group;

         [self.project.serviceProvider
          fetchProjectWithID:self.project.providerEntityID
          success:^(TCSProject *fetchedProject) {

              [self.group.serviceProvider
               fetchGroupWithID:self.group.providerEntityID
               success:^(TCSGroup *fetchedGroup) {

                   GHAssertNotNil(fetchedProject.parent,
                                  @"fetchedProject.parent is nil");
                   GHAssertTrue(fetchedGroup.children.count == 1,
                                @"fetchedGroup.children.count (%d) != 1", fetchedGroup.children.count);

                   GHAssertEquals(fetchedProject.parent.providerEntityID,
                                  fetchedGroup.providerEntityID,
                                  @"fetchedProject.parent.providerEntityID != fetchedGroup.providerEntityID");

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

- (void)moveSecondProjectToGroup:(SEL)selector {

    [self prepare];

    [self.service
     moveProject:self.secondProject
     toGroup:self.group
     success:^{

         [self.secondProject.serviceProvider
          fetchProjectWithID:self.secondProject.providerEntityID
          success:^(TCSProject *fetchedProject) {

              [self.group.serviceProvider
               fetchGroupWithID:self.group.providerEntityID
               success:^(TCSGroup *fetchedGroup) {

                   GHAssertNotNil(fetchedProject.parent,
                                  @"fetchedProject.parent is nil");
                   GHAssertTrue(fetchedGroup.children.count == 2,
                                @"fetchedGroup.children.count (%d) != 2", fetchedGroup.children.count);

                   GHAssertEquals(fetchedProject.parent.providerEntityID,
                                  fetchedGroup.providerEntityID,
                                  @"fetchedProject.parent.providerEntityID != fetchedGroup.providerEntityID");

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

- (void)ungroupProject:(SEL)selector {

    [self prepare];

    id groupProviderID = self.group.providerEntityID;

    [self.service
     moveProject:self.project
     toGroup:nil
     success:^{

         [self.project.serviceProvider
          fetchProjectWithID:self.project.providerEntityID
          success:^(TCSProject *fetchedProject) {

              [self.project.serviceProvider
               fetchGroupWithID:groupProviderID
               success:^(TCSGroup *fetchedGroup) {

                   GHAssertNil(fetchedProject.parent,
                               @"fetchedProject.parent is not nil");
                   GHAssertTrue(fetchedGroup.children.count == 1,
                                @"fetchedGroup.children.count (%d) != 1", fetchedGroup.children.count);

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

- (void)ungroupSecondProject:(SEL)selector {

    [self prepare];

    id groupProviderID = self.group.providerEntityID;

    [self.service
     moveProject:self.secondProject
     toGroup:nil
     success:^{

         [self.secondProject.serviceProvider
          fetchProjectWithID:self.secondProject.providerEntityID
          success:^(TCSProject *fetchedProject) {

              [self.secondProject.serviceProvider
               fetchGroupWithID:groupProviderID
               success:^(TCSGroup *fetchedGroup) {

                   GHAssertNil(fetchedProject.parent,
                               @"fetchedProject.parent is not nil");
                   GHAssertNil(fetchedGroup,
                               @"fetchedGroup is not nil");

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

- (void)editGroup:(SEL)selector {

    [self prepare];

    BOOL archived = YES;
    NSString *name = @"bababooey group";
    NSInteger color = 50;

    self.group.archived = archived;
    self.group.name = name;
    self.group.color = color;

    [self.service
     updateGroup:self.group
     success:^{

         [self
          findGroupWithEntityID:self.group.providerEntityID
          serviceProvider:self.serviceProvider
          success:^(TCSGroup *group) {

              GHAssertTrue(group.archived == archived,
                           @"group.archived (%d) != archived (%d)",
                           group.archived, archived);

              GHAssertTrue(group.color == color,
                           @"group.color (%d) != color (%d)",
                           group.color, color);

              GHAssertEquals(group.name, name,
                             @"group.name (%@) != name (%@)",
                             group.name, name);

              [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

          } failure:^{
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

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

         [self.serviceProvider
          fetchGroups:^(NSArray *groups) {

              GHAssertTrue(groups.count == 0, @"Group remains after deletion");

              [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

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

@end
