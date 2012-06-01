//  WriteNowViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "WriteNowViewController.h"

#import "ADhD_NotesAppDelegate.h"
#import "CustomToolBar.h"
#import "NewItemOrEvent.h"
#import "SchedulerViewController.h"
#import "CalendarViewController.h"
#import "ArchiveViewController.h"
#import "TodayTableViewController.h"

#import "ToDoDetailViewController.h"
#import "AppointmentDetailViewController.h"
#import "MemoDetailViewController.h"
#import "ListDetailViewController.h"

@interface WriteNowViewController ()

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) UIView *topView, *bottomView; 
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) TKCalendarMonthView *calendarView;
@property (nonatomic, retain) NewItemOrEvent *theItem;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSArray *listArray;
@property (nonatomic, retain) UITableView *listTableView;
@property (nonatomic, retain) TodayTableViewController *todayTableViewController;
@property (nonatomic, readwrite) BOOL saving;
@end

@implementation WriteNowViewController

@synthesize textView, topView, bottomView, toolbar, actionsPopover, textField;
@synthesize listTableView,todayTableViewController, theItem, managedObjectContext, calendarView, segmentedControl,listArray, saving;

#pragma mark - View Management

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewDidLoad{
    [super viewDidLoad];    
    self.saving = NO;
    self.navigationController.delegate = self;
    
    /*-- Point current instance of the MOC to the main managedObjectContext --*/
	if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"WriteNow VIEWCONTROLLER: After managedObjectContext: %@",  managedObjectContext);
	}        
    //Navigation Bar SetUp
    NSArray *items = [NSArray arrayWithObjects:@"Note", @"List", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setWidth:90 forSegmentAtIndex:0];
    [segmentedControl setWidth:90 forSegmentAtIndex:1];
    [segmentedControl setSelectedSegmentIndex:0];
    [segmentedControl addTarget:self action:@selector(toggleNoteListView)
               forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
    self.navigationController.navigationBar.topItem.title = @"Write Now";    

    //Init and add the top and bottom Views. These views will be used to animate the transitions of textView and the table and calendar Views. 
    if (bottomView.superview == nil && bottomView == nil) {
        bottomView = [[UIView alloc] initWithFrame:kBottomViewRect];
        bottomView.backgroundColor = [UIColor blackColor];
    }
    if (topView.superview == nil && topView == nil) {
        topView = [[UIView alloc] initWithFrame:kTopViewRect];
        //topView.backgroundColor = [UIColor blackColor];
        UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
        
        [topView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
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
    if (self.textView.superview == nil) {
        if (self.textView == nil){
            self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 150)];
        }
        [self.topView addSubview:textView];
        self.textView.delegate = self;    
        self.textView.inputAccessoryView = toolbar;
        self.textView.scrollEnabled = YES;
        self.textView.contentSize = CGSizeMake (320, 150);
        self.textView.textColor = [UIColor whiteColor];
        [self.textView setFont:[UIFont boldSystemFontOfSize:16]];
        UIImage *patternImage = [[UIImage imageNamed:@"lined_paper4.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        
        [self.textView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
    }    
    if (textField == nil) {
        textField = [[UITextField alloc] initWithFrame: CGRectMake (320,0,310,45)];
        textField.textColor = [UIColor whiteColor];
        UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
        [textField.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        textField.layer.cornerRadius = 5.0;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [textField setFont:[UIFont systemFontOfSize:18]];
        //textField.layer.borderWidth = 2.0;
        //textField.layer.borderColor = [UIColor darkGrayColor].CGColor;
        textField.borderStyle = UITextBorderStyleLine;
        textField.inputAccessoryView = toolbar;
        [textField setDelegate:self];
        textField.placeholder = @"tap 'return' to add item";
        [textField setReturnKeyType:UIReturnKeyDefault];
        textField.clearButtonMode = UITextFieldViewModeAlways;
        
        
        listTableView = [[UITableView alloc] initWithFrame:CGRectMake (320,50,310,topView.frame.size.height-50)];
        listTableView.rowHeight = 33.0;
        listTableView.tag = 1;
        listTableView.backgroundColor = [UIColor blackColor];
        listTableView.separatorColor = [UIColor blackColor];
        listTableView.delegate = self;
        listTableView.dataSource = self;
        
        todayTableViewController = [[TodayTableViewController alloc] init];
        [self.bottomView addSubview:todayTableViewController.tableView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartNewItemNotification:) name:@"StartNewItemNotification" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    //  [super viewWillAppear:NO];    
    [self.navigationController hidesBottomBarWhenPushed];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:UITableViewSelectionDidChangeNotification object:nil];    
}

- (void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UITableViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
}

#pragma mark - Nav Bar Actions

- (void) toggleNoteListView {    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
                {
            if (textView.superview == nil){
                
                [topView addSubview:textView];
            }
            
             [UIView beginAnimations:nil context:nil];
             [UIView setAnimationDelegate:self];
             [UIView setAnimationDuration:0.5];
             UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
            
             [topView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
                CGRect frame = textView.frame;
                frame.origin.x = 0.0;
                textView.frame = frame;
                textField.frame = CGRectMake (320,0,310,45);
                listTableView.frame = CGRectMake (320,50,310,topView.frame.size.height-50);

            [UIView commitAnimations];
            
             //[textField removeFromSuperview];
                }
            break;
        case 1:
            {
            if (listArray == nil){
                listArray = [[NSArray alloc] init];
            }
            if (textField.superview == nil) {
                [topView addSubview:textField];
                [textField becomeFirstResponder];
                [topView addSubview: listTableView];
            }
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.5];
            
            [topView.layer setBackgroundColor:[UIColor blackColor].CGColor];
            CGRect frame = textView.frame;
            frame.origin.x = -320.0;
            textView.frame = frame;
            textField.frame = CGRectMake (5,0,310,45);
            listTableView.frame = CGRectMake (5,50,310,topView.frame.size.height-50);
            
            [UIView commitAnimations];
            //[textView removeFromSuperview];
            }
            break;
    }
}

#pragma mark - TextField Delegate Actions

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    
    if (toolbar.firstButton.enabled == NO && toolbar.fourthButton.enabled == NO) {
        toolbar.firstButton.enabled = YES;
        toolbar.fourthButton.enabled = YES;
    }        
    if (theItem == nil) {
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
        [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
        theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    }

    if (![self.textField.text isEqualToString:@""]){
        
        [theItem createNewStringFromText:self.textField.text withType:1];
    }
    self.textField.text = nil;

    [listTableView reloadData];
    
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem);
        self.navigationItem.rightBarButtonItem.target =self;
        
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
    }
    return YES;
}

- (void) textFieldDidBeginEditing: (UITextField *) textField{
  //
}

#pragma mark - tableView Delegate and Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    int sections;
    if (tableView.tag == 1){
        sections = 1;
    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int rows;
    if (tableView.tag == 1) {
    rows =  [theItem.listArray count];
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger temp = [theItem.listArray count] - indexPath.row - 1;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (cell==nil){
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CellIdentifier"];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    Liststring *myString = [theItem.listArray objectAtIndex: temp];
    cell.textLabel.text = myString.aString;
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
        cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:33]];;        
        [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
        [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
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
}
     
- (void) presentArchiver: (id) sender {    
    [actionsPopover dismissPopoverAnimated:YES];   
    if (theItem == nil) {//CASE: User entered text and touches one of the buttons
        self.saving = YES;
        [self saveItem];
    }
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    //archiveViewController.managedObjectContext = addingContext;
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.saving = YES;
    archiveViewController.theItem = self.theItem;
    [self.navigationController pushViewController:archiveViewController animated:YES];
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
        NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
        [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
        theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    }
        
    if (theItem.type == nil){
        if (segmentedControl.selectedSegmentIndex == 0) {
            theItem.type = [NSNumber numberWithInt:0];
            //Change state of view
            self.textView.userInteractionEnabled = YES; 
            [self.textView setScrollsToTop:YES];
            [self.textView resignFirstResponder];            
            }
        else if (segmentedControl.selectedSegmentIndex == 1){
        theItem.type = [NSNumber numberWithInt:1];
            self.textField.userInteractionEnabled = YES;
            [self.textField resignFirstResponder];
            self.navigationItem.rightBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem =  [self.navigationController addEditButton];
            self.navigationItem.rightBarButtonItem.target = self;
            self.navigationItem.leftBarButtonItem.target =self;
            }
    }
    theItem.text = self.textView.text;
    
    switch ([theItem.type intValue]) {
        case 0: 
            {
            [theItem createNewSimpleNote];
                if (!saving) {
            MemoDetailViewController *detailViewController = [[MemoDetailViewController alloc] initWithStyle:UITableViewStylePlain];            
            detailViewController.theItem = self.theItem;
            detailViewController.saving = YES;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
                }
            }
            break;
        case 1: 
            {
            [theItem createNewList];
                if (!saving) {
            ListDetailViewController *detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];            
            detailViewController.theItem = self.theItem;
            detailViewController.saving = YES;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
                }
            }
            break;
        case 2:
            {
            [theItem createNewAppointment];
            AppointmentDetailViewController *detailViewController = [[AppointmentDetailViewController alloc] initWithStyle:UITableViewStylePlain];            
            detailViewController.theItem = self.theItem;
            detailViewController.saving = YES;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
            }
            break;
        case 3:
            {   
            [theItem createNewToDo];
            ToDoDetailViewController *detailViewController =[[ToDoDetailViewController alloc] initWithStyle:UITableViewStylePlain];            
            detailViewController.theItem = self.theItem;
            detailViewController.saving = YES;
            detailViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:detailViewController animated:YES];
            }
            break;
        default:
            break;
    }
        [theItem saveNewItem];
        return;
}

- (void) handleStartNewItemNotification: (NSNotification *) notification {
    NSDictionary *theDict = [notification userInfo];
    if ([self.textView hasText]) {
        self.saving = YES;
        [self startNewItem:nil];
    }
    [self.textView becomeFirstResponder];
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
    theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    theItem.aDate = [theDict objectForKey:@"theDate"];
    theItem.type = [theDict objectForKey:@"theType"];
}

- (void) startNewItem: (id) sender{
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
        listArray = nil;
        [listTableView reloadData];
    }
    //remove the nav Buttons
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    //disable save and send buttons
    toolbar.firstButton.enabled = NO;
    toolbar.fourthButton.enabled = NO;
}

