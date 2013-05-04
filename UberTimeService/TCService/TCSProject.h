//
//  TCSProject.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimedEntity.h"

@class TCSTimer;

@interface TCSProject : TCSTimedEntity

@property (nonatomic) NSInteger filteredModifiers;
@property (nonatomic) NSInteger keyCode;
@property (nonatomic) NSInteger modifiers;
@property (nonatomic) NSInteger order;

@property (nonatomic, strong) NSArray *timers;

@end
