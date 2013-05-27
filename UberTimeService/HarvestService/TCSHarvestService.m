//
//  TCSHarvestService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSHarvestService.h"
#import "NSData+Base64.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"
#import "NSDate+Utilities.h"

static NSString * const kTCSHarvestBaseURL = @"";
static NSString * const kTCSHarvestProjectIDSeparator = @"|";

NSString * const kTCSHarvestLastPollingDateKey = @"harvest-last-polling-date";

@interface TCSHarvestService() {
}

@property (nonatomic, strong) NSDate *lastPollingDate;
@property (nonatomic, strong) NSMutableSet *pollingProviderInstances;

@end


@implementation TCSHarvestService

- (id)init {
    self = [super init];

    if (self != nil) {
        self.pollingProviderInstances = [NSMutableSet set];
    }

    return self;
}

- (NSString *)name {
    return NSLocalizedString(@"Harvest", nil);
}

- (NSDateFormatter *)systemTimeFormatter {

    static NSDateFormatter *dateFormatter = nil;

    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"];
    }

    return dateFormatter;
}

- (NSDateFormatter *)timerEntryFormatter {

    static NSDateFormatter *dateFormatter = nil;
    
    if (dateFormatter == nil) {
        // Tue, 17 Oct 2006
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEE, d MMM yyyy"];
    }

    return dateFormatter;
}

- (NSString *)addTimerPostFormat {

    static NSString *format = nil;
    
    if (format == nil) {
        format =
        @"{\"notes\":\"%@\",\"hours\":\"%f\",\"project_id\":\"%@\",\"task_id\":\"%@\",\"spent_at\":\"%@\"}";//,\"started_at\":\"8:00am\",\"ended_at\":\"10:55am\"}";
    }
    return format;
}

- (void)clearCache {
}

- (BOOL)importProjectsAsArchived {
    return YES;
}

- (NSString *)timerProjectIDSeparator {
    return kTCSHarvestProjectIDSeparator;
}

- (NSDictionary *)flushUpdates:(BOOL *)requestSent
                         error:(NSError **)error {
    return nil;
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

}

- (void)updateProviderInstanceUserIdIfNeeded:(TCSProviderInstance *)providerInstance
                                       force:(BOOL)force
                                     success:(void(^)(TCSProviderInstance *providerInstance))successBlock
                                     failure:(void(^)(NSError *error))failureBlock {

    if (force || providerInstance.userID == nil) {

        providerInstance.userID = nil;
        
        [self
         primAuthenticateUser:providerInstance.username
         password:providerInstance.password
         success:^(NSString *userID) {

             if (userID != nil) {
                 providerInstance.userID = userID;
                 if (successBlock != nil) {
                     successBlock(providerInstance);
                 }
             }
             
         } failure:failureBlock];
    }
}

// Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    [self
     primAuthenticateUser:username
     password:password
     success:^(NSString *userID) {

         if (successBlock) {
             successBlock();
         }
         
     } failure:failureBlock];
}


- (void)primAuthenticateUser:(NSString *)username
                    password:(NSString *)password
                     success:(void (^)(NSString *userID))successBlock
                     failure:(void (^)(NSError *))failureBlock {

    NSString *authString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers =
    @{
      @"Accept" : @"application/json",
      @"Content-Type" : @"application/json",
      @"Authorization" : [NSString stringWithFormat:@"Basic %@", auth],
    };

    NSDictionary *metadata =
    @{
      @"url" : [NSString stringWithFormat:@"%@/account/who_am_i", @"https://deucent.harvestapp.com"],
      @"method" : @"GET",
      @"headers" : headers,
    };

    [self
     requestWithURL:[NSURL URLWithString:metadata[@"url"]]
     method:metadata[@"method"]
     headers:metadata[@"headers"]
     userContext:nil
     asynchronous:YES
     success:^(NSDictionary *json, id userContext) {

         NSDictionary *user = json[@"user"];
         
         NSString *userid = [self safeRemoteID:user[@"id"]];

         if (userid != nil) {

             if (successBlock != nil) {
                 successBlock(userid);
             }
             
         } else {
             if (failureBlock != nil) {

                 NSError *error =
                 [NSError
                  errorWithCode:TCErrorRequestInvalidCredentials
                  message:TCSLoc(@"Invalid credentials.")];

                 failureBlock(error);
             }
         }

     } failure:^(NSError *error, id userContext) {

         if (failureBlock != nil) {
             failureBlock(error);
         }
     }];
}

