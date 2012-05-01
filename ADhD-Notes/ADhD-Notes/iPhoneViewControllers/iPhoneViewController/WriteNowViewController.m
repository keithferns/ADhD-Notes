//
//  WriteNowViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ADhD_NotesAppDelegate.h"
#import "WriteNowViewController.h"
#import "CustomToolBar.h"
#import "CustomTextView.h"
#import "Constants.h"
#import "NewItemOrEvent.h"
#import "SchedulerViewController.h"
#import "ArchiveViewController.h"
#import "NSDate+TKCategory.h"



@interface WriteNowViewController ()


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic,retain) UIView *topView, *bottomView; 
@property (nonatomic, retain) CustomTextView *textView;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) TKCalendarMonthView *calendarView;
@property (nonatomic, retain) NewItemOrEvent *theItem;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain)  UITableView *tableView;

@end

@implementation WriteNowViewController

@synthesize textView, topView, bottomView, toolbar, actionsPopover, textField, tableView;
@synthesize theItem;
@synthesize managedObjectContext, calendarView;
@synthesize segmentedControl;
@synthesize listArray;


- (void)viewDidLoad{
    [super viewDidLoad];    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    
    NSLog(@"Today's date is %@", [formatter stringFromDate:[NSDate date]]);
     
    
    NSLog(@"Today's date is %@", [formatter dateFromString:@"20120430"]);


    
    
    /*-- Point current instance of the MOC to the main managedObjectContext --*/
	if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"WriteNow VIEWCONTROLLER: After managedObjectContext: %@",  managedObjectContext);
	}        
    
    //Navigation Bar SetUp
    //self.navigationController.navigationBar.topItem.title = @"Write Now";  
    NSArray *items = [NSArray arrayWithObjects:@"Note", @"List", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setWidth:90 forSegmentAtIndex:0];
    [segmentedControl setWidth:90 forSegmentAtIndex:1];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self
                         action:@selector(toggleNoteListView)
               forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
    
    //Init and add the top and bottom Views. These views will be used to animate the transitions of textView and the table and calendar Views. 
    if (bottomView.superview == nil && bottomView == nil) {
        bottomView = [[UIView alloc] initWithFrame:kBottomViewRect];
        bottomView.backgroundColor = [UIColor blackColor];
    }
    if (topView.superview == nil && topView == nil) {
        topView = [[UIView alloc] initWithFrame:kTopViewRect];
        topView.backgroundColor = [UIColor blackColor];
    }    
    //View Heirarchy: topView - bottomview
    [self.view addSubview:topView];
    [self.view addSubview:bottomView];

    //Initialize the toolbar. disable 'save' and 'send' buttons.
    if (toolbar == nil) {
        toolbar = [[CustomToolBar alloc] init];
        [toolbar.firstButton setTarget:self];
        [toolbar.secondButton setTarget:self];
        [toolbar.thirdButton setTarget:self];
        [toolbar.fourthButton setTarget:self];
        [toolbar.fifthButton setTarget:self];
    }
    
    //Initialize and add the textView. the TV is a basic part of initial view.     
    if (textView.superview == nil) {
        if (textView == nil){
            textView = [[CustomTextView alloc] initWithFrame:kTextViewRect];
        }
        [self.topView addSubview:textView];
        textView.delegate = self;    
        textView.inputAccessoryView = toolbar;
    }    
    if (textField == nil) {
        textField = [[UITextField alloc] initWithFrame: CGRectMake (5,0,310,30)];
        
        textField.textColor = [UIColor whiteColor];
        UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
        [textField.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        textField.layer.cornerRadius = 5.0;
        
        [textField setFont:[UIFont systemFontOfSize:18]];
        textField.layer.borderWidth = 2.0;
        textField.layer.borderColor = [UIColor darkGrayColor].CGColor;      
        textField.inputAccessoryView = toolbar;
        [textField setDelegate:self];
        [textField setReturnKeyType:UIReturnKeyDone];
        //[textField addTarget:self action:@selector(addToList) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        
        tableView = [[UITableView alloc] initWithFrame:CGRectMake (5,35,310,topView.frame.size.height-30)];
        tableView.rowHeight = 30.0;
        tableView.backgroundColor = [UIColor blackColor];
        tableView.separatorColor = [UIColor whiteColor];
        tableView.delegate = self;
        tableView.dataSource = self;
    }
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [self.navigationController hidesBottomBarWhenPushed];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
}

