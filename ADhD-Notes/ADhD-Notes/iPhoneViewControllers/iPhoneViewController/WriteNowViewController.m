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
#import "MailComposerViewController.h"
#import "CustomPopoverView.h"
#import "ListViewAndTableViewController.h"
#import "NotesViewController.h"
#import "EventsTableViewController2.h"
#import "FilesTableViewController.h"
#import "CustomTopToolbarView.h"

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
@property (nonatomic, retain) UITableView *listTableView;
@property (nonatomic, retain) TodayTableViewController *todayTableViewController;
@property (nonatomic, retain) EventsTableViewController2 *listTableViewController;
@property (nonatomic, retain) FilesTableViewController *filesTableViewController;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic, retain) CustomTopToolbarView *topToolbarView;
@end

@implementation WriteNowViewController

@synthesize textView, topView, bottomView, toolbar, actionsPopover, textField;
@synthesize listTableView,todayTableViewController, theItem, managedObjectContext, calendarView, segmentedControl, saving;
@synthesize listTableViewController, filesTableViewController;
@synthesize topToolbarView;

#pragma mark - View Management

- (void)viewDidUnload {
    [super viewDidUnload];
    self.textView = nil;
    self.topView = nil;
    self.bottomView = nil;
    self.toolbar = nil;
    self.actionsPopover = nil;
    self.textField = nil;
    self.listTableView = nil;
    self.todayTableViewController = nil;
    self.theItem = nil;
    self.managedObjectContext = nil;
    self.calendarView = nil;
    self.segmentedControl = nil;
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
        self.textView.bounces = NO;
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
        listTableView.allowsSelection = NO;
        listTableView.delegate = self;
        listTableView.dataSource = self;
                
        todayTableViewController = [[TodayTableViewController alloc] init];
        [self.bottomView addSubview:todayTableViewController.tableView];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStartNewItemNotification:) name:@"StartNewItemNotification" object:nil];    
    
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.textView addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown:)];
    downSwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.textView addGestureRecognizer:downSwipe];
    
    if (!theItem) {
        [self createNewItem:nil];
    }
    
}

-(void)didSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Method: didSwipeLeft: called");
    if (self.textView.editable == YES && [self.textView hasText]) {
        self.textView.text = nil;
        //
        [self startNewItem:nil];
    }
}

-(void)didSwipeDown:(UISwipeGestureRecognizer *)recognizer {
    NSLog(@"Method: didSwipeDown: called");
    [self dismissKeyboard];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self.navigationController hidesBottomBarWhenPushed];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:UITableViewSelectionDidChangeNotification object:nil];    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListSelection:) name:@"ListSelectedNotification" object:nil];    

    
    [self.actionsPopover dismissPopoverAnimated:YES];
    self.actionsPopover = nil;
    self.navigationItem.backBarButtonItem = nil;
    self.saving = NO;    
}

- (void) viewDidAppear:(BOOL)animated{
    NSLog(@"WRITENOWVIEWCONTROLLER: viewWillAppear");

    [super viewDidAppear:animated];
    if (theItem.saved) {
        self.theItem = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
        self.textView.text = nil;
        [self toggleNoteListView];
    } else if (!theItem.saved && [theItem.type intValue] ==2){
        [self saveItem:nil];
        NSLog(@"theItem.aDate = %@, theItem.startTime = %@, theItem.endTime = %@", theItem.aDate, theItem.startTime, theItem.endTime);

    }    
}

- (void) viewWillDisappear:(BOOL)animated {
    NSLog(@"WRITENOWVIEWCONTROLLER: viewWillDisappear");
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UITableViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ListSelectedNotification" object:nil];
    
    [self.actionsPopover dismissPopoverAnimated:YES];
    self.actionsPopover = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - Nav Bar Actions

- (void) toggleNoteListView {    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:{
            if (textView.superview == nil){
                [topView addSubview:textView];
            }
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDidStopSelector:@selector(removeViews)];
            UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
            [topView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
            CGRect frame = textView.frame;
            frame.origin.x = 0.0;
            textView.frame = frame;
            textField.frame = CGRectMake (320,0,310,45);
            listTableView.frame = CGRectMake (320,50,310,topView.frame.size.height-50);
            
            [UIView commitAnimations];
            
            if (![textView hasText]) {
                self.navigationItem.leftBarButtonItem = nil;
                self.navigationItem.rightBarButtonItem = nil;
                }
                }
            break;
        case 1: {

            if (textField.superview == nil) {
                NSLog (@"adding textField and listTableView");

                [topView addSubview:textField];
                [textField becomeFirstResponder];
                [topView addSubview: listTableView];
                [self.listTableView reloadData];
            }            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDidStopSelector:@selector(removeViews)];

            [topView.layer setBackgroundColor:[UIColor blackColor].CGColor];
            CGRect frame = textView.frame;
            frame.origin.x = -320.0;
            textView.frame = frame;
            textField.frame = CGRectMake (5,0,310,45);
            listTableView.frame = CGRectMake (5,50,310,topView.frame.size.height-50);
            [UIView commitAnimations];
            }
            break;
    }
}

