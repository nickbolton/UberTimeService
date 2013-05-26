// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseMetadataEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSBaseMetadataEntityAttributes {
	__unsafe_unretained NSString *relatedObjectId;
} TCSBaseMetadataEntityAttributes;

extern const struct TCSBaseMetadataEntityRelationships {
} TCSBaseMetadataEntityRelationships;

extern const struct TCSBaseMetadataEntityFetchedProperties {
} TCSBaseMetadataEntityFetchedProperties;




@interface TCSBaseMetadataEntityID : NSManagedObjectID {}
@end

@interface _TCSBaseMetadataEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSBaseMetadataEntityID*)objectID;




@property (nonatomic, strong) NSString* relatedObjectId;


//- (BOOL)validateRelatedObjectId:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSBaseMetadataEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSBaseMetadataEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRelatedObjectId;
- (void)setPrimitiveRelatedObjectId:(NSString*)value;




@end
