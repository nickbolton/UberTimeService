//
//  TCSCommon.h
//  UberTimeService
//
//  Created by Nick Bolton on 4/3/11.
//  Copyright 2011 Pixelbleed LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSConstants.h"

typedef enum _TCPreferencesMaxTimerSession {

    TCSPreferencesMaxTimerSession_None = 0,
    TCSPreferencesMaxTimerSession_1_Hour,
    TCSPreferencesMaxTimerSession_2_Hour,
    TCSPreferencesMaxTimerSession_3_Hour,
    TCSPreferencesMaxTimerSession_4_Hour,
    TCSPreferencesMaxTimerSession_5_Hour,
    TCSPreferencesMaxTimerSession_6_Hour,
    TCSPreferencesMaxTimerSession_7_Hour,
    TCSPreferencesMaxTimerSession_8_Hour,
    TCSPreferencesMaxTimerSession_24_Hour,

} TCSPreferencesMaxTimerSession;

@interface TCSDummyClass : NSObject {} @end

#define TCSLoc(key) TCSLocalizedString(key, nil)
#define TCSLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, @"timecop", [NSBundle bundleForClass: [TCSDummyClass class]], comment)

#define TCSError(...) NSLog(@"[%@:%d (%p)]: %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, self, [NSString stringWithFormat:__VA_ARGS__])


#if defined(DEBUG)
#define TCSLog(...) NSLog(@"%s (%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define TCSLog(...) ((void)0)
#endif

#define TCSTraceLogOn(...) NSLog(@"%s (%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#define TCSTraceLogOff(...) ((void)0)

@interface TCSCommon : NSObject {
@private
    
}

@end