- (void)logoutUser:(void(^)(void))successBlock
           failure:(void(^)(NSError *error))failureBlock {
    
}

- (BOOL)isUserAuthenticated:(TCSProviderInstance *)providerInstance {
    return providerInstance.userID != nil;
}

#pragma mark - Timer

//- (void)updateTimerProperties:(TCSParseTimer *)parseTimer
//                        timer:(TCSTimer *)timer {
//    parseTimer.startTime = [self safePropertyValue:timer.startTime];
//    parseTimer.endTime = [self safePropertyValue:timer.endTime];
//    parseTimer.adjustment = timer.adjustmentValue;
//    parseTimer.message = [self safePropertyValue:timer.message];
//    parseTimer.instanceID = [NSString applicationInstanceId];
//    parseTimer.entityVersion = timer.entityVersionValue;
//
//    NSAssert(timer.project.remoteId != nil, @"No remoteId for timer project");
//    parseTimer.projectID = timer.project.remoteId;
//}

- (BOOL)createTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if ([NSStringFromClass([self class]) isEqualToString:timer.providerInstance.remoteProvider] == NO) {
        NSLog(@"%s WARN : wrong provider to harvest: %@", timer.providerInstance.remoteProvider);
        return NO;
    }

    if (timer.providerInstance.userID == nil) {
        NSLog(@"%s WARN : provider to harvest: %@", timer.providerInstance.remoteProvider);

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTCSServiceRemoteProviderInstanceNotAuthenticatedNotification
         object:self
         userInfo:@{
         kTCSServiceRemoteProviderInstanceKey : timer.providerInstance,
         }];
        return NO;
    }

    NSString *authString = [NSString stringWithFormat:@"%@:%@",
                            timer.providerInstance.username,
                            timer.providerInstance.password];
    
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"application/json", @"Accept",
                             @"application/json", @"Content-Type",
                             [NSString stringWithFormat:@"Basic %@", auth], @"Authorization",
                             nil];

    NSDateFormatter *dateFormatter = [self timerEntryFormatter];

    NSString *postData = [NSString stringWithFormat:[self addTimerPostFormat],
                          timer.message != nil ? timer.message : @"",
                          MAX(0.01666666666667f, [timer elapsedTimeInHours]),
                          timer.project.parent.remoteId,
                          timer.project.remoteId,
                          [dateFormatter stringFromDate:timer.metadata.startTime]];

    NSURL *url =
    [NSURL URLWithString:[NSString stringWithFormat:@"%@/daily/add", timer.providerInstance.baseURL]];

    [self
     postWithURL:url
     headers:headers
     postData:postData
     userContext:nil
     success:^(NSDictionary *json, id userContext) {

         if ([json isKindOfClass:[NSDictionary class]]) {

             NSString *remoteId = [self safeRemoteID:json[@"id"]];

             if (remoteId != nil) {

                 if (successBlock != nil) {
                     successBlock(timer.objectID, remoteId);
                 }
                 
             } else {

                 if (failureBlock != nil) {
                     NSError *error =
                     [NSError
                      errorWithCode:TCErrorRequestServerError
                      message:TCSLoc(@"Invalid create timer reply. No remote ID.")];

                     failureBlock(error);
                 }
             }
         } else {

             if (failureBlock != nil) {
                 NSError *error =
                 [NSError
                  errorWithCode:TCErrorRequestServerError
                  message:TCSLoc(@"Invalid create timer reply. Not a dictionary.")];

                 failureBlock(error);
             }
         }
         
     } failure:^(NSError *error, id userContext) {

         if (failureBlock != nil) {
             failureBlock(error);
         }
     }];

    return YES;
}

