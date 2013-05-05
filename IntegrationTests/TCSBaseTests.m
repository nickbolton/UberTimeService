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

- (void)findTimerWithEntityID:(id)entityID
              serviceProvider:(id <TCSServiceProvider>)serviceProvider
                      success:(void(^)(TCSTimer *timer))successBlock
                      failure:(void(^)(void))failureBlock {
    [serviceProvider
     fetchTimerWithID:entityID
     success:^(TCSTimer *timer) {

         NSLog(@"ZZZ timer: %@", timer);

         if (successBlock != nil) {
             successBlock(timer);
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

@end
