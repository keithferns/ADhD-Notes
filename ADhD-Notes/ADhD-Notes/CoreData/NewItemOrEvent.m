//  NewMemo.m
//  ADhD-Notes
//  Created by Keith Fernandes on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.

#import "NewItemOrEvent.h"

@implementation NewItemOrEvent

@synthesize delegate, theMemo, theToDo, theAppointment, theProject, theFolder, theDocument, theSimpleNote,theList, theString,theTag, addingContext, saving;
@synthesize eventType, collection, priority, text, name, tags, sorter, type, listArray;
@synthesize aDate, startTime, endTime, editDate, location, recurring, alarm1, alarm2, alarm3, alarm4,  alarmArray, tagArray;

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
}

- (void)addNotificationForObject: (id)myObject {
    Appointment *myAppointment = myObject;
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    if (localNotification == nil){
        return;
        }
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = [myAppointment.startTime dateByAddingTimeInterval: -120];
    //localNotification.alertAction = @”View”;
    localNotification.alertBody = myAppointment.text;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    //NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
    //localNotification.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

#pragma mark - CREATE NEW ITEMS

- (void) createNewSimpleNote {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SimpleNote" inManagedObjectContext:addingContext];
        theSimpleNote = [[SimpleNote alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
        theSimpleNote.text = self.text;
        self.type = [NSNumber numberWithInt:0];
        if (tagArray != nil) {
        theSimpleNote.tags = [NSSet setWithArray:tagArray];
    }    
    theSimpleNote.editDate = [[NSDate date] timelessDate];
}

- (Liststring *) createNewListString: (NSString *) thetext {
     NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liststring" inManagedObjectContext:addingContext];
    theString = [[Liststring alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext]; 
    theString.aString = thetext;
    return theString;
}
- (void) createListstringsFromArray {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liststring" inManagedObjectContext:addingContext];
    theList.aStrings = [[NSSet alloc] init];
    for (int i = 0; i < [listArray count]; i++) {     
        theString = [[Liststring alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext]; 
        theString.aString = [listArray objectAtIndex:i];
        theString.order = [NSNumber numberWithInt:i];
        theList.aStrings = [theList.aStrings setByAddingObject:theString];
        theList.editDate = [[NSDate date] timelessDate];
    }
}


- (void) createNewList{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:addingContext];
    theList = [[List alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    
    self.type = [NSNumber numberWithInt:1];
    theList.type = [NSNumber numberWithInt:1];
    [self createListstringsFromArray];
    
    NSString *tempString = [listArray objectAtIndex:0];
    
    for (int i = 1; i<[listArray count]; i++) {
        ;
        tempString = [tempString stringByAppendingString:@"\n"];
        tempString = [tempString stringByAppendingString:[listArray objectAtIndex:i]];
    }
    theList.text = tempString;
    theList.editDate = [[NSDate date] timelessDate];
}

- (void) createNewStringFromText:(NSString *)mytext withType:(NSInteger) theInt {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liststring" inManagedObjectContext:addingContext];
    theString = [[Liststring alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext]; 
    
    if (theInt == 2) {
        if (alarmArray == nil) {
            alarmArray = [[NSArray alloc] init];
        }
        alarmArray = [alarmArray arrayByAddingObject:theString];
        theString.order = [NSNumber numberWithInt:[alarmArray count]-1];
    }
}


- (void) createNewTagFromText:(NSString *)mytext forType: (NSInteger) myType {
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:addingContext];
    theTag = [[Tag alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext]; 
    theTag.name = mytext;
    switch(myType){
        case 0:
            theSimpleNote.tags = [theSimpleNote.tags setByAddingObject:theTag];
            break;
        case 1:
            theList.tags = [theList.tags setByAddingObject: theTag];
            break;
        case 2: 
            theAppointment.tags = [theAppointment.tags setByAddingObject:theTag];
            break;
        case 3:
            theToDo.tags = [theToDo.tags setByAddingObject:theTag];
            break;
        default:
            break;
    }
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
    if (alarmArray != nil) {
        theAppointment.alarms = [NSSet setWithArray:alarmArray];
    }    
    [self addNotificationForObject:self.theAppointment];    
    /*
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    EKEvent *myEvent  = [EKEvent eventWithEventStore:eventDB];    
    myEvent.title     = @"New Event";
    myEvent.startDate = [[NSDate alloc] init];
    myEvent.endDate   = [[NSDate alloc] init];
    myEvent.allDay = YES;    
    [myEvent setCalendar:[eventDB defaultCalendarForNewEvents]];
    NSError *err;
    [eventDB saveEvent:myEvent span:EKSpanThisEvent error:&err];
    
     if (err == noErr) {
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:@"Event Created"
     message:@"Yay!"
     delegate:nil
     cancelButtonTitle:@"Okay"
     otherButtonTitles:nil];
     [alert show];
     }
     */
}
    
- (void) createNewToDo{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:addingContext];
    theToDo = [[ToDo alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];
    
    theToDo.list = theList;
    theToDo.type = [NSNumber numberWithInt:3];
    theToDo.aDate = self.aDate;
    theToDo.startTime = self.startTime;
    theToDo.endTime = self.endTime;
    theToDo.recurrence = self.recurring;   
    
    if (alarmArray != nil) {
        theToDo.alarms = [NSSet setWithArray:alarmArray];
    }  
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
    
- (void) updateSchedule{
    if (self.theAppointment != nil) {
        theAppointment.aDate = self.aDate;
        theAppointment.startTime = self.startTime;
        theAppointment.endTime = self.endTime;
        theAppointment.recurrence = self.recurring;
    }
    else if (self.theToDo != nil){
        theToDo.aDate = self.aDate;
        theToDo.recurrence = self.recurring;
    }
    NSError *error;
    if(![addingContext save:&error]){ 
        NSLog(@"NEWITEMOREVENT ADDING MOC: DID NOT SAVE");
    } 
    return;
}

- (void) updateText:(NSString *) currentText{
    //if the text is changed since creation of the appointment
    if (currentText == @"") {
        //put up an alert view.
        return;
    }
    else if (![self.text isEqualToString:currentText]){
        self.text = currentText;
        if (theToDo != nil){
            theToDo.text = self.text;
        }
        else if (theAppointment != nil){
            theAppointment.text = self.text;
        }
        else if (theSimpleNote != nil){
            theSimpleNote.text = self.text;
        }
    }
    /*--Save the MOC--*/
    NSError *error;
    if(![addingContext save:&error]){ 
        NSLog(@"NEWITEMOREVENT ADDING MOC: DID NOT SAVE");
    } 
    return;
}

- (void) saveNewItem {    
    /*--Save the MOC--*/
    NSError *error;
    if(![addingContext save:&error]){ 
        NSLog(@"NEWITEMOREVENT ADDING MOC: DID NOT SAVE");
    } 
    //
}

- (void) deleteItem:(NSManagedObject *)theObject{
    [addingContext deleteObject:theObject];
    /*--Save the MOC--*/
    NSError *error;
    if(![addingContext save:&error]){ 
        NSLog(@"NEWITEMOREVENT ADDING MOC: DID NOT SAVE");
    } 
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
