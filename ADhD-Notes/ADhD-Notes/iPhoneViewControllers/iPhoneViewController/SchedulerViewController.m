//  SchedulerViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

//FIXME: the Calendar Button is not connected

#import "SchedulerViewController.h"
#import "EventsTableViewController2.h"


@interface SchedulerViewController ()
@property (nonatomic, retain) EventsTableViewController2 *tableViewController;
@property (nonatomic, retain) UIView *alarmView, *tagView, *topView;
@property (nonatomic, retain) UITextField *dateField, *startTimeField, *endTimeField, *recurringField, *locationField, *dayField;
@property (nonatomic, retain) UITextField *alarm1Field, *alarm2Field,*alarm3Field;
@property (nonatomic, retain) UIDatePicker *datePicker,*timePicker;
@property (nonatomic, retain) NSNumber *editing;
@property (nonatomic, retain) UIPickerView *recurringPicker, *locationPicker, *alarmPicker, *dayPicker;
@property (nonatomic, retain) NSArray *recurringArray, *locationArray, *alarmArray, *dayArray;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, readwrite) BOOL saving;

@end

#define textFieldFont 14

@implementation SchedulerViewController

@synthesize toolbar, theItem, tableViewController, alarmView, tagView, topView, dateField, startTimeField, endTimeField, recurringField, locationField, dayField;
@synthesize alarm1Field, alarm2Field, alarm3Field, datePicker, timePicker;
@synthesize recurringPicker, alarmPicker, dayPicker, locationPicker, recurringArray, alarmArray, dayArray, locationArray, editing, saving;

