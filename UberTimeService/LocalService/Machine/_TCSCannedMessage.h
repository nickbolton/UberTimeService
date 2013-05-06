// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSCannedMessage.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSCannedMessageAttributes {
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *order;
} TCSCannedMessageAttributes;

extern const struct TCSCannedMessageRelationships {
} TCSCannedMessageRelationships;

extern const struct TCSCannedMessageFetchedProperties {
} TCSCannedMessageFetchedProperties;





@interface TCSCannedMessageID : NSManagedObjectID {}
@end

@interface _TCSCannedMessage : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSCannedMessageID*)objectID;




@property (nonatomic, strong) NSString* message;


//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int16_t orderValue;
- (int16_t)orderValue;
- (void)setOrderValue:(int16_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSCannedMessage (CoreDataGeneratedAccessors)

@end

@interface _TCSCannedMessage (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int16_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int16_t)value_;




@end
