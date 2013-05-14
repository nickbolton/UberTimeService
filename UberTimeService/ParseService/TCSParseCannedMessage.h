//
//  TCSParseCannedMessage.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@interface TCSParseCannedMessage : TCSParseBaseEntity<PFSubclassing, TCSProvidedCannedMessage>

+ (NSString *)parseClassName;

@property (nonatomic) NSString *message;
@property (nonatomic) NSInteger order;

@end
