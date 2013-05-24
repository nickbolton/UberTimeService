#import "TCSGroup.h"
#import "TCSProject.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSGroup

+ (void)createRemoteObject:(TCSGroup *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (remoteProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSGroup class]],
                 @"Not a TCSGroup object");

        if (localEntity.parent == nil || localEntity.parent.remoteId != nil) {

            [remoteProvider
             createGroup:localEntity
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

+ (void)updateRemoteObject:(TCSGroup *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        if (remoteProvider != nil) {

            NSAssert([localEntity isKindOfClass:[TCSGroup class]],
                     @"Not a TCSGroup object");

            if (localEntity.parent == nil || localEntity.parent.remoteId != nil) {

                [remoteProvider
                 updateGroup:localEntity
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
}

+ (void)deleteRemoteObject:(TCSGroup *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSGroup class]],
             @"Not a TCSGroup object");

    if (successBlock != nil) {

        if (remoteProvider != nil) {

            [remoteProvider
             deleteGroup:localEntity
             success:successBlock
             failure:failureBlock];

        } else {
            if (failureBlock != nil) {
                failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
            }
        }
    }
}

- (BOOL)isActive {
    
    for (TCSTimedEntity *ent in self.children) {
        if ([ent isKindOfClass:[TCSProject class]]) {
            if ([(TCSProject *)ent isActive]) return YES;
        } else if ([ent isKindOfClass:[TCSGroup class]] && [(TCSGroup *)ent isActive]) {
            return YES;
        }
    }
    return NO;
}

@end
