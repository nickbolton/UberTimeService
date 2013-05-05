//
//  TCSProjectTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSBaseTests.h"

@interface TCSProjectTests : TCSBaseTests

- (void)createProject:(SEL)selector;
- (void)fetchProjectByEntityID:(SEL)selector;
- (void)fetchAllProjects:(SEL)selector;
- (void)editProject:(SEL)selector;
- (void)deleteProject:(SEL)selector;
- (void)deleteAllProjects:(SEL)selector;

@end
