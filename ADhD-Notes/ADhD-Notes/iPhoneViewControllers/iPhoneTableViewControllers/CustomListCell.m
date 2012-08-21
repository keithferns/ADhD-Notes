//
//  CustomListCell.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomListCell.h"

#define kSliderHeight			7.0
#define kViewTag				1		// for tagging our embedded controls for removal at cell recycle time


@implementation CustomListCell
@synthesize textView, thetext, theRow;
@synthesize theString;
@synthesize prioritySlider, due, alarm, selectedView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:33]];        
        self.textView = [[UITextView alloc] initWithFrame:CGRectZero];
        self.textView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:33]];;        
        self.textView.alpha = 1.0;
        self.textView.font = [UIFont boldSystemFontOfSize:14];
        self.textView.textColor = [UIColor whiteColor];
        self.textView.userInteractionEnabled = NO;
        //cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        //self.textView.editable = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self setEditing:self.editing animated:YES];

        thetext = self.textView.text;
        
        CGSize size = [thetext sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(280, 60) lineBreakMode:UILineBreakModeWordWrap];
        CGFloat theight = MAX (size.height+10, 40);
        self.textView.frame = CGRectMake(0, 0, 280, theight);
        
        selectedView = [self selectedView];
        selectedView.frame = CGRectMake(0, theight, 320, 40);
        selectedView.tag = 1;	// tag this view for later so we can remove it from recycled table cells

        [self.contentView addSubview:selectedView]; 
        
        /*
        CGRect frame = CGRectMake(10, theight, 100.0, kSliderHeight);
        prioritySlider = [[UISlider alloc] initWithFrame:frame];
        //[prioritySlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        prioritySlider.backgroundColor = [UIColor clearColor];	
        UIImage *stetchLeftTrack = [[UIImage imageNamed:@"orangeslide.png"]
									stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];

        UIImage *stetchRightTrack = [[UIImage imageNamed:@"yellowslide.png"]
									 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [prioritySlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
        [prioritySlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [prioritySlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        [prioritySlider setMaximumTrackTintColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:1.0]];
        [prioritySlider setMinimumTrackTintColor:[UIColor colorWithRed:255 green:255 blue:0 alpha:1.0]];
        //[prioritySlider setThumbTintColor:[UIColor colorWithRed:0 green:0 blue:255 alpha:1.0]];
        prioritySlider.minimumValue = 0.0;
        prioritySlider.maximumValue = 100.0;
        prioritySlider.continuous = YES;
        prioritySlider.value = 50.0;

        [self.contentView addSubview:prioritySlider];
        
        due = [[UITextField alloc] initWithFrame:CGRectZero];
        due.frame = CGRectMake(120, theight, 80, 20);
        [self.contentView addSubview:due];
        due.placeholder = @"Due: NO";
        
        alarm = [UIButton buttonWithType: UIButtonTypeRoundedRect];
        alarm.titleLabel.font  = [UIFont systemFontOfSize: 12];
        alarm.titleLabel.lineBreakMode  = UILineBreakModeTailTruncation;
        alarm.titleLabel.shadowOffset  = CGSizeMake (1.0, 0.0);
        alarm.frame = CGRectMake(210, theight, 80, 20);
        [alarm setTitle:@"Reminders" forState:UIControlStateNormal];
        [self.contentView addSubview:alarm];
        */
                
    }else {
                
        self.textView.editable = NO;
        self.textView.textColor = [UIColor whiteColor];
        [self setEditing:self.editing animated:YES];
        self.textView.frame = CGRectMake(0, 0, 280, 40);
        [self.contentView addSubview:self.textView];    
        [self.selectedView removeFromSuperview];
        
        /*
        if (![self.thetext isEqualToString:self.textView.text] && [self.textView hasText]) {
            
            NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:theRow, @"row", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemEdited" object:self.textView.text userInfo:dict];
                  }
         */
        if ([self.thetext isEqualToString:self.textView.text]) {
            NSLog(@"No change in Text");
        }
    }
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    if (editing && self.selected) {
        [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        self.textView.userInteractionEnabled = YES;
        self.textView.editable = YES;
        self.textView.textColor = [UIColor blackColor];
        [self.textView becomeFirstResponder];
        /*
        CGSize size = [thetext sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(280, 60) lineBreakMode:UILineBreakModeWordWrap];
        CGFloat theight = MAX (size.height+10, 40);
        
        self.textView.frame = CGRectMake(0, 0, 280, theight);
        
        due.frame = CGRectMake(120, theight, 80, 25);
        [self.contentView addSubview:due];
        
        alarm.frame = CGRectMake(210, theight, 80, 25);
        alarm.titleLabel.text = @"Reminders";
        [self.contentView addSubview:alarm];
         */
        
    }  else if (!editing) {
        //NSLog(@"SETEDITING: Cell %d is NOT editing ", [self.theRow intValue]);
        [self.textView resignFirstResponder];
        self.textView.textColor = [UIColor whiteColor];
        self.textView.userInteractionEnabled = NO;
    }    
}


