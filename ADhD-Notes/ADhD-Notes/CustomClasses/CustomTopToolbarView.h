//
//  CustomTopToolbarView.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTopToolbarView : UIView

@property (nonatomic, retain) UIButton *leftButton, *middleButton, *rightButton;
@property (nonatomic, retain) UILabel *dateLabel;
@property (nonatomic, retain) UISearchBar *searchBar;


- (void) setAppendOrSave:(id)type;  
- (void) setDiaryDate:(NSDate *)date;
- (void) setItemTitle: (NSString *)title;
- (void) setAppointmentTimeFrom: (NSDate *)start Till:(NSDate *)end;


@end
