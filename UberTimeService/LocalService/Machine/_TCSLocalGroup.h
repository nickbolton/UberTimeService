// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSLocalGroup.h instead.

#import <CoreData/CoreData.h>
#import "TCSLocalTimedEntity.h"

extern const struct TCSLocalGroupAttributes {
} TCSLocalGroupAttributes;

extern const struct TCSLocalGroupRelationships {
	__unsafe_unretained NSString *children;
} TCSLocalGroupRelationships;

extern const struct TCSLocalGroupFetchedProperties {
} TCSLocalGroupFetchedProperties;

@class TCSLocalTimedEntity;


@interface TCSLocalGroupID : NSManagedObjectID {}
@end

@interface _TCSLocalGroup : TCSLocalTimedEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSLocalGroupID*)objectID;





@property (nonatomic, strong) NSSet* children;

- (NSMutableSet*)childrenSet;





@end

@interface _TCSLocalGroup (CoreDataGeneratedAccessors)

- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(TCSLocalTimedEntity*)value_;
- (void)removeChildrenObject:(TCSLocalTimedEntity*)value_;

@end

@interface _TCSLocalGroup (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;


@end
