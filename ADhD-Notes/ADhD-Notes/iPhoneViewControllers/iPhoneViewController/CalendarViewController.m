//  CalendarViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "CalendarViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "EventsTableViewController2.h"

#import "AppointmentDetailViewController.h"
#import "ToDoDetailViewController.h"
#import "MemoDetailViewController.h"
#import "ListDetailViewController.h"
#import "CustomPopoverView.h"

@interface CalendarViewController ()

@property BOOL saving;
@property (nonatomic, retain) EventsTableViewController2 *tableViewController1, *tableViewController2;
@property (nonatomic, retain) NSDate *selectedDate;
@end

@implementation CalendarViewController

@synthesize tableViewController1, tableViewController2, segmentedControl, actionsPopover, saving, pushed, frontViewIsVisible, managedObjectContext, flipIndicatorButton, calendarView, flipperImageForDateNavigationItem, flipperView, listImageForFlipperView, selectedDate;

#pragma mark - ViewManagement

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedDate = [NSDate date];
    frontViewIsVisible = YES;
    if (managedObjectContext == nil) { 
        managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"CURRENT VIEWCONTROLLER: After managedObjectContext: %@",  managedObjectContext);
    }    
    /*-ADD FLIPPER VIEW -*/
    flipperView = [[UIView alloc] initWithFrame:mainFrame];
    [flipperView setBackgroundColor:[UIColor blackColor]];
    [self.view   addSubview:flipperView];
    
    if (tableViewController2 == nil){
        tableViewController2 = [[EventsTableViewController2 alloc] init];
        tableViewController2.calendarIsVisible = NO;
        tableViewController2.tableView.frame = CGRectMake(0, 0, flipperView.frame.size.width, flipperView.frame.size.height-kTabBarHeight);
        [tableViewController2.tableView setSeparatorColor:[UIColor blackColor]];
        [tableViewController2.tableView setSectionHeaderHeight:13];
        tableViewController2.tableView.rowHeight = kCellHeight;
        UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        searchBar.tintColor = [UIColor blackColor];
        tableViewController2.tableView.tableHeaderView = searchBar;
    }
    if (calendarView.superview==nil) {
        calendarView = 	[[TKCalendarMonthView alloc] init];        
        calendarView.delegate = self;
        calendarView.dataSource = self;            
        
       // calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
        calendarView.frame = CGRectMake(0, 0, calendarView.frame.size.width, calendarView.frame.size.height);
        tableViewController1 = [[EventsTableViewController2 alloc]init];
        tableViewController1.calendarIsVisible = YES;
        tableViewController1.tableView.frame = CGRectMake(0, calendarView.frame.size.height,kScreenWidth, kScreenHeight-calendarView.frame.size.height);
        [tableViewController1.tableView setSeparatorColor:[UIColor blackColor]];
        [tableViewController1.tableView setSectionHeaderHeight:13];
        tableViewController1.tableView.rowHeight = kCellHeight;        
        [self.flipperView addSubview:tableViewController1.tableView];
        [self.flipperView addSubview:calendarView];
        [calendarView reload];
    }
    /*
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
     */
    
    if (!pushed) {
        self.navigationController.navigationBar.topItem.title = @"Calendar";    

        NSLog (@"Calendar ViewC - NOT pushed");
        UIBarButtonItem *leftNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentActionsPopover:)];
        leftNavButton.tag = 1;
        self.navigationItem.leftBarButtonItem = leftNavButton;
    
    UIImage *image = self.listImageForFlipperView;
    CGSize theSize = image.size;        
    UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height)];    
    self.flipIndicatorButton=tempButton;
    [flipIndicatorButton setBackgroundImage:image forState:UIControlStateNormal];
    flipIndicatorButton.layer.cornerRadius = 4.0;
    flipIndicatorButton.layer.borderWidth = 1.0;
    
    UIBarButtonItem *flipButtonBarItem=[[UIBarButtonItem alloc] initWithCustomView:flipIndicatorButton];	
    
    [self.navigationItem setRightBarButtonItem:flipButtonBarItem animated:YES];
    [flipIndicatorButton addTarget:self action:@selector(toggleCalendar:) forControlEvents:(UIControlEventTouchDown)];
    }
    //[UIView commitAnimations];
    
    if (pushed) {
        NSLog (@"Calendar ViewC - pushed");
        UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addDateToCurrentEvent)];
        rightNavButton.tag = 1;
        self.navigationItem.rightBarButtonItem = rightNavButton;
    }
    /* Init and Add the Segmented Control */
    NSArray *items = [NSArray arrayWithObjects:@"Month",@"Day", nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
    [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
    [segmentedControl setWidth:60 forSegmentAtIndex:0];
    [segmentedControl setWidth:60 forSegmentAtIndex:1];
    [segmentedControl setSelectedSegmentIndex:0];
    self.navigationItem.titleView = segmentedControl;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated{
    /*
    if (!tableViewController){
        NSLog(@"CalendarViewController: viewWillAppear: CreatingNewTableViewController");
        tableViewController = [[EventsTableViewController2 alloc] init];
        tableViewController.tableView.frame = CGRectMake(0,kNavBarHeight,kScreenWidth, kScreenHeight-kNavBarHeight);
    }
     
    if (self.calendarView.superview == nil && self.tableViewController.tableView.superview == nil){
        self. tableViewController.tableView.frame = CGRectMake(0, 0, flipperView.frame.size.width, flipperView.frame.size.height-kTabBarHeight);
        [self.flipperView addSubview:tableViewController.tableView];
    }
    */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:UITableViewSelectionDidChangeNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {

    [[NSNotificationCenter defaultCenter] removeObserver:self name: UITableViewSelectionDidChangeNotification object:nil];
}

- (UIImage *)flipperImageForDateNavigationItem {
	// returns a 30 x 30 image to display the flipper button in the navigation bar
	CGSize itemSize=CGSizeMake(30.0,30.0);
	UIGraphicsBeginImageContext(itemSize);
	UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"calendar_date_background.png"]];
	CGRect calendarRectangle = CGRectMake(0,0, itemSize.width, itemSize.height);
	[backgroundImage drawInRect:calendarRectangle];
    // draw the element name
	[[UIColor whiteColor] set];
    // draw the date 
    NSDateFormatter *imageDateFormatter = [[NSDateFormatter alloc] init];
    [imageDateFormatter setDateFormat:@"d"];
    UIFont *font = [UIFont boldSystemFontOfSize:7];
	//CGPoint point = CGPointMake(1,1);
    CGSize stringSize = [[imageDateFormatter stringFromDate:[NSDate date]] sizeWithFont:font];
    CGPoint point = CGPointMake((calendarRectangle.size.width-stringSize.width)/2+5,16);    
	[[imageDateFormatter stringFromDate:[NSDate date]] drawAtPoint:point withFont:font];
    // draw the month    
    [imageDateFormatter setDateFormat:@"MMM"];
	font = [UIFont boldSystemFontOfSize:8];
    stringSize = [[imageDateFormatter stringFromDate:[NSDate date]] sizeWithFont:font];
    point = CGPointMake((calendarRectangle.size.width-stringSize.width)/2,9);
	[[imageDateFormatter stringFromDate:[NSDate date]] drawAtPoint:point withFont:font];

	UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

- (UIImage *) listImageForFlipperView {
    CGSize itemSize=CGSizeMake(30.0,30.0);
	UIGraphicsBeginImageContext(itemSize);
	UIImage *backgroundImage = [UIImage imageNamed:[NSString stringWithFormat:@"list_nav.png"]];
	CGRect buttonRectange = CGRectMake(2,4, backgroundImage.size.width, backgroundImage.size.height);
	[backgroundImage drawInRect:buttonRectange];
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return theImage;
}

- (void) toggleAppointmentsTasksView: (id) sender{
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            {
            NSNumber *num = [NSNumber numberWithInt:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetEventTypeNotification" object:num userInfo:nil]; 
            }
            break;
        case 1:
            {
            NSNumber *num = [NSNumber numberWithInt:3];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GetEventTypeNotification" object:num userInfo:nil]; 
            }
            break;
        default:
            break;
    }    
}

- (void)toggleCalendar:(id) sender {
    // disable user interaction during the flip
    flipperView.userInteractionEnabled = NO;
	flipIndicatorButton.userInteractionEnabled = NO;
    
    // setup the animation group
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
	
	// swap the views and transition
    if (frontViewIsVisible==YES) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:flipperView cache:YES];
        [calendarView removeFromSuperview];
        [self.tableViewController1.tableView removeFromSuperview];
        //self. tableViewController.tableView.frame = CGRectMake(0, 0, flipperView.frame.size.width, flipperView.frame.size.height-kTabBarHeight);
        
        //self.tableViewController.calendarIsVisible = NO;
        
        [self.flipperView addSubview:tableViewController2.tableView];
        self.navigationItem.titleView = nil;
        NSArray *items = [NSArray arrayWithObjects:@"Events", @"Memos", nil];
        segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentedControl setWidth:90 forSegmentAtIndex:0];
        [segmentedControl setWidth:90 forSegmentAtIndex:1];
        [segmentedControl setSelectedSegmentIndex:0];
        [segmentedControl addTarget:self
                             action:@selector(toggleAppointmentsTasksView:)
                   forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.titleView = segmentedControl;
        
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:flipperView cache:YES];
        [tableViewController2.tableView removeFromSuperview];
        
        [self.flipperView addSubview:calendarView];        
        [self.flipperView addSubview:tableViewController1.tableView];

        self.navigationItem.titleView = nil;
        NSArray *items = [NSArray arrayWithObjects:@"Month", @"Day", nil];
        segmentedControl = [[UISegmentedControl alloc] initWithItems:items];
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentedControl setWidth:60 forSegmentAtIndex:0];
        [segmentedControl setWidth:60 forSegmentAtIndex:1];
        [segmentedControl setSelectedSegmentIndex:0];
       
        self.navigationItem.titleView = segmentedControl;
    }
	[UIView commitAnimations];
    
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(myTransitionDidStop:finished:context:)];
    
	if (frontViewIsVisible==YES) {
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:flipIndicatorButton cache:YES];
        [flipIndicatorButton setBackgroundImage:self.flipperImageForDateNavigationItem forState:UIControlStateNormal];
	} 
	else {
        
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:flipIndicatorButton cache:YES];
		[flipIndicatorButton setBackgroundImage:self.listImageForFlipperView forState:UIControlStateNormal];
	}
	[UIView commitAnimations];
    frontViewIsVisible=!frontViewIsVisible;
}

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// re-enable user interaction when the flip is completed.
	flipIndicatorButton.userInteractionEnabled = YES;
    flipperView.userInteractionEnabled = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

