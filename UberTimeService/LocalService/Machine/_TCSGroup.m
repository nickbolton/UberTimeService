// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSGroup.m instead.

#import "_TCSGroup.h"

const struct TCSGroupAttributes TCSGroupAttributes = {
};

const struct TCSGroupRelationships TCSGroupRelationships = {
	.children = @"children",
};

const struct TCSGroupFetchedProperties TCSGroupFetchedProperties = {
};

@implementation TCSGroupID
@end

@implementation _TCSGroup

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSGroup" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSGroup";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSGroup" inManagedObjectContext:moc_];
}

- (TCSGroupID*)objectID {
	return (TCSGroupID*)[super objectID];
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
