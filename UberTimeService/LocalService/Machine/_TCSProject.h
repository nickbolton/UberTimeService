// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProject.h instead.

#import <CoreData/CoreData.h>
#import "TCSTimedEntity.h"

extern const struct TCSProjectAttributes {
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



- (NSMutableSet*)primitiveTimers;
- (void)setPrimitiveTimers:(NSMutableSet*)value;


@end
