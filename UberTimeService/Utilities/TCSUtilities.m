//
//  TCSUtilities.m
//  UberTimeService
//
//  Created by Nick Bolton on 12/21/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import "TCSUtilities.h"
#import <math.h>

@implementation TCSUtilities

static dispatch_once_t predicate_;
static TCSUtilities *sharedInstance_ = nil;

#pragma mark - Singleton Methods

#if TARGET_OS_IPHONE

- (BOOL)isOSVersionGreaterThanOrEqualTo:(CGFloat)versionNumber {
    return ([[[UIDevice currentDevice] systemVersion] compare:[[NSNumber numberWithFloat:versionNumber] stringValue] options:NSNumericSearch] != NSOrderedAscending);
}

#else

- (BOOL)isOSVersionGreaterThanOrEqualTo:(CGFloat)versionNumber {    
    return NSAppKitVersionNumber >= versionNumber;
}

#endif

+ (void)executeBlockOnMainThread:(void (^)(void))block async:(BOOL)async {

    if ([NSThread isMainThread]) {
        block();
    } else if (async) {
        dispatch_async(dispatch_get_main_queue(), block);
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)executeBlockOnBackground:(void (^)(void))block
           withCompletionOnMain:(void(^)(void))completionBlock {

    void (^executionBlock)(void) = ^{

        if (block) {
            block();
        }

        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        }
    };

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                   executionBlock);
}

+ (void)executeBlock:(void (^)(void))block
             onQueue:(dispatch_queue_t)queue
withCompletionOnMain:(void(^)(void))completionBlock {

    void (^executionBlock)(void) = ^{

        if (block) {
            block();
        }

        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        }
    };

    if (queue == dispatch_get_current_queue()) {
        executionBlock();
    } else {
        dispatch_async(queue, executionBlock);
    }
}

+ (id)sharedInstance {
    
    dispatch_once(&predicate_, ^{
        sharedInstance_ = [TCSUtilities alloc];
        sharedInstance_ = [sharedInstance_ init];
    });
    
    return sharedInstance_;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
