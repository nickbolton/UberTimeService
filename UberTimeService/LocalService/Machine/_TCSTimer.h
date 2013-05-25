// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimer.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSTimerAttributes {
	__unsafe_unretained NSString *message;
} TCSTimerAttributes;

extern const struct TCSTimerRelationships {
	__unsafe_unretained NSString *metadata;
	__unsafe_unretained NSString *project;
} TCSTimerRelationships;

extern const struct TCSTimerFetchedProperties {
} TCSTimerFetchedProperties;

@class TCSTimerMetadata;
@class TCSProject;



@interface TCSTimerID : NSManagedObjectID {}
@end

@interface _TCSTimer : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimerID*)objectID;




@property (nonatomic, strong) NSString* message;


//- (BOOL)validateMessage:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSTimerMetadata* metadata;

//- (BOOL)validateMetadata:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) TCSProject* project;

//- (BOOL)validateProject:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSTimer (CoreDataGeneratedAccessors)

@end

@interface _TCSTimer (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveMessage;
- (void)setPrimitiveMessage:(NSString*)value;





- (TCSTimerMetadata*)primitiveMetadata;
- (void)setPrimitiveMetadata:(TCSTimerMetadata*)value;



- (TCSProject*)primitiveProject;
- (void)setPrimitiveProject:(TCSProject*)value;


@end
