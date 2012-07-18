//  CustomToolBar.m
//  ADhD-Notes
//  Created by Keith Fernandes on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "CustomToolBar.h"
#import "Constants.h"
@implementation CustomToolBar

@synthesize firstButton, secondButton, fourthButton, thirdButton, fifthButton, flexSpace,titleView, myItems, searchBar;

- (id)init{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, kScreenWidth, 50);
        [self setBarStyle:UIBarStyleBlackTranslucent];
        //[self setTintColor:[UIColor colorWithRed:0.34 green:0.36 blue:0.42 alpha:0.3]];
        [self setTag:0];
        
        self.firstButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"clock_running.png"]style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.firstButton setTitle:@"Plan"];
        [self.firstButton setTag:1];
        [self.firstButton setWidth:40.0];
        [firstButton setAction:@selector(presentActionsPopover:)];
        
        self.secondButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"save.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.secondButton setTitle:@"Save"];
        [self.secondButton setWidth:40.0];
        [self.secondButton setTag:2];
        [self.secondButton setEnabled:NO];
        [secondButton setAction:@selector(presentActionsPopover:)];
        
        thirdButton = [[UIBarButtonItem alloc] initWithImage:self.flipperImageForDateNavigationItem style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.thirdButton setTitle:@"Calendar"];
        [self.thirdButton setTag:3];
        [self.thirdButton setWidth:40.0];
        [thirdButton setAction:@selector(toggleCalendar:)];
        
        fourthButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"email_white.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.fourthButton setTitle:@"Send"];
        [self.fourthButton setWidth:40.0];
        [self.fourthButton setTag:4];
        [fourthButton setAction:@selector(presentActionsPopover:)];
        [self.fourthButton setEnabled:NO];

        
        fifthButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"keyboard_down.png"] style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.fifthButton setTitle:@"Drop"];
        [self.fifthButton setWidth:40.0];
        [self.fifthButton setTag:5];
        [fifthButton setAction:@selector(dismissKeyboard)];        
        
        flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil	action:nil];
        
        myItems = [NSArray arrayWithObjects:flexSpace, firstButton, flexSpace, secondButton, flexSpace, thirdButton, flexSpace, fourthButton,flexSpace, fifthButton, flexSpace, nil];
        [self setItems:myItems];
    }
    return self;
}

- (void) changeToSchedulingButtons{
    firstButton.image = [UIImage imageNamed:@"arrow_right_24.png"];
    firstButton.title = @"";
    firstButton.action = @selector(moveToNextField);
    
    secondButton.image = [UIImage imageNamed:@"arrow_left_24.png"];
    secondButton.title = @"";
    secondButton.action = @selector(moveToPreviousField);
    
    fourthButton.image = [UIImage imageNamed:@"alarm_24.png"];
    fourthButton.title = @"Remind";
    fourthButton.action = @selector(addReminderFields);
    
    fifthButton = nil;
    fifthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    
    
    myItems = [NSArray arrayWithObjects:flexSpace, firstButton, flexSpace, secondButton, flexSpace, thirdButton, flexSpace, fourthButton,flexSpace, fifthButton, flexSpace, nil];
    [self setItems:myItems];
    
    //fifthButton.image = [UIImage imageNamed:@"tag_24.png"];
    //fifthButton.title = @"Tag";
    //fifthButton.action = @selector(addTagFields);
}

- (void) changeToEditingButtons{
    secondButton.image = [UIImage imageNamed:@"save.png"];
    [self.secondButton setTitle:@"Save"];
    [self.secondButton setTag:2];
    [secondButton setAction:@selector(presentActionsPopover:)];
    [secondButton setEnabled:NO];

    firstButton.image = [UIImage imageNamed:@"clock_running.png"];
    [self.firstButton setTitle:@"Plan"];
    [self.firstButton setTag:1];
    [firstButton setAction:@selector(presentActionsPopover:)];
    
    fourthButton.image = [UIImage imageNamed:@"email_white.png"];
    [self.fourthButton setTitle:@"Send"];
    [self.fourthButton setTag:4];
    [fourthButton setAction:@selector(presentActionsPopover:)];
    [fourthButton setEnabled:NO];
    
    fifthButton.image = [UIImage imageNamed:@"keyboard_down.png"];
    [self.fifthButton setTitle:@"Drop"];
    [self.fifthButton setTag:5];
    [fifthButton setAction:@selector(dismissKeyboard)];
}

- (void) changeToDetailButtons{
    firstButton.image = [UIImage imageNamed:@"tab_notepad.png"];
    [self.firstButton setTitle:@"Write Now"];
    [firstButton setAction:@selector(goToMain:)];
    
    secondButton.image = [UIImage imageNamed:@"save.png"];
    [self.secondButton setTitle:@"Save"];
    [secondButton setAction:@selector(presentActionsPopover:)];
    [secondButton setEnabled:YES];

    fourthButton.image = [UIImage imageNamed:@"email_white.png"];
    [self.fourthButton setTitle:@"Send"];
    [fourthButton setAction:@selector(presentActionsPopover:)];
    [fourthButton setEnabled:YES];
    [self.fourthButton setTag:4];

    fifthButton = nil;
    fifthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:nil action:nil];
    
    myItems = [NSArray arrayWithObjects:flexSpace, firstButton, flexSpace, secondButton, flexSpace, thirdButton, flexSpace, fourthButton,flexSpace, fifthButton, flexSpace, nil];
    [self setItems:myItems];
}


- (void) changeToTopButtons: (NSString *)type {
    
    firstButton.image = [UIImage imageNamed:@"arrow_left_24.png"];
    firstButton.title = nil;
    firstButton.action = @selector(firstButtonAction:);
    firstButton.tag = 1;

    fifthButton.image = [UIImage imageNamed:@"arrow_right_24.png"];
    fifthButton.title = nil;
    fifthButton.action = @selector(fifthButtonAction:);
    fifthButton.tag = 2;    
    
    if (type == @"title") {
        
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-85, 40)];
        [titleView setBackgroundColor:[UIColor clearColor]];
        titleView.textColor = [UIColor whiteColor];
        titleView.textAlignment = UITextAlignmentCenter;
        titleView.font = [UIFont systemFontOfSize:20];
        
        thirdButton = [[UIBarButtonItem alloc] initWithCustomView:titleView];    
        
    }else if (type == @"search"){
        firstButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:@selector(firstButtonAction:)];
        fifthButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:nil action:@selector(fifthButtonAction:)];
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-85, 40)];
        searchBar.tintColor = [UIColor clearColor];
        //[searchBar setTranslucent:YES];
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        
        UIView *searchBarContainer = [[UIView alloc] initWithFrame:searchBar.frame];
        searchBarContainer.backgroundColor = [UIColor clearColor];
        [searchBarContainer addSubview:searchBar];
        thirdButton = [[UIBarButtonItem alloc] initWithCustomView:searchBarContainer]; 
    }
    
    myItems = [NSArray arrayWithObjects:firstButton, flexSpace, thirdButton, flexSpace, fifthButton, nil];
    self.items = myItems;
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


@end

