//
//  TCSParseTimerMetadata.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/25/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseMetadataEntity.h"

@interface TCSParseTimerMetadata : TCSParseBaseMetadataEntity <PFSubclassing, TCSProvidedTimerMetadata>

+ (NSString *)parseClassName;

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *endTime;
@property (nonatomic) NSTimeInterval adjustment;

@end
