// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntity.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimedEntityAttributes {
	__unsafe_unretained NSString *name;
} TCSTimedEntityAttributes;

extern const struct TCSTimedEntityRelationships {
	__unsafe_unretained NSString *metadata;
	__unsafe_unretained NSString *parent;
} TCSTimedEntityRelationships;

extern const struct TCSTimedEntityFetchedProperties {
} TCSTimedEntityFetchedProperties;

@class TCSTimedEntityMetadata;
@class TCSGroup;



@interface TCSTimedEntityID : NSManagedObjectID {}
@end

@interface _TCSTimedEntity : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimedEntityID*)objectID;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSTimedEntityMetadata* metadata;

//- (BOOL)validateMetadata:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) TCSGroup* parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSTimedEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSTimedEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (TCSTimedEntityMetadata*)primitiveMetadata;
- (void)setPrimitiveMetadata:(TCSTimedEntityMetadata*)value;



- (TCSGroup*)primitiveParent;
- (void)setPrimitiveParent:(TCSGroup*)value;


@end
