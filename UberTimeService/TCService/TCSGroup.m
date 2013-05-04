//
//  TCSGroup.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSGroup.h"
#import "TCSProject.h"

@implementation TCSGroup

- (NSArray *)children {
    return [self providerToManyRelationForKey:@"children" andType:[TCSProject class]];
}

- (void)setChildren:(NSArray *)children {
    [self setProviderToManyRelation:children forKey:@"children"];
}

@end
