//
//  TCSDefaultProvider.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSDefaultProvider.h"
#import "TCSBaseEntity.h"
#import "TCSService.h"

@implementation TCSDefaultProvider

- (TCSBaseEntity *)wrapProviderEntity:(id)entity
                               inType:(Class)type
                             provider:(id <TCSServiceProvider>)serviceProvider {

    TCSBaseEntity *wrappedEntity = [[type alloc] init];
    wrappedEntity.providerEntity = entity;
    wrappedEntity.providerEntityID = [serviceProvider entityIDForEntity:entity];
    wrappedEntity.serviceProvider = (id)self;

    return wrappedEntity;
}

- (NSArray *)wrapProviderEntities:(NSArray *)entities
                           inType:(Class)type
                         provider:(id <TCSServiceProvider>)serviceProvider {

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:entities.count];

    for (id entity in entities) {
        id wrappedEntity =
        [self wrapProviderEntity:entity inType:type provider:serviceProvider];
        [result addObject:wrappedEntity];
    }

    return result;
}

@end
