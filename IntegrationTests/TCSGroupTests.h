//
//  TCSGroupTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/4/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import "TCSBaseTests.h"

@class TCSProject;
@class TCSGroup;

@interface TCSGroupTests : TCSBaseTests

@property (nonatomic, strong) TCSProject *project;
@property (nonatomic, strong) TCSProject *secondProject;
@property (nonatomic, strong) TCSProject *targetProject;
@property (nonatomic, strong) TCSGroup *group;

- (void)createProjects:(SEL)selector;
- (void)moveProjectToGroup:(SEL)selector;
- (void)moveSecondProjectToGroup:(SEL)selector;
- (void)ungroupProject:(SEL)selector;
- (void)ungroupSecondProject:(SEL)selector;
- (void)editGroup:(SEL)selector;
- (void)deleteGroup:(SEL)selector;
- (void)deleteAllData:(SEL)selector;

@end
