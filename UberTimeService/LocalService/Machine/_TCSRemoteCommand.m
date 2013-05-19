// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSRemoteCommand.m instead.

#import "_TCSRemoteCommand.h"

const struct TCSRemoteCommandAttributes TCSRemoteCommandAttributes = {
	.executed = @"executed",
	.payload = @"payload",
	.type = @"type",
};

const struct TCSRemoteCommandRelationships TCSRemoteCommandRelationships = {
};

const struct TCSRemoteCommandFetchedProperties TCSRemoteCommandFetchedProperties = {
};

@implementation TCSRemoteCommandID
@end

@implementation _TCSRemoteCommand

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSRemoteCommand" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSRemoteCommand";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSRemoteCommand" inManagedObjectContext:moc_];
}

- (TCSRemoteCommandID*)objectID {
	return (TCSRemoteCommandID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"executedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"executed"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"typeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"type"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic executed;



- (BOOL)executedValue {
	NSNumber *result = [self executed];
	return [result boolValue];
}

- (void)setExecutedValue:(BOOL)value_ {
	[self setExecuted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveExecutedValue {
	NSNumber *result = [self primitiveExecuted];
	return [result boolValue];
}

- (void)setPrimitiveExecutedValue:(BOOL)value_ {
	[self setPrimitiveExecuted:[NSNumber numberWithBool:value_]];
}





@dynamic payload;






@dynamic type;



- (int32_t)typeValue {
	NSNumber *result = [self type];
	return [result intValue];
}

- (void)setTypeValue:(int32_t)value_ {
	[self setType:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result intValue];
}

- (void)setPrimitiveTypeValue:(int32_t)value_ {
	[self setPrimitiveType:[NSNumber numberWithInt:value_]];
}










@end
