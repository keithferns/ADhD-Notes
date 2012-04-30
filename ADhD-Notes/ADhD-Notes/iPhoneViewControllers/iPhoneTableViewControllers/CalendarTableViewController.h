//
//  CalendarTableViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"


@interface CalendarTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, UISearchBarDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSDate *selectedDate;

- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)aPredicate; 


- (void) getSelectedCalendarDate: (NSNotification *) notification;


@end
