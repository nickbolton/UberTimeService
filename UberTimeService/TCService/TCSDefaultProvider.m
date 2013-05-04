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

- (id)entityIDForEntity:(id)entity {

    if ([entity isKindOfClass:[TCSBaseEntity class]]) {
        return ((TCSBaseEntity *)entity).providerEntityID;
    }
    return nil;
}

- (BOOL)entityBoolValue:(id)entity forKey:(NSString *)key {
    return [entity valueForKey:key];
}

- (NSInteger)entityIntegerValue:(id)entity forKey:(NSString *)key {

}

- (CGFloat)entityFloatValue:(id)entity forKey:(NSString *)key {

}

- (NSString *)entityStringValue:(id)entity forKey:(NSString *)key {

}

- (NSDate *)entityDateValue:(id)entity forKey:(NSString *)key {

}

- (void)setEntity:(id)entity boolValue:(BOOL)value forKey:(NSString *)key {

}

- (void)setEntity:(id)entity integerValue:(NSInteger)value forKey:(NSString *)key {

}

- (void)setEntity:(id)entity floatValue:(CGFloat)value forKey:(NSString *)key {

}

- (void)setEntity:(id)entity stringValue:(NSString *)value forKey:(NSString *)key {

}

- (void)setEntity:(id)entity dateValue:(NSDate *)value forKey:(NSString *)key {
    
}

- (TCSBaseEntity *)wrapProviderEntity:(id)entity
                               inType:(Class)type
                             provider:(id <TCSServiceProvider>)serviceProvider {

    if (entity != nil) {
        TCSBaseEntity *wrappedEntity = [[type alloc] init];
        wrappedEntity.providerEntity = entity;
        wrappedEntity.providerEntityID = [serviceProvider entityIDForEntity:entity];
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

@end
