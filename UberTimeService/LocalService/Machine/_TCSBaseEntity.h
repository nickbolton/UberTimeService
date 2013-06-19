// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSBaseEntityAttributes {
	__unsafe_unretained NSString *dataVersion;
	__unsafe_unretained NSString *entityVersion;
	__unsafe_unretained NSString *pending;
	__unsafe_unretained NSString *pendingRemoteDelete;
	__unsafe_unretained NSString *remoteId;
	__unsafe_unretained NSString *syncingSource;
	__unsafe_unretained NSString *updateTime;
} TCSBaseEntityAttributes;

extern const struct TCSBaseEntityRelationships {
	__unsafe_unretained NSString *providerInstance;
} TCSBaseEntityRelationships;

extern const struct TCSBaseEntityFetchedProperties {
} TCSBaseEntityFetchedProperties;

@class TCSProviderInstance;









@interface TCSBaseEntityID : NSManagedObjectID {}
@end

@interface _TCSBaseEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSBaseEntityID*)objectID;




@property (nonatomic, strong) NSNumber* dataVersion;


@property int64_t dataVersionValue;
- (int64_t)dataVersionValue;
- (void)setDataVersionValue:(int64_t)value_;

//- (BOOL)validateDataVersion:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* entityVersion;


@property int64_t entityVersionValue;
- (int64_t)entityVersionValue;
- (void)setEntityVersionValue:(int64_t)value_;

//- (BOOL)validateEntityVersion:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* pending;


@property BOOL pendingValue;
- (BOOL)pendingValue;
- (void)setPendingValue:(BOOL)value_;

//- (BOOL)validatePending:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* pendingRemoteDelete;


@property BOOL pendingRemoteDeleteValue;
- (BOOL)pendingRemoteDeleteValue;
- (void)setPendingRemoteDeleteValue:(BOOL)value_;

//- (BOOL)validatePendingRemoteDelete:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteId;


//- (BOOL)validateRemoteId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* syncingSource;


@property BOOL syncingSourceValue;
- (BOOL)syncingSourceValue;
- (void)setSyncingSourceValue:(BOOL)value_;

//- (BOOL)validateSyncingSource:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* updateTime;


//- (BOOL)validateUpdateTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSProviderInstance* providerInstance;

//- (BOOL)validateProviderInstance:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSBaseEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDataVersion;
- (void)setPrimitiveDataVersion:(NSNumber*)value;

- (int64_t)primitiveDataVersionValue;
- (void)setPrimitiveDataVersionValue:(int64_t)value_;




- (NSNumber*)primitiveEntityVersion;
- (void)setPrimitiveEntityVersion:(NSNumber*)value;

- (int64_t)primitiveEntityVersionValue;
- (void)setPrimitiveEntityVersionValue:(int64_t)value_;




- (NSNumber*)primitivePending;
- (void)setPrimitivePending:(NSNumber*)value;

- (BOOL)primitivePendingValue;
- (void)setPrimitivePendingValue:(BOOL)value_;




- (NSNumber*)primitivePendingRemoteDelete;
- (void)setPrimitivePendingRemoteDelete:(NSNumber*)value;

- (BOOL)primitivePendingRemoteDeleteValue;
- (void)setPrimitivePendingRemoteDeleteValue:(BOOL)value_;




- (NSString*)primitiveRemoteId;
- (void)setPrimitiveRemoteId:(NSString*)value;




- (NSNumber*)primitiveSyncingSource;
- (void)setPrimitiveSyncingSource:(NSNumber*)value;

- (BOOL)primitiveSyncingSourceValue;
- (void)setPrimitiveSyncingSourceValue:(BOOL)value_;




- (NSDate*)primitiveUpdateTime;
- (void)setPrimitiveUpdateTime:(NSDate*)value;





- (TCSProviderInstance*)primitiveProviderInstance;
- (void)setPrimitiveProviderInstance:(TCSProviderInstance*)value;


@end
