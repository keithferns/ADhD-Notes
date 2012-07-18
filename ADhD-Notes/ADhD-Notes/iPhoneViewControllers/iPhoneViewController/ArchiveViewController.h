//
//  ArchiveViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewItemOrEvent.h"


@interface ArchiveViewController : UIViewController <WEPopoverControllerDelegate, UIAlertViewDelegate, UITableViewDelegate>{
    
    NewItemOrEvent *theItem;
    BOOL saving;
    NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic, readwrite) BOOL appending;
@property (nonatomic, retain) UISegmentedControl *archivingControl;

- (void) presentActionsPopover:(id) sender;

@end
