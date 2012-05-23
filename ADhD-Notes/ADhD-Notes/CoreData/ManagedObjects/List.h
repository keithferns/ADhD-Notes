//
//  List.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Memo.h"

@class Liststring;

@interface List : Memo

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSSet *aStrings;
@end

@interface List (CoreDataGeneratedAccessors)

- (void)addAStringsObject:(Liststring *)value;
- (void)removeAStringsObject:(Liststring *)value;
- (void)addAStrings:(NSSet *)values;
- (void)removeAStrings:(NSSet *)values;

@end
