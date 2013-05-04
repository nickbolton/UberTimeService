//
//  TCSBaseTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseTests.h"
#import "TCSService.h"

@implementation TCSBaseTests

#pragma mark - Helpers

- (void)findProjectNamed:(NSString *)name
         serviceProvider:(id <TCSServiceProvider>)serviceProvider
                 success:(void(^)(TCSProject *project))successBlock
                 failure:(void(^)(void))failureBlock {

    [serviceProvider
     fetchProjectWithName:name
     success:^(NSArray *projects) {

         GHAssertTrue(projects.count == 1, @"Only one project should be returned (%d)", projects.count);

         TCSProject *project = projects[0];
         GHAssertEquals(project.name, name,
                        @"Project name (%@) does not match (%)", project.name, name);

         NSLog(@"ZZZ project.name: %@", project.name);

         if (successBlock != nil) {
             successBlock(project);
         }

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         if (failureBlock != nil) {
             failureBlock();
         }
     }];
}

- (void)findProjectWithEntityID:(id)entityID
                serviceProvider:(id <TCSServiceProvider>)serviceProvider
                        success:(void(^)(TCSProject *project))successBlock
                        failure:(void(^)(void))failureBlock {

    [serviceProvider
     fetchProjectWithID:entityID
     success:^(TCSProject *project) {

         NSLog(@"ZZZ project.name: %@", project.name);

         if (successBlock != nil) {
             successBlock(project);
         }

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         if (failureBlock != nil) {
             failureBlock();
         }
     }];
}

- (void)findGroupWithEntityID:(id)entityID
              serviceProvider:(id <TCSServiceProvider>)serviceProvider
                      success:(void(^)(TCSGroup *group))successBlock
                      failure:(void(^)(void))failureBlock {

    [serviceProvider
     fetchGroupWithID:entityID
     success:^(TCSGroup *group) {

         NSLog(@"ZZZ group.name: %@", group.name);

         if (successBlock != nil) {
             successBlock(group);
         }

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         if (failureBlock != nil) {
             failureBlock();
         }
     }];
}

- (void)findProjectWithEntityID:(id)entityID
                           name:(NSString *)name
                serviceProvider:(id <TCSServiceProvider>)serviceProvider
                        success:(void(^)(TCSProject *project))successBlock
                        failure:(void(^)(void))failureBlock {

    [self
     findProjectWithEntityID:entityID
     serviceProvider:serviceProvider
     success:^(TCSProject *project) {

         GHAssertEquals(project.name, name,
                        @"Project name (%@) does not match (%)", project.name, name);

         if (successBlock != nil) {
             successBlock(project);
         }

     } failure:failureBlock];
}

@end
