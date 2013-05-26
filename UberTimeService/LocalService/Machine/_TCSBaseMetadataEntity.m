// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseMetadataEntity.m instead.

#import "_TCSBaseMetadataEntity.h"

const struct TCSBaseMetadataEntityAttributes TCSBaseMetadataEntityAttributes = {
	.relatedObjectId = @"relatedObjectId",
};

const struct TCSBaseMetadataEntityRelationships TCSBaseMetadataEntityRelationships = {
};

const struct TCSBaseMetadataEntityFetchedProperties TCSBaseMetadataEntityFetchedProperties = {
};

@implementation TCSBaseMetadataEntityID
@end

@implementation _TCSBaseMetadataEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSBaseMetadataEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSBaseMetadataEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSBaseMetadataEntity" inManagedObjectContext:moc_];
}

- (TCSBaseMetadataEntityID*)objectID {
	return (TCSBaseMetadataEntityID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic relatedObjectId;











@end
