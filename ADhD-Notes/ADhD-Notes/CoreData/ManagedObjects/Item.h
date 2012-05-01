//
//  Item.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Collection, Tag;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * creationDay;
@property (nonatomic, retain) NSDate * editDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSString * sectionIdentifier, *primitiveSectionIdentifier;
@property (nonatomic, retain) NSDate * aDate, *primitiveADate;
@property (nonatomic, retain) NSNumber * sorter;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet *collection;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addCollectionObject:(Collection *)value;
- (void)removeCollectionObject:(Collection *)value;
- (void)addCollection:(NSSet *)values;
- (void)removeCollection:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
