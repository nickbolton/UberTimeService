// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalTimer.m instead.

#import "_TCSLocalTimer.h"

const struct TCSLocalTimerAttributes TCSLocalTimerAttributes = {
	.adjustment = @"adjustment",
	.endTime = @"endTime",
	.message = @"message",
	.startTime = @"startTime",
};

const struct TCSLocalTimerRelationships TCSLocalTimerRelationships = {
	.project = @"project",
};

const struct TCSLocalTimerFetchedProperties TCSLocalTimerFetchedProperties = {
};

@implementation TCSLocalTimerID
@end

@implementation _TCSLocalTimer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSLocalTimer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSLocalTimer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSLocalTimer" inManagedObjectContext:moc_];
}

- (TCSLocalTimerID*)objectID {
	return (TCSLocalTimerID*)[super objectID];
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






@dynamic message;






@dynamic startTime;






@dynamic project;

	






@end
