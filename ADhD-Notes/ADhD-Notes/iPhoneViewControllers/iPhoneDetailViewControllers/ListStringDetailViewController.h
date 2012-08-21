//
//  ListStringDetailViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListStringDetailViewController : UIViewController <UITextFieldDelegate>{
    //
}

@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) List *theList;
@property (nonatomic, retain) Liststring *theString;

@end

