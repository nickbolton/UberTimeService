//
//  TCSHarvestService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSHarvestService.h"

@implementation TCSHarvestService

- (NSString *)name {
    return NSLocalizedString(@"Harvest", nil);
}

- (void)clearCache {
}

- (id)entityIDForEntity:(id)entity {
    
}

- (BOOL)entityBoolValue:(id)entity forKey:(NSString *)key {

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

- (TCSBaseEntity *)relation:(id)entity forKey:(NSString *)key andType:(Class)type error:(NSError **)error{

}

- (void)setEntity:(id)entity relation:(id)relation forKey:(NSString *)key {

}

- (NSArray *)toManyRelation:(id)entity forKey:(NSString *)key andType:(Class)type {

}

- (void)setEntity:(id)entity toManyRelation:(NSArray *)relations forKey:(NSString *)key error:(NSError **)error {

}

- (void)setEntity:(id)entity addParentRelation:(id)relation forKey:(NSString *)key {

}

- (void)setEntity:(id)entity removeParentRelationForKey:(NSString *)key {

}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

    if (successBlock != nil) {
        successBlock();
    }
}

#pragma mark - Project Methods

- (void)createProjectWithName:(NSString *)name
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {
    
}

- (void)createProjectWithName:(NSString *)name
            filteredModifiers:(NSInteger)filteredModifiers
                      keyCode:(NSInteger)keyCode
                    modifiers:(NSInteger)modifiers
                      success:(void(^)(TCSProject *project))successBlock
                      failure:(void(^)(NSError *error))failureBlock {

}

- (void)updateProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {
    
}

- (void)deleteProject:(TCSProject *)project
              success:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchProjectWithName:(NSString *)name
                     success:(void(^)(NSArray *projects))successBlock
                     failure:(void(^)(NSError *error))failureBlock {
    
}

- (void)fetchProjectWithID:(id)entityID
                   success:(void(^)(TCSProject *project))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchProjects:(void(^)(NSArray *projects))successBlock
              failure:(void(^)(NSError *error))failureBlock {

}

#pragma mark - Group Methods

- (void)updateGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

}

- (void)deleteGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchGroupWithID:(id)entityID
                 success:(void(^)(TCSGroup *group))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchGroups:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {

}

- (void)moveProject:(TCSProject *)sourceProject
          toProject:(TCSProject *)toProject
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

}

- (void)moveProject:(TCSProject *)sourceProject
            toGroup:(TCSGroup *)group
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {
    
}

#pragma mark - Timer Methods

- (void)startTimerForProject:(TCSProject *)project
                     success:(void(^)(TCSTimer *timer))successBlock
                     failure:(void(^)(NSError *error))failureBlock {
    
}

- (void)stopTimer:(TCSTimer *)timer
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

}

- (void)updateTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {

}

- (void)moveTimer:(TCSTimer *)timer
        toProject:(TCSProject *)project
          success:(void(^)(void))successBlock
          failure:(void(^)(NSError *error))failureBlock {

}

- (void)rollTimer:(TCSTimer *)timer
      maxDuration:(NSTimeInterval)maxDuration
          success:(void(^)(NSArray *rolledTimers))successBlock
          failure:(void(^)(NSError *error))failureBlock {

}

- (void)deleteTimer:(TCSTimer *)timer
            success:(void(^)(void))successBlock
            failure:(void(^)(NSError *error))failureBlock {
    
}

- (void)fetchTimerWithID:(id)entityID
                 success:(void(^)(TCSTimer *timer))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchTimersForProjects:(NSArray *)projects
                      fromDate:(NSDate *)fromDate
                        toDate:(NSDate *)toDate
                           now:(NSDate *)now
                       success:(void(^)(NSArray *timers))successBlock
                       failure:(void(^)(NSError *error))failureBlock {

}

- (void)fetchTimers:(void(^)(NSArray *groups))successBlock
            failure:(void(^)(NSError *error))failureBlock {
    
}

#pragma mark - Singleton Methods

static dispatch_once_t predicate_;
static TCSHarvestService *sharedInstance_ = nil;

+ (id)sharedInstance {

    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSHarvestService alloc];
        sharedInstance_ = [sharedInstance_ init];
    });

    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
