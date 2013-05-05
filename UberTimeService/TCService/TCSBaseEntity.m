//
//  TCSBaseEntity.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseEntity.h"
#import "TCSService.h"
#import "TCSServicePrivate.h"

@implementation TCSBaseEntity

- (BOOL)providerBoolValueForKey:(NSString *)key {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider entityBoolValue:_providerEntity forKey:key];
}

- (NSInteger)providerIntegerValueForKey:(NSString *)key {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider entityIntegerValue:_providerEntity forKey:key];
}

- (CGFloat)providerFloatValueForKey:(NSString *)key {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider entityFloatValue:_providerEntity forKey:key];
}

- (NSString *)providerStringValueForKey:(NSString *)key {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider entityStringValue:_providerEntity forKey:key];
}

- (NSDate *)providerDateValueForKey:(NSString *)key {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider entityDateValue:_providerEntity forKey:key];
}

- (void)setProviderBoolValue:(BOOL)value forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity boolValue:value forKey:key];
}

- (void)setProviderIntegerValue:(NSInteger)value forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity integerValue:value forKey:key];
}

- (void)setProviderFloatValue:(CGFloat)value forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity floatValue:value forKey:key];
}

- (void)setProviderStringValue:(NSString *)value forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity stringValue:value forKey:key];
}

- (void)setProviderDateValue:(NSDate *)value forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity dateValue:value forKey:key];
}

- (NSString *)description {
    return
    [NSString stringWithFormat:@"%@ : %@",
     NSStringFromClass([self class]), [_providerEntity description]];
}

- (NSUInteger)hash {
    return ((NSObject *)_providerEntity).hash;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[TCSBaseEntity class]]) {
        TCSBaseEntity *baseEntityObject = object;
        return [_providerEntity isEqual:baseEntityObject.providerEntity];
    }
    return NO;
}

#pragma mark - Relations

- (void)addParentRelation:(TCSBaseEntity *)parent forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity addParentRelation:parent.providerEntity forKey:key];
}

- (void)removeParentRelationForKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity removeParentRelationForKey:key];
}

- (TCSBaseEntity *)providerRelationForKey:(NSString *)key andType:(Class)type error:(NSError **)error {
    return [(id <TCSServiceProviderPrivate>)_serviceProvider relation:_providerEntity forKey:key andType:type error:error];
}

- (void)setProviderRelation:(TCSBaseEntity *)entity forKey:(NSString *)key {
    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity relation:entity.providerEntity forKey:key];
}

- (NSArray *)providerToManyRelationForKey:(NSString *)key andType:(Class)type error:(NSError **)error{
    return [(id <TCSServiceProviderPrivate>)_serviceProvider toManyRelation:_providerEntity forKey:key andType:type error:error];
}

- (void)setProviderToManyRelation:(NSArray *)entities forKey:(NSString *)key {

    NSMutableArray *values =
    [NSMutableArray arrayWithCapacity:entities.count];

    for (TCSBaseEntity *childEntity in entities) {
        [values addObject:childEntity.providerEntity];
    }

    [(id <TCSServiceProviderPrivate>)_serviceProvider setEntity:_providerEntity toManyRelation:values forKey:key];
}

@end
