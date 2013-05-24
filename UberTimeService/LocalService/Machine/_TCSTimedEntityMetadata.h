// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntityMetadata.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimedEntityMetadataAttributes {
	__unsafe_unretained NSString *archived;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *filteredModifiers;
	__unsafe_unretained NSString *keyCode;
	__unsafe_unretained NSString *modifiers;
	__unsafe_unretained NSString *order;
} TCSTimedEntityMetadataAttributes;

extern const struct TCSTimedEntityMetadataRelationships {
	__unsafe_unretained NSString *timedEntities;
} TCSTimedEntityMetadataRelationships;

extern const struct TCSTimedEntityMetadataFetchedProperties {
} TCSTimedEntityMetadataFetchedProperties;

@class TCSTimedEntity;








@interface TCSTimedEntityMetadataID : NSManagedObjectID {}
@end

@interface _TCSTimedEntityMetadata : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimedEntityMetadataID*)objectID;




@property (nonatomic, strong) NSNumber* archived;


@property BOOL archivedValue;
- (BOOL)archivedValue;
- (void)setArchivedValue:(BOOL)value_;

//- (BOOL)validateArchived:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* color;


@property int32_t colorValue;
- (int32_t)colorValue;
- (void)setColorValue:(int32_t)value_;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* filteredModifiers;


@property int32_t filteredModifiersValue;
- (int32_t)filteredModifiersValue;
- (void)setFilteredModifiersValue:(int32_t)value_;

//- (BOOL)validateFilteredModifiers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* keyCode;


@property int32_t keyCodeValue;
- (int32_t)keyCodeValue;
- (void)setKeyCodeValue:(int32_t)value_;

//- (BOOL)validateKeyCode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* modifiers;


@property int32_t modifiersValue;
- (int32_t)modifiersValue;
- (void)setModifiersValue:(int32_t)value_;

//- (BOOL)validateModifiers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* timedEntities;

- (NSMutableSet*)timedEntitiesSet;





@end

@interface _TCSTimedEntityMetadata (CoreDataGeneratedAccessors)

- (void)addTimedEntities:(NSSet*)value_;
- (void)removeTimedEntities:(NSSet*)value_;
- (void)addTimedEntitiesObject:(TCSTimedEntity*)value_;
- (void)removeTimedEntitiesObject:(TCSTimedEntity*)value_;

@end

@interface _TCSTimedEntityMetadata (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveArchived;
- (void)setPrimitiveArchived:(NSNumber*)value;

- (BOOL)primitiveArchivedValue;
- (void)setPrimitiveArchivedValue:(BOOL)value_;




- (NSNumber*)primitiveColor;
- (void)setPrimitiveColor:(NSNumber*)value;

- (int32_t)primitiveColorValue;
- (void)setPrimitiveColorValue:(int32_t)value_;




- (NSNumber*)primitiveFilteredModifiers;
- (void)setPrimitiveFilteredModifiers:(NSNumber*)value;

- (int32_t)primitiveFilteredModifiersValue;
- (void)setPrimitiveFilteredModifiersValue:(int32_t)value_;




- (NSNumber*)primitiveKeyCode;
- (void)setPrimitiveKeyCode:(NSNumber*)value;

- (int32_t)primitiveKeyCodeValue;
- (void)setPrimitiveKeyCodeValue:(int32_t)value_;




- (NSNumber*)primitiveModifiers;
- (void)setPrimitiveModifiers:(NSNumber*)value;

- (int32_t)primitiveModifiersValue;
- (void)setPrimitiveModifiersValue:(int32_t)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;





- (NSMutableSet*)primitiveTimedEntities;
- (void)setPrimitiveTimedEntities:(NSMutableSet*)value;


@end
