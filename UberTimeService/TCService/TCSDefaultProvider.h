//
//  TCSDefaultProvider.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

@class TCSBaseEntity;
@protocol TCSServiceProvider;

@interface TCSDefaultProvider : NSObject

- (TCSBaseEntity *)wrapProviderEntity:(id)entity
                               inType:(Class)type
                             provider:(id <TCSServiceProvider>)serviceProvider;

- (NSArray *)wrapProviderEntities:(NSArray *)entities
                           inType:(Class)type
                         provider:(id <TCSServiceProvider>)serviceProvider;

@end
