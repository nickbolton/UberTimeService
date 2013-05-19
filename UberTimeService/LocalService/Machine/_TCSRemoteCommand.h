// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSRemoteCommand.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSRemoteCommandAttributes {
	__unsafe_unretained NSString *executed;
	__unsafe_unretained NSString *payload;
	__unsafe_unretained NSString *type;
} TCSRemoteCommandAttributes;

extern const struct TCSRemoteCommandRelationships {
} TCSRemoteCommandRelationships;

extern const struct TCSRemoteCommandFetchedProperties {
} TCSRemoteCommandFetchedProperties;



@class NSObject;


@interface TCSRemoteCommandID : NSManagedObjectID {}
@end

@interface _TCSRemoteCommand : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSRemoteCommandID*)objectID;




@property (nonatomic, strong) NSNumber* executed;


@property BOOL executedValue;
- (BOOL)executedValue;
- (void)setExecutedValue:(BOOL)value_;

//- (BOOL)validateExecuted:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) id payload;


//- (BOOL)validatePayload:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* type;


@property int32_t typeValue;
- (int32_t)typeValue;
- (void)setTypeValue:(int32_t)value_;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;






@end

@interface _TCSRemoteCommand (CoreDataGeneratedAccessors)

@end

@interface _TCSRemoteCommand (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveExecuted;
- (void)setPrimitiveExecuted:(NSNumber*)value;

- (BOOL)primitiveExecutedValue;
- (void)setPrimitiveExecutedValue:(BOOL)value_;




- (id)primitivePayload;
- (void)setPrimitivePayload:(id)value;




- (NSNumber*)primitiveType;
- (void)setPrimitiveType:(NSNumber*)value;

- (int32_t)primitiveTypeValue;
- (void)setPrimitiveTypeValue:(int32_t)value_;




@end
