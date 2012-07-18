//
//  ToDo.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Event.h"

@class List;

@interface ToDo : Event

@property (nonatomic, retain) List *list;

@end
