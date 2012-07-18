//
//  SchedulerViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomToolBar.h"
#import "NewItemOrEvent.h"


@interface SchedulerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>{
}



@property (nonatomic, retain) NewItemOrEvent *theItem;

- (void) addReminderFields;
- (void) textFieldResignFirstResponder;
- (void) textFieldBecomeFirstResponder;
- (void) moveToPreviousField;
- (void) moveToNextField;


@end