#pragma mark - ViewManagement

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.saving = NO;
    /*
    self.navigationItem.leftBarButtonItem = [self.navigationController addCancelButton];
    self.navigationItem.leftBarButtonItem.target = self;
    self.navigationItem.leftBarButtonItem.action = @selector(cancelScheduling);
    */

    
    self.navigationItem.rightBarButtonItem =[self.navigationController addDoneButton];
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(saveSchedule)];
    
    if (toolbar == nil) {
        toolbar = [[CustomToolBar alloc] init];
        [toolbar.firstButton setTarget:self];
        [toolbar.secondButton setTarget:self];
        [toolbar.thirdButton setTarget:self];
        [toolbar.fourthButton setTarget:self];
        [toolbar.fifthButton setTarget:self];
    }
    [toolbar changeToSchedulingButtons];
    toolbar.fourthButton.enabled = YES;
    
    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    datePicker.datePickerMode = UIDatePickerModeDate;
    if (theItem.aDate != nil) {
        [datePicker setDate:theItem.aDate];
    } else {
        [datePicker setDate:[NSDate date]];
    }
    [datePicker setMinimumDate:[NSDate date]];
    [datePicker setMaximumDate:[NSDate dateWithTimeIntervalSinceNow:(2*60*60*24*365)]];
    datePicker.timeZone = [NSTimeZone systemTimeZone];
    [datePicker sizeToFit];
    datePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    [datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];  
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
    
    dateField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 150, 35)];
    dateField.borderStyle = UITextBorderStyleRoundedRect;
    dateField.text = [dateFormatter stringFromDate:[datePicker date] ];
    dateField.tag = 1;
    dateField.inputView = datePicker;
    [dateField setFont:[UIFont systemFontOfSize:textFieldFont]];
    dateField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [dateFormatter setDateFormat:@"h:mm a"];

    timePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    timePicker.datePickerMode = UIDatePickerModeTime;
    [timePicker setMinuteInterval:10];
    timePicker.timeZone = [NSTimeZone systemTimeZone];
    [timePicker sizeToFit];
    timePicker.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    if (theItem.startTime != nil) {
        timePicker.date = theItem.startTime;
    }else {
        timePicker.date = [dateFormatter dateFromString:@"12:00 PM"]; 
    }
    [timePicker addTarget:self action:@selector(timePickerChanged:) forControlEvents:UIControlEventValueChanged];        
    
    recurringPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [recurringPicker setDataSource:self];
    [recurringPicker setDelegate:self];
    recurringPicker.showsSelectionIndicator = YES;
    [recurringPicker setTag:1];
    
    locationPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [locationPicker setDataSource:self];
    [locationPicker setDelegate:self];
    locationPicker.showsSelectionIndicator = YES;
    [locationPicker setTag:2];
    
    dayPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [dayPicker setDataSource:self];
    [dayPicker setDelegate:self];
    dayPicker.showsSelectionIndicator = YES;
    [dayPicker setTag:4];
    
    recurringArray = [[NSArray alloc] initWithObjects:@"Never",@"Daily",@"Weekly", @"Fortnightly", @"Monthy", @"Annualy", nil];
    locationArray = [[NSArray alloc] initWithObjects:@"Home", @"Work", @"School", @"Gym", nil];
    dayArray = [[NSArray alloc] initWithObjects:@"Someday", @"Today", @"Tomorrow", @"Next Week", @"Next Month", nil];
        
    if ([theItem.type intValue] == 3) {
        dayField = [[UITextField alloc] initWithFrame:CGRectMake(5, 40, 150, 35)];
        dayField.borderStyle = UITextBorderStyleRoundedRect;
        dayField.tag = 2;
        dayField.placeholder = @"Due: Someday";
        dayField.inputView = dayPicker;
        [dayField setFont:[UIFont systemFontOfSize:textFieldFont]];
        dayField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    }
    topView = [[UIView alloc] initWithFrame:kTopViewRect];
    topView.backgroundColor = [UIColor blackColor]; 
    [self.view addSubview:topView];
        
    NSDate *temp = [timePicker date];
    if ([theItem.type intValue] == 2){
            startTimeField = [[UITextField alloc] initWithFrame:CGRectMake(5, 40, 75, 35)];
            startTimeField.borderStyle = UITextBorderStyleRoundedRect;
            startTimeField.text = [dateFormatter stringFromDate:temp];
            startTimeField.tag = 2;
            startTimeField.inputView = timePicker;
            [startTimeField setFont:[UIFont systemFontOfSize:textFieldFont]];
            startTimeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;                         
            if (theItem.endTime != nil){
                temp = theItem.endTime;
            }else {
                temp = [temp dateByAddingTimeInterval:60*60];
            }
            endTimeField = [[UITextField alloc] initWithFrame:CGRectMake(80, 40, 75, 35)];
            endTimeField.borderStyle = UITextBorderStyleRoundedRect;
            endTimeField.text = [dateFormatter stringFromDate:temp];
            endTimeField.tag = 3;
            endTimeField.inputView = timePicker;
            [endTimeField setFont:[UIFont systemFontOfSize:textFieldFont]];
            endTimeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
            locationField = [[UITextField alloc] initWithFrame:CGRectMake(5, 110, 150, 35)];
            locationField.borderStyle = UITextBorderStyleRoundedRect;
            locationField.placeholder = @"Place";
            locationField.tag = 5;
            [locationField setFont:[UIFont systemFontOfSize:textFieldFont]];
            locationField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            locationField.inputView = locationPicker;
        
            [topView addSubview:startTimeField];
            [topView addSubview:endTimeField];    
            [topView addSubview:locationField];
            startTimeField.delegate = self;
            endTimeField.delegate = self;
            locationField.delegate = self;
        
        }
    recurringField = [[UITextField alloc] initWithFrame:CGRectMake(5, 75, 150, 35)];
    recurringField.borderStyle = UITextBorderStyleRoundedRect;
    [topView addSubview:recurringField];
    recurringField.placeholder = @"Recurring:";
    recurringField.tag = 4;
    [recurringField setFont:[UIFont systemFontOfSize:textFieldFont]];
    recurringField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    recurringField.inputView = recurringPicker;
        
    [topView addSubview:dateField];
    [topView addSubview:dayField];

    if (tableViewController == nil) {
        tableViewController = [[EventsTableViewController2 alloc] initWithStyle:UITableViewStylePlain];
        tableViewController.calendarIsVisible = YES;
        tableViewController.tableView.frame = CGRectMake(160, 5, 155, 140);
        tableViewController.tableView.rowHeight = kCellHeight;       
        tableViewController.selectedDate = [[NSDate date] timelessDate];
    }
    [topView addSubview:tableViewController.tableView];
        
    dateField.delegate = self;
    dayField.delegate = self;
    recurringField.delegate = self;
    
    dateField.inputAccessoryView = self.toolbar;
    dayField.inputAccessoryView = self.toolbar;
    startTimeField.inputAccessoryView = self.toolbar;
    endTimeField.inputAccessoryView = self.toolbar;
    recurringField.inputAccessoryView = self.toolbar;
    locationField.inputAccessoryView = self.toolbar;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    tableViewController = nil;
    theItem = nil;
}

