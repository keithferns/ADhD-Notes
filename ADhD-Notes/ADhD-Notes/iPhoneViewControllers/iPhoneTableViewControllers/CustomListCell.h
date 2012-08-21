//
//  CustomListCell.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"
@interface CustomListCell : UITableViewCell

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) NSString *thetext;
@property (nonatomic, retain) NSNumber *theRow;
@property (nonatomic, retain) Liststring *theString;
@property (nonatomic, retain) UIView *selectedView;
@property (nonatomic, retain) UISlider *prioritySlider;
@property (nonatomic, retain) UITextField *due;
@property (nonatomic, retain) UIButton *alarm;

- (NSString *) getText; 

@end
