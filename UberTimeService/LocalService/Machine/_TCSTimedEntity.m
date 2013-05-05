// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntity.m instead.

#import "_TCSTimedEntity.h"

const struct TCSTimedEntityAttributes TCSTimedEntityAttributes = {
	.archived = @"archived",
	.color = @"color",
	.name = @"name",
	.remoteId = @"remoteId",
	.remoteProvider = @"remoteProvider",
};

const struct TCSTimedEntityRelationships TCSTimedEntityRelationships = {
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






@dynamic remoteId;






@dynamic remoteProvider;






@dynamic parent;

	






@end
