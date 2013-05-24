//
//  TCSDefaultProvider.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSServicePrivate.h"

@interface TCSDefaultProvider : NSObject

@property (nonatomic, weak) id <TCSServiceDelegate> delegate;

@property (nonatomic, getter = isHoldingUpdates) BOOL holdingUpdates;
@property (nonatomic, getter = isPollingForUpdates) BOOL pollingForUpdates;

@end

@interface TCSDefaultProviderBase : NSObject <TCSProvidedBaseEntity>
@end

@interface TCSDefaultProviderGroup : TCSDefaultProviderBase<TCSProvidedGroup>
@end