- (void) removeView {
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.listTableView removeFromSuperview];
            [self.textField removeFromSuperview];
            break;
        case 1:
            [self.textView removeFromSuperview];
            break;
        default:
            break;
    }
}

#pragma mark - TextField Delegate Actions

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    if (!self.listTableView) {
        listTableView = [[UITableView alloc] initWithFrame:CGRectMake (320,50,310,topView.frame.size.height-50)];
        listTableView.rowHeight = 33.0;
        listTableView.tag = 1;
        listTableView.backgroundColor = [UIColor blackColor];
        listTableView.separatorColor = [UIColor blackColor];
        listTableView.delegate = self;
        listTableView.dataSource = self;
        [self.topView addSubview:listTableView];
    }
    
    if (self.navigationItem.leftBarButtonItem == nil) {
        self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem:);
        self.navigationItem.rightBarButtonItem.target =self;
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
        self.navigationItem.leftBarButtonItem.tag = 0;
    }
    if (theItem == nil) {
        [self createNewItem:nil];
    }
        theItem.type = [NSNumber numberWithInt:1];
        if (theItem.listArray == nil) {
            theItem.listArray = [[NSArray alloc] init];
        }
   
    if (![self.textField.text isEqualToString:@""]){
        theItem.listArray = [theItem.listArray arrayByAddingObject:self.textField.text];
        NSLog (@"The list array count is %d", [theItem.listArray count]);
        }
    
    self.textField.text = nil;
    [listTableView reloadData];
    return YES;
}

