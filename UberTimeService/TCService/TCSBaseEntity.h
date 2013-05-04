//
//  TCSBaseEntity.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TCSServiceProvider;

@interface TCSBaseEntity : NSObject

@property (nonatomic, strong) id providerEntity;
@property (nonatomic, strong) id providerEntityID;
@property (nonatomic, strong) id <TCSServiceProvider> serviceProvider;

- (BOOL)providerBoolValueForKey:(NSString *)key;
- (NSInteger)providerIntegerValueForKey:(NSString *)key;
- (CGFloat)providerFloatValueForKey:(NSString *)key;
- (NSString *)providerStringValueForKey:(NSString *)key;
- (NSDate *)providerDateValueForKey:(NSString *)key;

- (void)setProviderBoolValue:(BOOL)value forKey:(NSString *)key;
- (void)setProviderIntegerValue:(NSInteger)value forKey:(NSString *)key;
- (void)setProviderFloatValue:(CGFloat)value forKey:(NSString *)key;
- (void)setProviderStringValue:(NSString *)value forKey:(NSString *)key;
- (void)setProviderDateValue:(NSDate *)value forKey:(NSString *)key;

- (TCSBaseEntity *)providerRelationForKey:(NSString *)key andType:(Class)type;
- (void)setProviderRelation:(TCSBaseEntity *)entity forKey:(NSString *)key;

- (NSArray *)providerToManyRelationForKey:(NSString *)key andType:(Class)type;
- (void)setProviderToManyRelation:(NSArray *)entities forKey:(NSString *)key;

- (void)addParentRelation:(TCSBaseEntity *)parent forKey:(NSString *)key;
- (void)removeParentRelationForKey:(NSString *)key;

@end
