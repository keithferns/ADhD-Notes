//
//  CustomPopoverView.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPopoverView : UIView


@property (nonatomic, retain) UIButton *button1, *button2, *button3, *button4;


- (void) addItemsView;
- (void)organizerView;

- (void) addItemsViewForCalendar;
- (void) organizerViewForCalendar;


- (void) toolbarPlanButton;
- (void) toolbarSaveButton;
- (void) toolbarSendButton;

@end
