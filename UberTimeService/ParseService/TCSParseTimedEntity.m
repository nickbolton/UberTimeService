//
//  TCSParseTimedEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimedEntity.h"

@implementation TCSParseTimedEntity

@dynamic name;
@dynamic filteredModifiers;
@dynamic keyCode;
@dynamic modifiers;
@dynamic order;
@dynamic archived;
@dynamic color;
@dynamic parentID;

- (NSString *)utsName {
    return self.name;
}

- (NSInteger)utsFilteredModifiers {
    return self.filteredModifiers;
}

- (NSInteger)utsKeyCode {
    return self.keyCode;
}

- (NSInteger)utsModifiers {
    return self.modifiers;
}

- (NSInteger)utsOrder {
    return self.order;
}

- (BOOL)utsArchived {
    return self.archived;
}

- (NSInteger)utsColor {
    return self.color;
}

- (NSString *)utsParentID {
    return self.parentID;
}

@end
