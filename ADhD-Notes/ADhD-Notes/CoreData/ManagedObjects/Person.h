//
//  Person.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * fisrtName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * homePhone;
@property (nonatomic, retain) NSNumber * workPhone;
@property (nonatomic, retain) NSNumber * cellPhone;
@property (nonatomic, retain) NSSet *events;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
