// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.m instead.

#import "_TCSBaseEntity.h"

const struct TCSBaseEntityAttributes TCSBaseEntityAttributes = {
	.dirty = @"dirty",
	.remoteId = @"remoteId",
	.remoteProvider = @"remoteProvider",
};

const struct TCSBaseEntityRelationships TCSBaseEntityRelationships = {
};

const struct TCSBaseEntityFetchedProperties TCSBaseEntityFetchedProperties = {
};

@implementation TCSBaseEntityID
@end

@implementation _TCSBaseEntity

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSBaseEntity" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSBaseEntity";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSBaseEntity" inManagedObjectContext:moc_];
}

- (TCSBaseEntityID*)objectID {
	return (TCSBaseEntityID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"dirtyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"dirty"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic dirty;



- (BOOL)dirtyValue {
	NSNumber *result = [self dirty];
	return [result boolValue];
}

- (void)setDirtyValue:(BOOL)value_ {
	[self setDirty:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDirtyValue {
	NSNumber *result = [self primitiveDirty];
	return [result boolValue];
}

- (void)setPrimitiveDirtyValue:(BOOL)value_ {
	[self setPrimitiveDirty:[NSNumber numberWithBool:value_]];
}





@dynamic remoteId;






@dynamic remoteProvider;











@end
