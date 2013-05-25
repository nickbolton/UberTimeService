//
//  TCSParseProviderInstance.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/23/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSParseBaseEntity.h"

@interface TCSParseProviderInstance : TCSParseBaseEntity<PFSubclassing, TCSProvidedProviderInstance>

+ (NSString *)parseClassName;

@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *password;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *userID;
@property (nonatomic) NSString *remoteProvider;

@end
