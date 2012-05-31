//
//  AppointmentDetailViewController.h
//  iDoit
//
//  Created by Keith Fernandes on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface AppointmentDetailViewController : UITableViewController <UITextViewDelegate>{

    NewItemOrEvent *theItem;

}
  
@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, readwrite) BOOL saving;


@end
