//
//  NSError+Utilities.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTCErrorDomain;

@interface NSError (Utilities)

typedef NS_ENUM(NSInteger, TCErrorCode) {

    TCErrorCodeUnknown = 0,
    TCErrorCodePreviousOperationNotFinished,
    TCErrorCodeRemoteObjectNotFound,

    // communication errors

    TCErrorRequestInvalidCredentials,
    TCErrorRequestMissingResource,
    TCErrorRequestServerError,
    TCErrorRequestUnknownError,
};

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

@end
