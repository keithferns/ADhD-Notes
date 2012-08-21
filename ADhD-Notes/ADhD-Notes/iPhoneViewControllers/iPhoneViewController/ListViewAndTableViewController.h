//
//  ListViewAndTableViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"
@interface ListViewAndTableViewController : UIViewController <WEPopoverControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>


@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving, appending;
@property (nonatomic, retain) UITableView *tableView;

@end