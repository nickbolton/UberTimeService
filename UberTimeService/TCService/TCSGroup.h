//
//  TCSGroup.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSTimedEntity.h"

@interface TCSGroup : TCSTimedEntity

@property (nonatomic, strong) NSArray *children;

@end
