//
//  DiaryViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiaryViewController.h"
#import "HorizontalCells.h"
#import "DiaryTableViewController.h"
#import "CustomTopToolbarView.h"

//#import "TKCalendarDayEventView.h"

@interface DiaryViewController ()

@property (nonatomic, retain) DiaryTableViewController *currentTableViewController;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UILabel *dateLabel;
@property NSInteger dateCounter;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, retain) CustomTopToolbarView *topToolbarView;

@end

@implementation DiaryViewController

@synthesize currentTableViewController, dateCounter, dateLabel, calendarView, textView, selectedDate, topToolbarView;
//@synthesize calendarDayTimelineView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dateCounter = 0;    
    
    //Navigation Bar SetUP    
    
    self.navigationItem.title = @"Diary";
    
    self.navigationItem.leftBarButtonItem = [self.navigationController addLeftArrowButton];
    self.navigationItem.leftBarButtonItem.target = self;
    self.navigationItem.leftBarButtonItem.tag = 1;
    
    topToolbarView = [[CustomTopToolbarView alloc] init];
    [self.view addSubview:topToolbarView];
    [self.topToolbarView setDiaryDate:[NSDate date]];
    
    UIImage *rightImage = [UIImage imageNamed:@"Calendar-Month-30x30.png"];
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton setImage:rightImage forState:UIControlStateNormal];
    [rightNavButton setImage:rightImage forState:UIControlStateHighlighted];
    rightNavButton.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
    rightNavButton.tag = 2;
    [rightNavButton addTarget:self action:@selector(toggleTodayCalendarView:) forControlEvents:UIControlEventTouchUpInside];
    rightNavButton.layer.cornerRadius = 4.0;
    rightNavButton.layer.borderWidth = 1.0; 
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.tag = 2;

    //self.navigationItem.rightBarButtonItem = [self.navigationController addRightArrowButton];
    //self.navigationItem.rightBarButtonItem.target = self;
     
     /*
     scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-kNavBarHeight)];
     scrollView.contentSize = CGSizeMake( scrollView.frame.size.width * 3,scrollView.frame.size.height);
     scrollView.contentOffset = CGPointMake(0, 0);    
     [scrollView setDelegate:self];
     //[scrollView setPagingEnabled:YES];
     [self.view addSubview:scrollView];
     [pageControl setNumberOfPages:3];
     [pageControl setCurrentPage:1];
     // nextTableViewController = [[DiaryTableViewController alloc] init];     
     //[self.scrollView addSubview:nextTableViewController.tableView];
     */
        
    //[self.view addSubview:currentTableViewController.tableView];    
    //[self.view addSubview:self.calendarDayTimelineView];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0,80,320,420)];
    [self.view addSubview:textView];
    [textView setTextColor:[UIColor whiteColor]];
    [self.textView setFont:[UIFont boldSystemFontOfSize:14]];
    UIImage *patternImage = [[UIImage imageNamed:@"54700.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    [self.textView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];

    textView.editable = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotesArray:) name:@"GetNotesArrayNotification" object:nil];    
    }

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    currentTableViewController = [[DiaryTableViewController alloc] init];
    currentTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight);
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    currentTableViewController = nil;
}

-(void) handleNotesArray: (NSNotification *) notif{
    NSLog(@"GetNotesArrayNotification Received");
    NSArray *notesArray = [NSArray arrayWithArray:[notif object]];
    NSString *theString = @"";
    for (int i = 0; i < [notesArray count]; i++) {
        if ([[notesArray objectAtIndex:i] isKindOfClass:[Note class]]){
        Note *theNote  = [notesArray objectAtIndex:i];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"h:mm a"];    
            NSString *temp = [NSString stringWithFormat:@"\t\t\t\t\t\t\t     %@\n%@\n_______________________________________\n", [df stringFromDate:theNote.creationDate], theNote.text];
        theString = [theString stringByAppendingString:temp];
        }
    }
    textView.text = theString;    
}
- (void) toggleTodayCalendarView:(id) sender{
    switch ([sender tag]) {
		case 1:
            NSLog(@"DiaryViewController:toggleTodayCalendarView -> Switching to Today View");
            dateCounter = 0;
            selectedDate = [[NSDate date] timelessDate];
            [self postSelectedDateNotification:nil];
            [self moveCalendarDown];
			break;
        case 2:
            NSLog(@"DiaryViewController:toggleTodayCalendarView  -> Switching to Calendar View");	       
            if (calendarView.superview == nil) {
                if (calendarView == nil) {
                    calendarView = 	[[TKCalendarMonthView alloc] init];
                    }
                    calendarView.delegate = self;
                    [self.view addSubview:calendarView];
                    [calendarView reload];
                    calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
                    //calendarView.frame = CGRectMake(0, kScreenHeight, calendarView.frame.size.width, calendarView.frame.size.height);
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    [UIView setAnimationDelegate:self];                
                    calendarView.frame = CGRectMake(0, kNavBarHeight, calendarView.frame.size.width, calendarView.frame.size.height);
                    [UIView commitAnimations];
                }else {
                    [self moveCalendarDown];
                }
            break;
	}
}

