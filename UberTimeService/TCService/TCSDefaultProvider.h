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
@property (nonatomic, weak) id <TCSPollingDelegate> pollingDelegate;

@property (nonatomic, getter = isHoldingUpdates) BOOL holdingUpdates;
@property (nonatomic, getter = isPollingForUpdates) BOOL pollingForUpdates;

- (NSString *)safeRemoteID:(id)remoteID;

@end

@interface TCSDefaultProviderBase : NSObject <TCSProvidedBaseEntity>
@property (nonatomic, strong) NSString *utsRemoteID;
@property (nonatomic) NSInteger utsEntityVersion;
@property (nonatomic) Class utsLocalEntityType;
@property (nonatomic, strong) NSDate *utsUpdateTime;
@property (nonatomic, strong) NSManagedObjectID *utsProviderInstanceID;
@end

@interface TCSDefaultProviderBaseMetadata : TCSDefaultProviderBase <TCSProvidedBaseMetadataEntity>
@property (nonatomic, strong) NSString *utsRelatedRemoteID;
@end

@interface TCSDefaultProviderTimedEntity : TCSDefaultProviderBase <TCSProvidedTimedEntity>
@property (nonatomic, strong) NSString *utsName;
@property (nonatomic, strong) NSString *utsParentID;
@end

@interface TCSDefaultProviderGroup : TCSDefaultProviderTimedEntity<TCSProvidedGroup>
@end

@interface TCSDefaultProviderProject : TCSDefaultProviderTimedEntity<TCSProvidedProject>
@end

@interface TCSDefaultProviderTimer : TCSDefaultProviderBase <TCSProvidedTimer>
@property (nonatomic, strong) NSString *utsMessage;
@property (nonatomic, strong) NSDate *utsStartTime;
@property (nonatomic, strong) NSDate *utsEndTime;
@property (nonatomic, strong) NSString *utsProjectID;
@end

@interface TCSDefaultProviderTimedEntityMetadata : TCSDefaultProviderBaseMetadata <TCSProvidedTimedEntityMetadata>
@property (nonatomic) NSInteger utsFilteredModifiers;
@property (nonatomic) NSInteger utsKeyCode;
@property (nonatomic) NSInteger utsModifiers;
@property (nonatomic) NSInteger utsOrder;
@property (nonatomic) BOOL utsArchived;
@property (nonatomic) NSInteger utsColor;
@end

@interface TCSDefaultProviderTimerMetadata : TCSDefaultProviderBaseMetadata <TCSProvidedTimerMetadata>
@property (nonatomic) NSTimeInterval utsAdjustment;
@property (nonatomic, strong) NSDate *utsStartTime;
@property (nonatomic, strong) NSDate *utsEndTime;
@end


