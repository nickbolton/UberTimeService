//
//  TCSTimedEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSBaseEntity.h"

@class TCSGroup;

@interface TCSTimedEntity : TCSBaseEntity

@property (nonatomic, getter = isArchived) BOOL archived;
@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger color;

@property (nonatomic) TCSGroup *parent;

@end