- (BOOL)updateTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if ([NSStringFromClass([self class]) isEqualToString:timer.providerInstance.remoteProvider] == NO) {
        NSLog(@"%s WARN : wrong provider to harvest: %@", timer.providerInstance.remoteProvider);
        return NO;
    }

    if (timer.providerInstance.userID == nil) {
        NSLog(@"%s WARN : provider to harvest: %@", timer.providerInstance.remoteProvider);

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTCSServiceRemoteProviderInstanceNotAuthenticatedNotification
         object:self
         userInfo:@{
         kTCSServiceRemoteProviderInstanceKey : timer.providerInstance,
         }];
        return NO;
    }

    if (timer.remoteId == nil) {
        NSLog(@"%s WARN : no timer remoteID: %@", timer);
        return NO;
    }

    NSString *authString = [NSString stringWithFormat:@"%@:%@",
                            timer.providerInstance.username,
                            timer.providerInstance.password];

    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"application/json", @"Accept",
                             @"application/json", @"Content-Type",
                             [NSString stringWithFormat:@"Basic %@", auth], @"Authorization",
                             nil];

    NSDateFormatter *dateFormatter = [self timerEntryFormatter];

    NSString *postData = [NSString stringWithFormat:[self addTimerPostFormat],
                          timer.message != nil ? timer.message : @"",
                          MAX(0.01666666666667f, [timer elapsedTimeInHours]),
                          timer.project.parent.remoteId,
                          timer.project.remoteId,
                          [dateFormatter stringFromDate:timer.metadata.startTime]];

    NSURL *url =
    [NSURL
     URLWithString:
     [NSString stringWithFormat:@"%@/daily/update/%@",
      timer.providerInstance.baseURL, timer.remoteId]];

    [self
     postWithURL:url
     headers:headers
     postData:postData
     userContext:nil
     success:^(NSDictionary *json, id userContext) {

         if ([json isKindOfClass:[NSDictionary class]]) {

             NSString *remoteId = [self safeRemoteID:json[@"id"]];

             if (remoteId != nil) {

                 if (successBlock != nil) {
                     successBlock(timer.objectID);
                 }

             } else {

                 if (failureBlock != nil) {
                     NSError *error =
                     [NSError
                      errorWithCode:TCErrorRequestServerError
                      message:TCSLoc(@"Invalid create timer reply. No remote ID.")];

                     failureBlock(error);
                 }
             }
         } else {

             if (failureBlock != nil) {
                 NSError *error =
                 [NSError
                  errorWithCode:TCErrorRequestServerError
                  message:TCSLoc(@"Invalid create timer reply. Not a dictionary.")];

                 failureBlock(error);
             }
         }

     } failure:^(NSError *error, id userContext) {
         
         if (failureBlock != nil) {
             failureBlock(error);
         }
     }];
    
    return YES;
}

- (BOOL)deleteTimer:(TCSTimer *)timer
            success:(void(^)(NSManagedObjectID *objectID))successBlock
            failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if ([NSStringFromClass([self class]) isEqualToString:timer.providerInstance.remoteProvider] == NO) {
        NSLog(@"%s WARN : wrong provider to harvest: %@", timer.providerInstance.remoteProvider);
        return NO;
    }

    if (timer.providerInstance.userID == nil) {
        NSLog(@"%s WARN : provider to harvest: %@", timer.providerInstance.remoteProvider);

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTCSServiceRemoteProviderInstanceNotAuthenticatedNotification
         object:self
         userInfo:@{
         kTCSServiceRemoteProviderInstanceKey : timer.providerInstance,
         }];
        return NO;
    }

    if (timer.remoteId == nil) {
        NSLog(@"%s WARN : no timer remoteID: %@", timer);
        return NO;
    }

    NSString *authString = [NSString stringWithFormat:@"%@:%@",
                            timer.providerInstance.username,
                            timer.providerInstance.password];

    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"application/json", @"Accept",
                             @"application/json", @"Content-Type",
                             [NSString stringWithFormat:@"Basic %@", auth], @"Authorization",
                             nil];

    NSURL *url =
    [NSURL
     URLWithString:
     [NSString stringWithFormat:@"%@/daily/delete/%@",
      timer.providerInstance.baseURL, timer.remoteId]];

    [self
     deleteWithURL:url
     headers:headers
     postData:nil
     userContext:nil
     success:^(NSDictionary *json, id userContext) {

         if (successBlock != nil) {
             successBlock(timer.objectID);
         }
         
     } failure:^(NSError *error, id userContext) {
         
         if (failureBlock != nil) {
             failureBlock(error);
         }
     }];
    
    return YES;
}