#pragma mark - TKCalendarMonthViewDelegate methods
- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
    selectedDate = d;
    NSLog (@"CalendarViewController:selected date is %@", selectedDate);
    //ADD DATE TO CURRENT EVENT
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
}

- (void) calendarMonthView:(TKCalendarMonthView*)monthView monthDidChange:(NSDate*)month animated:(BOOL)animated {
	NSLog(@"calendarMonthView monthDidChange");	
    [tableViewController1.tableView removeFromSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.75];
    [UIView setAnimationDelegate:self];
    
    CGRect frame = tableViewController1.tableView.frame;
    frame.origin.y = calendarView.frame.origin.y + calendarView.frame.size.height;
    tableViewController1.tableView.frame = frame;
    [self.flipperView addSubview:tableViewController1.tableView];    
    [UIView commitAnimations];
}

#pragma mark - TKCalendarMonthViewDataSource methods
//get dates with events
- (NSArray *)fetchDatesForTimedEvents { 
    
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
        
    //kjf the array data contains Event objects. need to convert this to an array which has date objects 
    NSMutableArray *data = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[results count]; i++) {
        
        if ([[results objectAtIndex:i] isKindOfClass:[Appointment class]]){
            Appointment *tempAppointment = [results objectAtIndex:i];
            [data addObject:tempAppointment.aDate];
            
        } 
        else if ([[results objectAtIndex:i] isKindOfClass:[ToDo class]]){
            ToDo *tempToDo = [results objectAtIndex:i];
            [data addObject:tempToDo.aDate];            
        }
    }
    return data;    
}

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate {	
	NSArray *data = [NSArray arrayWithArray:[self fetchDatesForTimedEvents]];	
	// Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
	NSMutableArray *marks = [NSMutableArray array];
	// Initialise calendar to current type and set the timezone to never have daylight saving
	NSCalendar *cal = [NSCalendar currentCalendar];
    [cal setTimeZone:[NSTimeZone systemTimeZone]];
	
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
	return [NSArray arrayWithArray:marks];
}

