//
//  Liststring.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Liststring.h"
#import "Document.h"
#import "List.h"


@implementation Liststring

@dynamic aString;
@dynamic checked;
@dynamic order;
@dynamic creationDate;
@dynamic list;
@dynamic document;


- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSDate date] forKey:@"creationDate"];
    
}

@end