#pragma mark - Update Polling

- (void)pollForUpdates:(TCSProviderInstance *)providerInstance
               success:(void(^)(void))successBlock
               failure:(void(^)(NSError *error))failureBlock {

    if ([_pollingProviderInstances containsObject:providerInstance]) {
        return;
    }

    [_pollingProviderInstances addObject:providerInstance];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);

        __block NSArray *groupsAndProjects = nil;
        __block NSArray *timers = nil;

        if (providerInstance.userID != nil) {
            dispatch_group_async(group, queue, ^{
                groupsAndProjects = [self fetchUpdatedProjectObjects:providerInstance];
            });

            dispatch_group_async(group, queue, ^{
                timers = [self fetchUpdatedTimerObjects:providerInstance];
            });
        }

        dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

        NSMutableArray *updatedEntities = [NSMutableArray array];

        if (groupsAndProjects.count > 0) {
            [updatedEntities addObjectsFromArray:groupsAndProjects];
        }

        if (timers.count > 0) {
            [updatedEntities addObjectsFromArray:timers];
        }

        if (updatedEntities.count > 0) {

            BOOL updatePollingDate =
            [self.pollingDelegate
             remoteProvider:self
             updatePollingEntities:updatedEntities
             providerName:NSStringFromClass([self class])];

            if (updatePollingDate) {
                for (TCSDefaultProviderBase *entity in updatedEntities) {
                    if (_lastPollingDate == nil || [entity.utsUpdateTime isGreaterThan:_lastPollingDate]) {
                        self.lastPollingDate =
                        entity.utsUpdateTime;
                    }
                }

                if (_lastPollingDate != nil) {
                    [[NSUserDefaults standardUserDefaults]
                     setObject:_lastPollingDate forKey:kTCSHarvestLastPollingDateKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }

        [_pollingProviderInstances removeObject:providerInstance];

        if (successBlock != nil) {
            successBlock();
        }
    });
}

- (NSArray *)fetchUpdatedProjectObjects:(TCSProviderInstance *)providerInstance {

    NSString *authString =
    [NSString
     stringWithFormat:@"%@:%@",
     providerInstance.username, providerInstance.password];
    
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers =
    @{
      @"Accept" : @"application/json",
      @"Content-Type" : @"application/json",
      @"Authorization" : [NSString stringWithFormat:@"Basic %@", auth],
      };

    NSDictionary *metadata =
    @{
      @"url" : [NSString stringWithFormat:@"%@/daily", providerInstance.baseURL],
      @"method" : @"GET",
      @"headers" : headers,
      };

    NSError *error = nil;

    NSDictionary *json =
    [self fetchRecordsWithMetadata:metadata error:&error];

    if (error != nil) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }

    NSLog(@"JSON: %@", json);

    NSMutableArray *normalizedGroups = [NSMutableArray array];
    NSMutableArray *normalizedProjects = [NSMutableArray array];

    NSArray *groups = json[@"projects"];
    NSArray *projects;
    NSDate *updateTime = json[kTCSJsonServiceProviderSystemTimeKey];

    for (NSDictionary *groupDict in groups) {

        TCSDefaultProviderGroup *group = [[TCSDefaultProviderGroup alloc] init];
        group.utsRemoteID = groupDict[@"id"];
        group.utsName = groupDict[@"name"];
        group.utsUpdateTime = updateTime;
        group.utsProviderInstanceID = providerInstance.objectID;

        [normalizedGroups addObject:group];

        projects = groupDict[@"tasks"];

        for (NSDictionary *projectDict in projects) {

            TCSDefaultProviderProject *project =
            [[TCSDefaultProviderProject alloc] init];

            project.utsRemoteID = projectDict[@"id"];
            project.utsName = projectDict[@"name"];
            project.utsParentID = group.utsRemoteID;
            project.utsProviderInstanceID = providerInstance.objectID;
            project.utsUpdateTime = updateTime;

            [normalizedProjects addObject:project];
        }
    }

    [normalizedGroups addObjectsFromArray:normalizedProjects];

    return normalizedGroups;
}

