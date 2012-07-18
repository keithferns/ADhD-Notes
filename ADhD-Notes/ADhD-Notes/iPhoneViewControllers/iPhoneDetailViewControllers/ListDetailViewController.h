//
//  ListDetailViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface ListDetailViewController : UITableViewController<UIGestureRecognizerDelegate>{

NewItemOrEvent *theItem;
    
}

@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic, retain) List *theList;


//- (void) handleChecking:(UITapGestureRecognizer *)tapRecognizer;

@end
