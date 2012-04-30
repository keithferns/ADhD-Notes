//
//  Document.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Document.h"


@implementation Document

@dynamic text;

- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:5] forKey:@"type"];
    
    [self setValue:@"Document" forKey:@"text"];
}

@end
