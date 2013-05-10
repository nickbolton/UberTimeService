//
//  TCSLocalDDDCannedMessageTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/10/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSCannedMessageTests.h"
#import "TCSLocalService.h"

@interface TCSLocalDDDCannedMessageTests : TCSCannedMessageTests { }
@end

@implementation TCSLocalDDDCannedMessageTests

- (void)testAAAcreateCannedMessages {
    [self createCannedMessages:_cmd];
}

- (void)testBBBupdateCannedMessage {
    [self updateCannedMessage:_cmd];
}

- (void)testCCCreorderCannedMessage1 {
    [self reorderCannedMessage1:_cmd];
}

- (void)testFFFdeleteCannedMessage {
    [self deleteCannedMessage:_cmd];
}

@end
