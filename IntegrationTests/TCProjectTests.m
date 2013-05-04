//
//  TCProjectTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCProjectTests.h"
#import "TCSService.h"

@interface TCProjectTests()

@property (nonatomic) NSInteger filteredModifiers;
@property (nonatomic) NSInteger keyCode;
@property (nonatomic) NSInteger modifiers;
@property (nonatomic) NSInteger order;
@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger color;

@end

@implementation TCProjectTests

- (void)setUpClass {

    [super setUpClass];

    self.projectName = @"projectA";

    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.serviceProvider = nil;
    self.service = nil;
    self.foundProject = nil;
    self.projectName = nil;
}

- (void)createProject:(SEL)selector {

    [self prepare];

    [self.serviceProvider
     createProjectWithName:_projectName
     success:^(TCSProject *project) {

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0];
}

- (void)editProject:(SEL)selector {

    [self prepare];

    self.filteredModifiers = 10;
    self.keyCode = 20;
    self.modifiers = 30;
    self.order = 40;
    self.archived = YES;
    self.name = @"bababooey";
    self.color = 50;

    self.foundProject.filteredModifiers = _filteredModifiers;
    self.foundProject.keyCode = _keyCode;
    self.foundProject.modifiers = _modifiers;
    self.foundProject.order = _order;
    self.foundProject.archived = _archived;
    self.foundProject.name = _name;
    self.foundProject.color = _color;

    [self.service
     updateProject:self.foundProject
     success:^{

         [self
          findProjectWithEntityID:self.foundProject.providerEntityID
          serviceProvider:self.serviceProvider
          success:^(TCSProject *project) {

              GHAssertTrue(project.filteredModifiers == _filteredModifiers,
                           @"project.filteredModifiers (%d) != filteredModifiers (%d)",
                           project.filteredModifiers, _filteredModifiers);

              GHAssertTrue(project.keyCode == _keyCode,
                           @"project.keyCode (%d) != keyCode (%d)",
                           project.keyCode, _keyCode);

              GHAssertTrue(project.modifiers == _modifiers,
                           @"project.modifiers (%d) != modifiers (%d)",
                           project.modifiers, _modifiers);

              GHAssertTrue(project.order == _order,
                           @"project.order (%d) != order (%d)",
                           project.order, _order);

              GHAssertTrue(project.archived == _archived,
                           @"project.archived (%d) != archived (%d)",
                           project.archived, _archived);

              GHAssertTrue(project.color == _color,
                           @"project.color (%d) != color (%d)",
                           project.color, _color);

              GHAssertEquals(project.name, _name,
                           @"project.name (%@) != name (%@)",
                           project.name, _name);

              [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

          } failure:^{
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0];
}

- (void)deleteProject:(SEL)selector {

    [self prepare];
        
    [self.service
     deleteProject:self.foundProject
     success:^{

         [self.serviceProvider
          fetchProjects:^(NSArray *projects) {

              GHAssertTrue(projects.count == 0, @"Project remains after deletion");

              [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

          } failure:^(NSError *error) {
              NSLog(@"ZZZ Error: %@", error);
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0];
}

- (void)findProjectWithName:(SEL)selector {

    [self
     findProjectNamed:_projectName
     serviceProvider:self.serviceProvider
     success:^(TCSProject *project){

         self.foundProject = project;

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^{
         [self notify:kGHUnitWaitStatusFailure forSelector:_cmd];
     }];
}

- (void)fetchProjectByEntityID:(SEL)selector {

    [self
     findProjectWithEntityID:self.foundProject.providerEntityID
     name:_projectName
     serviceProvider:self.serviceProvider
     success:^(TCSProject *project) {

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^{
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
}

- (void)fetchAllProjects:(SEL)selector {

    NSLog(@"All Projects...");
    
    [self.serviceProvider
     fetchProjects:^(NSArray *projects) {

         for (TCSProject *p in projects) {
             NSLog(@"ZZZ p: %@", p.name);
         }
         
     } failure:^(NSError *error) {
         NSLog(@"Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
}

- (void)deleteAllProjects:(SEL)selector {

    [self prepare];

    [self.serviceProvider
     fetchProjects:^(NSArray *projects) {

         NSEnumerator *enumerator = [projects objectEnumerator];
         [self deleteNextProject:enumerator selector:selector];

     } failure:^(NSError *error) {
         NSLog(@"Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0];
}

- (void)deleteNextProject:(NSEnumerator *)enumerator selector:(SEL)selector {

    TCSProject *nextProject = [enumerator nextObject];

    if (nextProject == nil) {

        [self.serviceProvider
         fetchProjects:^(NSArray *projects) {

             GHAssertTrue(projects.count == 0, @"Project remains after deleting all");

             [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

         } failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
             [self notify:kGHUnitWaitStatusFailure forSelector:selector];
         }];
    } else {

        [self.serviceProvider
         deleteProject:nextProject
         success:^{

             [self deleteNextProject:enumerator selector:selector];
             
         } failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
             [self notify:kGHUnitWaitStatusFailure forSelector:selector];
         }];
    }
}

@end
