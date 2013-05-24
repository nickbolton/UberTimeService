//
//  TCSParseTimedEntityMetadata.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@interface TCSParseTimedEntityMetadata : TCSParseBaseEntity<PFSubclassing, TCSProvidedTimedEntityMetadata>

+ (NSString *)parseClassName;

@property (nonatomic) NSInteger filteredModifiers;
@property (nonatomic) NSInteger keyCode;
@property (nonatomic) NSInteger modifiers;
@property (nonatomic) NSInteger order;
@property (nonatomic) BOOL archived;
@property (nonatomic) NSInteger color;

@end