- (void) textFieldDidBeginEditing: (UITextField *) textField{
    if (toolbar.secondButton.enabled == NO && toolbar.fourthButton.enabled == NO) {
        toolbar.secondButton.enabled = YES;
        toolbar.fourthButton.enabled = YES;
    }  
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
    NSString *myString = [theItem.listArray objectAtIndex: temp];
    cell.textLabel.text = myString;
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
    NSLog(@"Hiding Keyboard");
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
    NSLog(@"Dismissing Keyboard");
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

- (void) sendItem:(id)sender {
    NSLog(@"Sending  text");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    MailComposerViewController *sendViewController = [[MailComposerViewController alloc] init];
    if([sender tag] == 6){
        sendViewController.sendType = [NSNumber numberWithInt:1];
    } else if ([sender tag] == 7){
        sendViewController.sendType = [NSNumber numberWithInt:2];
    }
    sendViewController.theText = self.textView.text;
    [self.navigationController pushViewController: sendViewController animated:YES];
}

#pragma mark - Data Management

- (void) createNewItem: (id) sender {
        NSLog(@"WRITENOWVIEWCONTROLLER: createNewItem");
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];    
        [moc setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
        theItem = [[NewItemOrEvent alloc] init];
        theItem.addingContext = moc; 
        if (segmentedControl.selectedSegmentIndex == 0) {
            theItem.type = [NSNumber numberWithInt:0];
            if ([self.textView isFirstResponder] && ![self.textView hasText] ){
                return;
            }else{
                theItem.text = self.textView.text;
            }    
        }else if (segmentedControl.selectedSegmentIndex == 1){
            theItem.listArray = [[NSArray alloc] init];
            theItem.type = [NSNumber numberWithInt:1];
    } 
}

- (void) saveItem: (id) sender {
    NSLog (@"The Item Type is %d", [theItem.type intValue]);
    if (!theItem) {
        [self createNewItem:nil];
        }
    if (!saving) {
        switch ([theItem.type intValue]) {
            case 0:{
                theItem.text = self.textView.text;
                [theItem createNewSimpleNote];
                self.textView.text = nil;                
                NotesViewController *notesAppointmentsViewController = [[NotesViewController alloc] init];
                theItem.saved = YES;
                notesAppointmentsViewController.theItem = theItem;
                notesAppointmentsViewController.saving = NO;
                notesAppointmentsViewController.hidesBottomBarWhenPushed = YES;
                [self.textView resignFirstResponder];
                [self.navigationController pushViewController:notesAppointmentsViewController animated:YES]; 
                    }
                break;
            case 1:{
                if (!theItem || [self.textField hasText]) {
                    //CASE: user types in textbox, does not RETURN but calls up Archive popover and touches Folder or Document button.
                    [self createNewItem:nil];
                    if (![self.textField.text isEqualToString:@""]){
                    theItem.listArray = [theItem.listArray arrayByAddingObject:self.textField.text];
                    }       
                }
                [theItem createNewList];
                [theItem saveNewItem];
                ListViewAndTableViewController *listC = [[ListViewAndTableViewController alloc] init];
                theItem.saved = YES;
                listC.theItem = theItem;
                listC.saving = NO;
                listC.appending = NO;
                listC.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:listC animated:YES];    
                
                self.textField.userInteractionEnabled = YES;
                [self.textField resignFirstResponder];
                [self.textField removeFromSuperview];
                [self.listTableView removeFromSuperview];
                }
                break;
            case 2:{
                theItem.text = self.textView.text;
                [theItem createNewAppointment];
                
                NotesViewController *notesAppointmentsViewController = [[NotesViewController alloc] init];
                theItem.saved = YES;
                notesAppointmentsViewController.theItem = theItem;
                notesAppointmentsViewController.saving = NO;
                notesAppointmentsViewController.hidesBottomBarWhenPushed = YES;
                [self.textView resignFirstResponder];
                [self.navigationController pushViewController:notesAppointmentsViewController animated:YES]; 
                    }
                break;
            case 3:{
                [theItem createNewToDo];
                ListViewAndTableViewController *listC = [[ListViewAndTableViewController alloc] init];
                theItem.saved = YES;
                listC.theItem = theItem;
                listC.saving = NO;
                listC.appending = NO;
                listC.hidesBottomBarWhenPushed = YES;
                [self.textView resignFirstResponder];
                [self.navigationController pushViewController:listC animated:YES]; 
                    }
                break;
            default:
                break;
            }
        [theItem saveNewItem];
        theItem.saved = YES;
        
    }
}