#pragma mark - Nav Bar Actions

- (void) toggleNoteListView {
    
    NSLog(@"WriteNowViewController:toggleNoteListView -> segmentedControl Segment %d touched", segmentedControl.selectedSegmentIndex);
    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [textField removeFromSuperview];
            NSLog (@"Adding TextView");

            if (textView.superview == nil){
                [topView addSubview:textView];
            }
            
            break;
        case 1:
            [textView removeFromSuperview];
            NSLog (@"Adding TextField");
            if (listArray == nil){
                listArray = [[NSMutableArray alloc] init];
            }
            if (textField.superview == nil) {
                [topView addSubview:textField];
                [topView addSubview: tableView];
            }
            break;
    }
}

#pragma mark - TextField Delegate Actions

-(BOOL) textFieldShouldReturn:(UITextField*) textField {

    NSLog(@"ADDING TO LIST");
    if (![self.textField.text isEqualToString:@""]){
    [listArray addObject:self.textField.text];
    }
    self.textField.text = nil;

    NSLog (@"The List contains %d lines", [listArray count]);
    NSLog (@"The List contains %@", listArray);
    
    [self.tableView reloadData];
    return YES;
}

- (void) textFieldDidBeginEditing: (UITextField *) textField{
    
    if (self.navigationItem.leftBarButtonItem == nil) {
            self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
            self.navigationItem.rightBarButtonItem.action = @selector(saveItem);
            self.navigationItem.rightBarButtonItem.target =self;
            
            self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
            self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
            self.navigationItem.leftBarButtonItem.target = self;    
    }
}


#pragma mark - tableView Delegate and Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [listArray count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger temp = [listArray count] - indexPath.row - 1;
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];

    if (cell==nil){
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [listArray objectAtIndex: temp];
    
    return cell;
}

#pragma mark - Responding to keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; // Get the origin of the keyboard when it's displayed.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];//??
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];    //Check the height of the topView. If height is at minimum value, then grow
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:animationDuration];
    
    
    //move bottomView below toolbar.
    CGRect frame = bottomView.frame;
    frame.origin.y = keyboardTop + self.toolbar.frame.size.height;
    self.bottomView.frame = frame;
 
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
 
    //Raise the bottomView
    CGRect frame = self.bottomView.frame;
    frame.origin.y = kBottomViewRect.origin.y;
    self.bottomView.frame = frame;
 
    [UIView commitAnimations];
}

#pragma mark - ToolBar Actions


- (void) dismissKeyboard { 
    
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
    }
    if ([textView isFirstResponder]){
        [textView resignFirstResponder];       
    }
    if (![textView hasText]) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    [self.textView setUserInteractionEnabled:YES];
    
    //TEXTFIELD
    if ([textField isFirstResponder]){
        [textField resignFirstResponder];
    }
}

