//
//  CustomDatePlaceCell.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomDatePlaceCell.h"

@implementation CustomDatePlaceCell

@synthesize editDate, placeLabel, repeatLabel, alarm1, alarm2, aDate; 

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];   
        
        editDate = [[UILabel alloc] initWithFrame:CGRectMake(5,2,145,15)];
        editDate.backgroundColor = [UIColor blackColor];
        editDate.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        editDate.textColor = [UIColor whiteColor];
        editDate.textAlignment = UITextAlignmentLeft;
        //NSString *temp = [NSString stringWithFormat:@"%@", date];
        NSString *temp = @"editDate";

        editDate.text = temp;
        [self.contentView addSubview: editDate];
                
        //FIXME: add the key theItem.theMemo.aPlace
        placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,32,140,15)];
        placeLabel.backgroundColor = [UIColor blackColor];
        placeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        placeLabel.textColor = [UIColor whiteColor];
        placeLabel.textAlignment = UITextAlignmentLeft;
        temp = [NSString stringWithFormat:@"Some Place"];
        placeLabel.text = temp;
        [self addSubview: placeLabel];
        
        UILabel *labelrepeat = [[UILabel alloc] initWithFrame:CGRectMake (160,2,45,15)];
        labelrepeat.text = @"Repeat";
        labelrepeat.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(13.0)];
        labelrepeat.backgroundColor = [UIColor blackColor];
        labelrepeat.enabled = NO;
        [self.contentView addSubview:labelrepeat];
        
        repeatLabel = [[UILabel alloc] initWithFrame: CGRectMake (205,2,105,15)];
        repeatLabel.text = @"Never";
        repeatLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        repeatLabel.backgroundColor = [UIColor blackColor];
        repeatLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:repeatLabel];   
        
        UILabel *labelAlarm = [[UILabel alloc] initWithFrame:CGRectMake (160,17,45,15)];
        labelAlarm.text = @"Alerts";
        labelAlarm.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(13.0)];
        labelAlarm.backgroundColor = [UIColor blackColor];
        labelAlarm.enabled = NO;
        [self.contentView addSubview:labelAlarm];
        
        alarm1 = [[UILabel alloc] initWithFrame: CGRectMake (205,17,105,15)];
        alarm1.text = @"2 days before";
        alarm1.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        alarm1.backgroundColor = [UIColor blackColor];
        alarm1.textColor = [UIColor whiteColor];
        [self.contentView addSubview:alarm1];   
        
        alarm2 = [[UILabel alloc] initWithFrame: CGRectMake (205,32,105,15)];
        alarm2.text = @"15 minutes before";
        alarm2.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        alarm2.backgroundColor = [UIColor blackColor];
        alarm2.textColor = [UIColor whiteColor];
        [self.contentView addSubview:alarm2]; 
    
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    if (selected) {
        NSLog(@"CustomDatePlaceCell:Selected");
    }else if (!selected){
        NSLog(@"CustomDatePlaceCell:Not Selected");
   
    }
}

@end
