//
//  TCSLocalService.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/2/13.
//  Copyright 2013 Pixelbleed. All rights reserved.
//
#import "TCSDefaultProvider.h"
#import "TCSService.h"
#import "TCSServicePrivate.h"

@interface TCSLocalService : TCSDefaultProvider <TCSServiceProvider, TCSServiceProviderPrivate>

- (void)resetCoreDataStack;

@end
