//
//  TCSParseProject.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseProject.h"
#import <Parse/PFObject+Subclass.h>

@implementation TCSParseProject

@dynamic filteredModifiers;
@dynamic keyCode;
@dynamic modifiers;
@dynamic order;

+ (NSString *)parseClassName {
    return NSStringFromClass([self class]);
}

- (Class)utsLocalEntityType {
    return [TCSProject class];
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

@end
