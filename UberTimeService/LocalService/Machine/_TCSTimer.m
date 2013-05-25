// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimer.m instead.

#import "_TCSTimer.h"

const struct TCSTimerAttributes TCSTimerAttributes = {
	.message = @"message",
};

const struct TCSTimerRelationships TCSTimerRelationships = {
	.metadata = @"metadata",
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
	

	return keyPaths;
}




@dynamic message;






@dynamic metadata;

	

@dynamic project;

	






@end
