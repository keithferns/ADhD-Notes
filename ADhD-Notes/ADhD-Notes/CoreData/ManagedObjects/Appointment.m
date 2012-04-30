//
//  Appointment.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Appointment.h"


@implementation Appointment

@dynamic startTime;
@dynamic endTime;



- (void) awakeFromInsert{
    [super awakeFromInsert];
    
    [self setValue:[NSNumber numberWithInt:2] forKey:@"type"];
    
}


@end
