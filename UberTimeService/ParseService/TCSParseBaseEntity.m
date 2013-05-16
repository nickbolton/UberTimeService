//
//  TCSParseBaseEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@implementation TCSParseBaseEntity

@dynamic softDeleted;
@dynamic entityVersion;
@dynamic instanceID;
@dynamic user;

- (NSString *)utsRemoteID {
    return self.objectId;
}

- (BOOL)utsSoftDeleted {
    return self.softDeleted;
}

- (NSInteger)utsEntityVersion {
    return self.entityVersion;
}

- (NSDate *)utsUpdateTime {
    return self.updatedAt;
}

@end
