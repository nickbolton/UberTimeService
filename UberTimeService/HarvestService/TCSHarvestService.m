//
//  TCSHarvestService.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSHarvestService.h"
#import "NSData+Base64.h"

static NSString * const kTCSHarvestBaseURL = @"";

@interface TCSHarvestService() {

    BOOL _pollingForUpdates;
}

@end


@implementation TCSHarvestService

- (NSString *)name {
    return NSLocalizedString(@"Harvest", nil);
}

- (void)clearCache {
}

- (NSDictionary *)flushUpdates:(BOOL *)requestSent
                         error:(NSError **)error {
    return nil;
}

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(NSError *error))failureBlock {

}

// Authentication

- (void)authenticateUser:(NSString *)username
                password:(NSString *)password
                 success:(void(^)(void))successBlock
                 failure:(void(^)(NSError *error))failureBlock {

    NSString *authString = [NSString stringWithFormat:@"%@:%@", username, password];
    NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *auth = [authData base64EncodedString];

    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"application/json", @"Accept",
                             @"application/json", @"Content-Type",
                             [NSString stringWithFormat:@"Basic %@", auth], @"Authorization",
                             nil];

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
     success:^(NSDictionary *json, id userContext) {

         NSDictionary *user = json[@"user"];
         
         id userid = user[@"id"];

         if (userid != nil) {
             if (successBlock != nil) {
                 successBlock();
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

- (BOOL)isUserAuthenticated {
    return NO;
}

#pragma mark - Update Polling

- (BOOL)pollForUpdates:(NSArray *)providerInstances {

    if (_pollingForUpdates) return NO;

//    if ([PFUser currentUser] != nil) {
//
//        _pollingForUpdates = YES;
//
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//
//            dispatch_group_t group = dispatch_group_create();
//            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
//
//            __block NSArray *remoteCommands = nil;
//            __block NSArray *groups = nil;
//            __block NSArray *projects = nil;
//            __block NSArray *timers = nil;
//            __block NSArray *cannedMessages = nil;
//            __block BOOL sentSyncStarting = NO;
//
//            dispatch_group_async(group, queue, ^{
//                remoteCommands = [self fetchUpdatedRemoteCommandObjects];
//                if (sentSyncStarting == NO && remoteCommands.count > 0) {
//                    sentSyncStarting = YES;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate remoteSyncStarting];
//                    });
//                }
//            });
//
//            dispatch_group_async(group, queue, ^{
//                groups = [self fetchUpdatedGroupObjects];
//                if (sentSyncStarting == NO && groups.count > 0) {
//                    sentSyncStarting = YES;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate remoteSyncStarting];
//                    });
//                }
//            });
//
//            dispatch_group_async(group, queue, ^{
//                projects = [self fetchUpdatedProjectObjects];
//                if (sentSyncStarting == NO && projects.count > 0) {
//                    sentSyncStarting = YES;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate remoteSyncStarting];
//                    });
//                }
//            });
//
//            dispatch_group_async(group, queue, ^{
//                timers = [self fetchUpdatedTimerObjects];
//                if (sentSyncStarting == NO && timers.count > 0) {
//                    sentSyncStarting = YES;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate remoteSyncStarting];
//                    });
//                }
//            });
//
//            dispatch_group_async(group, queue, ^{
//                cannedMessages = [self fetchUpdatedCannedMessageObjects];
//                if (sentSyncStarting == NO && cannedMessages.count > 0) {
//                    sentSyncStarting = YES;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.delegate remoteSyncStarting];
//                    });
//                }
//            });
//
//            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
//
//            NSMutableArray *updatedEntities = [NSMutableArray array];
//
//            if (remoteCommands.count > 0) {
//                [updatedEntities addObjectsFromArray:remoteCommands];
//            }
//
//            if (groups.count > 0) {
//                [updatedEntities addObjectsFromArray:groups];
//            }
//
//            if (projects.count > 0) {
//                [updatedEntities addObjectsFromArray:projects];
//            }
//
//            if (timers.count > 0) {
//                [updatedEntities addObjectsFromArray:timers];
//            }
//
//            if (cannedMessages.count > 0) {
//                [updatedEntities addObjectsFromArray:cannedMessages];
//            }
//
//            if (updatedEntities.count > 0) {
//
//                for (TCSParseBaseEntity *entity in updatedEntities) {
//                    if (_lastPollingDate == nil || [entity.utsUpdateTime isGreaterThan:_lastPollingDate]) {
//                        NSLog(@"updating lastPollingDate to: %@", entity.utsUpdateTime);
//                        self.lastPollingDate =
//                        entity.utsUpdateTime;
//                    }
//                }
//
//                if (_lastPollingDate != nil) {
//                    [[NSUserDefaults standardUserDefaults]
//                     setObject:_lastPollingDate forKey:kTCSParseLastPollingDateKey];
//                    [[NSUserDefaults standardUserDefaults] synchronize];
//                }
//            }
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter]
//                 postNotificationName:kTCSLocalServiceUpdatedRemoteEntitiesNotification
//                 object:self
//                 userInfo:@{
//                 kTCSLocalServiceUpdatedRemoteEntitiesKey : updatedEntities,
//                 kTCSLocalServiceRemoteProviderNameKey : NSStringFromClass([self class]),
//                 }];
//            });
//            
//            _pollingForUpdates = NO;
//        });
//    }

    if (_pollingForUpdates) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    
    return _pollingForUpdates;
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
