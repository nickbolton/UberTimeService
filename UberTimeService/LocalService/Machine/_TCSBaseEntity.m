// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSBaseEntity.m instead.

#import "_TCSBaseEntity.h"

const struct TCSBaseEntityAttributes TCSBaseEntityAttributes = {
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
	

	return keyPaths;
}




@dynamic remoteId;






@dynamic remoteProvider;











@end
