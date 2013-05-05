//
//  TCSProjectTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSProjectTests.h"
#import "TCSService.h"

@interface TCSProjectTests()

@property (nonatomic, strong) TCSProject *project;
@property (nonatomic, strong) id projectEntityID;
@property (nonatomic, strong) NSString *projectName;

@end

@implementation TCSProjectTests

- (void)setUpClass {
    [super setUpClass];
    self.projectName = @"projectA";
    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.serviceProvider = nil;
    self.service = nil;
    self.project = nil;
    self.projectName = nil;
    [super tearDownClass];
}

- (void)createProject:(SEL)selector {

    [self prepare];

    [self.serviceProvider
     createProjectWithName:_projectName
     success:^(TCSProject *project) {

         self.projectEntityID = project.providerEntityID;

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)editProject:(SEL)selector {

    [self prepare];

    NSInteger filteredModifiers = 10;
    NSInteger keyCode = 20;
    NSInteger modifiers = 30;
    NSInteger order = 40;
    BOOL archived = YES;
    NSString *name = @"bababooey";
    NSInteger color = 50;

    self.project.filteredModifiers = filteredModifiers;
    self.project.keyCode = keyCode;
    self.project.modifiers = modifiers;
    self.project.order = order;
    self.project.archived = archived;
    self.project.name = name;
    self.project.color = color;

    [self.service
     updateProject:self.project
     success:^{

         [self
          findProjectWithEntityID:self.project.providerEntityID
          serviceProvider:self.serviceProvider
          success:^(TCSProject *project) {

              GHAssertTrue(project.filteredModifiers == filteredModifiers,
                           @"project.filteredModifiers (%d) != filteredModifiers (%d)",
                           project.filteredModifiers, filteredModifiers);

              GHAssertTrue(project.keyCode == keyCode,
                           @"project.keyCode (%d) != keyCode (%d)",
                           project.keyCode, keyCode);

              GHAssertTrue(project.modifiers == modifiers,
                           @"project.modifiers (%d) != modifiers (%d)",
                           project.modifiers, modifiers);

              GHAssertTrue(project.order == order,
                           @"project.order (%d) != order (%d)",
                           project.order, order);

              GHAssertTrue(project.archived == archived,
                           @"project.archived (%d) != archived (%d)",
                           project.archived, archived);

              GHAssertTrue(project.color == color,
                           @"project.color (%d) != color (%d)",
                           project.color, color);

              GHAssertTrue([project.name isEqualToString:name],
                           @"projectName (%@) != name (%@)",
                           project.name, name);

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

- (void)deleteProject:(SEL)selector {

    [self prepare];
        
    [self.service
     deleteProject:self.project
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

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)fetchProjectByEntityID:(SEL)selector {

    [self prepare];

    [self
     findProjectWithEntityID:self.projectEntityID
     serviceProvider:self.serviceProvider
     success:^(TCSProject *project) {

         self.project = project;

         GHAssertNotNil(project, @"fetched project is nil");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^{
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
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

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)deleteNextProject:(NSEnumerator *)enumerator selector:(SEL)selector {

    TCSProject *nextProject = [enumerator nextObject];

    if (nextProject == nil) {

        [self.serviceProvider clearCache];

        [self.serviceProvider
         fetchProjects:^(NSArray *projects) {

             GHAssertTrue(projects.count == 0, @"Project remains after deleting all");

             [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

         } failure:^(NSError *error) {
             NSLog(@"Error: %@", error);
             [self notify:kGHUnitWaitStatusFailure forSelector:selector];
         }];
    } else {

        [self.service
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
