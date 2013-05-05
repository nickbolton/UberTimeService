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
#import "TCSServicePrivate.h"

@implementation TCSDefaultProvider

- (id)entityIDForEntity:(id)entity {

    if ([entity isKindOfClass:[TCSBaseEntity class]]) {
        return ((TCSBaseEntity *)entity).providerEntityID;
    }
    return nil;
}

- (TCSBaseEntity *)wrapProviderEntity:(id)entity
                               inType:(Class)type
                             provider:(id <TCSServiceProvider>)serviceProvider {

    if (entity != nil) {
        TCSBaseEntity *wrappedEntity = [[type alloc] init];
        wrappedEntity.providerEntity = entity;
        wrappedEntity.providerEntityID = [(id <TCSServiceProviderPrivate>)serviceProvider entityIDForEntity:entity];
        wrappedEntity.serviceProvider = (id)self;

        return wrappedEntity;
    }

    return nil;
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

#pragma mark - User Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        successBlock();
    }
}

- (void)logoutUser:(void(^)(void))successBlock
           failure:(void(^)(NSError *error))failureBlock {
    if (successBlock != nil) {
        successBlock();
    }
}

- (BOOL)isUserAuthenticated {
    return YES;
}

@end
