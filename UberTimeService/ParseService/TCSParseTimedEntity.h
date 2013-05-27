//
//  TCSParseTimedEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSParseBaseEntity.h"

@interface TCSParseTimedEntity : TCSParseBaseEntity<TCSProvidedTimedEntity>

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger filteredModifiers;
@property (nonatomic) NSInteger keyCode;
@property (nonatomic) NSInteger modifiers;
@property (nonatomic) NSInteger order;
@property (nonatomic) BOOL archived;
@property (nonatomic) NSInteger color;
@property (nonatomic) NSString *parentID;

@end
