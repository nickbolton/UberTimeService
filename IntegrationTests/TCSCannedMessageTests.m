//
//  TCSCannedMessageTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSCannedMessageTests.h"

@implementation TCSCannedMessageTests

- (void)setUpClass {
    [super setUpClass];
    self.service = [TCSService sharedInstance];
}

- (void)tearDownClass {
    self.service = nil;
    self.cannedMessage1 = nil;
    self.cannedMessage2 = nil;
    self.cannedMessage3 = nil;
    self.remoteProvider = nil;
    [super tearDownClass];
}

- (void)createCannedMessages:(SEL)selector {

    [self prepare];

    NSString *messageValue = @"boooooooooo";

    [self.service
     createCannedMessage:messageValue
     remoteProvider:nil
     success:^(TCSCannedMessage *cannedMessage) {

         self.cannedMessage1 = cannedMessage;

         GHAssertTrue([messageValue isEqualToString:cannedMessage.message],
                      @"cannedMessage1 message does not match");

         GHAssertTrue(cannedMessage.orderValue == 0,
                      @"cannedMessage1 order != 0");

         NSString *messageValue2 = @"boooooooooo222222";

         [self.service
          createCannedMessage:messageValue2
          remoteProvider:nil
          success:^(TCSCannedMessage *cannedMessage) {

              self.cannedMessage2 = cannedMessage;

              GHAssertTrue([messageValue2 isEqualToString:cannedMessage.message],
                           @"cannedMessage2 message does not match");

              GHAssertTrue(cannedMessage.orderValue == 1,
                           @"cannedMessage2 order != 1");

              NSString *messageValue3 = @"boooooooooo333333";

              [self.service
               createCannedMessage:messageValue3
               remoteProvider:nil
               success:^(TCSCannedMessage *cannedMessage) {

                   self.cannedMessage3 = cannedMessage;

                   GHAssertTrue([messageValue3 isEqualToString:cannedMessage.message],
                                @"cannedMessage3 message does not match");

                   GHAssertTrue(cannedMessage.orderValue == 2,
                                @"cannedMessage1 order != 2");

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

- (void)updateCannedMessage:(SEL)selector {

    [self prepare];

    NSString *updatedMessage = @"babababa";

    self.cannedMessage1.message = updatedMessage;

    [self.service
     updateCannedMessage:self.cannedMessage1
     success:^(TCSCannedMessage *updatedCannedMessage){

         GHAssertTrue([updatedMessage isEqualToString:updatedCannedMessage.message],
                      @"updated message not equal");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)reorderCannedMessage1:(SEL)selector {

    [self prepare];

    [self.service
     reorderCannedMessage:self.cannedMessage1
     order:1
     success:^{

         NSArray *cannedMessages = [self.service allCannedMessages];

         GHAssertTrue(cannedMessages.count == 3,
                      @"Incorrect object count (%d)", cannedMessages.count);

         GHAssertTrue([self.cannedMessage1.objectID isEqual:((TCSCannedMessage *)cannedMessages[1]).objectID],
                      @"cannedMessage1 is in the incorrect position");

         GHAssertTrue([self.cannedMessage2.objectID isEqual:((TCSCannedMessage *)cannedMessages[0]).objectID],
                      @"cannedMessage2 is in the incorrect position");

         GHAssertTrue([self.cannedMessage3.objectID isEqual:((TCSCannedMessage *)cannedMessages[2]).objectID],
                      @"cannedMessage3 is in the incorrect position");

         NSInteger i=0;
         for (TCSCannedMessage *cannedMessage in cannedMessages) {

             GHAssertTrue(cannedMessage.orderValue == i++,
                          @"first message order is not %d", i-1);
         }

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

- (void)deleteCannedMessage:(SEL)selector {

    [self prepare];

    [self.service
     deleteCannedMessage:self.cannedMessage1
     success:^{

         NSArray *cannedMessages = [self.service allCannedMessages];

         GHAssertTrue(cannedMessages.count == 2, @"message count != 2");

         [self notify:kGHUnitWaitStatusSuccess forSelector:selector];

     } failure:^(NSError *error) {
         NSLog(@"ZZZ Error: %@", error);
         [self notify:kGHUnitWaitStatusFailure forSelector:selector];
     }];

    [self waitForStatus:kGHUnitWaitStatusSuccess timeout:5.0f];
}

@end
