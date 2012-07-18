//
//  Liststring.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Document, List;

@interface Liststring : NSManagedObject

@property (nonatomic, retain) NSString * aString;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) List *list;
@property (nonatomic, retain) Document *document;

@end