- (void) presentScheduler: (id) sender {
    [actionsPopover dismissPopoverAnimated:YES];
    
    if (theItem == nil) {
        NSLog(@"WriteNowViewController:presentScheduler - Creating theItem");
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
        [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
        theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    }
    
    switch ([sender tag]) {
        case 0:
            theItem.type = [NSNumber numberWithInt:2];
            break;
        case 1:
            theItem.type = [NSNumber numberWithInt:3];
            break;
        default:
            break;
    }
    
    SchedulerViewController *scheduleViewController = [[SchedulerViewController alloc] init];
    scheduleViewController.hidesBottomBarWhenPushed = YES;

    scheduleViewController.theItem = self.theItem;
    [self.navigationController pushViewController:scheduleViewController animated:YES];
    NSLog(@"WriteNowViewController -> Pushed SchedulerViewController");

}
     

- (void) presentArchiver: (id) sender {
    
    [actionsPopover dismissPopoverAnimated:YES];   
    
    if (theItem == nil) {//CASE: User entered text and touches one of the buttons
        [self saveItem];
    }
    
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.saving = YES;
    //archiveViewController.theItem = self.theItem;
    [self.navigationController pushViewController:archiveViewController animated:YES];
    NSLog(@"WriteNowViewController -> Pushed ArchiveViewController");

}


- (void) sendItem:(id)sender {
    [actionsPopover dismissPopoverAnimated:YES];
    return;
}

#pragma mark - Data Management


- (void) saveItem {
    
    [actionsPopover dismissPopoverAnimated:YES];
    
    if ([textView isFirstResponder]){
        if (![textView hasText]) {
            return;
        }
    }
    if ([self.textView hasText] && self.textView.superview !=nil){
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem =  [self.navigationController addEditButton];
        self.navigationItem.rightBarButtonItem.target = self;
    }
    
    if (theItem == nil) {
        NSLog(@"WriteNowViewController:saveItem - Creating theItem");
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
        [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
        theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    
    }
        
    if (theItem.type == nil){
        if (segmentedControl.selectedSegmentIndex == 0) {
            theItem.type = [NSNumber numberWithInt:0];
            NSLog(@"Item:SimpleNote");
            }
        else if (segmentedControl.selectedSegmentIndex == 1){
        theItem.type = [NSNumber numberWithInt:1];
            NSLog(@"Item:list");
            }
    }
    theItem.text = self.textView.text;


    theItem.text = self.textView.text;
    
    switch ([theItem.type intValue]) {
        case 0: 
            [theItem createNewSimpleNote];
            break;
        case 1: 
            [theItem createNewList];
            break;
        case 2:
            [theItem createNewAppointment];
            break;
        case 3:
            [theItem createNewToDo];
            break;
        default:
            break;
    }
    
        [theItem saveNewItem];
        
        //Change state of view
        self.textView.userInteractionEnabled = YES; 
        [self.textView setScrollsToTop:YES];
        [self.textView resignFirstResponder];
        return;
}
     
- (void) startNewItem:(id) sender{//Called by Left Nav ADD_ITEM Button.

    if (theItem == nil) {
        [self saveItem];
        }
    
    //clear the current instance of theItem
    self.theItem = nil;
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        self.textView.text = nil;
        [self.textView setEditable:YES];
        [self.textView becomeFirstResponder];
        }
    else if (segmentedControl.selectedSegmentIndex == 1){
        self.textField.text = nil;
        [self.textField becomeFirstResponder];
        [self.listArray removeAllObjects];
        [tableView reloadData];
    }
    
    //remove the nav Buttons
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    //disable save and send buttons
    toolbar.firstButton.enabled = NO;
    toolbar.fourthButton.enabled = NO;
}
    

#pragma mark - calendar actions


- (void) toggleCalendar:(id)sender {    
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
    }
    
    if ([textView isFirstResponder]) {
        //Check if textView is first responder. If it is, resign first responder and disable user interaction
        [textView resignFirstResponder];
        self.textView.userInteractionEnabled = NO;
    }
    
    if (calendarView == nil) {
        //Check if the calendar obect exists. If it is not in view, it should not exist. Initialize and slide into view from bottom.
        calendarView = 	[[TKCalendarMonthView alloc] init];        
        calendarView.delegate = self;
        calendarView.dataSource = self;
        [self.topView addSubview:calendarView];
        [calendarView reload];
        calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
        //calendarView.frame = CGRectMake(0, kScreenHeight, calendarView.frame.size.width, calendarView.frame.size.height);
        
        //Add Nav buttons to dismiss the calendar (left) and to add date selected from the calendar to a new event or an event that is in the process of being created. If the user taps the calendar button before inputting any text, create a new Event object and add the selected date. If there is already some text input, create a new Event object and add both the selected date and the text to the event object. 
        self.navigationItem.leftBarButtonItem = [self.navigationController addCancelButton];
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(toggleCalendar:);
        
        self.navigationItem.rightBarButtonItem = [self.navigationController addAddButton];
        self.navigationItem.rightBarButtonItem.target = self;
        self.navigationItem.rightBarButtonItem.action = @selector(addDateToCurrentEvent);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        CGRect frame = topView.frame;
        frame.size.height = calendarView.frame.size.height;
        self.topView.frame = frame;
        frame = bottomView.frame;
        frame.origin.y = topView.frame.origin.y + topView.frame.size.height;    
        self.bottomView.frame = frame;
        calendarView.frame = CGRectMake(0, 0, calendarView.frame.size.width, calendarView.frame.size.height);
        self.textView.frame = CGRectMake(0, -kTopViewRect.size.height, self.textView.frame.size.width, self.textView.frame.size.height);
        [UIView commitAnimations];
        NSDate *d = [NSDate date];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
    }
    else {
        NSLog(@"Dismissing Calendar");
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(finishedCalendarTransition)];
        if (textView.superview != nil) {
            //check to see if the textView is below the calendar view.
            CGRect frame = topView.frame;
            frame.size.height = kTopViewRect.size.height+35.0;
            self.topView.frame = frame;
            frame = textView.frame;
            frame.size.height = kTextViewRect.size.height+35.0;
            frame.origin.y  = 0;
            textView.frame = frame;
            frame = bottomView.frame;
            frame.origin.y = kBottomViewRect.origin.y+85;    
            self.bottomView.frame = frame;
        }
        /*
         else if (scheduleView.superview != nil){
         //check to see if the ScheduleView is below the calendar view
         CGRect frame = topView.frame;
         frame.size.height = kTopViewRect.size.height+35;
         self.topView.frame = frame;
         frame = bottomView.frame;
         frame.origin.y = kBottomViewRect.origin.y+85;
         self.bottomView.frame = frame;
         }
         */
        calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
        
        //calendarView.frame = CGRectMake(0, kScreenHeight, calendarView.frame.size.width, calendarView.frame.size.height);
        
        [UIView commitAnimations];
    }
}
- (void) finishedCalendarTransition{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:nil userInfo:nil]; 
    
    [calendarView removeFromSuperview];
    calendarView = nil;
    if (textView.superview !=nil) {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        [textView becomeFirstResponder];
        [textView setUserInteractionEnabled:YES];
    }/*
      
      
      else if (scheduleView.superview != nil){
      //Add Cancel Button to the Nav Bar. Set it to call method to toggle text/shedule view
      self.navigationItem.leftBarButtonItem = [self.navigationController addCancelButton];
      self.navigationItem.leftBarButtonItem.target = self;
      self.navigationItem.leftBarButtonItem.action = @selector(toggleTextAndScheduleView:);
      
      //Add Done Button to the Nav Bar. Set it to call method to save input and to return to editing
      self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
      self.navigationItem.rightBarButtonItem.target = self;
      self.navigationItem.rightBarButtonItem.action = @selector(toggleTextAndScheduleView:);
      
      
      //Call method to return control to the textfield that was editing when the calendar was called
      [scheduleView textFieldBecomeFirstResponder];
      }*/
}

