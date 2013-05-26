//
//  TCSParseTimedEntityMetadata.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimedEntityMetadata.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseTimedEntityMetadata

@dynamic filteredModifiers;
@dynamic keyCode;
@dynamic modifiers;
@dynamic order;
@dynamic archived;
@dynamic color;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSTimedEntityMetadata class];
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

@end
