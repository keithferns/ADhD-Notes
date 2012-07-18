//
//  CustomPopoverView.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomPopoverView.h"

@implementation CustomPopoverView

@synthesize button1, button2, button3, button4;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) addItemsView {
    NSLog(@"CustomPopoverView - > Calling addItemsView");
    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 39)];
    [addLabel setText:@"ADD NEW"];
    [addLabel setTextAlignment:UITextAlignmentCenter];
    [addLabel setBackgroundColor:[UIColor clearColor]];
    addLabel.textColor = [UIColor lightTextColor];
    addLabel.font = [UIFont boldSystemFontOfSize:18];
    addLabel.layer.borderWidth = 2;
    addLabel.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIButton *b1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 120, 39)];
    [b1 setTitle:@"Folder" forState:UIControlStateNormal];
    b1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    //b1.backgroundColor = [UIColor darkGrayColor];
    b1.alpha = 1.0;
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b1.layer.cornerRadius = 6.0;
    //b1.layer.borderWidth = 1.0;
    [b1 addTarget:nil action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];
    [b1 setTag:1];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 120, 39)];
    // b2.backgroundColor = [UIColor darkGrayColor];
    b2.alpha = 1.0;
    [b2 setTitle:@"Document" forState:UIControlStateNormal];
    b2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [b2 addTarget:nil action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];
    //b2.layer.cornerRadius = 6.0;
    //b2.layer.borderWidth = 1.0;
    [b2 setTag:2];
    //b2.layer.borderWidth = 2;
    //b2.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    UIButton *b3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 120, 120, 39)];
    [b3 setTitle:@"Note" forState:UIControlStateNormal];
    b3.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b3.backgroundColor = [UIColor darkGrayColor];
    b3.alpha = 1.0;
    [b3 addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    //b3.layer.cornerRadius = 6.0;
    //b3.layer.borderWidth = 1.0;
    
    [self addSubview:addLabel];
    [self addSubview:b1];
    [self addSubview:b2];
    [self addSubview:b3];
}

- (void)organizerView {
    NSLog(@"CustomPopoverView - > Calling organizerView");

    UILabel *sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 29)];
    [sortLabel setText:@"Sort By"];
    [sortLabel setTextAlignment:UITextAlignmentCenter];
    [sortLabel setBackgroundColor:[UIColor clearColor]];
    sortLabel.textColor = [UIColor lightTextColor];
    sortLabel.font = [UIFont boldSystemFontOfSize:18];
    sortLabel.layer.borderWidth = 2;
    sortLabel.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIButton *b1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 120, 39)];
    [b1 setTitle:@"Name" forState:UIControlStateNormal];
    b1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    //b1.backgroundColor = [UIColor darkGrayColor];
    b1.alpha = 1.0;
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b1.layer.cornerRadius = 6.0;
    //b1.layer.borderWidth = 1.0;
    [b1 addTarget:self action:@selector(pushingDetail) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 70, 120, 39)];
    //b2.backgroundColor = [UIColor darkGrayColor];
    b2.alpha = 1.0;
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b2 setTitle:@"Date Created" forState:UIControlStateNormal];
    b2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b2.layer.cornerRadius = 6.0;
    //b2.layer.borderWidth = 1.0;
    
    UIButton *b3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, 120, 39)];
    [b3 setTitle:@"Date Modified" forState:UIControlStateNormal];
    b3.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted]; 
    //b3.backgroundColor = [UIColor darkGrayColor];
    b3.alpha = 1.0;
    //b3.layer.cornerRadius = 6.0;
    //b3.layer.borderWidth = 1.0;
    
    UIButton *b4 = [[UIButton alloc] initWithFrame:CGRectMake(10, 150, 120, 39)];
    [b4 setTitle:@"Other" forState:UIControlStateNormal];
    b4.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    //b4.backgroundColor = [UIColor darkGrayColor];
    [b4 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b4 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b4 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    b4.alpha = 1.0;
    //b4.layer.cornerRadius = 6.0;
    //b4.layer.borderWidth = 1.0;
    
    [self addSubview:sortLabel];
    [self addSubview:b1];
    [self addSubview:b2];
    [self addSubview:b3];
    [self addSubview:b4];
}

