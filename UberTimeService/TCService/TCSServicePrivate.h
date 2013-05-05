//
//  TCSServicePrivate.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

@protocol TCSServiceProviderPrivate <NSObject>

- (id)entityIDForEntity:(id)entity;

- (BOOL)entityBoolValue:(id)entity forKey:(NSString *)key;
- (NSInteger)entityIntegerValue:(id)entity forKey:(NSString *)key;
- (CGFloat)entityFloatValue:(id)entity forKey:(NSString *)key;
- (NSString *)entityStringValue:(id)entity forKey:(NSString *)key;
- (NSDate *)entityDateValue:(id)entity forKey:(NSString *)key;

- (void)setEntity:(id)entity boolValue:(BOOL)value forKey:(NSString *)key;
- (void)setEntity:(id)entity integerValue:(NSInteger)value forKey:(NSString *)key;
- (void)setEntity:(id)entity floatValue:(CGFloat)value forKey:(NSString *)key;
- (void)setEntity:(id)entity stringValue:(NSString *)value forKey:(NSString *)key;
- (void)setEntity:(id)entity dateValue:(NSDate *)value forKey:(NSString *)key;

- (TCSBaseEntity *)relation:(id)entity forKey:(NSString *)key andType:(Class)type error:(NSError **)error;
- (void)setEntity:(id)entity relation:(id)relation forKey:(NSString *)key;
- (NSArray *)toManyRelation:(id)entity forKey:(NSString *)key andType:(Class)type error:(NSError **)error;
- (void)setEntity:(id)entity toManyRelation:(NSArray *)relations forKey:(NSString *)key;

- (void)setEntity:(id)entity addParentRelation:(id)relation forKey:(NSString *)key;
- (void)setEntity:(id)entity removeParentRelationForKey:(NSString *)key;

- (void)deleteAllData:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock;

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock;

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(TCSGroup *group))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer))successBlock
                     failure:(void(^)(NSError *error))failureBlock;

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock;

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock;

- (void)fetchTimersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                           now:(NSDate *)now
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock;

@end