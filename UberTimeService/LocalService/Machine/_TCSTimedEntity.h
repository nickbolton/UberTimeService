// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSTimedEntity.h instead.

#import <CoreData/CoreData.h>


extern const struct TCSTimedEntityAttributes {
	__unsafe_unretained NSString *archived;
	__unsafe_unretained NSString *color;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *remoteId;
	__unsafe_unretained NSString *remoteProvider;
} TCSTimedEntityAttributes;

extern const struct TCSTimedEntityRelationships {
	__unsafe_unretained NSString *parent;
} TCSTimedEntityRelationships;

extern const struct TCSTimedEntityFetchedProperties {
} TCSTimedEntityFetchedProperties;

@class TCSGroup;







@interface TCSTimedEntityID : NSManagedObjectID {}
@end

@interface _TCSTimedEntity : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSTimedEntityID*)objectID;




@property (nonatomic, strong) NSNumber* archived;


@property BOOL archivedValue;
- (BOOL)archivedValue;
- (void)setArchivedValue:(BOOL)value_;

//- (BOOL)validateArchived:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* color;


@property int32_t colorValue;
- (int32_t)colorValue;
- (void)setColorValue:(int32_t)value_;

//- (BOOL)validateColor:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteId;


//- (BOOL)validateRemoteId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteProvider;


//- (BOOL)validateRemoteProvider:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) TCSGroup* parent;

//- (BOOL)validateParent:(id*)value_ error:(NSError**)error_;





@end

@interface _TCSTimedEntity (CoreDataGeneratedAccessors)

@end

@interface _TCSTimedEntity (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveArchived;
- (void)setPrimitiveArchived:(NSNumber*)value;

- (BOOL)primitiveArchivedValue;
- (void)setPrimitiveArchivedValue:(BOOL)value_;




- (NSNumber*)primitiveColor;
- (void)setPrimitiveColor:(NSNumber*)value;

- (int32_t)primitiveColorValue;
- (void)setPrimitiveColorValue:(int32_t)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveRemoteId;
- (void)setPrimitiveRemoteId:(NSString*)value;




- (NSString*)primitiveRemoteProvider;
- (void)setPrimitiveRemoteProvider:(NSString*)value;





- (TCSGroup*)primitiveParent;
- (void)setPrimitiveParent:(TCSGroup*)value;


@end
