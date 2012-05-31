//
//  Alarm.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Alarm : NSManagedObject

@property (nonatomic, retain) NSString * reminder;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSSet *event;
@end

@interface Alarm (CoreDataGeneratedAccessors)

- (void)addEventObject:(Event *)value;
- (void)removeEventObject:(Event *)value;
- (void)addEvent:(NSSet *)values;
- (void)removeEvent:(NSSet *)values;

@end
