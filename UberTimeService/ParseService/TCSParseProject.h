//
//  TCSParseProject.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseTimedEntity.h"

@interface TCSParseProject : TCSParseTimedEntity<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic) NSInteger filteredModifiers;
@property (nonatomic) NSInteger keyCode;
@property (nonatomic) NSInteger modifiers;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSArray *timers;

@end
