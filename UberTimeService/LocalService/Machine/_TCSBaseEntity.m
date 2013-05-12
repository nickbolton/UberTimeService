// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.m instead.

#import "_TCSBaseEntity.h"

const struct TCSBaseEntityAttributes TCSBaseEntityAttributes = {
	.entityVersion = @"entityVersion",
	.pending = @"pending",
	.remoteDeleted = @"remoteDeleted",
	.remoteId = @"remoteId",
	.remoteProvider = @"remoteProvider",
	.updateTime = @"updateTime",
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
	
	if ([key isEqualToString:@"entityVersionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"entityVersion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"pendingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pending"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"remoteDeletedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"remoteDeleted"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic entityVersion;



- (int64_t)entityVersionValue {
	NSNumber *result = [self entityVersion];
	return [result longLongValue];
}

- (void)setEntityVersionValue:(int64_t)value_ {
	[self setEntityVersion:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveEntityVersionValue {
	NSNumber *result = [self primitiveEntityVersion];
	return [result longLongValue];
}

- (void)setPrimitiveEntityVersionValue:(int64_t)value_ {
	[self setPrimitiveEntityVersion:[NSNumber numberWithLongLong:value_]];
}





@dynamic pending;



- (BOOL)pendingValue {
	NSNumber *result = [self pending];
	return [result boolValue];
}

- (void)setPendingValue:(BOOL)value_ {
	[self setPending:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePendingValue {
	NSNumber *result = [self primitivePending];
	return [result boolValue];
}

- (void)setPrimitivePendingValue:(BOOL)value_ {
	[self setPrimitivePending:[NSNumber numberWithBool:value_]];
}





@dynamic remoteDeleted;



- (BOOL)remoteDeletedValue {
	NSNumber *result = [self remoteDeleted];
	return [result boolValue];
}

- (void)setRemoteDeletedValue:(BOOL)value_ {
	[self setRemoteDeleted:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveRemoteDeletedValue {
	NSNumber *result = [self primitiveRemoteDeleted];
	return [result boolValue];
}

- (void)setPrimitiveRemoteDeletedValue:(BOOL)value_ {
	[self setPrimitiveRemoteDeleted:[NSNumber numberWithBool:value_]];
}





@dynamic remoteId;






@dynamic remoteProvider;






@dynamic updateTime;











@end
