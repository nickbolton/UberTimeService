//
//  TCSBaseTests.m
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseTests.h"
#import "TCSService.h"
#import <CoreData/CoreData.h>

@implementation TCSBaseTests

#pragma mark - Helpers

- (void)deleteAllData:(void(^)(void))successBlock
              failure:(void(^)(void))failureBlock {
    [_service deleteAllData:successBlock failure:^(NSError *error) {
        NSLog(@"ZZZ Error: %@", error);
        if (failureBlock != nil) {
            failureBlock();
        }
    }];;
}

- (TCSProject *)projectWithEntityID:(NSManagedObjectID *)objectID {
    return [_service projectWithID:objectID];
}

- (TCSTimer *)timerWithEntityID:(NSManagedObjectID *)objectID {
    return [_service timerWithID:objectID];
}

- (TCSGroup *)groupWithEntityID:(NSManagedObjectID *)objectID {
    return [_service groupWithID:objectID];
}

@end
