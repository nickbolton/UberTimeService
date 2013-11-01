//
//  TCSiCloudService.m
//  Pods
//
//  Created by Nick Bolton on 10/31/13.
//
//

#import "TCSiCloudService.h"
#import "UbiquityStoreManager.h"
#import "CoreData+MagicalRecord.h"

NSString * const kTCSiCloudServiceLocalStoreDeadNotification = @"kTCSiCloundServiceLocalStoreDeadNotification";
NSString * const kTCSiCloudServiceLocalStoreLoadedNotification = @"kTCSiCloudServiceLocalStoreLoadedNotification";
NSString * const kTCSiCloudServiceCloudStoreKey = @"cloud-store";
NSString * const kTCSiCloudServiceUbiquityStoreErrorCauseKey = @"cause";

static NSString * TCSiCloudService_storeName = nil;
static NSString * TCSiCloudService_containerIdentifier = nil;

@interface TCSiCloudService() <UbiquityStoreManagerDelegate> {

    BOOL _mocInitialized;
}

@property (nonatomic, strong) UbiquityStoreManager *ubiquityStoreManager;

@end

@implementation TCSiCloudService

+ (void)setStoreName:(NSString *)storeName {

}

+ (void)setContainerIdentifier:(NSString *)containerIdentifier {

}

- (void)setupCoreDataStack {

    self.ubiquityStoreManager =
    [[UbiquityStoreManager alloc]
     initStoreNamed:TCSiCloudService_storeName
     withManagedObjectModel:nil
     localStoreURL:nil
     containerIdentifier:TCSiCloudService_containerIdentifier
     additionalStoreOptions:nil
     delegate:self];

    self.enabled = YES;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    self.ubiquityStoreManager.cloudEnabled = enabled;
}

- (void)fixCloudContent {
    [self.ubiquityStoreManager rebuildCloudContentFromCloudStoreOrLocalStore:YES];
}

- (void)fixLocalContent {
    [self.ubiquityStoreManager deleteLocalStore];
}

#pragma mark - UbiquityStoreManagerDelegate Conformance

- (NSManagedObjectContext *)managedObjectContextForUbiquityChangesInManager:(UbiquityStoreManager *)manager {
    return [NSManagedObjectContext MR_contextForCurrentThread];
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager willLoadStoreIsCloud:(BOOL)isCloudStore {

    if (_mocInitialized) {
        [[NSManagedObjectContext MR_contextForCurrentThread]
         MR_saveToPersistentStoreAndWait];
    }
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager didLoadStoreForCoordinator:(NSPersistentStoreCoordinator *)coordinator
                     isCloud:(BOOL)isCloudStore {


    [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:coordinator];
    [NSManagedObjectContext MR_initializeDefaultContextWithCoordinator:coordinator];

    NSManagedObjectContext *moc = [NSManagedObjectContext MR_defaultContext];
    moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;

    _mocInitialized = YES;

    dispatch_async( dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTCSiCloudServiceLocalStoreLoadedNotification
         object:self
         userInfo:nil];
    } );
}

- (void)ubiquityStoreManager:(UbiquityStoreManager *)manager failedLoadingStoreWithCause:(UbiquityStoreErrorCause)cause context:(id)context
                    wasCloud:(BOOL)wasCloudStore {

    dispatch_async( dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter]
         postNotificationName:kTCSiCloudServiceLocalStoreDeadNotification
         object:self
         userInfo:
         @{
           kTCSiCloudServiceCloudStoreKey : @(wasCloudStore),
           kTCSiCloudServiceUbiquityStoreErrorCauseKey : @(cause),
           }];
    } );
}

- (BOOL)ubiquityStoreManager:(UbiquityStoreManager *)manager handleCloudContentCorruptionWithHealthyStore:(BOOL)storeHealthy {

    if ([self.delegate respondsToSelector:@selector(iCloudService:handleCloudContentCorruptionWithHealthyStore:)]) {
        return
        [self.delegate
         iCloudService:self
         handleCloudContentCorruptionWithHealthyStore:storeHealthy];
    }

    return NO;
}

+ (id)sharedInstance {

    static dispatch_once_t predicate;
    static TCSiCloudService *sharedInstance = nil;

    dispatch_once(&predicate, ^{
        sharedInstance = [TCSiCloudService alloc];
        sharedInstance = [sharedInstance init];
    });

    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
