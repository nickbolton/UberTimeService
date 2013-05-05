//
//  TCAppDelegate.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TCSService.h"
#import "TCSLocalService.h"

@implementation TCAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    TCSService *service = [TCSService sharedInstance];
    [service registerServiceProvider:[TCSLocalService class]];

    return YES;
}

@end
