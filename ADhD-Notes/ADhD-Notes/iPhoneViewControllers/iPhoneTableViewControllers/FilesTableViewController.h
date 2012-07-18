//
//  FilesTableViewController.h
//  WriteNow
//
//  Created by Keith Fernandes on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"

@interface FilesTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, UISearchBarDelegate> {

    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    BOOL saving;
    NewItemOrEvent *theItem;


}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic,retain) NewItemOrEvent *theItem;


- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)aPredicate; 

@end
