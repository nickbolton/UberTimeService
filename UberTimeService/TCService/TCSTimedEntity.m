//
//  TCSTimedEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimedEntity.h"

@implementation TCSTimedEntity

- (BOOL)isArchived {
    return [self providerBoolValueForKey:@"archived"];
}

- (void)setArchived:(BOOL)archived {
    [self setProviderBoolValue:archived forKey:@"archived"];
}

- (NSString *)name {
    return [self providerStringValueForKey:@"name"];
}

- (void)setName:(NSString *)name {
    [self setProviderStringValue:name forKey:@"name"];
}

- (NSInteger)color {
    return [self providerIntegerValueForKey:@"color"];
}

- (void)setColor:(NSInteger)color {
    [self setProviderIntegerValue:color forKey:@"color"];
}

@end
