//
//  ListViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListDetailViewController.h"


@interface ListViewController : UIViewController <WEPopoverControllerDelegate,UINavigationControllerDelegate>{
 
    NewItemOrEvent *theItem;
}

@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic, retain) List *theList;

@end
