//
//  MemoTableViewController.h
//  iDoit
//
//  Created by Keith Fernandes on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemoTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSDate *selectedDate;


//- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)aPredicate; 
- (void) getSelectedCalendarDate: (NSNotification *) notification;


@end
