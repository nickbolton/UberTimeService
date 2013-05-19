// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSBaseEntityAttributes {
	__unsafe_unretained NSString *entityVersion;
	__unsafe_unretained NSString *pending;
	__unsafe_unretained NSString *pendingRemoteDelete;
	__unsafe_unretained NSString *remoteId;
	__unsafe_unretained NSString *remoteProvider;
	__unsafe_unretained NSString *updateTime;
} TCSBaseEntityAttributes;

extern const struct TCSBaseEntityRelationships {
} TCSBaseEntityRelationships;

extern const struct TCSBaseEntityFetchedProperties {
} TCSBaseEntityFetchedProperties;









@interface TCSBaseEntityID : NSManagedObjectID {}
@end

@interface _TCSBaseEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSBaseEntityID*)objectID;




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




@property (nonatomic, strong) NSString* remoteProvider;


//- (BOOL)validateRemoteProvider:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* updateTime;


//- (BOOL)validateUpdateTime:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSBaseEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSBaseEntity (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveRemoteProvider;
- (void)setPrimitiveRemoteProvider:(NSString*)value;




- (NSDate*)primitiveUpdateTime;
- (void)setPrimitiveUpdateTime:(NSDate*)value;




@end
