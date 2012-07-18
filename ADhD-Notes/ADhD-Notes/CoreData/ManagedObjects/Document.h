//
//  Document.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Collection.h"

@class Liststring;

@interface Document : Collection

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSSet *aStrings;
@end

@interface Document (CoreDataGeneratedAccessors)

- (void)addAStringsObject:(Liststring *)value;
- (void)removeAStringsObject:(Liststring *)value;
- (void)addAStrings:(NSSet *)values;
- (void)removeAStrings:(NSSet *)values;

@end
