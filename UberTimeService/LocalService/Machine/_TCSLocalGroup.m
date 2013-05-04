// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalGroup.m instead.

#import "_TCSLocalGroup.h"

const struct TCSLocalGroupAttributes TCSLocalGroupAttributes = {
};

const struct TCSLocalGroupRelationships TCSLocalGroupRelationships = {
	.children = @"children",
};

const struct TCSLocalGroupFetchedProperties TCSLocalGroupFetchedProperties = {
};

@implementation TCSLocalGroupID
@end

@implementation _TCSLocalGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSLocalGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSLocalGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSLocalGroup" inManagedObjectContext:moc_];
}

- (TCSLocalGroupID*)objectID {
	return (TCSLocalGroupID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic children;

	
- (NSMutableSet*)childrenSet {
	[self willAccessValueForKey:@"children"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"children"];
  
	[self didAccessValueForKey:@"children"];
	return result;
}
	






@end