#pragma mark - calendar actions

- (void) toggleCalendar:(id) sender{
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
    }
    CalendarViewController *calendarViewC = [[CalendarViewController alloc] init];
    calendarViewC.hidesBottomBarWhenPushed = YES;
    calendarViewC.pushed = YES;
    [self.navigationController pushViewController: calendarViewC animated:YES];
    NSDate *d = [NSDate date];    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
}

#pragma mark - TextView Management - Delegate Methods

- (void) textViewDidBeginEditing:(UITextView *)textView {
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
    [label1 setTextAlignment:UITextAlignmentCenter];
    
    UIButton *button1 = [[UIButton alloc] init];
    button1.frame = CGRectMake(0, 40, 100, 39);
    //button1.backgroundColor = [UIColor darkGrayColor];
    [button1 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    button1.alpha = 1.0;
    [button1 setTitle:@"Event" forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button1.layer.cornerRadius = 6.0;
    //button1.layer.borderWidth = 1.0;
    
    UIButton *button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(0, 81, 100, 39);
    //button2.backgroundColor = [UIColor darkGrayColor];
    button2.alpha = 1.0;
    [button2 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button2 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [button2 setTitle:@"To Do" forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button2.layer.cornerRadius = 6.0;
    //button2.layer.borderWidth = 1.0;
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

#pragma mark - Details

- (void) handleTableRowSelection:(NSNotification *) notification {
    NSLog(@"WriteNowViewController:handleTableRowSelection - notification received");
    
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
    //selectedItem.addingContext = addingContext;

    if ([[notification object] isKindOfClass:[Appointment class]]) {
        AppointmentDetailViewController *detailViewController = [[AppointmentDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        Appointment *selectedAppointment = [notification object];
        selectedItem.theAppointment = selectedAppointment;
        selectedItem.eventType = [NSNumber numberWithInt:2];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    } 
    
    else if ([[notification object] isKindOfClass:[ToDo class]]){
        ToDoDetailViewController *detailViewController = [[ToDoDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        ToDo *selectedToDo = [notification object];
        selectedItem.theToDo = selectedToDo;
        selectedItem.eventType = [NSNumber numberWithInt:3];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    }
    else if ([[notification object] isKindOfClass:[SimpleNote class]]){
        MemoDetailViewController *detailViewController = [[MemoDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        SimpleNote *selectedMemo = [notification object];
        selectedItem.theSimpleNote = selectedMemo;
        selectedItem.eventType = [NSNumber numberWithInt:0];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    }else if ([[notification object] isKindOfClass:[List class]]){
        ListDetailViewController *detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];              
        List *selectedList = [notification object];
        selectedItem.theList = selectedList;
        selectedItem.eventType = [NSNumber numberWithInt:1];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;

        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    }
}

@end

/*
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
 */
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
/*
 calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
 
 //calendarView.frame = CGRectMake(0, kScreenHeight, calendarView.frame.size.width, calendarView.frame.size.height);
 
 [UIView commitAnimations];
 }
 }
 */
/*
- (void) finishedCalendarTransition{
[[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:nil userInfo:nil]; 

[calendarView removeFromSuperview];
calendarView = nil;
if (textView.superview !=nil) {
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    [textView becomeFirstResponder];
    [textView setUserInteractionEnabled:YES];
}
 */
 /*
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
//}


