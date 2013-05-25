// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProviderInstance.m instead.

#import "_TCSProviderInstance.h"

const struct TCSProviderInstanceAttributes TCSProviderInstanceAttributes = {
	.baseURL = @"baseURL",
	.name = @"name",
	.password = @"password",
	.remoteProvider = @"remoteProvider",
	.userID = @"userID",
	.username = @"username",
};

const struct TCSProviderInstanceRelationships TCSProviderInstanceRelationships = {
	.entities = @"entities",
};

const struct TCSProviderInstanceFetchedProperties TCSProviderInstanceFetchedProperties = {
};

@implementation TCSProviderInstanceID
@end

@implementation _TCSProviderInstance

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSProviderInstance" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSProviderInstance";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSProviderInstance" inManagedObjectContext:moc_];
}

- (TCSProviderInstanceID*)objectID {
	return (TCSProviderInstanceID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic baseURL;






@dynamic name;






@dynamic password;






@dynamic remoteProvider;






@dynamic userID;






@dynamic username;






@dynamic entities;

	
- (NSMutableSet*)entitiesSet {
	[self willAccessValueForKey:@"entities"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"entities"];
  
	[self didAccessValueForKey:@"entities"];
	return result;
}
	






@end