- (NSArray *)fetchUpdatedTimerObjects:(TCSProviderInstance *)providerInstance {

    NSString *authString =
    [NSString
     stringWithFormat:@"%@:%@",
     providerInstance.username, providerInstance.password];

    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers =
    @{
      @"Accept" : @"application/json",
      @"Content-Type" : @"application/json",
      @"Authorization" : [NSString stringWithFormat:@"Basic %@", auth],
      };

    NSDictionary *metadata =
    @{
      @"url" : [NSString stringWithFormat:@"%@/people/%@/entries?from=00000101&to=99991231",
                providerInstance.baseURL, providerInstance.userID],
      @"method" : @"GET",
      @"headers" : headers,
      };

    NSError *error = nil;

    NSDictionary *json =
    [self fetchRecordsWithMetadata:metadata error:&error];

    if (error != nil) {
        NSLog(@"%s Error: %@", __PRETTY_FUNCTION__, error);
    }

    NSLog(@"timer JSON: %@", json);

    NSMutableArray *normalizedTimers = [NSMutableArray array];

    NSArray *timers = json[kTCSJsonServiceEntriesKey];
    NSArray *projects;
    NSDate *updateTime = json[kTCSJsonServiceProviderSystemTimeKey];

    NSDateFormatter *timestampFormatter = [[NSDateFormatter alloc] init];
    timestampFormatter.dateFormat = @"yyyy-MM-dd HH:mmaa";

    for (NSDictionary *dayEntry in timers) {

        NSDictionary *timerDict = dayEntry[@"day_entry"];

        if (timerDict != nil) {

            TCSDefaultProviderTimer *timer = [[TCSDefaultProviderTimer alloc] init];
            timer.utsRemoteID = timerDict[@"id"];
            
            NSString *hoursString = timerDict[@"hours"];
            NSTimeInterval duration = [hoursString floatValue] * 3600.0f;
            
            NSString *spentAt = timerDict[@"spent_at"];
            NSString *startedAt = timerDict[@"started_at"];
            NSString *timerStartedAt = timerDict[@"timer_started_at"];
            NSString *startDateString = nil;

            if (timerStartedAt != nil && timerStartedAt != [NSNull null]) {
                startDateString = timerStartedAt;
            } else {

                if (startedAt == nil || startedAt == [NSNull null]) {
                    startedAt = @"12:00am";
                }

                startDateString =
                [NSString stringWithFormat:@"%@ %@", spentAt, startedAt];
            }

            timer.utsStartTime =
            [timestampFormatter dateFromString:startDateString];
            timer.utsEndTime = [timer.utsStartTime dateByAddingTimeInterval:duration];
            timer.utsMessage = timerDict[@"notes"];
            timer.utsProviderInstanceID = providerInstance.objectID;

            timer.utsProjectID =
            [NSString stringWithFormat:@"%@%@%@",
             timerDict[@"project_id"],
             kTCSHarvestProjectIDSeparator,
             timerDict[@"task_id"]];

            timer.utsUpdateTime = updateTime;

            [normalizedTimers addObject:timer];
        }
    }
    
    return normalizedTimers;
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
