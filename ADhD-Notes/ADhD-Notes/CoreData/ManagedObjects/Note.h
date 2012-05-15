//
//  Note.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Item.h"

@class Location;

@interface Note : Item

@property (nonatomic, retain) NSNumber * editing;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) Location *location;

@end
