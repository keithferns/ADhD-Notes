//  HorizontalCells.h
//  WriteNow
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
#import "MemoTableViewController.h"
#import "EventTableViewController.h"
#import "AllItemsTableViewController.h"
@interface HorizontalCells : UITableViewCell  {
 
}

@property (nonatomic, retain) MemoTableViewController *memoTV;
@property (nonatomic, retain) EventTableViewController *eventTV;
@property (nonatomic, retain) AllItemsTableViewController *allItemsTVC; 


@end
