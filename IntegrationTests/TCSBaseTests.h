//
//  TCSBaseTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@protocol TCSServiceProvider;
@class TCSProject;
@class TCSGroup;
@class TCSTimer;
@class TCSService;

@interface TCSBaseTests : GHAsyncTestCase

@property (nonatomic, strong) TCSService *service;
@property (nonatomic, strong) id <TCSServiceProvider> serviceProvider;

- (void)findProjectWithEntityID:(id)entityID
                serviceProvider:(id <TCSServiceProvider>)serviceProvider
                        success:(void(^)(TCSProject *project))successBlock
                        failure:(void(^)(void))failureBlock;

- (void)findTimerWithEntityID:(id)entityID
              serviceProvider:(id <TCSServiceProvider>)serviceProvider
                      success:(void(^)(TCSTimer *timer))successBlock
                      failure:(void(^)(void))failureBlock;

- (void)findGroupWithEntityID:(id)entityID
              serviceProvider:(id <TCSServiceProvider>)serviceProvider
                      success:(void(^)(TCSGroup *group))successBlock
                      failure:(void(^)(void))failureBlock;

@end
