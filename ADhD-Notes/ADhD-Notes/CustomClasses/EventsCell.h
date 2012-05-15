//
//  EventsCell.h
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EventsCell : UITableViewCell {
    UILabel *dateLabel;  
    UIImageView *_myTextView;
}

@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) UIImageView *myTextView;

@end
