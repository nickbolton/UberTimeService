// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProject.h instead.

#import <CoreData/CoreData.h>
#import "TCSTimedEntity.h"

extern const struct TCSProjectAttributes {
	__unsafe_unretained NSString *filteredModifiers;
	__unsafe_unretained NSString *keyCode;
	__unsafe_unretained NSString *modifiers;
	__unsafe_unretained NSString *order;
} TCSProjectAttributes;

extern const struct TCSProjectRelationships {
	__unsafe_unretained NSString *timers;
} TCSProjectRelationships;

extern const struct TCSProjectFetchedProperties {
} TCSProjectFetchedProperties;

@class TCSTimer;






@interface TCSProjectID : NSManagedObjectID {}
@end

@interface _TCSProject : TCSTimedEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSProjectID*)objectID;




@property (nonatomic, strong) NSNumber* filteredModifiers;


@property int32_t filteredModifiersValue;
- (int32_t)filteredModifiersValue;
- (void)setFilteredModifiersValue:(int32_t)value_;

//- (BOOL)validateFilteredModifiers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* keyCode;


@property int32_t keyCodeValue;
- (int32_t)keyCodeValue;
- (void)setKeyCodeValue:(int32_t)value_;

//- (BOOL)validateKeyCode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* modifiers;


@property int32_t modifiersValue;
- (int32_t)modifiersValue;
- (void)setModifiersValue:(int32_t)value_;

//- (BOOL)validateModifiers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* order;


@property int32_t orderValue;
- (int32_t)orderValue;
- (void)setOrderValue:(int32_t)value_;

//- (BOOL)validateOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* timers;

- (NSMutableSet*)timersSet;





@end

@interface _TCSProject (CoreDataGeneratedAccessors)

- (void)addTimers:(NSSet*)value_;
- (void)removeTimers:(NSSet*)value_;
- (void)addTimersObject:(TCSTimer*)value_;
- (void)removeTimersObject:(TCSTimer*)value_;

@end

@interface _TCSProject (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveFilteredModifiers;
- (void)setPrimitiveFilteredModifiers:(NSNumber*)value;

- (int32_t)primitiveFilteredModifiersValue;
- (void)setPrimitiveFilteredModifiersValue:(int32_t)value_;




- (NSNumber*)primitiveKeyCode;
- (void)setPrimitiveKeyCode:(NSNumber*)value;

- (int32_t)primitiveKeyCodeValue;
- (void)setPrimitiveKeyCodeValue:(int32_t)value_;




- (NSNumber*)primitiveModifiers;
- (void)setPrimitiveModifiers:(NSNumber*)value;

- (int32_t)primitiveModifiersValue;
- (void)setPrimitiveModifiersValue:(int32_t)value_;




- (NSNumber*)primitiveOrder;
- (void)setPrimitiveOrder:(NSNumber*)value;

- (int32_t)primitiveOrderValue;
- (void)setPrimitiveOrderValue:(int32_t)value_;





- (NSMutableSet*)primitiveTimers;
- (void)setPrimitiveTimers:(NSMutableSet*)value;


@end
