// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntityMetadata.m instead.

#import "_TCSTimedEntityMetadata.h"

const struct TCSTimedEntityMetadataAttributes TCSTimedEntityMetadataAttributes = {
	.archived = @"archived",
	.color = @"color",
	.filteredModifiers = @"filteredModifiers",
	.keyCode = @"keyCode",
	.modifiers = @"modifiers",
	.order = @"order",
};

const struct TCSTimedEntityMetadataRelationships TCSTimedEntityMetadataRelationships = {
	.timedEntities = @"timedEntities",
};

const struct TCSTimedEntityMetadataFetchedProperties TCSTimedEntityMetadataFetchedProperties = {
};

@implementation TCSTimedEntityMetadataID
@end

@implementation _TCSTimedEntityMetadata

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSTimedEntityMetadata" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSTimedEntityMetadata";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSTimedEntityMetadata" inManagedObjectContext:moc_];
}

- (TCSTimedEntityMetadataID*)objectID {
	return (TCSTimedEntityMetadataID*)[super objectID];
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
	if ([key isEqualToString:@"filteredModifiersValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"filteredModifiers"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"keyCodeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"keyCode"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"modifiersValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"modifiers"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
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





@dynamic filteredModifiers;



- (int32_t)filteredModifiersValue {
	NSNumber *result = [self filteredModifiers];
	return [result intValue];
}

- (void)setFilteredModifiersValue:(int32_t)value_ {
	[self setFilteredModifiers:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveFilteredModifiersValue {
	NSNumber *result = [self primitiveFilteredModifiers];
	return [result intValue];
}

- (void)setPrimitiveFilteredModifiersValue:(int32_t)value_ {
	[self setPrimitiveFilteredModifiers:[NSNumber numberWithInt:value_]];
}





@dynamic keyCode;



- (int32_t)keyCodeValue {
	NSNumber *result = [self keyCode];
	return [result intValue];
}

- (void)setKeyCodeValue:(int32_t)value_ {
	[self setKeyCode:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveKeyCodeValue {
	NSNumber *result = [self primitiveKeyCode];
	return [result intValue];
}

- (void)setPrimitiveKeyCodeValue:(int32_t)value_ {
	[self setPrimitiveKeyCode:[NSNumber numberWithInt:value_]];
}





@dynamic modifiers;



- (int32_t)modifiersValue {
	NSNumber *result = [self modifiers];
	return [result intValue];
}

- (void)setModifiersValue:(int32_t)value_ {
	[self setModifiers:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveModifiersValue {
	NSNumber *result = [self primitiveModifiers];
	return [result intValue];
}

- (void)setPrimitiveModifiersValue:(int32_t)value_ {
	[self setPrimitiveModifiers:[NSNumber numberWithInt:value_]];
}





@dynamic order;



- (int32_t)orderValue {
	NSNumber *result = [self order];
	return [result intValue];
}

- (void)setOrderValue:(int32_t)value_ {
	[self setOrder:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result intValue];
}

- (void)setPrimitiveOrderValue:(int32_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithInt:value_]];
}





@dynamic timedEntities;

	
- (NSMutableSet*)timedEntitiesSet {
	[self willAccessValueForKey:@"timedEntities"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"timedEntities"];
  
	[self didAccessValueForKey:@"timedEntities"];
	return result;
}
	






@end
