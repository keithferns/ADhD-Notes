//
//  CustomDatePlaceCell.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomDatePlaceCell : UITableViewCell

@property (nonatomic, retain) UILabel *editDate, *placeLabel, *repeatLabel, *alarm1, *alarm2;
@property (nonatomic, retain) NSDate *aDate;

@end
