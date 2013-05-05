//
//  TCSParseTimer.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@class TCSParseProject;

@interface TCSParseTimer : TCSParseBaseEntity<PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *endTime;
@property (nonatomic) NSString *message;
@property (nonatomic) NSTimeInterval adjustment;
@property (nonatomic) TCSParseProject *project;

@end
