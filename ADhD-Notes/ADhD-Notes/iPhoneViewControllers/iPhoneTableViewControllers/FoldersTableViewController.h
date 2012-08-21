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
    

    
}
@property (nonatomic,retain) NewItemOrEvent *theItem;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readwrite) BOOL saving;



- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate:(NSPredicate *)aPredicate; 


@end
