// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimer.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimerAttributes {
	__unsafe_unretained NSString *adjustment;
	__unsafe_unretained NSString *endTime;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *startTime;
} TCSTimerAttributes;

extern const struct TCSTimerRelationships {
	__unsafe_unretained NSString *project;
} TCSTimerRelationships;

extern const struct TCSTimerFetchedProperties {
} TCSTimerFetchedProperties;

@class TCSProject;






@interface TCSTimerID : NSManagedObjectID {}
@end

@interface _TCSTimer : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimerID*)objectID;




@property (nonatomic, strong) NSNumber* adjustment;


@property float adjustmentValue;
- (float)adjustmentValue;
- (void)setAdjustmentValue:(float)value_;

//- (BOOL)validateAdjustment:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* endTime;


//- (BOOL)validateEndTime:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* message;


//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* startTime;


//- (BOOL)validateStartTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSProject* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSTimer (CoreDataGeneratedAccessors)

@end

@interface _TCSTimer (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAdjustment;
- (void)setPrimitiveAdjustment:(NSNumber*)value;

- (float)primitiveAdjustmentValue;
- (void)setPrimitiveAdjustmentValue:(float)value_;




- (NSDate*)primitiveEndTime;
- (void)setPrimitiveEndTime:(NSDate*)value;




- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;




- (NSDate*)primitiveStartTime;
- (void)setPrimitiveStartTime:(NSDate*)value;





- (TCSProject*)primitiveProject;
- (void)setPrimitiveProject:(TCSProject*)value;


@end
