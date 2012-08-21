//
//  List.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "List.h"
#import "Liststring.h"
#import "ToDo.h"


@implementation List

@dynamic category;
@dynamic aStrings;
@dynamic todo;

- (void) awakeFromFetch{
    [super awakeFromFetch];
 
}

- (void) willSave{
    /*
     NSArray *listStrings = [self.aStrings allObjects];
     NSString *tempString = [[listStrings objectAtIndex:0] aString];
     
     for (int i = 1; i<[listStrings count]; i++) {
     ;
     tempString = [tempString stringByAppendingString:@"\n"];
     tempString = [tempString stringByAppendingString:[listStrings objectAtIndex:i]];
     }
     self.text = tempString;   
     */
    
}


@end
