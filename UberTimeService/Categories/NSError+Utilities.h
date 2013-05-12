//
//  NSError+Utilities.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/11/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Utilities)

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message;

@end
