//
//  Folder.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Folder.h"


@implementation Folder


- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:4] forKey:@"type"];
    
}
@end