- (void) addDateToCurrentEvent {
    /* the navigation bar needs to be changed for the schedule view 
     Left button = Cancel. Returns the user to the editing page.
     
     Right Button = ADD item - when the calendar is pulled up.
     If the textview has text then, check if there is an appointment or task event linked. 
     If not, selecting a date and hitting the ADD button, creates an event  if it doesn't already exist 
     and adds the date.
     If there is no text in TV, then create note and event. 
     
     Alternately, have two different looking buttons which show depending on whether there is text or not. 
     */
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

- (void) startNewItem:(id) sender {

    if (!pushed) {

        NSNumber *num;
        switch ([sender tag]) {
            case 1:           
               
                num = [NSNumber numberWithInt:2];
                
                break;
            case 2:
                num = [NSNumber numberWithInt:3];

                break;
            case 3:
                num = [NSNumber numberWithInt:0];

                //Note
                break;
                
            default:
                break;
        }
        NSArray *objects = [NSArray arrayWithObjects:selectedDate , num, nil];
        NSArray *keys = [NSArray arrayWithObjects:@"theDate", @"theType",nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil userInfo:dict];                

        self.tabBarController.selectedViewController 
        = [self.tabBarController.viewControllers objectAtIndex:0];
        
    }else{
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
        return;
    }
}

#pragma mark - Popover Management

- (void) presentActionsPopover:(id) sender {
    //Check for visisble instance of actionsPopover. if yes dismiss.
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
        return;
    }
    if(!actionsPopover ) {
        UIViewController *viewCon = [[UIViewController alloc] init];
        switch ([sender tag]) {
            case 1:
            {
                CGSize size = CGSizeMake(140, 160);
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView addItemsViewForCalendar];
                viewCon.view =  addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                
                if (saving){
                    [actionsPopover presentPopoverFromRect:CGRectMake(80, kScreenHeight-kTabBarHeight, 50, 40)
                                                    inView:self.view    
                                  permittedArrowDirections:UIPopoverArrowDirectionDown
                                                  animated:YES];  
                }
                else if (!saving) {
                    [actionsPopover presentPopoverFromRect:CGRectMake(10, 0, 50, 40)
                                                    inView:self.view    
                                  permittedArrowDirections:UIPopoverArrowDirectionUp
                                                  animated:YES];     
                }
            }
                break;
            case 2:
            {
                CGSize size = CGSizeMake(140, 260);
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView organizerViewForCalendar];
                viewCon.view =  addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                
                if (saving) {
                    [actionsPopover presentPopoverFromRect:CGRectMake(190, kScreenHeight-kTabBarHeight, 50, 40)
                                                    inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionDown
                                                  animated:YES];
                }
                else if (!saving) {
                    [actionsPopover presentPopoverFromRect:CGRectMake(280,0, 50, 40) inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionUp
                                                  animated:YES];
                }
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
    if ([[notification object] isKindOfClass:[Appointment class]]) {
        AppointmentDetailViewController *detailViewController = [[AppointmentDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        Appointment *selectedAppointment = [notification object];
        NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
        selectedItem.theAppointment = selectedAppointment;
        selectedItem.eventType = [NSNumber numberWithInt:2];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    } else if ([[notification object] isKindOfClass:[ToDo class]]){
        ToDoDetailViewController *detailViewController = [[ToDoDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        ToDo *selectedToDo = [notification object];
        NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
        selectedItem.theToDo = selectedToDo;
        selectedItem.eventType = [NSNumber numberWithInt:3];
        detailViewController.theItem = selectedItem;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    } else if ([[notification object] isKindOfClass:[SimpleNote class]]){
        NSLog(@"Selected Item is a Simple Note");
        MemoDetailViewController *detailViewController = [[MemoDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        SimpleNote *selectedSimpleNote = [notification object];
        NSLog(@"The Simple Note Text is %@", selectedSimpleNote.text);
        NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
        selectedItem.theSimpleNote = selectedSimpleNote;
        selectedItem.eventType = [NSNumber numberWithInt:0];
        detailViewController.theItem = selectedItem;
        detailViewController.theSimpleNote = selectedSimpleNote;
        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    }else if ([[notification object] isKindOfClass:[List class]]){
        NSLog(@"Selected Item is a List");
        ListDetailViewController *detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        List *selectedList = [notification object];
        NewItemOrEvent *selectedItem = [[NewItemOrEvent alloc] init];
        selectedItem.theList = selectedList;
        selectedItem.eventType = [NSNumber numberWithInt:1];
        detailViewController.theItem = selectedItem;
        detailViewController.theList = selectedList;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
        return;
    }
}

@end