- (void)viewWillAppear:(BOOL)animated{

    [dateField becomeFirstResponder];    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!self.saving) {
        NSLog(@"Canceling Scheduling");
        theItem.type = nil;
    }
}

/*
- (void) cancelScheduling{
    NSLog(@"Canceling Scheduling");
    theItem.type = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) addReminderFields {
    if (alarmView.superview == nil) {
        if (tagView == nil) {
            alarmView = [[UIView alloc] initWithFrame:CGRectMake(155, topView.frame.size.height, kScreenWidth-155, topView.frame.size.height)];
        }
        [topView addSubview:alarmView];
        
        alarmPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
        [alarmPicker setDataSource:self];
        [alarmPicker setDelegate:self];
        alarmPicker.showsSelectionIndicator = YES;
        [alarmPicker setTag:3];
        
        alarmArray = [[NSArray alloc] initWithObjects:@"15 minutes before", @"30 minutes before", @"1 hour before", @"1 day before",@"2 Days Before", @"1 week before", nil];
        
        //Check if any of the alarmFields exist, if YES, then add the alarmFields
        if (alarm1Field == nil) {
            alarm1Field = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 155, 35)];
            alarm1Field.borderStyle = UITextBorderStyleRoundedRect;
            [alarmView addSubview:alarm1Field];
            alarm1Field.placeholder = @"Alarm 1:";
            alarm1Field.tag = 6;
            alarm1Field.inputView = alarmPicker;
            [alarm1Field setFont:[UIFont systemFontOfSize:textFieldFont]];
            alarm1Field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            alarm2Field = [[UITextField alloc] initWithFrame:CGRectMake(0, 40, 155, 35)];
            alarm2Field.borderStyle = UITextBorderStyleRoundedRect;
            [alarmView addSubview:alarm2Field];
            alarm2Field.placeholder = @"Alarm 2:";
            alarm2Field.tag = 7;
            alarm2Field.inputView = alarmPicker;
            [alarm2Field setFont:[UIFont systemFontOfSize:textFieldFont]];
            alarm2Field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            
            alarm3Field = [[UITextField alloc] initWithFrame:CGRectMake(0, 75, 155, 35)];
            alarm3Field.borderStyle = UITextBorderStyleRoundedRect;
            [alarmView addSubview:alarm3Field];
            alarm3Field.placeholder = @"Alarm 3:";
            alarm3Field.tag = 8;
            alarm3Field.inputView = alarmPicker;
            [alarm3Field setFont:[UIFont systemFontOfSize:textFieldFont]];
            alarm3Field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
             
            alarm1Field.delegate = self;
            alarm2Field.delegate = self;
            alarm3Field.delegate = self;

            alarm1Field.inputAccessoryView = self.toolbar;
            alarm2Field.inputAccessoryView = self.toolbar;
            alarm3Field.inputAccessoryView = self.toolbar;
        }
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishedAlarmTransition)];
    
    CGRect frame = alarmView.frame;
    frame.origin.y = 0;
    alarmView.frame = frame;
    if (tableViewController.tableView.superview != nil){
        frame = tableViewController.tableView.frame;
        frame.origin.y = - tableViewController.tableView.frame.size.height;
        tableViewController.tableView.frame = frame;
    }

    [UIView commitAnimations];
    
    UISlider *proritySlider = [[UISlider alloc] initWithFrame:CGRectMake(5, 110, 300, 35)];
    [topView addSubview:proritySlider];
    
}

- (void) finishedAlarmTransition {
    [tableViewController.tableView removeFromSuperview];
}


#pragma Mark - Dates and Times

- (void) saveSchedule {
    self.saving = YES;
    theItem.recurring  = recurringField.text;
    
    if (alarm2Field.text != nil) {
        [theItem createNewStringFromText:self.alarm1Field.text withType:2];
    } else if (alarm1Field.text != nil){
        [theItem createNewStringFromText:self.alarm2Field.text withType:2];
    }
    [theItem saveSchedule];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EventCreatedNotification" object:nil];
    
    //Programmatically return to parentViewController//
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TextField Delegate and Navigation 

- (void) textFieldResignFirstResponder{
    switch ([editing intValue]) {
        case 1:
            [self.dateField resignFirstResponder];
            break;
        case 2:
            [self.startTimeField resignFirstResponder];
            break;
        case 3:
            [self.endTimeField resignFirstResponder];
            break;
        case 4:
            [self.recurringField resignFirstResponder];
            break;
        case 5:
            [self.locationField resignFirstResponder];
            break;
        case 6:
            [self.alarm1Field resignFirstResponder];
            break;
        case 7:
            [self.alarm2Field resignFirstResponder];
            break;
        case 8:
            [self.alarm3Field resignFirstResponder];
            break;
  
        default:
            break;
    }    
}

- (void) textFieldBecomeFirstResponder{
    
    switch ([editing intValue]) {
        case 1:
            [self.dateField becomeFirstResponder];
            break;
        case 2:
            [self.startTimeField becomeFirstResponder];
            break;
        case 3:
            [self.endTimeField becomeFirstResponder];
            break;
        case 4:
            [self.recurringField becomeFirstResponder];
            break;
        case 5:
            [self.locationField becomeFirstResponder];
            break;
        case 6:
            [self.alarm1Field becomeFirstResponder];
            break;
        case 7:
            [self.alarm2Field becomeFirstResponder];
            break;
        case 8:
            [self.alarm3Field becomeFirstResponder];
            break;

        default:
            break;
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField{
    //
}

- (void) textFieldDidBeginEditing:(UITextField *)textField{
    switch ([textField tag]) {
        case 1:
            self.editing = [NSNumber numberWithInt:1];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = NO;
            break;
        case 2:
            self.editing = [NSNumber numberWithInt:2];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            break;
        case 3:
            self.editing = [NSNumber numberWithInt:3];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            break;
        case 4:
            self.editing = [NSNumber numberWithInt:4];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            break;
        case 5:
            self.editing = [NSNumber numberWithInt:5];
            toolbar.secondButton.enabled = YES;
            if (self.alarm1Field.superview == nil) {
                toolbar.firstButton.enabled = NO;
            }
            else {
                toolbar.secondButton.enabled = YES;
            }
            break;
        case 6:
            self.editing = [NSNumber numberWithInt:6];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            break;
        case 7:
            self.editing = [NSNumber numberWithInt:7];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            break;
        case 8:
            self.editing = [NSNumber numberWithInt:8];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = NO;
            break;
 
        default:
            break;
    }
}


#pragma mark - Date & Time Picker Methods

- (void) datePickerChanged:(id)sender{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
    
    self.dateField.text = [dateFormatter stringFromDate:[datePicker date]];
    theItem.aDate = [datePicker date];
    
    NSDate *selectedDate = [[datePicker date] timelessDate];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:selectedDate userInfo:nil]; 
}

- (void) timePickerChanged:(id) sender{
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"h:mm a"];
    if ([editing intValue] == 2) {
        self.startTimeField.text = [timeFormatter stringFromDate:[timePicker date]];
        theItem.startTime = [timePicker date];
    }
    else if ([editing intValue] == 3){
        self.endTimeField.text = [timeFormatter stringFromDate:[timePicker date]];
        theItem.endTime  = [timePicker date];
    }
}

#pragma mark - PickerView DataSource and Delgate Methods

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{  
    
    switch ([pickerView tag]) {
        case 1:
            //
            self.recurringField.text = [recurringArray objectAtIndex:row];
            break;
        case 2:
            self.locationField.text = [locationArray objectAtIndex:row];
            break;
        case 3:
            switch ([editing intValue]) {
                case 6:
                    self.alarm1Field.text = [alarmArray objectAtIndex:row];
                    break;
                case 7:
                    self.alarm2Field.text = [alarmArray objectAtIndex:row];
                    break;
                case 8:
                    self.alarm3Field.text = [alarmArray objectAtIndex:row];
                    break;
              
                default:
                    break;
            }
            break;
        case 4:
            self.dayField.text = [dayArray objectAtIndex:row];
            break;
        default:
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // tell the picker how many rows are available for a given component
    NSInteger numberofrows;
    switch ([pickerView tag]) {
        case 1:
            numberofrows =  [recurringArray count];
            break;
        case 2:
            numberofrows =  [locationArray count];
            break;
        case 3:
            numberofrows =  [alarmArray count];
            break;
        case 4:
            numberofrows = [dayArray count];
            break;
     
        default:
            break;
    }
    return numberofrows;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    // tell the picker how many components it will have
    return 1;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // tell the picker the title for a given component
    NSString *titleforrow = [[NSString alloc] init];
    switch ([pickerView tag]) {
        case 1:
            titleforrow =  [recurringArray objectAtIndex:row];
            break;
        case 2:
            titleforrow =  [locationArray objectAtIndex:row];
            break;
        case 3:
            titleforrow =  [alarmArray objectAtIndex:row];
            break;
        case 4:
            titleforrow = [dayArray objectAtIndex:row];
        default:
            break;
    }
    return titleforrow;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    // tell the picker the width of each row for a given component
    int sectionWidth = 300;    
    return sectionWidth;
}

#pragma mark - ToolBar Actions


- (void) moveToPreviousField {
    //Check which textField is first responder. Move to previous textField. 
    [self textFieldResignFirstResponder];
    
    switch ([self.editing intValue]) {
        case 2:
            self.editing = [NSNumber numberWithInt:1];
            break;
        case 3:
            self.editing = [NSNumber numberWithInt:2];
            break;
        case 4:
            self.editing = [NSNumber numberWithInt:3];
            break;
        case 5:
            self.editing = [NSNumber numberWithInt:4];
            break;
        case 6:
            self.editing = [NSNumber numberWithInt:5];
            break;
        case 7:
            self.editing = [NSNumber numberWithInt:6];
            break;
        case 8:
            self.editing = [NSNumber numberWithInt:7];
            break;
        case 9:
            self.editing = [NSNumber numberWithInt:8];
            break;
        case 10:
            self.editing = [NSNumber numberWithInt:5];
            break;
        case 11:
            self.editing = [NSNumber numberWithInt:10];
            break;
        case 12:
            self.editing = [NSNumber numberWithInt:11];
        default:
            break;
    }
    [self textFieldBecomeFirstResponder];
}

- (void) moveToNextField{
    //Check which textField is first responder. Move to next textField. 
    [self textFieldResignFirstResponder];
    
    switch ([self.editing intValue]) {
        case 1:
            self.editing = [NSNumber numberWithInt:2];
            break;
        case 2:
            self.editing = [NSNumber numberWithInt:3];
            break;
        case 3:
            self.editing = [NSNumber numberWithInt:4];
            break;
        case 4:
            self.editing = [NSNumber numberWithInt:5];
            break;
        case 5:
            if (self.alarmView.superview == nil) {
                self.editing = [NSNumber numberWithInt:10];
            }
            else if (self.tagView.superview == nil){
                self.editing = [NSNumber numberWithInt:6];
            }
            break;
        case 6:
            self.editing = [NSNumber numberWithInt:7];
            break;
        case 7:
            self.editing = [NSNumber numberWithInt:8];
            break;
        case 8:
            self.editing = [NSNumber numberWithInt:9];
            break;
        case 9:
            self.editing = [NSNumber numberWithInt:10];
            break;        
        case 10:
            self.editing = [NSNumber numberWithInt:11];
            break;        
        case 11:
            self.editing = [NSNumber numberWithInt:12];
            break;
        default:
            break;
    }
    [self textFieldBecomeFirstResponder];
}

@end