- (void) moveCalendarDown{
    if (calendarView.superview != nil) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(finishedMovingCalendar)];
        calendarView.frame = CGRectMake(0, -calendarView.frame.size.height, calendarView.frame.size.width, calendarView.frame.size.height);
        
        [UIView commitAnimations];
    }
}

- (void) finishedMovingCalendar{
    if (calendarView !=nil) {
        calendarView = nil;
    }
}

#pragma mark - TKCalendarMonthViewDelegate methods
- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d {
	NSLog(@"calendarMonthView didSelectDate: %@", d);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDateNotification" object:d userInfo:nil]; 
    selectedDate = d;
    [self postSelectedDateNotification:nil];
    [self moveCalendarDown];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d {
	NSLog(@"calendarMonthView monthDidChange");	
    //
}

- (void) postSelectedDateNotification:(id) sender{
    NSLog(@"DiaryViewController:postDateNotification -> posting dateNotification");
    // if nil then post current date. 
    //if left arrow selected add
    if ([sender tag] ==2 && dateCounter >= 0){
        //right arrow does nothing
        return;
    } else if ([sender tag] == 1){
        NSLog(@"decrement dateCounter by 1");
        
        --dateCounter;
    }else if ([sender tag] == 2){
        NSLog(@"increment dateCounter by 1");
        ++dateCounter;
    }
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *currentDate= [[NSDate date] timelessDate];    
    NSDateComponents *addDay = [[NSDateComponents alloc] init];
    addDay.day = dateCounter;
    if (sender != nil) {
    
    selectedDate = [gregorian dateByAddingComponents:addDay toDate:currentDate options:0];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetSelectedDateNotification" object:selectedDate userInfo:nil];   
    
    [self.topToolbarView setDiaryDate:selectedDate];
    

}

/*
- (NSArray *)calendarDayTimelineView:(TKCalendarDayTimelineView*)calendarDayTimeline eventsForDate:(NSDate *)eventDate{
	TKCalendarDayEventView *eventViewFirst = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
                                                                                     id:nil 
                                                                              startDate:[[NSDate date]addTimeInterval:60 * 60 * 2] 
                                                                                endDate:[[NSDate date]addTimeInterval:60 * 60 * 24]
                                                                                  title:@"First"
                                                                               location:@"Test Location"];
	
	TKCalendarDayEventView *eventViewSecond = [TKCalendarDayEventView eventViewWithFrame:CGRectZero
                                                                                      id:nil
                                                                               startDate:[NSDate date] 
                                                                                 endDate:[NSDate date]
                                                                                   title:@"Second ultra mega hypra long text to test again with more"
                                                                                location:nil];
	
	return [NSArray arrayWithObjects:eventViewFirst, eventViewSecond, nil];
}
- (void)calendarDayTimelineView:(TKCalendarDayTimelineView*)calendarDayTimeline eventViewWasSelected:(TKCalendarDayEventView *)eventView{
	NSLog(@"CalendarDayTimelineView: EventViewWasSelected");
}

- (TKCalendarDayTimelineView *) calendarDayTimelineView{
	if (!_calendarDayTimelineView) {
		_calendarDayTimelineView = [[TKCalendarDayTimelineView alloc]initWithFrame:self.view.bounds];
		_calendarDayTimelineView.delegate = self;
	}
	return _calendarDayTimelineView;
}
*/

- (void)viewDidUnload{
    [super viewDidUnload];
    currentTableViewController  = nil;
    dateLabel = nil;
    calendarView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
