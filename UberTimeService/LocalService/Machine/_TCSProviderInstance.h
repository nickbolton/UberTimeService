// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TCSProviderInstance.h instead.

#import <CoreData/CoreData.h>
#import "TCSBaseEntity.h"

extern const struct TCSProviderInstanceAttributes {
	__unsafe_unretained NSString *baseURL;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *password;
	__unsafe_unretained NSString *remoteProvider;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *username;
} TCSProviderInstanceAttributes;

extern const struct TCSProviderInstanceRelationships {
	__unsafe_unretained NSString *entities;
} TCSProviderInstanceRelationships;

extern const struct TCSProviderInstanceFetchedProperties {
} TCSProviderInstanceFetchedProperties;

@class TCSBaseEntity;








@interface TCSProviderInstanceID : NSManagedObjectID {}
@end

@interface _TCSProviderInstance : TCSBaseEntity {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TCSProviderInstanceID*)objectID;




@property (nonatomic, strong) NSString* baseURL;


//- (BOOL)validateBaseURL:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* password;


//- (BOOL)validatePassword:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* remoteProvider;


//- (BOOL)validateRemoteProvider:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* userID;


//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* username;


//- (BOOL)validateUsername:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* entities;

- (NSMutableSet*)entitiesSet;





@end

@interface _TCSProviderInstance (CoreDataGeneratedAccessors)

- (void)addEntities:(NSSet*)value_;
- (void)removeEntities:(NSSet*)value_;
- (void)addEntitiesObject:(TCSBaseEntity*)value_;
- (void)removeEntitiesObject:(TCSBaseEntity*)value_;

@end

@interface _TCSProviderInstance (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveBaseURL;
- (void)setPrimitiveBaseURL:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitivePassword;
- (void)setPrimitivePassword:(NSString*)value;




- (NSString*)primitiveRemoteProvider;
- (void)setPrimitiveRemoteProvider:(NSString*)value;




- (NSString*)primitiveUserID;
- (void)setPrimitiveUserID:(NSString*)value;




- (NSString*)primitiveUsername;
- (void)setPrimitiveUsername:(NSString*)value;





- (NSMutableSet*)primitiveEntities;
- (void)setPrimitiveEntities:(NSMutableSet*)value;


@end
