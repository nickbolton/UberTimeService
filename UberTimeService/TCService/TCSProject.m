//
//  TCSProject.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSProject.h"
#import "TCSTimer.h"

@implementation TCSProject

- (NSInteger)filteredModifiers {
    return [self providerIntegerValueForKey:@"filteredModifiers"];
}

- (void)setFilteredModifiers:(NSInteger)filteredModifiers {
    [self setProviderIntegerValue:filteredModifiers forKey:@"filteredModifiers"];
}

- (NSInteger)keyCode {
    return [self providerIntegerValueForKey:@"keyCode"];
}

- (void)setKeyCode:(NSInteger)keyCode {
    [self setProviderIntegerValue:keyCode forKey:@"keyCode"];
}

- (NSInteger)modifiers {
    return [self providerIntegerValueForKey:@"modifiers"];
}

- (void)setModifiers:(NSInteger)modifiers {
    [self setProviderIntegerValue:modifiers forKey:@"modifiers"];
}

- (NSInteger)order {
    return [self providerIntegerValueForKey:@"order"];
}

- (void)setOrder:(NSInteger)order {
    [self setProviderIntegerValue:order forKey:@"order"];
}

- (NSArray *)timers {
    return [self providerToManyRelationForKey:@"timers" andType:[TCSTimer class]];
}

- (void)setTimers:(NSArray *)timers {
    [self setProviderToManyRelation:timers forKey:@"timers"];
}

@end
