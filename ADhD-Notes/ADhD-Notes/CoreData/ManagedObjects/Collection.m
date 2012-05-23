//
//  Collection.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Collection.h"
#import "Item.h"


@implementation Collection

@dynamic items;

- (void) awakeFromInsert{
    
[super awakeFromInsert];



[self setValue:[[NSDate date] timelessDate] forKey:@"aDate"];

}

@end
