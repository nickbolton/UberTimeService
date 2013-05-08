//
//  TCSConstants.h
//  UberTimeService
//
//  Created by Nick Bolton on 11/20/11.
//  Copyright (c) 2011 Pixelbleed LLC. All rights reserved.
//

#ifndef UberTimeService_TCSConstants_h
#define UberTimeService_TCSConstants_h


#define TCS_APP_NAME @"com.timecopapp.Timecop"

#define TCS_REMOVE_OBJECTS_CHANGED_NOTIFICATION {[[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:nil];}
#define TCS_ADD_OBJECTS_CHANGED_NOTIFICATION {int64_t delayInSeconds = .1f; dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void) { [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectsChangedNotification:) name:NSManagedObjectContextObjectsDidChangeNotification object:nil];});}

// Preferences

#define TCS_PREF_DEBUG_MODE                  @"debugMode"

#define TCS_PREF_ICLOUD_ENABLED_KEY @"iCloudEnabledKey"

#define TCS_PREF_ITEMS_SORTED_BY             @"itemsSortedBy"
#define TCS_PREF_TIME_EDITING_INCREMENT      @"timeIncrement"
#define TCS_PREF_SHOW_ON_ALL_SPACES          @"showOnAllSpaces"
#define TCS_PREF_FLOATING_WINDOW             @"floatingWindow"
#define TCS_PREF_NOTES_DIALOG_NAG            @"notesDialogNag"
#define TCS_PREF_SCREENSHOT_INTERVAL         @"screenSnapshotInterval"
#define TCS_PREF_EXPORT_GRANULARITY          @"exportGranularity"
#define TCS_PREF_KEEP_WINDOW_OPEN            @"keepWindowActive"
#define TCS_PREF_ANIMATE_WINDOWS             @"animateWindows"
#define TCS_PREF_GROWL_ENABLED               @"growlEnabled"
#define TCS_PREF_INCLUDE_TEST_DATA           @"includeTestDataOnSystemReset"
#define TCS_PREF_APP_ACTIVATION_KEY          @"ShortcutRecorder appActivationKeyCombo"
#define TCS_PREF_TOGGLE_RECENT_PROJECT_KEY   @"ShortcutRecorder toggleRecentProjectKeyCombo"
#define TCS_PREF_ENTER_COMMENT_KEY           @"ShortcutRecorder enterCommentKeyCombo"

#define TCS_PREF_PROJECTS_TIME_PERIOD        @"defaultTimePeriod"
#define TCS_PREF_PROJECTS_TIMER_INTERVAL     @"projectTimerInterval"
#define TCS_PREF_PROJECTS_ONE_ACTIVE         @"oneActiveProject"
#define TCS_PREF_PROJECTS_INCLUDE_SECONDS    @"includeSecondsInTimers"
#define TCS_PREF_PROJECTS_MAX_TIMER_SESSION  @"maxTimerSession"
#define TCS_PREF_PROJECTS_MODE_VIEW          @"projectViewMode"
#define TCS_PREF_SHOW_COMMENTS_FOR_IDLE_TIME_APPLIED_TO_INACTIVE_PROJECT @"showCommentsWhenIdleTimeAppliedToInactiveProjects"

#define TCS_PREF_IDLE_TIME_CHECK_INTERVAL    @"idleTimeCheckInterval"
#define TCS_PREF_IDLE_TIMEOUT                @"idleTimeout"
#define TCS_PREF_IDLE_TIMEOUT_IN_SECONDS     @"idleTimeoutInSeconds"
#define TCS_PREF_IDLE_MONITOR_ACTIVE_ONLY    @"idleTimeMonitoringActiveTimerOnly"
#define TCS_PREF_IDLE_THRESHOLD              @"idleTimeThreshold"

#define TCS_PREF_STATS_HIDE_EMPTY        @"hideEmptyProjects"
#define TCS_PREF_STATS_SELECTED_VIEW     @"selectedStatsView"
#define TCS_PREF_STATS_CUSTOM_START_DATE @"customStartDate"
#define TCS_PREF_STATS_CUSTOM_END_DATE   @"customEndDate"
#define TCS_PREF_STATS_TIMER_START_DATE  @"timerDisplayStartDate"
#define TCS_PREF_STATS_TIMER_END_DATE    @"timerDisplayEndDate"
#define TCS_PREF_STATS_MULTIPLE_TIMERS   @"multipleProjectTimers"

#define TCS_PREF_STATUS_BAR_ONBOARD_SEEN @"initialOnBoardSeen"

#define TCS_PREF_APPS_AUTO_TRACK         @"autoTrackApplications"
#define TCS_PREF_APPS_BLACKLIST          @"applicationMonitoringBlacklist"
#define TCS_PREF_APPS_MOST_ACTIVE_FILTER @"autoTrackingMostActiveFilter"

#define TCS_PREF_METRICS_ENABLED         @"metricsEnabled"

#define TCS_PREF_EVENT_TIMER_INTERVAL    @"eventTimerInterval"

#define TCS_PREF_STATUS_BAR_SIZE         @"statusBarSize"

#define TCS_PREF_EXTERNAL_REQUEST_TIMEOUT @"externalRequestTimeout"

