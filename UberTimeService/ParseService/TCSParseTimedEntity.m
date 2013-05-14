//
//  TCSParseTimedEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimedEntity.h"

@implementation TCSParseTimedEntity

@dynamic archived;
@dynamic name;
@dynamic color;
@dynamic parentID;

- (BOOL)utsArchived {
    return self.archived;
}

- (NSString *)utsName {
    return self.name;
}

- (NSInteger)utsColor {
    return self.color;
}

- (NSString *)utsParentID {
    return self.parentID;
}

@end
