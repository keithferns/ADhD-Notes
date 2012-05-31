//
//  NewMemo.h
//  WriteNow
//
//  Created by Keith Fernandes on 11/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@protocol NewItemOrEventDelegate <NSObject>


@end

@interface NewItemOrEvent : NSObject  {
    
    Appointment *theAppointment;
    ToDo *theToDo;
    Memo *theMemo;
    List *theList;
    Project *theProject;
    Folder *theFolder;
    Document *theDocument;
    Liststring *theString;
    
    NSManagedObjectContext *addingContext;
    __unsafe_unretained id<NewItemOrEventDelegate> delegate;

}

@property (nonatomic, retain) NSManagedObjectContext *addingContext;
@property (unsafe_unretained) id delegate;

@property (nonatomic, retain) NSNumber *eventType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * sorter;
@property (nonatomic, retain) NSDate * editDate;
@property (nonatomic, retain) NSNumber * priority;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * aDate, *startTime, *endTime;
@property (nonatomic, retain) NSSet *collection;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSString *recurring, *location, *alarm1, *alarm2, *alarm3, *alarm4;
@property (nonatomic, retain) NSArray *listArray, *alarmArray, *tagArray;

@property (nonatomic, retain) Appointment *theAppointment;
@property (nonatomic, retain) ToDo *theToDo;
@property (nonatomic, retain) Memo *theMemo;
@property (nonatomic, retain) List *theList;
@property (nonatomic, retain) Project *theProject;
@property (nonatomic, retain) Folder *theFolder;
@property (nonatomic, retain) Document *theDocument;
@property (nonatomic, retain) SimpleNote *theSimpleNote;
@property (nonatomic, retain) Liststring *theString;
@property (nonatomic, retain) Tag *theTag;

- (void) createNewSimpleNote;
- (void) createNewStringFromText:(NSString *)mytext withType:(NSInteger) theInt;
- (void) createNewTagFromText:(NSString *)mytext forType: (NSInteger) myType;

- (void) createNewList;
- (void) createNewAppointment;
- (void) createNewToDo;
- (void) createNewFolder;
- (void) createNewDocument;
- (void) createNewProject;

- (void) saveSchedule;
- (void) updateSchedule;
- (void) saveNewItem;
- (void) deleteItem:(id)sender;
- (void) updateText:(NSString *) currentText;

@end