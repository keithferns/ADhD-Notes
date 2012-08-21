//
//  AllItemsTableViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllItemsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>{

NSFetchedResultsController *_fetchedResultsController;
NSManagedObjectContext *managedObjectContext;

}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;


- (void) switchType: (NSInteger) type;


@end
