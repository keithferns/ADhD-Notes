//
//  CustomToolBar.h
//  iDoit
//
//  Created by Keith Fernandes on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomToolBar : UIToolbar {
    
    UIBarButtonItem *firstButton, *secondButton, *thirdButton, *fourthButton, *fifthButton, *flexSpace;
    UIButton *titleButton;
    UISearchBar *searchBar;
}

@property (nonatomic, retain) UIBarButtonItem *firstButton,  *secondButton, *thirdButton, *fourthButton, *fifthButton, *flexSpace;
@property (nonatomic, retain) UIButton *titleButton;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (readonly) UIImage *flipperImageForDateNavigationItem;
@property (nonatomic, retain) NSArray *myItems;

- (void) changeToSchedulingButtons;
- (void) changeToEditingButtons;
- (void) changeToDetailButtons;
- (void) changeToTopButtons:(NSString *)type;


@end
/*
- (void) toggleDateButton:(id)sender;
- (void) toggleStartButton:(id)sender;
- (void) toggleEndButton:(id)sender;
- (void) toggleRecurButton:(id)sender;
*/