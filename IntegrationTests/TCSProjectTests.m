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
@property (nonatomic, strong) NSManagedObjectID *projectEntityID;
@property (nonatomic, strong) NSString *projectName;

@end

@implementation TCSProjectTests

- (void)setUpClass {
    [super setUpClass];
    self.projectName = @"projectA";
    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.service = nil;
    self.project = nil;
    self.projectName = nil;
    self.remoteProvider = nil;
    [super tearDownClass];
}

- (void)deleteAllData:(SEL)selector {

    [self prepare];

    [self.service
     deleteAllData:^{

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)createProject:(SEL)selector {

    [self prepare];

    [self.service
     createProjectWithName:_projectName
     remoteProvider:self.remoteProvider
     success:^(TCSProject *project) {

         self.projectEntityID = project.objectID;

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

    self.project.name = name;
    self.project.metadata.filteredModifiersValue = filteredModifiers;
    self.project.metadata.keyCodeValue = keyCode;
    self.project.metadata.modifiersValue = modifiers;
    self.project.metadata.orderValue = order;
    self.project.metadata.archivedValue = archived;
    self.project.metadata.colorValue = color;

    [self.service
     updateProject:self.project
     success:^(TCSProject *updatedProject){

         GHAssertNotNil(updatedProject, @"project not found");

         GHAssertTrue([updatedProject.name isEqualToString:name],
                      @"projectName (%@) != name (%@)",
                      updatedProject.name, name);

         GHAssertTrue(updatedProject.metadata.filteredModifiersValue == filteredModifiers,
                      @"project.filteredModifiers (%d) != filteredModifiers (%d)",
                      updatedProject.metadata.filteredModifiersValue, filteredModifiers);

         GHAssertTrue(updatedProject.metadata.keyCodeValue == keyCode,
                      @"project.keyCode (%d) != keyCode (%d)",
                      updatedProject.metadata.keyCodeValue, keyCode);

         GHAssertTrue(updatedProject.metadata.modifiersValue == modifiers,
                      @"project.modifiers (%d) != modifiers (%d)",
                      updatedProject.metadata.modifiersValue, modifiers);

         GHAssertTrue(updatedProject.metadata.orderValue == order,
                      @"project.order (%d) != order (%d)",
                      updatedProject.metadata.orderValue, order);

         GHAssertTrue(updatedProject.metadata.archivedValue == archived,
                      @"project.archived (%d) != archived (%d)",
                      updatedProject.metadata.archivedValue, archived);

         GHAssertTrue(updatedProject.metadata.colorValue == color,
                      @"project.color (%d) != color (%d)",
                      updatedProject.metadata.colorValue, color);

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

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

         NSArray *projects = [self.service allProjects];

         GHAssertTrue(projects.count == 0, @"Project remains after deletion");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)projectByEntityID:(SEL)selector {

    self.project = [self projectWithEntityID:self.projectEntityID];
    
    GHAssertNotNil(_project, @"fetched project is nil");

    [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
}

- (void)allProjects:(SEL)selector {

    NSLog(@"All Projects...");

    NSArray *projects = [self.service allProjects];

    for (TCSProject *p in projects) {
        NSLog(@"ZZZ p: %@", p.name);
    }
}

- (void)deleteAllProjects:(SEL)selector {

    [self prepare];

    NSArray *projects = [self.service allProjects];

    NSEnumerator *enumerator = [projects objectEnumerator];
    [self deleteNextProject:enumerator selector:selector];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)deleteNextProject:(NSEnumerator *)enumerator selector:(SEL)selector {

    TCSProject *nextProject = [enumerator nextObject];

    if (nextProject == nil) {

        NSArray *projects = [self.service allProjects];

        GHAssertTrue(projects.count == 0, @"Project remains after deleting all");

        [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

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
