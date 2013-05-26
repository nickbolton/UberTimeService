// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseMetadataEntity.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSBaseMetadataEntityAttributes {
	__unsafe_unretained NSString *relatedRemoteId;
} TCSBaseMetadataEntityAttributes;

extern const struct TCSBaseMetadataEntityRelationships {
} TCSBaseMetadataEntityRelationships;

extern const struct TCSBaseMetadataEntityFetchedProperties {
} TCSBaseMetadataEntityFetchedProperties;




@interface TCSBaseMetadataEntityID : NSManagedObjectID {}
@end

@interface _TCSBaseMetadataEntity : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSBaseMetadataEntityID*)objectID;




@property (nonatomic, strong) NSString* relatedRemoteId;


//- (BOOL)validateRelatedRemoteId:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSBaseMetadataEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSBaseMetadataEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRelatedRemoteId;
- (void)setPrimitiveRelatedRemoteId:(NSString*)value;




@end
