#import "TCSTimer.h"
#import "TCSDateRange.h"
#import "NSDate+Utilities.h"
#import "NSError+Utilities.h"
#import "TCSCommon.h"

@implementation TCSTimer

@synthesize editing = _editing;

+ (void)createRemoteObject:(TCSTimer *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID, NSString *remoteID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (remoteProvider != nil) {

        NSAssert([localEntity isKindOfClass:[TCSTimer class]],
                 @"No a TCSTimer object");

        if (localEntity.project.remoteId != nil) {
            [remoteProvider
             createTimer:localEntity
             success:successBlock
             failure:failureBlock];
        } else {
            if (failureBlock != nil) {

                NSError *error =
                [NSError
                 errorWithCode:TCErrorCodePreviousOperationNotFinished
                 message:TCSLoc(@"timer.project.remoteId has yet to be retrieved")];
                
                failureBlock(error);
            }
        }

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)updateRemoteObject:(TCSTimer *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    if (successBlock != nil) {

        NSAssert([localEntity isKindOfClass:[TCSTimer class]],
                 @"No a TCSTimer object");

        if (localEntity.project.remoteId != nil) {

            [remoteProvider
             updateTimer:localEntity
             success:successBlock
             failure:failureBlock];
            
        } else {
            if (failureBlock != nil) {

                NSError *error =
                [NSError
                 errorWithCode:TCErrorCodePreviousOperationNotFinished
                 message:TCSLoc(@"timer.project.remoteId has yet to be retrieved")];

                failureBlock(error);
            }
        }
        
    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (void)deleteRemoteObject:(TCSTimer *)localEntity
            remoteProvider:(NSObject <TCSServiceRemoteProvider> *)remoteProvider
                   success:(void(^)(NSManagedObjectID *objectID))successBlock
                   failure:(void(^)(NSError *error))failureBlock {

    NSLog(@"%s", __PRETTY_FUNCTION__);

    NSAssert([localEntity isKindOfClass:[TCSTimer class]],
             @"No a TCSTimer object");

    if (successBlock != nil) {

        [remoteProvider
         deleteTimer:localEntity
         success:successBlock
         failure:failureBlock];

    } else {
        if (failureBlock != nil) {
            failureBlock([NSError errorWithCode:0 message:TCSLoc(@"No remote provider")]);
        }
    }
}

+ (NSTimeInterval)combinedTimeForStartTime:(NSDate *)startTime
                                   endTime:(NSDate *)endDate
                                adjustment:(NSTimeInterval)adjustment {

    NSTimeInterval timeInterval;

    if (endDate != nil) {
        timeInterval = [endDate timeIntervalSinceDate:startTime];
    } else {

        NSDate *currentTime = [NSDate date];
        timeInterval = [currentTime timeIntervalSinceDate:startTime];
    }

    return MAX(0.0f, timeInterval + adjustment);
}

- (NSTimeInterval)timeInterval {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

	if (end != nil) {
		return [end timeIntervalSinceDate:start];
	}

    NSDate *currentTime = [NSDate date];
    return [currentTime timeIntervalSinceDate:start];
}

- (NSTimeInterval)timeIntervalForDateRange:(TCSDateRange *)dateRange {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

    if (end == nil) {
        end = [NSDate date];
    }

    if ([start isLessThan:dateRange.startDate]) {
        start = dateRange.startDate;
    }

    if ([end isGreaterThan:dateRange.endDate]) {
        end = dateRange.endDate;
    }

    if ([end isLessThan:start]) {
        return 0.0f;
    }

    return [end timeIntervalSinceDate:start];
}

- (NSTimeInterval)combinedTime {
    return MAX(0.0f, self.timeInterval + self.adjustmentValue);
}

- (NSTimeInterval)combinedTimeForDateRange:(TCSDateRange *)dateRange {

    NSDate *start = self.startTime;
    NSDate *end = self.endTime;

    if (end == nil) {
        end = [NSDate date];
    }

    end = [end dateByAddingTimeInterval:self.adjustmentValue];

    if ([start isLessThan:dateRange.startDate]) {
        start = dateRange.startDate;
    }

    if ([end isGreaterThan:dateRange.endDate]) {
        end = dateRange.endDate;
    }

    if ([end isLessThan:start]) {
        return 0.0f;
    }

    return [end timeIntervalSinceDate:start];
}

- (CGFloat)elapsedTimeInHours {
    NSTimeInterval timeInterval = [self combinedTime];
    CGFloat hours = timeInterval / 3600.0;
    return hours;
}

- (void)updateWithStartTime:(NSDate *)startTime
                    endTime:(NSDate *)endTime
                 adjustment:(NSTimeInterval)adjustment
                    message:(NSString *)message
              entityVersion:(int64_t)entityVersion
              remoteDeleted:(BOOL)remoteDeleted
                   remoteId:(NSString *)remoteId
                 updateTime:(NSDate *)updateTime
              markAsUpdated:(BOOL)markAsUpdated {

    self.startTime = [self nonNullValue:startTime];
    self.endTime = [self nonNullValue:endTime];
    self.adjustmentValue = adjustment;
    self.message = [self nonNullValue:message];
    
    [super
     updateWithEntityVersion:entityVersion
     remoteDeleted:remoteDeleted
     remoteId:remoteId
     updateTime:updateTime
     markAsUpdated:markAsUpdated];
}

@end