- (UIView *) selectedView   {
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40 )];
    tempView.layer.borderWidth = 2;
    tempView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:255 alpha:1].CGColor;

    //CGSize size = [thetext sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(280, 60) lineBreakMode:UILineBreakModeWordWrap];
    //CGFloat theight = MAX (size.height+10, 40);
    if (prioritySlider == nil) {
        CGRect frame = CGRectMake(10, 10, 100.0, kSliderHeight);
        prioritySlider = [[UISlider alloc] initWithFrame:frame];
        //[prioritySlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        prioritySlider.backgroundColor = [UIColor clearColor];	
        UIImage *stetchLeftTrack = [[UIImage imageNamed:@"orangeslide.png"]
									stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        UIImage *stetchRightTrack = [[UIImage imageNamed:@"yellowslide.png"]
									 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [prioritySlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
        [prioritySlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [prioritySlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        prioritySlider.minimumValue = 0.0;
        prioritySlider.maximumValue = 100.0;
        prioritySlider.continuous = YES;
        prioritySlider.value = 50.0;
		// Add an accessibility label that describes the slider.
		//[prioritySlider setAccessibilityLabel:NSLocalizedString(@"CustomSlider", @"")];
		//prioritySlider.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
        }
        [tempView addSubview:prioritySlider];


    due = [[UITextField alloc] initWithFrame:CGRectZero];
    due.frame = CGRectMake(115, 10, 80, 20);
    due.placeholder = @"Due: NO";
    [tempView addSubview:due];

    alarm = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    alarm.titleLabel.font  = [UIFont systemFontOfSize: 12];
    alarm.titleLabel.lineBreakMode  = UILineBreakModeTailTruncation;
    alarm.titleLabel.shadowOffset  = CGSizeMake (1.0, 0.0);
    alarm.frame = CGRectMake(200, 10, 80, 20);
    [alarm setTitle:@"Reminders" forState:UIControlStateNormal];
    [tempView addSubview:alarm];
    return tempView;
}



- (UISlider *)customSlider
{
    CGSize size = [thetext sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(280, 60) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat theight = MAX (size.height+10, 40);
    if (prioritySlider == nil) {
        CGRect frame = CGRectMake(10, theight, 100.0, kSliderHeight);
        prioritySlider = [[UISlider alloc] initWithFrame:frame];
        //[prioritySlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
        // in case the parent view draws with a custom color or gradient, use a transparent color
        prioritySlider.backgroundColor = [UIColor clearColor];	
        UIImage *stetchLeftTrack = [[UIImage imageNamed:@"orangeslide.png"]
									stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        UIImage *stetchRightTrack = [[UIImage imageNamed:@"yellowslide.png"]
									 stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
        [prioritySlider setThumbImage: [UIImage imageNamed:@"slider_ball.png"] forState:UIControlStateNormal];
        [prioritySlider setMinimumTrackImage:stetchLeftTrack forState:UIControlStateNormal];
        [prioritySlider setMaximumTrackImage:stetchRightTrack forState:UIControlStateNormal];
        prioritySlider.minimumValue = 0.0;
        prioritySlider.maximumValue = 100.0;
        prioritySlider.continuous = YES;
        prioritySlider.value = 50.0;
		
		// Add an accessibility label that describes the slider.
		//[prioritySlider setAccessibilityLabel:NSLocalizedString(@"CustomSlider", @"")];
		
		//prioritySlider.tag = kViewTag;	// tag this view for later so we can remove it from recycled table cells
    }
    return prioritySlider;
    
    /*
     UISlider *slider = [[UISlider alloc] init];   
     UIImage *sliderLeftTrackImage = [[UIImage imageNamed: @"slider_body_min.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];   
     UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"slider_body_max.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];   
     UIImage *sliderThumb = [[UIImage imageNamed: @"slider_thumb.png"] stretchableImageWithLeftCapWidth: 9 topCapHeight: 0];   
     [slider setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];   
     [slider setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];   
     [slider setThumbImage:sliderThumb forState:UIControlStateNormal]; 
     */
}

- (NSString *) getText{
    //NSString *temp;    
    return self.textView.text;
}

@end
