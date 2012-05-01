//
//  Collection.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Collection.h"
#import "Item.h"


@implementation Collection

@dynamic items;

- (void) awakeFromInsert{
    
[super awakeFromInsert];
NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
[gregorian setLocale:[NSLocale currentLocale]];
[gregorian setTimeZone:[NSTimeZone localTimeZone]];

NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];  

[timeComponents setYear:[timeComponents year]];
[timeComponents setMonth:[timeComponents month]];
[timeComponents setDay:[timeComponents day]];


[self setValue:[gregorian dateFromComponents:timeComponents] forKey:@"aDate"];

}

@end
