//
//  CustomTopToolbarView.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "CustomTopToolbarView.h"
#import "Constants.h"

#define middleFrame CGRectMake(60, 0, kScreenWidth-120, 40)

@implementation CustomTopToolbarView

@synthesize dateLabel, searchBar;
@synthesize leftButton, rightButton, middleButton;
- (id)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 44, kScreenWidth, 40);
        self.backgroundColor = [UIColor blackColor];    
        leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, 44, 30)];
        [leftButton setImage:[UIImage imageNamed:@"arrow_left_24.png"] forState:UIControlStateNormal];
        leftButton.tag = 1;
        [leftButton addTarget:nil action:@selector(goToPrecedingItem:) forControlEvents:UIControlEventTouchUpInside];
        
        rightButton = [[UIButton alloc] initWithFrame:CGRectMake(276, 5, 44, 30)];
        [rightButton setImage:[UIImage imageNamed:@"arrow_right_24.png"] forState:UIControlStateNormal];
        rightButton.tag = 2;
        [rightButton addTarget:nil action:@selector(goToFollowingItem:) forControlEvents:UIControlEventTouchUpInside];
        
        
        middleButton = [[UIButton alloc] initWithFrame:middleFrame];
        [middleButton setBackgroundImage:[UIImage imageNamed:@"blackbutton.png"] forState:UIControlStateNormal];
        middleButton.layer.borderWidth = 2.0;
        middleButton.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.6].CGColor;
        middleButton.titleLabel.textColor = [UIColor whiteColor];
        middleButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        middleButton.titleLabel.shadowOffset    = CGSizeMake (1.0, 0.0); 
        middleButton.showsTouchWhenHighlighted = YES;
        middleButton.tag = 7;
        
        [self addSubview:leftButton];
        [self addSubview:rightButton];
        [self addSubview:middleButton];
        
    }
    return self;
}

- (void) setAppendOrSave:(id)type{
    [leftButton addTarget:nil action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];     
    [leftButton setImage:[UIImage imageNamed:@"addFolder_nav.png"] forState:UIControlStateNormal];
    //[leftButton setImage:[UIImage imageNamed:@"addDoc_nav.png"] forState:UIControlStateNormal];

    leftButton.tag = 1;
    
    [rightButton addTarget:nil action:@selector(presentActionsPopover:) forControlEvents:UIControlEventTouchUpInside];                                                                                      
    rightButton.tag = 5;    
    
    searchBar = [[UISearchBar alloc] initWithFrame:middleFrame];
    searchBar.tintColor = [UIColor clearColor];
    //[searchBar setTranslucent:YES];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [self addSubview:searchBar];
}

- (void) setDiaryDate:(NSDate *)date{
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEEE, MMMM dd"];
    [middleButton setTitle:[dateformatter stringFromDate:date] forState:UIControlStateNormal];
    
    
    [leftButton addTarget:nil action:@selector(postSelectedDateNotification:) forControlEvents:UIControlEventTouchUpInside];                                                                                  
    leftButton.tag = 1;
    
    [rightButton addTarget:nil action:@selector(postSelectedDateNotification:) forControlEvents:UIControlEventTouchUpInside]; 
    
}

- (void) setItemTitle: (NSString *)title {
    [middleButton setTitle:title forState:UIControlStateNormal];
    [middleButton addTarget:nil action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];
    
}


- (void) setAppointmentTimeFrom: (NSDate *)start Till:(NSDate *)end{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];   
    NSString *startTime = [dateFormatter stringFromDate:start];
    NSString *endTime = [dateFormatter stringFromDate:end];
        
    [middleButton setTitle:[NSString stringWithFormat:@"%@ - %@", startTime, endTime] forState:UIControlStateNormal];
    [middleButton addTarget:nil action:@selector(setEventTime:) forControlEvents:UIControlEventTouchUpInside];
}


@end
