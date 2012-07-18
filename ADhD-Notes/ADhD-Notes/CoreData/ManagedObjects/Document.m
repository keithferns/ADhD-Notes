//
//  Document.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Document.h"
#import "Liststring.h"


@implementation Document

@dynamic text;
@dynamic aStrings;

- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:5] forKey:@"type"];
    
}

@end
