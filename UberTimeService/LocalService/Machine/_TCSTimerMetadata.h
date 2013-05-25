// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimerMetadata.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimerMetadataAttributes {
	__unsafe_unretained NSString *adjustment;
	__unsafe_unretained NSString *endTime;
	__unsafe_unretained NSString *startTime;
} TCSTimerMetadataAttributes;

extern const struct TCSTimerMetadataRelationships {
	__unsafe_unretained NSString *timers;
} TCSTimerMetadataRelationships;

extern const struct TCSTimerMetadataFetchedProperties {
} TCSTimerMetadataFetchedProperties;

@class TCSTimer;





@interface TCSTimerMetadataID : NSManagedObjectID {}
@end

@interface _TCSTimerMetadata : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimerMetadataID*)objectID;




@property (nonatomic, strong) NSNumber* adjustment;


@property float adjustmentValue;
- (float)adjustmentValue;
- (void)setAdjustmentValue:(float)value_;

//- (BOOL)validateAdjustment:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* endTime;


//- (BOOL)validateEndTime:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSDate* startTime;


//- (BOOL)validateStartTime:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* timers;

- (NSMutableSet*)timersSet;





@end

@interface _TCSTimerMetadata (CoreDataGeneratedAccessors)

- (void)addTimers:(NSSet*)value_;
- (void)removeTimers:(NSSet*)value_;
- (void)addTimersObject:(TCSTimer*)value_;
- (void)removeTimersObject:(TCSTimer*)value_;

@end

@interface _TCSTimerMetadata (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveAdjustment;
- (void)setPrimitiveAdjustment:(NSNumber*)value;

- (float)primitiveAdjustmentValue;
- (void)setPrimitiveAdjustmentValue:(float)value_;




- (NSDate*)primitiveEndTime;
- (void)setPrimitiveEndTime:(NSDate*)value;




- (NSDate*)primitiveStartTime;
- (void)setPrimitiveStartTime:(NSDate*)value;





- (NSMutableSet*)primitiveTimers;
- (void)setPrimitiveTimers:(NSMutableSet*)value;


@end