- (void) createEvent: (id) sender {
    //called by toolbar popover Appointment or ToDo Buttons. 

    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    if (!theItem) {
        [self createNewItem:nil];
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

- (void) handleEventCreatedNotification:(NSNotification *) notification{
    sleep(1.0);
    
        theItem.text = self.textView.text;
        [theItem createNewAppointment];
        
        NotesViewController *notesAppointmentsViewController = [[NotesViewController alloc] init];
        theItem.saved = YES;
        notesAppointmentsViewController.theItem = theItem;
        notesAppointmentsViewController.saving = NO;
        notesAppointmentsViewController.hidesBottomBarWhenPushed = YES;
        [self.textView resignFirstResponder];
        [self.navigationController pushViewController:notesAppointmentsViewController animated:YES]; 
}

- (void) willSaveToFolderOrProject: (id) sender{
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    if (!theItem) { [self createNewItem:nil]; }
    if (segmentedControl.selectedSegmentIndex == 0) {
        theItem.text = self.textView.text;
    }else if (segmentedControl.selectedSegmentIndex == 1){
        if (!theItem || [self.textField hasText]) {
            //CASE: user types in textbox, does not RETURN but calls up Archive popover and touches Folder or Document button.
            [self createNewItem:nil];
            if (![self.textField.text isEqualToString:@""]){
                theItem.listArray = [theItem.listArray arrayByAddingObject:self.textField.text];
            }       
        }
    }
    if ([sender tag] == 4) {
        theItem.appendType = [NSNumber numberWithInt:4];        
    } else if ([sender tag] == 6){
        theItem.appendType = [NSNumber numberWithInt:6];
    }
    
    ArchiveViewController *archiveViewController= [[ArchiveViewController alloc] init];
    archiveViewController.theItem = self.theItem;
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.saving = YES;
    archiveViewController.appending = NO;
    [self.navigationController pushViewController:archiveViewController animated:YES];
}

#pragma mark - Append to List or Document

- (void) willAppendToListOrDocument: (id) sender{
    NSLog(@"WRITENOWVIEWCONTROLLER: willAppendToListOrDocument");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES]; }    
    [self dismissKeyboard];
    if (!theItem) { [self createNewItem:nil];}
    topToolbarView = [[CustomTopToolbarView alloc] init];
    [self.view addSubview:topToolbarView];
    [self.topToolbarView setAppendOrSave:@"search"];
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSaving:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem =nil;
    
    if ([theItem.appendType intValue] == 1 || [sender tag] == 1) {       
        NSLog(@"Appending to LIST");
    listTableViewController = [[EventsTableViewController2 alloc]init];
        if ([sender tag] == 1) {
            listTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+40, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        }else {
            listTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+40, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-40);
        }
        [listTableViewController.tableView setSeparatorColor:[UIColor blackColor]];
        [listTableViewController.tableView setSectionHeaderHeight:13];
        listTableViewController.tableView.rowHeight = kCellHeight;        
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetEventTypeNotification" object:num userInfo:nil];
        [self.view addSubview:listTableViewController.tableView];     
    }else if ([theItem.appendType intValue] == 5 || [sender tag] == 5){
        NSLog(@"Appending to DOC");
        filesTableViewController =  [[FilesTableViewController alloc] initWithStyle:UITableViewStylePlain];
        filesTableViewController.theItem = self.theItem;
        filesTableViewController.saving = YES;
        filesTableViewController.tableView.rowHeight = 50.0;
        filesTableViewController.tableView.frame = CGRectMake(kScreenHeight, kNavBarHeight+44,kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        filesTableViewController.tableView.tag = 13;
        filesTableViewController.managedObjectContext = theItem.addingContext;
        [self.view addSubview:filesTableViewController.tableView];
        [topToolbarView.searchBar setPlaceholder:@"Search for Document"];
        topToolbarView.searchBar.delegate = filesTableViewController;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    if ([theItem.appendType intValue] == 1 || [sender tag] == 1) {    
        listTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        NSLog(@"Moving TableView into View");
    }else if ([theItem.appendType intValue] == 5 || [sender tag] == 5){
        [[self.view viewWithTag:13] setFrame: CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    }
    [UIView commitAnimations];    
}



- (void) handleListSelection: (NSNotification *) notification{ 
    NSLog(@"WRITENOWVIEWCONTROLLER:handleListSelection -> ListSelectedNotification Received");    
    
    theItem.theList = [notification object];

    theItem.theList.editDate = [[NSDate date] timelessDate];
    theItem.saved = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseList:)]; 
    
}


- (void) cancelAppending:(id) sender{ 
    NSLog(@"WRITENOWVIEWCONTROLLER: cancelAppending");
    // Called by the Cancel Button over the ListsTableView (EventsTableViewController2)
    if (theItem.saved == NO) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.target = self;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDidStopSelector:@selector(removeViews)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    listTableViewController.tableView.frame=CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    
    [UIView commitAnimations];        
}


- (void) chooseList:(id)sender{
    // Called by the Done Button over the ListsTableView (EventsTableViewController2)    
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            [self.textView resignFirstResponder];
            theItem.addingContext = theItem.theList.managedObjectContext;
            [theItem createNewListString:theItem.text];
            theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];            
            break;
        case 1:
            {
            [self.textField resignFirstResponder]; 

            if (![textField.text isEqualToString:@""]){
                if (!theItem.listArray){
                //CASE: user types in textbox, does not RETURN but calls up Archive popover and touches Folder or Document button.
                    theItem.listArray = [[NSArray alloc] init];
                }  
                //add the textField.text to the listArray
                theItem.listArray = [theItem.listArray arrayByAddingObject:self.textField.text];
            }
            theItem.addingContext = theItem.theList.managedObjectContext;
            NSArray *tempArray = [[NSArray alloc] init];
            for (int i = 0; i<[theItem.listArray count]; i++) {
                [theItem createNewListString:[theItem.listArray objectAtIndex:i]];
                theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
                tempArray = [tempArray arrayByAddingObject:theItem.theString];
                    //theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:theItem.theString];
                }
                tempArray = [tempArray arrayByAddingObjectsFromArray:[theItem.theList.aStrings allObjects]];
            }
            break;
        default:
            break;
        }    
        switch ([sender tag]) {
            case 1:
            {theItem.appendType = [NSNumber numberWithInt:1];   
                ListViewAndTableViewController *listC = [[ListViewAndTableViewController alloc] init];
                listC.theItem = self.theItem;
                listC.saving = YES;
                listC.appending = YES;
                listC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:listC animated:YES];}
                
                break;
            case 5:
            {theItem.appendType = [NSNumber numberWithInt:5];
                ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init]; 
                archiveViewController.theItem = self.theItem;
                NSLog(@"Appending: theItem.text is %@", self.theItem.text);
                archiveViewController.saving = YES;
                archiveViewController.appending = YES;
                archiveViewController.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:archiveViewController animated:YES];}                
                break;    
            default:
                break;
        }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAppended)];    
}


