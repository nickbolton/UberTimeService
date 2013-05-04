//
//  TCAppDelegate.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCSService.h"
#import "TCSLocalService.h"

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    TCSService *service = [TCSService sharedInstance];
    [service registerServiceProvider:[TCSLocalService class]];

    id <TCSServiceProvider> localService = [service serviceProviderOfType:[TCSLocalService class]];

    [localService
     fetchProjects:^(NSArray *projects) {

         for (TCSProject *p in projects) {
             NSLog(@"p: %@", p.name);

             [localService
              startTimerForProject:p
              success:^(TCSTimer *timer) {
                  NSLog(@"timer: %@ - %@ (%f) %@", timer.startTime, timer.endTime, timer.adjustment, timer.message);
                  NSLog(@"timer.project: %@", timer.project.name);

                  for (TCSTimer *t in p.timers) {
                      NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustment, t.message);
                  }
              } failure:^(NSError *error) {

              }];

//             p.name = @"woooooo2222";
//
//             [localService
//              deleteProject:p
//              success:nil
//              failure:^(NSError *error) {
//                  NSLog(@"Error2: %@", error);
//              }];
         }

//         [localService
//          createProjectWithName:@"hello" success:^(TCSProject *project) {
//
//              NSLog(@"new project: %@", project.name);
//          } failure:^(NSError *error) {
//
//              NSLog(@"Error3: %@", error);
//          }];

     } failure:^(NSError *error) {

         NSLog(@"Error: %@", error);
     }];

    return YES;
}

@end
