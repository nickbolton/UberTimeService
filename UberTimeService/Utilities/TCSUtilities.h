//
//  TCSUtilities.h
//  UberTimeService
//
//  Created by Nick Bolton on 12/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

@interface TCSUtilities : NSObject

+ (TCSUtilities *) sharedInstance;

- (BOOL)isOSVersionGreaterThanOrEqualTo:(CGFloat)version;

+ (void)executeBlockOnMainThread:(void(^)(void))block async:(BOOL)async;

+ (void)executeBlockOnBackground:(void (^)(void))block
           withCompletionOnMain:(void(^)(void))completionBlock;

+ (void)executeBlock:(void (^)(void))block
             onQueue:(dispatch_queue_t)queue
withCompletionOnMain:(void(^)(void))completionBlock;


@end
