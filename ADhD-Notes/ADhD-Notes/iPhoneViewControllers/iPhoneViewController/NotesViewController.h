//
//  NotesViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface NotesViewController : UIViewController <WEPopoverControllerDelegate,UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate, UITextViewDelegate>


@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;


@end
