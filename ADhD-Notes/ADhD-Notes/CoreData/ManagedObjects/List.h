//
//  List.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Memo.h"

@class Liststring, ToDo;

@interface List : Memo

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSSet *aStrings;
@property (nonatomic, retain) ToDo *todo;
@end

@interface List (CoreDataGeneratedAccessors)

- (void)addAStringsObject:(Liststring *)value;
- (void)removeAStringsObject:(Liststring *)value;
- (void)addAStrings:(NSSet *)values;
- (void)removeAStrings:(NSSet *)values;

@end
