//
//  CalendarViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TKCalendarMonthViewController.h"
#import "CalendarTableViewController.h"


@interface CalendarViewController : UIViewController <TKCalendarMonthViewDataSource, TKCalendarMonthViewDelegate, PopoverControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;


@property (nonatomic, retain) WEPopoverController *actionsPopover;

@property (nonatomic, retain) UISegmentedControl *segmentedControl;

@property (assign) BOOL frontViewIsVisible;

@property (nonatomic,retain) UIButton *flipIndicatorButton;
@property (readonly) UIImage *flipperImageForDateNavigationItem;
@property (readonly) UIImage *listImageForFlipperView;
@property (nonatomic, retain) UIView *flipperView;


@property (nonatomic, retain) TKCalendarMonthView *calendarView;
@property (nonatomic, retain) CalendarTableViewController *tableViewController;

@end
