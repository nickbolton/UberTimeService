// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalProject.m instead.

#import "_TCSLocalProject.h"

const struct TCSLocalProjectAttributes TCSLocalProjectAttributes = {
	.filteredModifiers = @"filteredModifiers",
	.keyCode = @"keyCode",
	.modifiers = @"modifiers",
	.order = @"order",
};

const struct TCSLocalProjectRelationships TCSLocalProjectRelationships = {
	.timers = @"timers",
};

const struct TCSLocalProjectFetchedProperties TCSLocalProjectFetchedProperties = {
};

@implementation TCSLocalProjectID
@end

@implementation _TCSLocalProject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSLocalProject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSLocalProject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSLocalProject" inManagedObjectContext:moc_];
}

- (TCSLocalProjectID*)objectID {
	return (TCSLocalProjectID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
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





@dynamic timers;

	
- (NSMutableSet*)timersSet {
	[self willAccessValueForKey:@"timers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"timers"];
  
	[self didAccessValueForKey:@"timers"];
	return result;
}
	






@end
