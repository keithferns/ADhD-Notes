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

@property (nonatomic, retain) UIView *alarmView, *tagView, *topView;
@property (nonatomic, retain) UITextField *dateField, *startTimeField, *endTimeField, *recurringField, *locationField;
@property (nonatomic, retain) UITextField *alarm1Field, *alarm2Field,*alarm3Field, *alarm4Field;
@property (nonatomic, retain) UITextField *tag1Field, *tag2Field, *tag3Field;
@property (nonatomic, retain) UIButton *tagButton;
@property (nonatomic, retain) UIDatePicker *datePicker,*timePicker;
@property (nonatomic, retain) UITableView *tableView;;
@property (nonatomic, retain) NSNumber *isBeingEdited;
@property (nonatomic, retain) UIPickerView *recurringPicker, *locationPicker, *alarmPicker, *tagPicker;
@property (nonatomic, retain) NSArray *recurringArray, *locationArray, *alarmArray, *tagArray;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) NewItemOrEvent *theItem;


- (void) addReminderFields;
- (void) addTagFields;
- (void) textFieldResignFirstResponder;
- (void) textFieldBecomeFirstResponder;
- (void) moveToPreviousField;
- (void) moveToNextField;


@end