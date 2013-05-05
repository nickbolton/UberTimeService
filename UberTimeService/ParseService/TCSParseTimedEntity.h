//
//  TCSParseTimedEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSParseBaseEntity.h"

@class TCSParseGroup;

@interface TCSParseTimedEntity : TCSParseBaseEntity

@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger color;

@property (nonatomic) TCSParseGroup *parent;

@end
