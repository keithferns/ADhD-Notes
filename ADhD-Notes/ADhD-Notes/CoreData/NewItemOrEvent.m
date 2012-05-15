//
//  NewMemo.m
//  WriteNow
//
//  Created by Keith Fernandes on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewItemOrEvent.h"
#import "NSCalendar+CalendarCalculations.h"
#import "Constants.h"

@implementation NewItemOrEvent

@synthesize recurring;
@synthesize delegate;
@synthesize theMemo, theToDo, theAppointment, theProject, theFolder, theDocument, theSimpleNote, theList;
@synthesize addingContext;//note this MOC is an adding MOC passed from the parent.
@synthesize eventType;

@synthesize collection, priority, text, name, tags, sorter, type, listArray;

@synthesize aDate, startTime, endTime, editDate;


#pragma mark - DATA 

- (void) saveSchedule {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [gregorian setLocale:[NSLocale currentLocale]];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];

    //Convert the Appointment Date
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:self.aDate];  
    [timeComponents setYear:[timeComponents year]];
    [timeComponents setMonth:[timeComponents month]];
    [timeComponents setDay:[timeComponents day]];
    
    NSDate *tempDate= [gregorian dateFromComponents:timeComponents];
    //self.aDate = [tempDate dateByAddingTimeInterval:kTimeZoneOffset];
    self.aDate = tempDate;
    NSLog(@"the New aDate is %@", self.aDate);

    //Convert Start Time. 
    
    timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.startTime];
    int thehours = [timeComponents hour];
    int theminutes = [timeComponents minute];
    NSTimeInterval theTI = thehours*60*60 + theminutes*60;
    
    self.startTime = [self.aDate dateByAddingTimeInterval: theTI];


    
    //Convert End Time
    timeComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:self.endTime];
    thehours = [timeComponents hour];
    theminutes = [timeComponents minute];
    theTI = thehours*60*60 + theminutes*60;
    self.endTime = [self.aDate dateByAddingTimeInterval: theTI];
    NSLog(@"the endTime is %@", self.endTime);


}

#pragma mark - CREATE NEW ITEMS


- (void) createNewSimpleNote{
NSLog(@"NewItemOrEvent: Creating New Simple Note");
    
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SimpleNote" inManagedObjectContext:addingContext];
        theSimpleNote = [[SimpleNote alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    

        theSimpleNote.text = self.text;
        self.type = [NSNumber numberWithInt:0];
    
    NSLog(@"Simple Note aDate is %@", self.aDate);
    
    NSLog(@"Simple Note startTime is %@", theSimpleNote.startTime);
}

- (void) createNewList{
        
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:addingContext];
    
    theList = [[List alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    
    //FIXME: THIS SHOULD TAKE AN ARRAY OF STRING OBJECTS PASSED FROM A TEXT FEILD. 
    theList.text = self.text;
    self.type = [NSNumber numberWithInt:1];
    theList.type = [NSNumber numberWithInt:1];
    NSString *tempString = [NSString stringWithFormat:@"-"];
    
    for (int i = 0; i<[listArray count]; i++) {
        tempString = [tempString stringByAppendingString:[listArray objectAtIndex:i]];
        tempString = [tempString stringByAppendingString:@"\n-"];
    }
    theList.text = tempString;
    
    NSLog (@"THE LIST TEXT IS %@", tempString);

    NSLog (@"Creating New List");
}

- (void) createNewAppointment{
        
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:addingContext];
                
    theAppointment = [[Appointment alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    theAppointment.text = self.text;
    theAppointment.type = [NSNumber numberWithInt:2];
    theAppointment.aDate = self.aDate;
    theAppointment.startTime = self.startTime;
    theAppointment.endTime = self.endTime;
    theAppointment.recurrence = self.recurring;
    
    NSLog(@"Creating New Appointment");
                
}
    
- (void) createNewToDo{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:addingContext];
                
    theToDo = [[ToDo alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
                
    theToDo.text = self.text;
    theToDo.type = [NSNumber numberWithInt:3];
    theToDo.aDate = self.aDate;
    theToDo.startTime = self.startTime;
    theToDo.endTime = self.endTime;
    theToDo.recurrence = self.recurring;        
}

 
- (void) createNewFolder{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:addingContext];
                
    theFolder = [[Folder alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    
                
    }

- (void) createNewDocument{

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:addingContext];
                
    theDocument = [[Document alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
            
    }
- (void) createNewProject{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Project" inManagedObjectContext:addingContext];
    
    theProject = [[Project alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    
    //.. Other init
    
}
    
- (void) addDateField{
    
    return;
}

- (void) updateSelectedDate:(NSDate *)date{
//
    return;
}

- (void) updateText:(NSString *) currentText{
    //if the text is changed since creation of the appointment
    if (currentText == @"") {
        //put up an alert view.
        return;
    }
    else if (![self.text isEqualToString:text]){
        self.text = currentText;
    }
    return;
}

- (void) saveNewItem {
    NSLog(@"NewItemOrEvent: Saving New Item");
    

    /*--Save the MOC--*/
    NSError *error;
    if(![addingContext save:&error]){ 
        NSLog(@"NEWITEMOREVENT ADDING MOC: DID NOT SAVE");
    } 
    //
}

- (void) deleteItem:(id)sender{
    
    //FIXME
    //[addingContext deleteObject:theNote];
    
}

#pragma mark - Get Values From Event Objects

- (NSArray *) dateTimeArrayfromObject: (id)theObject{
    
    
    NSArray *theArray = [theObject allObjects];
    
    return theArray;
}

-(NSArray *) alarmArrayFromEventObject:(id)theObject{
        
    
    NSArray *theArray = [theObject allObjects];
    
    return theArray;
}


@end
