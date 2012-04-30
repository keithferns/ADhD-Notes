//
//  NewMemo.m
//  WriteNow
//
//  Created by Keith Fernandes on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NewItemOrEvent.h"
#import "NSCalendar+CalendarCalculations.h"

@implementation NewItemOrEvent

@synthesize recurring;
@synthesize delegate;
@synthesize theMemo, theToDo, theAppointment, theProject, theFolder, theDocument, theSimpleNote, theList;
@synthesize addingContext;//note this MOC is an adding MOC passed from the parent.
@synthesize eventType;

@synthesize collection, priority, aDate, text, name, tags, sorter, editDate, type;





#pragma mark - CREATE NEW ITEMS


- (void) createNewSimpleNote{
NSLog(@"NewItemOrEvent: Creating New Simple Note");
    
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"SimpleNote" inManagedObjectContext:addingContext];
        theSimpleNote = [[SimpleNote alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    

        theSimpleNote.text = self.text;
        self.type = [NSNumber numberWithInt:0];
}

- (void) createNewList{
        
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:addingContext];
    
    theList = [[List alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    
    //FIXME: THIS SHOULD TAKE AN ARRAY OF STRING OBJECTS PASSED FROM A TEXT FEILD. 
    theList.text = self.text;
    self.type = [NSNumber numberWithInt:1];
    theList.type = [NSNumber numberWithInt:1];

    NSLog (@"Creating New List");
}

- (void) createNewAppointment{
        
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:addingContext];
                
    theAppointment = [[Appointment alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
    theAppointment.text = self.text;
    theList.type = [NSNumber numberWithInt:2];
    
    NSLog(@"Creating New Appointment");
                
    }
    
- (void) createNewToDo{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ToDo" inManagedObjectContext:addingContext];
                
    theToDo = [[ToDo alloc] initWithEntity:entity insertIntoManagedObjectContext:addingContext];    
                
    theToDo.text = self.text;
    theList.type = [NSNumber numberWithInt:2];
           
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
