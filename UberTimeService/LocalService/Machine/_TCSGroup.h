// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSGroup.h instead.

#import <CoreData/CoreData.h>
#import "TCSTimedEntity.h"

extern const struct TCSGroupAttributes {
} TCSGroupAttributes;

extern const struct TCSGroupRelationships {
	__unsafe_unretained NSString *children;
} TCSGroupRelationships;

extern const struct TCSGroupFetchedProperties {
} TCSGroupFetchedProperties;

@class TCSTimedEntity;


@interface TCSGroupID : NSManagedObjectID {}
@end

@interface _TCSGroup : TCSTimedEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSGroupID*)objectID;





@property (nonatomic, strong) NSSet* children;

- (NSMutableSet*)childrenSet;





@end

@interface _TCSGroup (CoreDataGeneratedAccessors)

- (void)addChildren:(NSSet*)value_;
- (void)removeChildren:(NSSet*)value_;
- (void)addChildrenObject:(TCSTimedEntity*)value_;
- (void)removeChildrenObject:(TCSTimedEntity*)value_;

@end

@interface _TCSGroup (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableSet*)primitiveChildren;
- (void)setPrimitiveChildren:(NSMutableSet*)value;


@end