- (void) addItemsViewForCalendar{
    UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 39)];
    [addLabel setText:@"ADD NEW"];
    [addLabel setTextAlignment:UITextAlignmentCenter];
    [addLabel setBackgroundColor:[UIColor clearColor]];
    addLabel.textColor = [UIColor lightTextColor];
    addLabel.font = [UIFont boldSystemFontOfSize:18];
    addLabel.layer.borderWidth = 2;
    addLabel.layer.borderColor = [UIColor clearColor].CGColor;
    
    UIButton *b1 = [[UIButton alloc] initWithFrame:CGRectMake(10, 40, 120, 39)];
    [b1 setTitle:@"Appointment" forState:UIControlStateNormal];
    b1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    //b1.backgroundColor = [UIColor darkGrayColor];
    b1.alpha = 1.0;
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b1 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b1.layer.cornerRadius = 6.0;
    //b1.layer.borderWidth = 1.0;
    [b1 addTarget:nil action:@selector(startNewItem:) forControlEvents:UIControlEventTouchUpInside];
    [b1 setTag:1];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:CGRectMake(10, 80, 120, 39)];
    // b2.backgroundColor = [UIColor darkGrayColor];
    b2.alpha = 1.0;
    [b2 setTitle:@"To Do" forState:UIControlStateNormal];
    b2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b2 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [b2 addTarget:nil action:@selector(startNewItem:) forControlEvents:UIControlEventTouchUpInside];
    //b2.layer.cornerRadius = 6.0;
    //b2.layer.borderWidth = 1.0;
    [b2 setTag:2];
    //b2.layer.borderWidth = 2;
    //b2.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    UIButton *b3 = [[UIButton alloc] initWithFrame:CGRectMake(10, 120, 120, 39)];
    [b3 setTitle:@"Note" forState:UIControlStateNormal];
    b3.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [b3 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    [b3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b3.backgroundColor = [UIColor darkGrayColor];
    b3.alpha = 1.0;
    [b3 addTarget:nil action:@selector(startNewItem:) forControlEvents:UIControlEventTouchUpInside];
    //b3.layer.cornerRadius = 6.0;
    //b3.layer.borderWidth = 1.0;
    [b3 setTag:3];
    
    [self addSubview:addLabel];
    [self addSubview:b1];
    [self addSubview:b2];
    [self addSubview:b3];
}

- (void)organizerViewForCalendar{
    //FIXME: Potental Memory Leak for oView
    UILabel *sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 140, 29)];
    [sortLabel setText:@"Sort By"];
    [sortLabel setBackgroundColor:[UIColor clearColor]];
    sortLabel.textColor = [UIColor lightTextColor];
    sortLabel.font = [UIFont boldSystemFontOfSize:18];
    sortLabel.layer.borderWidth = 2;
    sortLabel.layer.borderColor = [UIColor clearColor].CGColor;
    UIButton *b1 = [[UIButton alloc] initWithFrame:CGRectMake(5, 30, 120, 39)];
    [b1 setTitle:@"Name" forState:UIControlStateNormal];
    b1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    b1.backgroundColor = [UIColor darkGrayColor];
    b1.alpha = 0.4;
    [b1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b1.layer.borderWidth = 2;
    //b1.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [b1 addTarget:self action:@selector(pushingDetail) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *b2 = [[UIButton alloc] initWithFrame:CGRectMake(5, 70, 120, 39)];
    b2.backgroundColor = [UIColor darkGrayColor];
    b2.alpha = 0.4;
    [b2 setTitle:@"Date Created" forState:UIControlStateNormal];
    b2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //b2.layer.borderWidth = 2;
    //b2.layer.borderColor = [UIColor darkGrayColor].CGColor;
    UIButton *b3 = [[UIButton alloc] initWithFrame:CGRectMake(5, 110, 120, 39)];
    [b3 setTitle:@"Date Modified" forState:UIControlStateNormal];
    b3.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [b3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    b3.backgroundColor = [UIColor darkGrayColor];
    b3.alpha = 0.4;
    
    //b3.layer.borderWidth = 2;
    //b3.layer.borderColor = [UIColor darkGrayColor].CGColor;
    UIButton *b4 = [[UIButton alloc] initWithFrame:CGRectMake(5, 150, 120, 39)];
    [b4 setTitle:@"Other" forState:UIControlStateNormal];
    b4.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    b4.backgroundColor = [UIColor darkGrayColor];
    //b4.layer.borderWidth = 2;
    //b4.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [b4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b4 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    b4.alpha = 0.4;
    
    UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 190, 140, 29)];
    deleteLabel.backgroundColor = [UIColor clearColor];
    deleteLabel.textColor = [UIColor lightTextColor];
    [deleteLabel setText:@"Delete"];
    deleteLabel.font = [UIFont boldSystemFontOfSize:18];
    
    UIButton *b5 = [[UIButton alloc] initWithFrame:CGRectMake(5, 220, 120, 39)];
    [b5 setTitle:@"Delete" forState:UIControlStateNormal];
    //b5.layer.borderWidth = 2;
    //b5.layer.borderColor = [UIColor darkGrayColor].CGColor;
    b5.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    b5.alpha = 0.4;
    b5.backgroundColor = [UIColor darkGrayColor];
    [b5 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [b5 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    
    [self addSubview:sortLabel];
    [self addSubview:b1];
    [self addSubview:b2];
    [self addSubview:b3];
    [self addSubview:b4];
    [self addSubview:deleteLabel];
    [self addSubview:b5];
}


- (void) toolbarPlanButton {
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(0, 0, 100, 34);
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.textColor = [UIColor lightTextColor];
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.layer.borderWidth = 2;
    label1.layer.borderColor = [UIColor clearColor].CGColor;
    [label1 setTextAlignment:UITextAlignmentCenter];
    label1.text = @"Create";
    
    button1 = [[UIButton alloc] init];
    button1.frame = CGRectMake(0, 40, 100, 35);
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
    button1.titleLabel.text = @"Appointment";
    [button1 setTitle:@"Appointment" forState:UIControlStateNormal];
    [button1 addTarget:nil action:@selector(createEvent:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTag:0];
    
    button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(0, 80, 100, 35);
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
    button2.titleLabel.text = @"To Do";
    [button2 setTitle:@"To Do" forState:UIControlStateNormal];
    [button2 addTarget:nil action:@selector(createEvent:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTag:1];
    
    [self addSubview:label1];
    [self addSubview:button1];
    [self addSubview:button2];
}

- (void) toolbarSaveButton {
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(0, 0, 100, 34);
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.textColor = [UIColor lightTextColor];
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.layer.borderWidth = 2;
    label1.layer.borderColor = [UIColor clearColor].CGColor;
    [label1 setTextAlignment:UITextAlignmentCenter];
    label1.text = @"Save To";
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(100, 0, 100, 34);
    [label2 setBackgroundColor:[UIColor clearColor]];
    label2.textColor = [UIColor lightTextColor];
    label2.font = [UIFont boldSystemFontOfSize:18];
    label2.layer.borderWidth = 2;
    label2.layer.borderColor = [UIColor clearColor].CGColor;
    [label2 setTextAlignment:UITextAlignmentCenter];
    label2.text = @"Add To";
    
    button1 = [[UIButton alloc] init];
    button1.frame = CGRectMake(0, 35, 100, 39);
    //button1.backgroundColor = [UIColor darkGrayColor];
    [button1 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    button1.alpha = 1.0;
    button1.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button1.layer.cornerRadius = 6.0;
    //button1.layer.borderWidth = 1.0;
    button1.titleLabel.text = @"Folder";
    [button1 setTitle:@"Folder" forState:UIControlStateNormal];
    [button1 addTarget:nil action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTag:2];
    
    button3 = [[UIButton alloc] init];
    button3.frame = CGRectMake(100, 35, 100, 39);
    //button3.backgroundColor = [UIColor darkGrayColor];
    [button3 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button3 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    button3.alpha = 1.0;
    button3.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button1.layer.cornerRadius = 6.0;
    //button1.layer.borderWidth = 1.0;
    button3.titleLabel.text = @"List";
    [button3 setTitle:@"List" forState:UIControlStateNormal];
    [button3 addTarget:nil action:@selector(appendToList:) forControlEvents:UIControlEventTouchUpInside];
    [button3 setTag:4];
    
    button2 = [[UIButton alloc] init];
    button2.frame = CGRectMake(0, 80, 100, 39);
    //button2.backgroundColor = [UIColor darkGrayColor];
    button2.alpha = 1.0;
    [button2 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button2 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    button2.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button2.layer.cornerRadius = 6.0;
    //button2.layer.borderWidth = 1.0;
    button2.titleLabel.text = @"Project";
    [button2 setTitle:@"Project" forState:UIControlStateNormal];
    [button2 addTarget:nil action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTag:3];
    
    button4 = [[UIButton alloc] init];
    button4.frame = CGRectMake(100, 80, 100, 39);
    //button4.backgroundColor = [UIColor darkGrayColor];
    button4.alpha = 1.0;
    [button4 setBackgroundImage:[UIImage imageNamed:@"button-normal.png"] forState:UIControlStateNormal];
    [button4 setBackgroundImage:[UIImage imageNamed:@"button-highlighted.png"] forState:UIControlStateHighlighted];
    button4.titleLabel.font = [UIFont italicSystemFontOfSize:15];
    [button4 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    //button4.layer.cornerRadius = 6.0;
    //button4.layer.borderWidth = 1.0;
    button4.titleLabel.text = @"Document";
    [button4 setTitle:@"Document" forState:UIControlStateNormal];
    [button4 addTarget:nil action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
    [button4 setTag:5];
    
    [self addSubview:label1];
    [self addSubview:label2];
    [self addSubview:button1];
    [self addSubview:button2];
    [self addSubview:button3];
    [self addSubview:button4];
}

- (void) toolbarSendButton {
    NSLog(@"Calling Send View");
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(0, 0, 100, 39);
    [label1 setBackgroundColor:[UIColor clearColor]];
    label1.textColor = [UIColor lightTextColor];
    label1.font = [UIFont boldSystemFontOfSize:18];
    label1.layer.borderWidth = 2;
    label1.layer.borderColor = [UIColor clearColor].CGColor;
    [label1 setTextAlignment:UITextAlignmentCenter];
    [label1 setText:@"Send as"];
    
    button1 = [[UIButton alloc] init];
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
    button1.titleLabel.text = @"Email";
    [button1 setTitle:@"Email" forState:UIControlStateNormal];
    [button1 addTarget:nil action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTag:6];
    
    button2 = [[UIButton alloc] init];
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
    
    button2.titleLabel.text = @"Message";
    [button2 setTitle:@"Message" forState:UIControlStateNormal];
    [button2 addTarget:nil action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTag:7];
    
    [self addSubview:label1];
    [self addSubview:button1];
    [self addSubview:button2];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
