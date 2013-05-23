//
//  TCSCannedMessageTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseTests.h"

@interface TCSCannedMessageTests : TCSBaseTests

@property (nonatomic, strong) TCSCannedMessage *cannedMessage1;
@property (nonatomic, strong) TCSCannedMessage *cannedMessage2;
@property (nonatomic, strong) TCSCannedMessage *cannedMessage3;

- (void)createCannedMessages:(SEL)selector;
- (void)updateCannedMessage:(SEL)selector;
- (void)reorderCannedMessage1:(SEL)selector;
//- (void)reorderCannedMessage2:(SEL)selector;
//- (void)reorderCannedMessage3:(SEL)selector;
- (void)deleteCannedMessage:(SEL)selector;

@end
