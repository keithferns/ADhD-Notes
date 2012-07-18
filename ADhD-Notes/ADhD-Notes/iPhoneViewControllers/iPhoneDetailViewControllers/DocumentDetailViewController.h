//
//  DocumentDetailViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface DocumentDetailViewController : UIViewController <UIActionSheetDelegate>{
    Document *theDocument;
    Liststring *theString;
    BOOL appending;
    NewItemOrEvent *theItem;

}
@property (nonatomic, readwrite) BOOL appending;
@property (nonatomic, retain) Document *theDocument;
@property (nonatomic, retain) Liststring *theString;
@property (nonatomic,retain) NewItemOrEvent *theItem;

@end
