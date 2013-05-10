//
//  TCSBaseTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

#import "TCSService.h"

@class NSManagedObjectID;

@interface TCSBaseTests : GHAsyncTestCase

@property (nonatomic, strong) TCSService *service;
@property (nonatomic, strong) NSString *remoteProvider;

- (TCSProject *)projectWithEntityID:(NSManagedObjectID *)objectID;

- (TCSTimer *)timerWithEntityID:(NSManagedObjectID *)objectID;

- (TCSGroup *)groupWithEntityID:(NSManagedObjectID *)objectID;

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(void))failureBlock;

@end
