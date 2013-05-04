//
//  TCSCalendarManager.h
//  timecop
//
//  Created by Nick Bolton on 3/14/12.
//  Copyright 2012 Pixelbleed LLC. All rights reserved.
//

@interface TCSCalendarManager : NSObject

+ (TCSCalendarManager *) sharedInstance;

- (NSCalendar *)calendarForCurrentThread;

@end
