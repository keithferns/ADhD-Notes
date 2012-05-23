//
//  ArchiveViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WEPopoverController.h"
#import "NewItemOrEvent.h"


@interface ArchiveViewController : UIViewController <PopoverControllerDelegate, UIAlertViewDelegate, UITableViewDelegate>{
    NewItemOrEvent *theItem;
    BOOL saving;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;


- (UIView *) addItemsView: (CGRect) frame;

- (UIView *)organizerView: (CGRect)frame;
- (void) presentActionsPopover:(id) sender;

@end
