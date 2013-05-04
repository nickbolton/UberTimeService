//
//  TCBaseTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>

@protocol TCSServiceProvider;
@class TCSProject;
@class TCSService;

@interface TCBaseTests : GHAsyncTestCase

@property (nonatomic, strong) TCSService *service;
@property (nonatomic, strong) id <TCSServiceProvider> serviceProvider;

- (void)findProjectNamed:(NSString *)name
         serviceProvider:(id <TCSServiceProvider>)serviceProvider
                 success:(void(^)(TCSProject *project))successBlock
                 failure:(void(^)(void))failureBlock;

- (void)findProjectWithEntityID:(id)entityID
                serviceProvider:(id <TCSServiceProvider>)serviceProvider
                        success:(void(^)(TCSProject *project))successBlock
                        failure:(void(^)(void))failureBlock;

- (void)findProjectWithEntityID:(id)entityID
                           name:(NSString *)name
                serviceProvider:(id <TCSServiceProvider>)serviceProvider
                        success:(void(^)(TCSProject *project))successBlock
                        failure:(void(^)(void))failureBlock;

@end
