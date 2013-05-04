//
//  TCSLocalService.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//
#import "TCSDefaultProvider.h"
#import "TCSService.h"

@interface TCSLocalService : TCSDefaultProvider <TCSServiceProvider>

- (void)resetCoreDataStack;

@end
