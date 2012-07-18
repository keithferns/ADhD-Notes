//
//  FoldersTableViewController.h
//  iDoit
//
//  Created by Keith Fernandes on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewItemOrEvent.h"
@interface FoldersTableViewController : UITableViewController<NSFetchedResultsControllerDelegate, UISearchBarDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
    BOOL saving;
    NewItemOrEvent *theItem;
    
    
}
@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readwrite) BOOL saving;
@property (nonatomic, retain) NSString *selectedFolder;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSNumber *deleting;


- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)aPredicate; 


@end
