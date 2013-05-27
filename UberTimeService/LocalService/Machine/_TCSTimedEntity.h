// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntity.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimedEntityAttributes {
	__unsafe_unretained NSString *archived;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *filteredModifiers;
	__unsafe_unretained NSString *keyCode;
	__unsafe_unretained NSString *modifiers;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *order;
} TCSTimedEntityAttributes;

extern const struct TCSTimedEntityRelationships {
	__unsafe_unretained NSString *parent;
} TCSTimedEntityRelationships;

extern const struct TCSTimedEntityFetchedProperties {
} TCSTimedEntityFetchedProperties;

@class TCSGroup;









@interface TCSTimedEntityID : NSManagedObjectID {}
@end

@interface _TCSTimedEntity : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimedEntityID*)objectID;




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




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSGroup* parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSTimedEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSTimedEntity (CoreDataGeneratedPrimitiveAccessors)


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




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;





- (TCSGroup*)primitiveParent;
- (void)setPrimitiveParent:(TCSGroup*)value;


@end