#pragma mark - TextView Management - Delegate Methods

- (void) textViewDidBeginEditing:(UITextView *)textView {
    NSLog(@"TextView Did Begin Editing");
    if ([self.textView hasText]){
        self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem);
        self.navigationItem.rightBarButtonItem.target =self;
        
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
    }
}
- (void) textViewDidEndEditing:(UITextView *)textView{

    //Check if TV has text, if yes, change right nav button to EDIT.
    
    if ([self.textView hasText] && self.textView.superview !=nil){
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem =  [self.navigationController addEditButton];
        self.navigationItem.rightBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.target =self;
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    
    //textView has text so enable the Save and Send buttons
    //FIXME: this method is called and the loop condition is checked each time a character is changed.  
    if (self.navigationItem.rightBarButtonItem == nil && [self.textView hasText]) {
        self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem);
        self.navigationItem.rightBarButtonItem.target =self;
        
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
        if (toolbar.firstButton.enabled == NO && toolbar.fourthButton.enabled == NO && [self.textView hasText]) {
            toolbar.firstButton.enabled = YES;
            toolbar.fourthButton.enabled = YES;
        }    
    }
}

- (void) editTextView:(id) sender {
//Returns User to Editing the TextView
//enable editing the TV
[self.textView setEditable:YES];

//make the tv first responder - raise kb
if (![self.textView isFirstResponder]){
    [self.textView becomeFirstResponder];
}
//reset the right nav button.
self.navigationItem.rightBarButtonItem = nil;
self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
self.navigationItem.rightBarButtonItem.action = @selector(saveItem);
self.navigationItem.rightBarButtonItem.target = self;    
}




