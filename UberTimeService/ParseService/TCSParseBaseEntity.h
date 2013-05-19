//
//  TCSParseBaseEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Parse/Parse.h>

@interface TCSParseBaseEntity : PFObject <TCSProvidedBaseEntity>

@property (nonatomic) NSInteger entityVersion;
@property (nonatomic) NSString *instanceID;
@property (nonatomic) PFUser *user;

@end
