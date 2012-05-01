//
//  Event.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Note.h"

@class Alarm, Location, Person;

@interface Event : Note

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSString * recurrence;
@property (nonatomic, retain) NSNumber * recurring;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) Alarm *alarms;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) Location *place;

@end
