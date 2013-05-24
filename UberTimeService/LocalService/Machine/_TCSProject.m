// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProject.m instead.

#import "_TCSProject.h"

const struct TCSProjectAttributes TCSProjectAttributes = {
};

const struct TCSProjectRelationships TCSProjectRelationships = {
	.timers = @"timers",
};

const struct TCSProjectFetchedProperties TCSProjectFetchedProperties = {
};

@implementation TCSProjectID
@end

@implementation _TCSProject

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSProject" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSProject";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSProject" inManagedObjectContext:moc_];
}

- (TCSProjectID*)objectID {
	return (TCSProjectID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic timers;

	
- (NSMutableSet*)timersSet {
	[self willAccessValueForKey:@"timers"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"timers"];
  
	[self didAccessValueForKey:@"timers"];
	return result;
}
	






@end
