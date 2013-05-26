//
//  TCSParseBaseMetadataEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/26/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Parse/Parse.h>

@interface TCSParseBaseMetadataEntity : PFObject<TCSProvidedBaseMetadataEntity>

@property (nonatomic) NSString *relatedRemoteID;

@end