#define TCS_ALL_PREFS_ARRAY {TCS_PREF_DEBUG_MODE, TCS_PREF_ITEMS_SORTED_BY, TCS_PREF_TIME_EDITING_INCREMENT, TCS_PREF_SHOW_ON_ALL_SPACES, TCS_PREF_FLOATING_WINDOW, TCS_PREF_NOTES_DIALOG_NAG, TCS_PREF_SCREENSHOT_INTERVAL, TCS_PREF_EXPORT_GRANULARITY, TCS_PREF_KEEP_WINDOW_OPEN, TCS_PREF_ANIMATE_WINDOWS, TCS_PREF_GROWL_ENABLED, TCS_PREF_INCLUDE_TEST_DATA, TCS_PREF_APP_ACTIVATION_KEY, TCS_PREF_TOGGLE_RECENT_PROJECT_KEY, TCS_PREF_ENTER_COMMENT_KEY, TCS_PREF_PROJECTS_TIME_PERIOD, TCS_PREF_PROJECTS_TIMER_INTERVAL, TCS_PREF_PROJECTS_ONE_ACTIVE, TCS_PREF_PROJECTS_INCLUDE_SECONDS, TCS_PREF_IDLE_TIME_CHECK_INTERVAL, TCS_PREF_IDLE_TIMEOUT, TCS_PREF_IDLE_TIMEOUT_IN_SECONDS, TCS_PREF_IDLE_MONITOR_ACTIVE_ONLY, TCS_PREF_STATS_HIDE_EMPTY, TCS_PREF_STATS_SELECTED_VIEW, TCS_PREF_STATS_CUSTOM_START_DATE, TCS_PREF_STATS_CUSTOM_END_DATE, TCS_PREF_STATS_TIMER_START_DATE, TCS_PREF_STATS_TIMER_END_DATE, TCS_PREF_STATUS_BAR_SIZE, TCS_PREF_EXTERNAL_REQUEST_TIMEOUT, nil}

#define TCS_HOTKEY_CAPTURE_FIELD_HEIGHT 22.0

#define TCS_BUTTON_REPEAT_DELAY 0.5
#define TCS_BUTTON_REPEAT_INTERVAL .05

// Fonts
#define TCS_FONT      @"HelveticaNeue"
#define TCS_BOLD_FONT @"HelveticaNeue-Bold"
#define TCS_MEDIUM_FONT @"HelveticaNeue-Medium"

#define TCS_FONT_SIZE_SMALL 10.0f
#define TCS_FONT_SIZE 12.0f
#define TCS_FONT_SIZE_TITLE 16.0f

// Colors

#define TCS_TEXTCOLOR_R (51.0f/256.0f)
#define TCS_TEXTCOLOR_G (51.0f/256.0f)
#define TCS_TEXTCOLOR_B (51.0f/256.0f)

#define TCS_TEXTCOLOR_LIGHT_R (255.0f/256.0f)
#define TCS_TEXTCOLOR_LIGHT_G (255.0f/256.0f)
#define TCS_TEXTCOLOR_LIGHT_B (255.0f/256.0f)

#import <QuartzCore/QuartzCore.h>

#if TARGET_OS_IPHONE

#define TCS_TEXTCOLOR [UIColor colorWithCalibratedRed:TCS_TEXTCOLOR_R green:TCS_TEXTCOLOR_G blue:TCS_TEXTCOLOR_B alpha:1.0f]
#define TCS_TEXTCOLOR_LIGHT [UIColor colorWithCalibratedRed:TCS_TEXTCOLOR_LIGHT_R green:TCS_TEXTCOLOR_LIGHT_G blue:TCS_TEXTCOLOR_LIGHT_B alpha:1.0f]

#define TCS_PREF_FLIPPED_UI @"flippedUI"
#define TCS_PREF_ACTIVE_TIMER_FIRE_DELAY @"activeTimerLocalNotificationFireDuration"
#define TCS_PREF_USE_RELATIVE_DATE_RANGES @"useHumanReadableDateRanges"
#define TCS_PREF_AUTO_SCROLL_TO_CURRENT_TIME @"autoScrollToCurrentTime"
#define TCS_PREF_CALENDAR_ALL_SELECTED @"calendarAllProjectsSelected"
#define TCS_PREF_SNAP_TO_TIMER_BOUNDARY @"snapToTimerBoundary"
#define TCS_PREF_TIMER_EDIT_TAP_HOLD_ACTION @"timerEditTapHoldAction"
#define TCS_PREF_SELECTED_SECTION @"selectedSection"

#else

//#import "TCUtilities.h"

#define TCS_LION_10_7_2_VERSION 1138.230000
#define TCS_LION_10_7_0_VERSION 1138

#define TCS_TEXTCOLOR [NSColor colorWithCalibratedRed:TCS_TEXTCOLOR_R green:TCS_TEXTCOLOR_G blue:TCS_TEXTCOLOR_B alpha:1.0f]
#define TCS_TEXTCOLOR_LIGHT [NSColor colorWithCalibratedRed:TCS_TEXTCOLOR_LIGHT_R green:TCS_TEXTCOLOR_LIGHT_G blue:TCS_TEXTCOLOR_LIGHT_B alpha:1.0f]

#define TCS_EASE_IN ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn])
#define TCS_EASE_OUT ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut])
#define TCS_EASE_INOUT ([CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut])

//#define TCS_ANIMATING ( ([[NSUserDefaults standardUserDefaults] boolForKey:TCS_PREF_ANIMATE_WINDOWS]) && ([[TCUtilities sharedInstance] isOSVersionGreaterThanOrEqualTo:TCS_LION_10_7_0_VERSION] == NO))
#define TCS_ANIMATING ([[NSUserDefaults standardUserDefaults] boolForKey:TCS_PREF_ANIMATE_WINDOWS])
#endif

// animations

#define TCS_WINDOW_ANIMATION_DURATION 0.25f
#define TCS_WINDOW_DEBUG_ANIMATION_DURATION 5.0f


#endif
