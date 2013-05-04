// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalTimedEntity.m instead.

#import "_TCSLocalTimedEntity.h"

const struct TCSLocalTimedEntityAttributes TCSLocalTimedEntityAttributes = {
	.archived = @"archived",
	.color = @"color",
	.name = @"name",
};

const struct TCSLocalTimedEntityRelationships TCSLocalTimedEntityRelationships = {
	.parent = @"parent",
};

const struct TCSLocalTimedEntityFetchedProperties TCSLocalTimedEntityFetchedProperties = {
};

@implementation TCSLocalTimedEntityID
@end

@implementation _TCSLocalTimedEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSLocalTimedEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSLocalTimedEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSLocalTimedEntity" inManagedObjectContext:moc_];
}

- (TCSLocalTimedEntityID*)objectID {
	return (TCSLocalTimedEntityID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"archivedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"archived"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"colorValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"color"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic archived;



- (BOOL)archivedValue {
	NSNumber *result = [self archived];
	return [result boolValue];
}

- (void)setArchivedValue:(BOOL)value_ {
	[self setArchived:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveArchivedValue {
	NSNumber *result = [self primitiveArchived];
	return [result boolValue];
}

- (void)setPrimitiveArchivedValue:(BOOL)value_ {
	[self setPrimitiveArchived:[NSNumber numberWithBool:value_]];
}





@dynamic color;



- (int32_t)colorValue {
	NSNumber *result = [self color];
	return [result intValue];
}

- (void)setColorValue:(int32_t)value_ {
	[self setColor:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveColorValue {
	NSNumber *result = [self primitiveColor];
	return [result intValue];
}

- (void)setPrimitiveColorValue:(int32_t)value_ {
	[self setPrimitiveColor:[NSNumber numberWithInt:value_]];
}





@dynamic name;






@dynamic parent;

	






@end
