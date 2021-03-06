//
//  EventsTableViewController2.h
//  iDoit
//
//  Created by Keith Fernandes on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface EventsTableViewController2 : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    NSDate *selectedDate;
    NSNumber *eventType;

    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, readwrite) BOOL calendarIsVisible;
@property (nonatomic, readwrite) NSNumber *eventType;

- (void) getSelectedCalendarDate: (NSNotification *) notification;


@end
