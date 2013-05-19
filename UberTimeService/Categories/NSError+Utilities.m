//
//  NSError+Utilities.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "NSError+Utilities.h"

NSString * const kTCErrorDomain = @"TCSDomain";

@implementation NSError (Utilities)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message {
    return
    [NSError
     errorWithDomain:kTCErrorDomain
     code:code
     userInfo:@{NSLocalizedDescriptionKey : message}];
}

@end
