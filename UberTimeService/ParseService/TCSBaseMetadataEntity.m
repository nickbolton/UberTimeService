//
//  TCSBaseMetadataEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/26/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseMetadataEntity.h"

@implementation TCSBaseMetadataEntity

@dynamic relatedRemoteID;

- (NSString *)utsRelatedRemoteID {
    return self.relatedRemoteID;
}

@end
