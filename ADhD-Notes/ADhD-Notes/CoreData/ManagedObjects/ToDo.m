//
//  ToDo.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ToDo.h"


@implementation ToDo




- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:3] forKey:@"type"];
    
}


@end
