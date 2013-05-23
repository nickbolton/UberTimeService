//
//  TCSHarvestService.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSJsonServiceProvider.h"
#import "TCSService.h"
#import "TCSServicePrivate.h"

@interface TCSHarvestService : TCSJsonServiceProvider <TCSServiceRemoteProvider>

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, weak) id <TCSServiceDelegate> delegate;

@end
