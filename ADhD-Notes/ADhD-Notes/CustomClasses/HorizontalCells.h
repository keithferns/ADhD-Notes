//
//  HorizontalCells.h
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoTableViewController.h"
#import "EventTableViewController.h"

@interface HorizontalCells : UITableViewCell  {
    
    NSNumber *eventType;
}
@property (nonatomic, retain) MemoTableViewController *memoTV;
@property (nonatomic, retain) EventTableViewController *eventTV;
@property (nonatomic, retain) NSNumber *eventType;



@end
