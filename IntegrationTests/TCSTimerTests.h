//
//  TCSTimerTests.h
//  UberTimeService
//
//  Created by Nick Bolton on 5/3/13.
//  Copyright (c) 2013 Pixelbleed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSBaseTests.h"

@interface TCSTimerTests : TCSBaseTests

@property (nonatomic, strong) TCSProject *project;
@property (nonatomic, strong) TCSProject *secondProject;
@property (nonatomic, strong) TCSTimer *timer;
@property (nonatomic, strong) TCSTimer *secondTimer;
@property (nonatomic, strong) TCSProject *timerProject;
@property (nonatomic, strong) NSArray *projectTimers;

- (void)createProject:(SEL)selector;
- (void)startTimer:(SEL)selector;
- (void)startSecondTimer:(SEL)selector;
- (void)stopTimer:(SEL)selector;
- (void)editTimer:(SEL)selector;
- (void)moveTimer:(SEL)selector;
- (void)deleteTimer:(SEL)selector;
- (void)rollTimer:(SEL)selector;

@end
