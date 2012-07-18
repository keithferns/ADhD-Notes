//
//  TagsDetailViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagsDetailViewController : UITableViewController

@property (nonatomic,retain) NSMutableArray *theArray;
@property (nonatomic, retain) Tag *theTag;
@property (nonatomic, retain) Item *theItem;
@end
