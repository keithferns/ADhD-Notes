//
//  Memo.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Memo.h"

@implementation Memo

- (void) awakeFromInsert{
    [super awakeFromInsert];
   
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [gregorian setLocale:[NSLocale currentLocale]];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];  
    int thehours = [timeComponents hour];
    int theminutes = [timeComponents minute];
    [timeComponents setYear:[timeComponents year]];
    [timeComponents setMonth:[timeComponents month]];
    [timeComponents setDay:[timeComponents day]];
    [timeComponents setHour:0];
    [timeComponents setMinute:0];
    [timeComponents setSecond:0];
    
    NSDate *temp = [gregorian dateFromComponents:timeComponents];
    [self setValue:temp forKey:@"aDate"];

    //set startTime to be 24-time. this will give the right order
    
    int theInverseTI = 24*60*60 - (thehours*60*60 + theminutes*60);
    NSDate *starts  = [temp dateByAddingTimeInterval:theInverseTI];
    [self setValue:starts forKey:@"startTime"];

}

@end
