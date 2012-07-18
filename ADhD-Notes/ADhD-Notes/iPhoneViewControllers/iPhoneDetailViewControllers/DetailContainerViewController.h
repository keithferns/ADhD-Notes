//
//  DetailContainerViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"
@interface DetailContainerViewController : UIViewController<WEPopoverControllerDelegate,UINavigationControllerDelegate>{
    
    NewItemOrEvent *theItem;
    
}

@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;




@property (nonatomic, retain) List *theList;


@end
