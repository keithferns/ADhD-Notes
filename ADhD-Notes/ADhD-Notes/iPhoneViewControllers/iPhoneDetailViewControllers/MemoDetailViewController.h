//
//  MemoDetailViewController.h
//  iDoit
//
//  Created by Keith Fernandes on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface MemoDetailViewController : UITableViewController <UITextViewDelegate, WEPopoverControllerDelegate, UIActionSheetDelegate>{
    
    NewItemOrEvent *theItem;
    SimpleNote *theSimpleNote;
}

@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, retain) SimpleNote *theSimpleNote;
@property (nonatomic, readwrite) BOOL saving;

@end