// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSBaseEntityAttributes {
	__unsafe_unretained NSString *dirty;
	__unsafe_unretained NSString *remoteId;
	__unsafe_unretained NSString *remoteProvider;
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




@property (nonatomic, strong) NSNumber* dirty;


@property BOOL dirtyValue;
- (BOOL)dirtyValue;
- (void)setDirtyValue:(BOOL)value_;

//- (BOOL)validateDirty:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteId;


//- (BOOL)validateRemoteId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteProvider;


//- (BOOL)validateRemoteProvider:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSBaseEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSBaseEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDirty;
- (void)setPrimitiveDirty:(NSNumber*)value;

- (BOOL)primitiveDirtyValue;
- (void)setPrimitiveDirtyValue:(BOOL)value_;




- (NSString*)primitiveRemoteId;
- (void)setPrimitiveRemoteId:(NSString*)value;




- (NSString*)primitiveRemoteProvider;
- (void)setPrimitiveRemoteProvider:(NSString*)value;




@end
