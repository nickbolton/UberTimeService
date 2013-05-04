//
//  TCSTimerTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimerTests.h"
#import "TCSService.h"

@implementation TCSTimerTests

- (void)setUpClass {

    [super setUpClass];

    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.serviceProvider = nil;
    self.service = nil;
    self.project = nil;
    self.secondProject = nil;
    self.timer = nil;
}

- (void)createProject:(SEL)selector {

    [self prepare];

    [self.serviceProvider
     createProjectWithName:@"projectB"
     success:^(TCSProject *project) {

         self.project = project;

         [self.serviceProvider
          createProjectWithName:@"second project"
          success:^(TCSProject *project) {

              self.secondProject = project;

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

- (void)startTimer:(SEL)selector {

    [self prepare];

    [self.service
     startTimerForProject:self.project
     success:^(TCSTimer *timer) {

         self.timer = timer;

         GHAssertNotNil(timer.providerEntity, @"timer providerEntity is nil");
         GHAssertNotNil(timer.providerEntityID, @"timer providerEntityID is nil");
         GHAssertEquals(timer.project.providerEntityID, self.project.providerEntityID, @"parent project entityID is not equal to test project entityID");

         __block NSInteger asyncCount = 2;

         [self.project.serviceProvider
          fetchProjectWithID:self.project.providerEntityID
          success:^(TCSProject *project) {

              GHAssertTrue(project.timers.count == 1, @"project.timers.count != 1");

              TCSTimer *projectTimer = project.timers.lastObject;

              GHAssertEquals(projectTimer.providerEntityID, timer.providerEntityID,
                             @"fetched project.timer != created timer");

              @synchronized (self) {

                  asyncCount--;

                  if (asyncCount == 0) {
                      [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
                  }
              }

          } failure:^(NSError *error) {
              NSLog(@"ZZZ Error: %@", error);
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

         [self.service
          fetchTimersForProjects:@[self.project]
          fromDate:nil
          toDate:nil
          sortByStartTime:YES
          success:^(NSArray *timers) {

              GHAssertTrue(timers.count <= 1, @"Multiple timers exist");
              GHAssertTrue(timers.count == 1, @"Timer doesn't exist after starting");

              TCSTimer *fetchedTimer = timers[0];

              GHAssertNotNil(fetchedTimer.providerEntityID, @"fetchedTimer providerEntityID is nil");
              GHAssertEquals(timer.providerEntityID, fetchedTimer.providerEntityID,
                             @"fetchedTimer entityID is not equal to entityID");

              GHAssertEquals(fetchedTimer.providerEntityID, self.service.activeTimer.providerEntityID, @"activeTimer is not returned timer");

              NSLog(@"timer: %@ - %@ (%f) %@", timer.startTime, timer.endTime, timer.adjustment, timer.message);
              NSLog(@"timer.project: %@", timer.project.name);

              for (TCSTimer *t in self.project.timers) {
                  NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustment, t.message);
              }
              
              @synchronized (self) {

                  asyncCount--;

                  if (asyncCount == 0) {
                      [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
                  }
              }

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

- (void)stopTimer:(SEL)selector {

    [self prepare];

    [self.service
     stopTimer:self.timer
     success:^{

         NSLog(@"timer: %@ - %@ (%f) %@", self.timer.startTime, self.timer.endTime, self.timer.adjustment, self.timer.message);
         NSLog(@"timer.project: %@", self.timer.project.name);

         GHAssertNil(self.service.activeTimer, @"Active timer remains after stopping");

         for (TCSTimer *t in self.project.timers) {
             NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustment, t.message);
         }

         [self.serviceProvider
          fetchTimerWithID:self.timer.providerEntityID
          success:^(TCSTimer *timer) {

              GHAssertNotNil(timer.endTime, @"timer endTime was nil after stopping timer");

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

- (void)editTimer:(SEL)selector {

    [self prepare];

    NSString *message = @"hello there";
    NSDate *startTime = [NSDate date];
    NSDate *endTime = [startTime dateByAddingTimeInterval:100];
    NSTimeInterval adjustment = 1000.0f;

    self.timer.message = message;
    self.timer.startTime = startTime;
    self.timer.endTime = endTime;
    self.timer.adjustment = adjustment;

    [self.service
     updateTimer:self.timer
     success:^{

         [self.serviceProvider
          fetchTimerWithID:self.timer.providerEntityID
          success:^(TCSTimer *timer) {

              GHAssertEquals(self.timer.providerEntityID, timer.providerEntityID,
                             @"fetched timer does not have the same entityID");

              GHAssertEquals(message, timer.message,
                             @"timer message (%@) does not match (%@)", timer.message, message);
              GHAssertTrue([startTime isEqualToDate:timer.startTime],
                             @"timer startTime (%@) does not match (%@)", timer.startTime, startTime);
              GHAssertTrue([endTime isEqualToDate:timer.endTime],
                             @"timer endTime (%@) does not match (%@)", timer.endTime, endTime);

              GHAssertTrue(adjustment == timer.adjustment,
                           @"timer adjustment (%f) does not match (%f)", timer.adjustment, adjustment);

              NSLog(@"timer: %@ - %@ (%f) %@", self.timer.startTime, self.timer.endTime, self.timer.adjustment, self.timer.message);

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

- (void)moveTimer:(SEL)selector {

    [self prepare];

    [self.service
     moveTimer:self.timer
     toProject:self.secondProject
     success:^{

         __block TCSProject *sourceProject = nil;
         __block TCSProject *targetProject = nil;
         __block TCSTimer *movedTimer = nil;

         void (^executionBlock)(void) = ^{

             GHAssertTrue(sourceProject.timers.count == 0,
                          @"sourceProject.timers.count != 0");
             GHAssertTrue(targetProject.timers.count == 1,
                          @"targetProject.timers.count != 1");
             TCSTimer *targetProjectTimer = targetProject.timers.lastObject;

             GHAssertEquals(movedTimer.providerEntityID, targetProjectTimer.providerEntityID,
                            @"timer.providerEntityID != targetProjectTimer.providerEntityID");

             [self notify:kGHUnitWaitStatusSuccess forSelector:selector];
         };

         __block NSInteger asyncCount = 3;

         [self.project.serviceProvider
          fetchProjectWithID:self.project.providerEntityID
          success:^(TCSProject *project) {

              sourceProject = project;

              @synchronized (self) {

                  asyncCount--;
                  if (asyncCount == 0) {
                      executionBlock();
                  }
              }

          } failure:^(NSError *error) {
              NSLog(@"ZZZ Error: %@", error);
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

         [self.secondProject.serviceProvider
          fetchProjectWithID:self.secondProject.providerEntityID
          success:^(TCSProject *project) {

              targetProject = project;

              @synchronized (self) {

                  asyncCount--;
                  if (asyncCount == 0) {
                      executionBlock();
                  }
              }

          } failure:^(NSError *error) {
              NSLog(@"ZZZ Error: %@", error);
              [self notify:kGHUnitWaitStatusFailure forSelector:selector];
          }];

         [self.timer.serviceProvider
          fetchTimerWithID:self.timer.providerEntityID
          success:^(TCSTimer *timer) {

              movedTimer = timer;

              @synchronized (self) {

                  asyncCount--;
                  if (asyncCount == 0) {
                      executionBlock();
                  }
              }
              
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

- (void)rollTimer:(SEL)selector {

    [self prepare];

    self.timer.endTime = [self.timer.startTime dateByAddingTimeInterval:100.0f];
    self.timer.adjustment = 0.0f;

    [self.service
     updateTimer:self.timer
     success:^{

         GHAssertTrue(self.timer.combinedTime == 100.0f,
                      @"combinedTime (%f) != 100", self.timer.combinedTime);

         [self.service
          rollTimer:self.timer
          maxDuration:10.0f
          success:^(NSArray *rolledTimers) {

              GHAssertTrue(rolledTimers.count == 10,
                           @"rolledTimers.count (%d) != 10",
                           rolledTimers.count);

              GHAssertTrue(self.timer.combinedTime == 10.0f,
                           @"rolled combinedTime (%f) != 10",
                           self.timer.combinedTime);

              for (TCSTimer *t in rolledTimers) {
                  GHAssertTrue(t.combinedTime == 10.0f,
                               @"rolled timer combinedTime (%f) != 10",
                               t.combinedTime);
              }

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

- (void)deleteTimer:(SEL)selector {

    [self prepare];

    [self.service
     deleteTimer:self.timer
     success:^{

         [self.project.serviceProvider
          fetchProjectWithID:self.project.providerEntityID
          success:^(TCSProject *project) {

              GHAssertTrue(project.timers.count == 0,
                           @"timer still referenced in project");

              [self.service
               fetchTimersForProjects:@[self.project]
               fromDate:nil
               toDate:nil
               sortByStartTime:YES
               success:^(NSArray *timers) {

                   GHAssertTrue(timers.count == 0, @"Timer remains after deletion");

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

@end