#pragma mark - Popover Management
- (void) presentActionsPopover:(id) sender{
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(0, 0, 100, 39);
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.textColor = [UIColor lightTextColor];
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.layer.borderWidth = 2;
    label1.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.frame = CGRectMake(0, 40, 100, 39);
    button1.backgroundColor = [UIColor darkGrayColor];
    button1.alpha = 0.8;
    [button1 setTitle:@"Event" forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button1.layer.cornerRadius = 6.0;
    button1.layer.borderWidth = 1.0;
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(0, 81, 100, 39);
    button2.backgroundColor = [UIColor darkGrayColor];
    button2.alpha = 0.8;
    [button2 setTitle:@"To Do" forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button2.layer.cornerRadius = 6.0;
    button2.layer.borderWidth = 1.0;
    UIViewController *viewCon = [[UIViewController alloc] init];
    viewCon.contentSizeForViewInPopover = CGSizeMake(100, 120);
    
    [viewCon.view addSubview:label1];
    [viewCon.view addSubview:button1];
    [viewCon.view addSubview:button2];
    
    if(!actionsPopover) {
        actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
        [actionsPopover setDelegate:(id)self];
    } 
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
    } else {
        switch ([sender tag]) {
                
            case 1:
                label1.text = @"Save To";
                button1.titleLabel.text = @"Folder";
                button2.titleLabel.text = @"Document";
                [button1 setTitle:@"Folder" forState:UIControlStateNormal];
                [button1 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                [button1 setTag:0];
                
                [button2 setTitle:@"Document" forState:UIControlStateNormal];
                [button2 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                [button2 setTag:1];
                [actionsPopover presentPopoverFromRect:CGRectMake(20, 192, 50, 40) inView:self.view
                              permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES name:@"Plan"];  
                break;
            case 2:
                label1.text = @"Create";
                button1.titleLabel.text = @"Appointment";
                button2.titleLabel.text = @"To Do";
                [button1 setTitle:@"Appointment" forState:UIControlStateNormal];
                [button1 addTarget:self action:@selector(presentScheduler:) forControlEvents:UIControlEventTouchUpInside];
                [button1 setTag:0];
                [button2 setTitle:@"To Do" forState:UIControlStateNormal];
                [button2 addTarget:self action:@selector(presentScheduler:) forControlEvents:UIControlEventTouchUpInside];
                [button2 setTag:1];
                
                [actionsPopover presentPopoverFromRect:CGRectMake(75, 192, 50, 40) inView:self.view
                              permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES name:@"Plan"];    
                break;
            case 3:
                break;        
            case 4:
                [label1 setText:@"Send as"];
                button1.titleLabel.text = @"Email";
                [button1 setTitle:@"Email" forState:UIControlStateNormal];
                [button1 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
                [button1 setTag:0];
                button2.titleLabel.text = @"Message";
                [button2 setTitle:@"Message" forState:UIControlStateNormal];
                [button2 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
                [button2 setTag:1];
                [actionsPopover presentPopoverFromRect:CGRectMake(192, 192, 50, 50) inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES name:@"Send"]; 
                break;
            default:
                break;
        }   
    }
     return;
}
- (void) cancelPopover:(id)sender {
    NSLog(@"CANCELLING POPOVER");
    return;
}
- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController {
    NSLog(@"Did dismiss");
    actionsPopover = nil;
}
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController {
    NSLog(@"Should dismiss");
    return YES;
}

#pragma mark - TKCalendarMonthViewDelegate methods
- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
	NSLog(@"calendarMonthView didSelectDate: %@", d);
    //ADD DATE TO CURRENT EVENT    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
}
- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d {
	NSLog(@"calendarMonthView monthDidChange");	
    
    CGRect frame = topView.frame;
    frame.size.height = calendarView.frame.size.height;
    topView.frame = frame;
    frame = bottomView.frame;
    frame.origin.y = topView.frame.origin.y + topView.frame.size.height;
    bottomView.frame = frame;
}


#pragma mark - TKCalendarMonthViewDataSource methods
//get dates with events
- (NSArray *)fetchDatesForTimedEvents{ 
    NSLog(@"Will get array of timed event objects from store");
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init]; 
    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]]; 
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"aDate" ascending:YES]; 
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]]; 
    
    //NSArray *events = [NSArray arrayWithObjects:@"1",@"2", nil];
    
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"aType == %@" argumentArray:events];
    //[request setPredicate:predicate];
    
    // Release the datesArray, if it already exists 
    NSError *anyError = nil; 
    NSArray *results = [managedObjectContext executeFetchRequest:request error:&anyError]; 
    if( !results ) 
    { NSLog(@"Error = %@", anyError);
        ///deal with error
    } 
    
    NSLog(@"Did get array of timed event objects from store");
    //kjf the array data contains Event objects. need to convert this to an array which has date objects 
    NSLog(@"Number of objects in results = %d", [results count]);
    NSMutableArray *data = [[NSMutableArray alloc]init];    
    NSTimeZone *myTimeZone = [NSTimeZone localTimeZone];    
    NSInteger timeZoneOffset = [myTimeZone secondsFromGMT];
    NSLog (@"Time Zone offset is %d", timeZoneOffset);
    
    //NSMutableArray *data = [NSMutableArray arrayWithCapacity:[results count]];
    for (int i=0; i<[results count]; i++) {
        
        if ([[results objectAtIndex:i] isKindOfClass:[Appointment class]]){
            Appointment *tempAppointment = [results objectAtIndex:i];
            [data addObject:tempAppointment.aDate];
            // [data addObject:[tempAppointment.aDate dateByAddingTimeInterval:timeZoneOffset]];
        } 
        else if ([[results objectAtIndex:i] isKindOfClass:[ToDo class]]){
            ToDo *tempToDo = [results objectAtIndex:i];
            [data addObject:[tempToDo.aDate dateByAddingTimeInterval:timeZoneOffset]];
        }
    }
    
    NSLog(@"Number of objects in data = %d", [data count]);
    
    NSLog(@"Contents of data array = %@", data);
    
    return data;
    
}


- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
	NSLog(@"calendarMonthView marksFromDate toDate");	
    
	NSArray *data = [NSArray arrayWithArray:[self fetchDatesForTimedEvents]];
    
	
	// Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
	NSMutableArray *marks = [NSMutableArray array];
	
	// Initialise calendar to current type and set the timezone to never have daylight saving
	NSCalendar *cal = [NSCalendar currentCalendar];
	//[cal setTimeZone:[NSTimeZone systemTimeZone]];
    
	// Construct DateComponents based on startDate so the iterating date can be created.
	// Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed 
	// with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first 
	// iterating date then times would go up and down based on daylight savings.
	NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit) fromDate:startDate];
	NSDate *d = [cal dateFromComponents:comp];
	
	// Init offset components to increment days in the loop by one each time
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:1];	
	
	// for each date between start date and end date check if they exist in the data array
	while (YES) {
		// Is the date beyond the last date? If so, exit the loop.
		// NSOrderedDescending = the left value is greater than the right
		if ([d compare:lastDate] == NSOrderedDescending) {
			break;
		}
		
		// If the date is in the data array, add it to the marks array, else don't
		//if ([data containsObject:[d description]]) {
		if ([data containsObject:d]) {
            
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
	
	NSLog(@"Number of marks is %d",[marks count]);
    NSLog(@"Array contains %@", marks);
	return [NSArray arrayWithArray:marks];
}
- (void) addDateToCurrentEvent{
    /* the navigation bar needs to be changed for the schedule view 
     Left button = Cancel. Returns the user to the editing page.
     
     Right Button = ADD item - when the calendar is pulled up.
     If the textview has text then, check if there is an appointment or task event linked. 
     If not, selecting a date and hitting the ADD button, creates an event  if it doesn't already exist 
     and adds the date.
     If there is no text in TV, then create note and event. 
     
     Alternately, have two different looking buttons which show depending on whether there is text or not. 
     
     */
    
    [self toggleCalendar:nil];
    return;
}


@end
