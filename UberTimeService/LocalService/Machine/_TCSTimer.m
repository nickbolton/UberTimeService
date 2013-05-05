// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimer.m instead.

#import "_TCSTimer.h"

const struct TCSTimerAttributes TCSTimerAttributes = {
	.adjustment = @"adjustment",
	.endTime = @"endTime",
	.message = @"message",
	.remoteId = @"remoteId",
	.startTime = @"startTime",
};

const struct TCSTimerRelationships TCSTimerRelationships = {
	.project = @"project",
};

const struct TCSTimerFetchedProperties TCSTimerFetchedProperties = {
};

@implementation TCSTimerID
@end

@implementation _TCSTimer

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSTimer" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSTimer";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSTimer" inManagedObjectContext:moc_];
}

- (TCSTimerID*)objectID {
	return (TCSTimerID*)[super objectID];
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






@dynamic remoteId;






@dynamic startTime;






@dynamic project;

	






@end
