//
//  TCSJsonServiceProvider.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/21/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSDefaultProvider.h"

extern NSString * const kTCSJsonServiceProviderSystemTimeKey;
extern NSString * const kTCSJsonServiceEntriesKey;

@interface TCSJsonServiceProvider : TCSDefaultProvider

@property (nonatomic, strong) NSDateFormatter *systemTimeFormatter;

- (id)fetchRecordsWithMetadata:(NSDictionary *)metadata
                         error:(NSError **)error;

- (id)requestWithURL:(NSURL *)url
              method:(NSString *)method
             headers:(NSDictionary *)headers
         userContext:(id)userContext
        asynchronous:(BOOL)asynchronous
             success:(void(^)(id json, id userContext))successBlock
             failure:(void(^)(NSError *error, id userContext))failureBlock;

- (void)putWithURL:(NSURL *)url
           headers:(NSDictionary *)headers
          postData:(NSDictionary *)postData
       userContext:(id)userContext
           success:(void(^)(id json, id userContext))successBlock
           failure:(void(^)(NSError *error, id userContext))failureBlock;

- (void)postWithURL:(NSURL *)url
            headers:(NSDictionary *)headers
           postData:(NSDictionary *)postData
        userContext:(id)userContext
            success:(void(^)(id json, id userContext))successBlock
            failure:(void(^)(NSError *error, id userContext))failureBlock;

- (void)deleteWithURL:(NSURL *)url
              headers:(NSDictionary *)headers
             postData:(NSDictionary *)postData
          userContext:(id)userContext
              success:(void(^)(id json, id userContext))successBlock
              failure:(void(^)(NSError *error, id userContext))failureBlock;

- (void)requestWithURL:(NSURL *)url
                method:(NSString *)method
               headers:(NSDictionary *)headers
              postData:(NSDictionary *)postData
           userContext:(id)userContext
               success:(void(^)(id json, id userContext))successBlock
               failure:(void(^)(NSError *error, id userContext))failureBlock;

@end
