//
//  TCBaseTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCBaseTests.h"
#import "TCSService.h"

@implementation TCBaseTests

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
