// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalTimedEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSLocalTimedEntityAttributes {
	__unsafe_unretained NSString *archived;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *name;
} TCSLocalTimedEntityAttributes;

extern const struct TCSLocalTimedEntityRelationships {
	__unsafe_unretained NSString *parent;
} TCSLocalTimedEntityRelationships;

extern const struct TCSLocalTimedEntityFetchedProperties {
} TCSLocalTimedEntityFetchedProperties;

@class TCSLocalGroup;





@interface TCSLocalTimedEntityID : NSManagedObjectID {}
@end

@interface _TCSLocalTimedEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSLocalTimedEntityID*)objectID;




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




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSLocalGroup* parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSLocalTimedEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSLocalTimedEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveArchived;
- (void)setPrimitiveArchived:(NSNumber*)value;

- (BOOL)primitiveArchivedValue;
- (void)setPrimitiveArchivedValue:(BOOL)value_;




- (NSNumber*)primitiveColor;
- (void)setPrimitiveColor:(NSNumber*)value;

- (int32_t)primitiveColorValue;
- (void)setPrimitiveColorValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (TCSLocalGroup*)primitiveParent;
- (void)setPrimitiveParent:(TCSLocalGroup*)value;


@end
