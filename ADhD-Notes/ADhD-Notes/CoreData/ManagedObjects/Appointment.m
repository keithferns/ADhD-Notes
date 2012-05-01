//
//  Appointment.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Appointment.h"


@implementation Appointment



- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:2] forKey:@"type"];
    
}



@end
