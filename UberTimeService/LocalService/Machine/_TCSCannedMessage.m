// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSCannedMessage.m instead.

#import "_TCSCannedMessage.h"

const struct TCSCannedMessageAttributes TCSCannedMessageAttributes = {
	.message = @"message",
	.order = @"order",
};

const struct TCSCannedMessageRelationships TCSCannedMessageRelationships = {
};

const struct TCSCannedMessageFetchedProperties TCSCannedMessageFetchedProperties = {
};

@implementation TCSCannedMessageID
@end

@implementation _TCSCannedMessage

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TCSCannedMessage" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TCSCannedMessage";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TCSCannedMessage" inManagedObjectContext:moc_];
}

- (TCSCannedMessageID*)objectID {
	return (TCSCannedMessageID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"orderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"order"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic message;






@dynamic order;



- (int16_t)orderValue {
	NSNumber *result = [self order];
	return [result shortValue];
}

- (void)setOrderValue:(int16_t)value_ {
	[self setOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result shortValue];
}

- (void)setPrimitiveOrderValue:(int16_t)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithShort:value_]];
}










@end
