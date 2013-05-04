// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalTimer.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSLocalTimerAttributes {
	__unsafe_unretained NSString *adjustment;
	__unsafe_unretained NSString *endTime;
	__unsafe_unretained NSString *message;
	__unsafe_unretained NSString *startTime;
} TCSLocalTimerAttributes;

extern const struct TCSLocalTimerRelationships {
	__unsafe_unretained NSString *project;
} TCSLocalTimerRelationships;

extern const struct TCSLocalTimerFetchedProperties {
} TCSLocalTimerFetchedProperties;

@class TCSLocalProject;






@interface TCSLocalTimerID : NSManagedObjectID {}
@end

@interface _TCSLocalTimer : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSLocalTimerID*)objectID;




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





@property (nonatomic, strong) TCSLocalProject* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSLocalTimer (CoreDataGeneratedAccessors)

@end

@interface _TCSLocalTimer (CoreDataGeneratedPrimitiveAccessors)


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





- (TCSLocalProject*)primitiveProject;
- (void)setPrimitiveProject:(TCSLocalProject*)value;


@end
