//
//  TCSJsonServiceProvider.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/21/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSJsonServiceProvider.h"
#import "NSError+Utilities.h"
#import "AFJSONRequestOperation.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

NSString * const kTCSJsonServiceProviderSystemTimeKey = @"tcs-json-system-time";
NSString * const kTCSJsonServiceEntriesKey = @"tcs-json-entries";

@implementation TCSJsonServiceProvider

- (NSDateFormatter *)systemTimeFormatter {
    return nil;
}

- (NSDictionary *)fetchRecordsWithMetadata:(NSDictionary *)metadata
                                     error:(NSError **)error {

    __block NSError *localError = nil;

    NSDictionary *result =
    [self
     requestWithURL:[NSURL URLWithString:metadata[@"url"]]
     method:metadata[@"method"]
     headers:metadata[@"headers"]
     userContext:nil
     asynchronous:NO
     success:nil
     failure:^(NSError *error, id userContext) {
         localError = error;
     }];

    if (*error != nil) {
        *error = localError;
    }
    
    return result;
}

- (NSDictionary *)appendSystemTime:(NSDictionary *)json
                          response:(NSHTTPURLResponse *)response {

    NSDateFormatter *systemTimeFormatter = self.systemTimeFormatter;

    if (systemTimeFormatter != nil) {
        NSString *dateValue = response.allHeaderFields[@"Date"];

        NSDate *systemTime =
        [systemTimeFormatter dateFromString:dateValue];

        if (systemTime != nil) {

            NSMutableDictionary *mutableJson;

            if ([json isKindOfClass:[NSDictionary class]]) {

                mutableJson = [json mutableCopy];

            } else if ([json isKindOfClass:[NSArray class]]) {

                mutableJson = [NSMutableDictionary dictionary];
                mutableJson[kTCSJsonServiceEntriesKey] = json;
            }

            mutableJson[kTCSJsonServiceProviderSystemTimeKey] = systemTime;
            json = mutableJson;
        }
    }

    return json;
}

- (NSDictionary *)executeJSONRequestWithRequest:(NSURLRequest *)request
                                    userContext:(id)userContext
                                   asynchronous:(BOOL)asynchronous
                                        success:(void(^)(NSDictionary *json, id userContext))successBlock
                                        failure:(void(^)(NSError *error, id userContext))failureBlock {

    __block NSDictionary *result = nil;

    NSLog(@"hello1");
    
    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

         NSInteger statusCode = response.statusCode;

         NSLog(@"sc: %d, async: %d", statusCode, asynchronous);
         
         NSLog(@"JSONNNNN: %@", JSON);

         if (statusCode >= 200 && statusCode < 300) {

             JSON = [self appendSystemTime:JSON response:response];

             if (asynchronous) {                 
                 successBlock(JSON, userContext);
             } else {
                 result = JSON;
             }

         } else {

             if (failureBlock != nil) {

                 TCErrorCode errorCode;
                 NSString *message;

                 if (statusCode == 404) {
                     errorCode = TCErrorRequestMissingResource;
                     message = TCSLoc(@"Resource no longer exists.");
                 } else if (statusCode >= 500) {
                     errorCode = TCErrorRequestServerError;
                     message = TCSLoc(@"Server failed.");
                 } else {
                     errorCode = TCErrorRequestUnknownError;
                     message = TCSLoc(@"Unknown request error.");
                 }

                 NSError *error =
                 [NSError errorWithCode:errorCode message:message];

                 failureBlock(error, userContext);

             }
         }

     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {

         if (failureBlock != nil) {
             failureBlock(error, userContext);
         }
     }];

    [operation start];

    if (asynchronous == NO) {
        [operation waitUntilFinished];
    }

    NSLog(@"hello2");

    return result;
}

- (NSDictionary *)requestWithURL:(NSURL *)url
                          method:(NSString *)method
                         headers:(NSDictionary *)headers
                     userContext:(id)userContext
                    asynchronous:(BOOL)asynchronous
                         success:(void(^)(NSDictionary *json, id userContext))successBlock
                         failure:(void(^)(NSError *error, id userContext))failureBlock {

    if (successBlock == nil && asynchronous) {
        NSLog(@"WARN : no successBlock. aborting json request.");
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;

    for (NSString *key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }

    NSLog(@"url: %@", request.URL);
    NSLog(@"headers: %@", request.allHTTPHeaderFields);

    return
    [self
     executeJSONRequestWithRequest:request
     userContext:userContext
     asynchronous:asynchronous
     success:successBlock
     failure:failureBlock];
}

- (void)putWithURL:(NSURL *)url
           headers:(NSDictionary *)headers
          postData:(NSDictionary *)postData
       userContext:(id)userContext
           success:(void(^)(NSDictionary *json, id userContext))successBlock
           failure:(void(^)(NSError *error, id userContext))failureBlock {

    [self
     requestWithURL:url
     method:@"PUT"
     headers:headers
     postData:postData
     userContext:userContext
     success:successBlock
     failure:failureBlock];
}

- (void)postWithURL:(NSURL *)url
            headers:(NSDictionary *)headers
           postData:(NSDictionary *)postData
        userContext:(id)userContext
            success:(void(^)(NSDictionary *json, id userContext))successBlock
            failure:(void(^)(NSError *error, id userContext))failureBlock {

    [self
     requestWithURL:url
     method:@"POST"
     headers:headers
     postData:postData
     userContext:userContext
     success:successBlock
     failure:failureBlock];
}

- (void)requestWithURL:(NSURL *)url
                method:(NSString *)method
               headers:(NSDictionary *)headers
              postData:(NSDictionary *)postData
           userContext:(id)userContext
               success:(void(^)(NSDictionary *json, id userContext))successBlock
               failure:(void(^)(NSError *error, id userContext))failureBlock {

    if (successBlock == nil) {
        NSLog(@"WARN : no successBlock. aborting json request.");
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://api.flickr.com/services/rest/?method=flickr.groups.browse&api_key=b6300e17ad3c506e706cb0072175d047&cat_id=34427469792%40N01&format=rest"]];
    request.HTTPMethod = method;

    for (NSString *key in headers) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }

    NSString *postDataString = [postData description];
    NSData *requestData =
    [NSData
     dataWithBytes:postDataString.UTF8String
     length:postDataString.length];

    request.HTTPBody = requestData;

    NSLog(@"url: %@", request.URL);
    NSLog(@"headers: %@", request.allHTTPHeaderFields);
    NSLog(@"postBody: %@", postDataString);

    [self
     executeJSONRequestWithRequest:request
     userContext:userContext
     asynchronous:YES
     success:successBlock
     failure:failureBlock];    
}

@end
