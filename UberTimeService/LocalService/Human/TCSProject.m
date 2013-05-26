#import "TCSProject.h"
#import "TCSService.h"
#import "TCSTimerMetadata.h"
#import "TCSTimer.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSProject

+ (void)createRemoteObject:(TCSProject *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (remoteProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSProject class]],
                 @"Not a TCSProject object");

        if (localEntity.parent == nil || localEntity.parent.remoteId != nil) {

            [remoteProvider
             createProject:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {

                NSError *error =
                [NSError
                 errorWithCode:TCErrorCodePreviousOperationNotFinished
                 message:TCSLoc(@"timer.project.remoteId has yet to be retrieved")];

                failureBlock(error);
            }
        }

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSProject *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        NSAssert([localEntity isKindOfClass:[TCSProject class]],
                 @"Not a TCSProject object");

        if (localEntity.parent == nil || localEntity.parent.remoteId != nil) {

            [remoteProvider
             updateProject:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {

                NSError *error =
                [NSError
                 errorWithCode:TCErrorCodePreviousOperationNotFinished
                 message:TCSLoc(@"timer.project.remoteId has yet to be retrieved")];

                failureBlock(error);
            }
        }

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)deleteRemoteObject:(TCSProject *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSProject class]],
             @"Not a TCSProject object");

    if (successBlock != nil) {

        [remoteProvider
         deleteProject:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

- (BOOL)isActive {
    TCSProject *activeProject =
    [TCSService sharedInstance].activeTimer.project;
    return [self.objectID isEqual:activeProject.objectID];
}

- (NSString *)displayName:(BOOL)groupFirst {

    NSString *displayName;

    if (self.parent != nil) {

        if (groupFirst) {

            displayName =
            [NSString stringWithFormat:@"%@ : %@",
             self.parent.name, self.name];

        } else {
            
            displayName =
            [NSString stringWithFormat:@"%@ : %@",
             self.name, self.parent.name];
        }

    } else {
        displayName = self.name;
    }

    return displayName;
}

- (void)markEntityAsDeleted {
    [super markEntityAsDeleted];

    for (TCSTimer *timer in self.timers) {
        [timer markEntityAsDeleted];
    }
}

- (void)markEntityAsUpdated {
    [super markEntityAsUpdated];

    for (TCSTimer *timer in self.timers) {
        [timer markEntityAsUpdated];
    }
}

@end
