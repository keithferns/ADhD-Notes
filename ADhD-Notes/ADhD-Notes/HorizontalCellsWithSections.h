//
//  HorizontalCellsWithSections.h
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalCellsWithSections : UITableViewCell <UITableViewDataSource, UITableViewDelegate> {
    
    UITableView *_hTableView;
    NSArray *myObjects;

}

@property (nonatomic, retain) UITableView *hTableView;
@property (nonatomic, retain) NSArray *myObjects;
@property (nonatomic, retain) NSString *name;

@end