#pragma  mark - START NEW ITEM


- (void) handleStartNewItemNotification: (NSNotification *) notification {
    if (segmentedControl.selectedSegmentIndex == 0) {
            [self startNewItem:nil];
            [self.textView resignFirstResponder];
            self.textView.text = nil;
            [self.textView setEditable:YES];
    } else if (segmentedControl.selectedSegmentIndex == 1){
        [self startNewItem:nil];
        textField.text = nil;
        [self.textField resignFirstResponder];
    } 
    
    CGRect frame = self.bottomView.frame;
    frame.origin.y = kBottomViewRect.origin.y;
    self.bottomView.frame = frame;

    /*
    NSDictionary *theDict = [notification userInfo];
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    theItem = [[NewItemOrEvent alloc] init];//Create new instance of delegate class.
    theItem.addingContext = addingContext; // pass adding MOC to the delegate instance.
    theItem.aDate = [theDict objectForKey:@"theDate"];
    theItem.type = [theDict objectForKey:@"theType"];
     */
}

- (void) startNewItem: (id) sender{
       if (theItem == nil && sender != nil) {
           [self saveItem:nil];
        }
        //clear the current instance of theItem
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.textView.text = nil;
            [self.textView setEditable:YES];
        }
        else if (segmentedControl.selectedSegmentIndex == 1){
            self.textField.text =nil;
            if (listTableView == nil){
                listTableView = [[UITableView alloc] initWithFrame:CGRectMake (5,50,310,topView.frame.size.height-50)];
                listTableView.rowHeight = 33.0;
                listTableView.tag = 1;
                listTableView.backgroundColor = [UIColor blackColor];
                listTableView.separatorColor = [UIColor blackColor];
                listTableView.delegate = self;
                listTableView.dataSource = self;
                [topView addSubview:listTableView];
            }
            if ([sender tag] == 0){
            [self.textField becomeFirstResponder];
            }else{
                [self.textField resignFirstResponder];
            }
    }
    self.theItem = nil;
    //remove the nav Buttons
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    //disable save and send buttons
    toolbar.secondButton.enabled = NO;
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
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem:);
        self.navigationItem.rightBarButtonItem.target =self;
        
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
        self.navigationItem.leftBarButtonItem.tag = 0;
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView{
    //Check if TV has text, if yes, change right nav button to EDIT.
    /*
    if ([self.textView hasText] && self.textView.superview !=nil){
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem =  [self.navigationController addEditButton];
        self.navigationItem.rightBarButtonItem.target = self;
        
        self.navigationItem.leftBarButtonItem.target =self;
    }
     */
}

