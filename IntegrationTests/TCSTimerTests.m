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
    self.service = nil;
    self.remoteProvider = nil;
    self.project = nil;
    self.secondProject = nil;
    self.timer = nil;
    [super tearDownClass];
}

- (void)createProject:(SEL)selector {

    [self prepare];

    [self.service
     createProjectWithName:@"projectB"
     providerInstance:nil
     success:^(TCSProject *project) {

         self.project = project;

         [self.service
          createProjectWithName:@"second project"
          providerInstance:nil
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
     success:^(TCSTimer *timer, TCSProject *updatedProject) {

         self.timer = timer;

         GHAssertNotNil(timer.project.objectID, @"timer parent objectID is nil");
         GHAssertTrue([timer.project.objectID isEqual:self.project.objectID],
                      @"parent project entityID is not equal to test project entityID");

         TCSProject *project =
         [self.service projectWithID:self.project.objectID];

         NSArray *timers =
         [[TCSService sharedInstance]
          timersForProjects:@[project]
          fromDate:nil
          toDate:nil
          sortByStartTime:NO];

         TCSTimer *projectTimer = timers.firstObject;

         GHAssertTrue([projectTimer.objectID isEqual:timer.objectID],
                      @"fetched project.timer != created timer");

         GHAssertTrue(timers.count <= 1, @"Multiple timers exist");
         GHAssertTrue(timers.count == 1, @"Timer doesn't exist after starting");

         TCSTimer *fetchedTimer = timers[0];

         GHAssertNotNil(fetchedTimer.objectID, @"fetchedTimer providerEntityID is nil");
         GHAssertTrue([timer.objectID isEqual:fetchedTimer.objectID],
                      @"fetchedTimer entityID (%@) is not equal to entityID (%@)",
                      fetchedTimer.objectID, timer.objectID);

         GHAssertTrue([fetchedTimer.objectID isEqual:self.service.activeTimer.objectID],
                      @"activeTimer is not returned timer");

         NSLog(@"timer: %@ - %@ (%f) %@", timer.startTime, timer.endTime, timer.adjustmentValue, timer.message);
         NSLog(@"timer.project: %@", timer.project.name);

         for (TCSTimer *t in self.project.timers) {
             NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustmentValue, t.message);
         }

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)startSecondTimer:(SEL)selector {

    [self prepare];

    [self.service
     startTimerForProject:self.project
     success:^(TCSTimer *timer, TCSProject *updatedProject) {

         self.secondTimer = timer;

         GHAssertNotNil(timer.project.objectID, @"timer parent objectID is nil");
         GHAssertTrue([timer.project.objectID isEqual:self.project.objectID],
                      @"parent project entityID is not equal to test project entityID");

         TCSProject *project =
         [self.service projectWithID:self.project.objectID];

         NSArray *timers =
         [[TCSService sharedInstance]
          timersForProjects:@[project]
          fromDate:nil
          toDate:nil
          sortByStartTime:NO];

         GHAssertTrue(timers.count == 2, @"project.timers.count != 2");

         BOOL foundTimer = NO;

         for (TCSTimer *t in timers) {
             if ([t.objectID isEqual:timer.objectID]) {
                 foundTimer = YES;
                 break;
             }
         }

         GHAssertTrue(foundTimer, @"created timer not found in project.timers");

         GHAssertFalse([timer.objectID isEqual:self.timer.objectID],
                       @"second timer IS first timer");

         GHAssertTrue(timers.count == 2, @"Timer doesn't exist after starting");

         TCSTimer *fetchedTimer = nil;

         for (TCSTimer *t in timers) {
             if ([t.objectID isEqual:timer.objectID]) {
                 fetchedTimer = t;
             }
         }

         GHAssertNotNil(fetchedTimer.objectID, @"fetchedTimer providerEntityID is nil");
         GHAssertTrue([timer.objectID isEqual:fetchedTimer.objectID],
                      @"fetchedTimer entityID (%@) is not equal to entityID (%@)",
                      fetchedTimer.objectID, timer.objectID);

         GHAssertTrue([fetchedTimer.objectID isEqual:self.service.activeTimer.objectID],
                      @"activeTimer is not returned timer");

         NSLog(@"timer: %@ - %@ (%f) %@", timer.startTime, timer.endTime, timer.adjustmentValue, timer.message);
         NSLog(@"timer.project: %@", timer.project.name);

         for (TCSTimer *t in self.project.timers) {
             NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustmentValue, t.message);
         }

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

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
     success:^(TCSTimer *updatedTimer) {

         NSLog(@"timer: %@ - %@ (%f) %@", self.timer.startTime, self.timer.endTime, self.timer.adjustmentValue, self.timer.message);
         NSLog(@"timer.project: %@", self.timer.project.name);

         GHAssertNil(self.service.activeTimer, @"Active timer remains after stopping");

         for (TCSTimer *t in self.project.timers) {
             NSLog(@"project timer: %@ - %@ (%f) %@", t.startTime, t.endTime, t.adjustmentValue, t.message);
         }

         TCSTimer *timer = [self.service timerWithID:self.timer.objectID];

         GHAssertNotNil(timer.endTime, @"timer endTime was nil after stopping timer");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:60.0f];

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
    self.timer.adjustmentValue = adjustment;

    [self.service
     updateTimer:self.timer
     success:^(TCSTimer *updatedTimer){

         GHAssertTrue([self.timer.objectID isEqual:updatedTimer.objectID],
                      @"fetched timer does not have the same entityID");

         GHAssertTrue([message isEqualToString:updatedTimer.message],
                      @"timer message (%@) does not match (%@)", updatedTimer.message, message);
         GHAssertTrue(roundf(startTime.timeIntervalSinceReferenceDate*1000.0f) == roundf(updatedTimer.startTime.timeIntervalSinceReferenceDate*1000.0f),
                      @"timer startTime (%f) does not match (%f)",
                      updatedTimer.startTime.timeIntervalSinceReferenceDate, startTime.timeIntervalSinceReferenceDate);
         GHAssertTrue(roundf(endTime.timeIntervalSinceReferenceDate*1000.0f) == roundf(updatedTimer.endTime.timeIntervalSinceReferenceDate*1000.0f),
                      @"timer endTime (%f) does not match (%f)",
                      updatedTimer.endTime.timeIntervalSinceReferenceDate, endTime.timeIntervalSinceReferenceDate);

         GHAssertTrue(adjustment == updatedTimer.adjustmentValue,
                      @"timer adjustment (%f) does not match (%f)", updatedTimer.adjustmentValue, adjustment);

         NSLog(@"timer: %@ - %@ (%f) %@",
               self.timer.startTime, self.timer.endTime,
               self.timer.adjustmentValue, self.timer.message);

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

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
     success:^(TCSTimer *updatedTimer, TCSProject *updatedProject) {

         TCSProject *sourceProject =
         [self.service projectWithID:self.project.objectID];

         TCSProject *targetProject =
         [self.service projectWithID:self.secondProject.objectID];

         TCSTimer *movedTimer =
         [self.service timerWithID:self.timer.objectID];

         NSArray *sourceTimers =
         [[TCSService sharedInstance]
          timersForProjects:@[sourceProject]
          fromDate:nil
          toDate:nil
          sortByStartTime:NO];

         NSArray *targetTimers =
         [[TCSService sharedInstance]
          timersForProjects:@[targetProject]
          fromDate:nil
          toDate:nil
          sortByStartTime:NO];

         GHAssertTrue(sourceTimers.count == 1,
                      @"sourceTimers.count != 1");
         GHAssertTrue(targetTimers.count == 1,
                      @"targetTimers.count != 1");
         TCSTimer *targetProjectTimer = targetTimers.firstObject;

         GHAssertTrue([movedTimer.objectID isEqual:targetProjectTimer.objectID],
                      @"movedTimer.objectID != targetProjectTimer.objectID");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)rollTimer:(SEL)selector {

    [self prepare];

    self.timer.endTime = [self.timer.startTime dateByAddingTimeInterval:100.0f];
    self.timer.adjustmentValue = 0.0f;

    [self.service
     updateTimer:self.timer
     success:^(TCSTimer *updatedTimer){

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

    TCSProject *sourceProject = self.timer.project;

    NSInteger timerCount =
    [[TCSService sharedInstance]
     timersForProjects:@[sourceProject]
     fromDate:nil
     toDate:nil
     sortByStartTime:NO].count;

    [self.service
     deleteTimer:self.timer
     success:^{

         TCSProject *project =
         [self.service projectWithID:sourceProject.objectID];

         NSInteger updatedTimerCount =
         [[TCSService sharedInstance]
          timersForProjects:@[project]
          fromDate:nil
          toDate:nil
          sortByStartTime:NO].count;

         GHAssertTrue(updatedTimerCount == timerCount-1,
                      @"timer still referenced in project");

         NSArray *timers =
         [self.service
          timersForProjects:@[sourceProject]
          fromDate:nil
          toDate:nil
          sortByStartTime:YES];

         GHAssertTrue(timers.count == timerCount-1, @"Timer remains after deletion");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];
    
    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

@end
