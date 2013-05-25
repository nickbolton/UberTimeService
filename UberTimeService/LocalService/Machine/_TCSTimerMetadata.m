// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimerMetadata.m instead.

#import "_TCSTimerMetadata.h"

const struct TCSTimerMetadataAttributes TCSTimerMetadataAttributes = {
	.adjustment = @"adjustment",
	.endTime = @"endTime",
	.startTime = @"startTime",
};

const struct TCSTimerMetadataRelationships TCSTimerMetadataRelationships = {
	.timers = @"timers",
};

const struct TCSTimerMetadataFetchedProperties TCSTimerMetadataFetchedProperties = {
};

@implementation TCSTimerMetadataID
@end

@implementation _TCSTimerMetadata

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSTimerMetadata" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSTimerMetadata";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSTimerMetadata" inManagedObjectContext:moc_];
}

- (TCSTimerMetadataID*)objectID {
	return (TCSTimerMetadataID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"adjustmentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"adjustment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic adjustment;



- (float)adjustmentValue {
	NSNumber *result = [self adjustment];
	return [result floatValue];
}

- (void)setAdjustmentValue:(float)value_ {
	[self setAdjustment:[NSNumber numberWithFloat:value_]];
}

- (float)primitiveAdjustmentValue {
	NSNumber *result = [self primitiveAdjustment];
	return [result floatValue];
}

- (void)setPrimitiveAdjustmentValue:(float)value_ {
	[self setPrimitiveAdjustment:[NSNumber numberWithFloat:value_]];
}





@dynamic endTime;






@dynamic startTime;






@dynamic timers;

	
- (NSMutableSet*)timersSet {
	[self willAccessValueForKey:@"timers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"timers"];
  
	[self didAccessValueForKey:@"timers"];
	return result;
}
	






@end
