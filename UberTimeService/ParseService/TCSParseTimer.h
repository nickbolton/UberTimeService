//
//  TCSParseTimer.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@class TCSParseProject;

@interface TCSParseTimer : TCSParseBaseEntity<PFSubclassing, TCSProvidedTimer>

+ (NSString *)parseClassName;

@property (nonatomic) NSString *message;
@property (nonatomic) NSString *projectID;

@end
