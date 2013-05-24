// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntity.m instead.

#import "_TCSTimedEntity.h"

const struct TCSTimedEntityAttributes TCSTimedEntityAttributes = {
	.name = @"name",
};

const struct TCSTimedEntityRelationships TCSTimedEntityRelationships = {
	.metadata = @"metadata",
	.parent = @"parent",
};

const struct TCSTimedEntityFetchedProperties TCSTimedEntityFetchedProperties = {
};

@implementation TCSTimedEntityID
@end

@implementation _TCSTimedEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSTimedEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSTimedEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSTimedEntity" inManagedObjectContext:moc_];
}

- (TCSTimedEntityID*)objectID {
	return (TCSTimedEntityID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic metadata;

	

@dynamic parent;

	






@end
