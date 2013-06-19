// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.m instead.

#import "_TCSBaseEntity.h"

const struct TCSBaseEntityAttributes TCSBaseEntityAttributes = {
	.dataVersion = @"dataVersion",
	.entityVersion = @"entityVersion",
	.pending = @"pending",
	.pendingRemoteDelete = @"pendingRemoteDelete",
	.remoteId = @"remoteId",
	.syncingSource = @"syncingSource",
	.updateTime = @"updateTime",
};

const struct TCSBaseEntityRelationships TCSBaseEntityRelationships = {
	.providerInstance = @"providerInstance",
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
	
	if ([key isEqualToString:@"dataVersionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"dataVersion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"entityVersionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"entityVersion"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"pendingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pending"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"pendingRemoteDeleteValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"pendingRemoteDelete"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"syncingSourceValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"syncingSource"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic dataVersion;



- (int64_t)dataVersionValue {
	NSNumber *result = [self dataVersion];
	return [result longLongValue];
}

- (void)setDataVersionValue:(int64_t)value_ {
	[self setDataVersion:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveDataVersionValue {
	NSNumber *result = [self primitiveDataVersion];
	return [result longLongValue];
}

- (void)setPrimitiveDataVersionValue:(int64_t)value_ {
	[self setPrimitiveDataVersion:[NSNumber numberWithLongLong:value_]];
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





@dynamic pendingRemoteDelete;



- (BOOL)pendingRemoteDeleteValue {
	NSNumber *result = [self pendingRemoteDelete];
	return [result boolValue];
}

- (void)setPendingRemoteDeleteValue:(BOOL)value_ {
	[self setPendingRemoteDelete:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePendingRemoteDeleteValue {
	NSNumber *result = [self primitivePendingRemoteDelete];
	return [result boolValue];
}

- (void)setPrimitivePendingRemoteDeleteValue:(BOOL)value_ {
	[self setPrimitivePendingRemoteDelete:[NSNumber numberWithBool:value_]];
}





@dynamic remoteId;






@dynamic syncingSource;



- (BOOL)syncingSourceValue {
	NSNumber *result = [self syncingSource];
	return [result boolValue];
}

- (void)setSyncingSourceValue:(BOOL)value_ {
	[self setSyncingSource:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveSyncingSourceValue {
	NSNumber *result = [self primitiveSyncingSource];
	return [result boolValue];
}

- (void)setPrimitiveSyncingSourceValue:(BOOL)value_ {
	[self setPrimitiveSyncingSource:[NSNumber numberWithBool:value_]];
}





@dynamic updateTime;






@dynamic providerInstance;

	






@end
