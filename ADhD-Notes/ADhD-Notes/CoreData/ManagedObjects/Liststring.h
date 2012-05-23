//
//  Liststring.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class List;

@interface Liststring : NSManagedObject

@property (nonatomic, retain) NSString * aString;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) List *list;

@end