- (void) textViewDidChange:(UITextView *)textView {
    
    //textView has text so enable the Save and Send buttons
    //FIXME: this method is called and the loop condition is checked each time a character is changed.  
    if (self.navigationItem.rightBarButtonItem == nil && [self.textView hasText]) {
        self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
        self.navigationItem.rightBarButtonItem.action = @selector(saveItem:);
        self.navigationItem.rightBarButtonItem.target =self;
        
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;    
        self.navigationItem.leftBarButtonItem.tag = 0;
        if (toolbar.secondButton.enabled == NO && toolbar.fourthButton.enabled == NO && [self.textView hasText]) {
            toolbar.secondButton.enabled = YES;
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
    self.navigationItem.rightBarButtonItem.action = @selector(saveItem:);
    self.navigationItem.rightBarButtonItem.target = self;    
}

#pragma mark - Popover Management
- (void) presentActionsPopover:(id) sender{
    if (actionsPopover) {
        [self.actionsPopover dismissPopoverAnimated:YES];
        self.actionsPopover = nil;
    }
    if(!actionsPopover) {
        UIViewController *viewCon = [[UIViewController alloc] init];

        switch ([sender tag]) {
            case 1:
            {
                CGSize theSize = CGSizeMake(100, 120);
                viewCon.contentSizeForViewInPopover = theSize;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height)];
                [addView toolbarPlanButton];
                viewCon.view = addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                [actionsPopover presentPopoverFromRect:CGRectMake(15, 192, 50, 40) inView:self.view
                              permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES]; 
            }
                break;
                
            case 2:
            {
                CGSize size = CGSizeMake(200, 120);                
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView toolbarSaveButton];
                viewCon.view = addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                [actionsPopover presentPopoverFromRect:CGRectMake(75, 192, 50, 40) inView:self.view
                              permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES];  
            }
                break;         
            case 3:
                break;        
            case 4:
            {
                CGSize size = CGSizeMake(100, 120);
                viewCon.contentSizeForViewInPopover = size;                
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView toolbarSendButton];
                viewCon.view = addView;                
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:(id)self];
                [actionsPopover presentPopoverFromRect:CGRectMake(192, 192, 50, 50) inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES]; 
            }
                break;
            default:
                break;
            }   
    }
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.actionsPopover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
    [self popoverControllerDidDismissPopover:actionsPopover];
	return YES;
}

#pragma mark - Details
- (void) handleTableRowSelection:(NSNotification *) notification {
    NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
    [selectedItem initWithObject:[notification object]];
    
    if ([[notification object] isKindOfClass:[Appointment class]]) {
        NotesViewController *notesAppointmentsViewController = [[NotesViewController alloc] init];
        selectedItem.theAppointment = [notification object];
        
        selectedItem.type = [NSNumber numberWithInt:2];
        selectedItem.text = selectedItem.theAppointment.text;
        selectedItem.aDate = selectedItem.theAppointment.aDate;
        notesAppointmentsViewController.theItem = selectedItem;
        notesAppointmentsViewController.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:notesAppointmentsViewController animated:YES];
        return;
    } else if ([[notification object] isKindOfClass:[ToDo class]]){
        ListViewAndTableViewController *listToDoViewController = [[ListViewAndTableViewController alloc] init];
        selectedItem.theToDo = [notification object];
        selectedItem.type = [NSNumber numberWithInt:3];
        selectedItem.text = selectedItem.theToDo.text;
        selectedItem.aDate = selectedItem.theToDo.aDate;
        selectedItem.startTime = selectedItem.theAppointment.startTime;
        selectedItem.endTime = selectedItem.theAppointment.endTime;
        listToDoViewController.theItem = selectedItem;
        listToDoViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listToDoViewController animated:YES];
        return;
    }
    else if ([[notification object] isKindOfClass:[SimpleNote class]]){
        NotesViewController *notesAppointmentsViewController = [[NotesViewController alloc] init];
        selectedItem.theSimpleNote = [notification object];
        selectedItem.type = [NSNumber numberWithInt:0];
        selectedItem.text = selectedItem.theSimpleNote.text;
        notesAppointmentsViewController.theItem = selectedItem;
        notesAppointmentsViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:notesAppointmentsViewController animated:YES];
        return;
    }else if ([[notification object] isKindOfClass:[List class]]){
        
        //detailViewController = [[DetailContainerViewController alloc] init];
        ListViewAndTableViewController *listC = [[ListViewAndTableViewController alloc] init];
        selectedItem.theList = [notification object];
        //selectedItem.type = [NSNumber numberWithInt:1];
        listC.theItem = selectedItem;
        listC.hidesBottomBarWhenPushed = YES;
        listC.saving = NO;
        //detailViewController.theItem = selectedItem;
        //detailViewController.hidesBottomBarWhenPushed = YES;
        //[self.navigationController pushViewController:detailViewController animated:YES];
        [self.navigationController pushViewController:listC animated:YES];
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


