// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProviderInstance.m instead.

#import "_TCSProviderInstance.h"

const struct TCSProviderInstanceAttributes TCSProviderInstanceAttributes = {
	.baseURL = @"baseURL",
	.name = @"name",
	.password = @"password",
	.type = @"type",
	.userID = @"userID",
	.username = @"username",
};

const struct TCSProviderInstanceRelationships TCSProviderInstanceRelationships = {
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






@dynamic type;






@dynamic userID;






@dynamic username;











@end
