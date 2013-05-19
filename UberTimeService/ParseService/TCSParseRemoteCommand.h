//
//  TCSParseRemoteCommand.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/19/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@interface TCSParseRemoteCommand : TCSParseBaseEntity<PFSubclassing, TCSProvidedRemoteCommand>

+ (NSString *)parseClassName;

@property (nonatomic) NSData *payload;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSArray *executedInstallations;

@end
