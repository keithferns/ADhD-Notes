//  MemoTableViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "MemoTableViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "EventsCell.h"
#import "MemoDetailViewController.h"

@implementation MemoTableViewController

@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize selectedDate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
       [self viewDidLoad];
    }
    return self;
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    selectedDate = nil;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    _fetchedResultsController.delegate = self;
    
       self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kBottomViewRect.size.height-kTabBarHeight);
    self.tableView.backgroundColor = [UIColor clearColor];
    self.clearsSelectionOnViewWillAppear = YES;

    if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"MemoTABLEVIEWCONTROLLER After managedObjectContext: %@",  managedObjectContext);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSelectedCalendarDate:) name:@"GetDateNotification" object:nil];
	}
    
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"FETCHING ERROR");
	}
}

- (void)handleDidSaveNotification:(NSNotification *)notification {
    NSLog(@"NSManagedObjectContextDidSaveNotification Received By MemoTableViewController");
    //FIXME: setting the fetchedResults controller to nil below is a temporary work-around for the problem created by having 1 row per section in the primary table view. 
    //self.fetchedResultsController = nil;
    
    [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"MEMOtableViewcont:handleDidSaveNotification -->did not save");
	}
    [self.tableView reloadData];
}

- (void) getSelectedCalendarDate: (NSNotification *) notification{
    selectedDate = [notification object];
    self.fetchedResultsController = nil;
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    [self.tableView reloadData];
}

- (void)viewDidUnload{
    [super viewDidUnload];
    
    self.managedObjectContext = nil;
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController{
        
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    if (_fetchedResultsController!=nil) {
		return _fetchedResultsController;
	}
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Memo" inManagedObjectContext:managedObjectContext]];
    selectedDate = [[NSDate date] timelessDate];
    NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate == %@", selectedDate];
    [request setPredicate:checkDate];
	NSSortDescriptor *timeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];    
	[request setSortDescriptors:[NSArray arrayWithObjects:timeDescriptor, nil]];
	[request setFetchBatchSize:10];
	NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
	newController.delegate = self;
	self.fetchedResultsController = newController;    
	return _fetchedResultsController;
 }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return [[_fetchedResultsController sections] count];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects]; 
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Memos";
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"EventsCell";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    EventsCell *cell = (EventsCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EventsCell alloc] init];
    }
     if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Memo class]]){
        Memo *currentMemo = [_fetchedResultsController objectAtIndexPath:indexPath];
        CGSize itemSize=CGSizeMake(kCellWidth-4, kCellHeight-25);
        UIGraphicsBeginImageContext(itemSize);
        [currentMemo.text drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height) withFont:[UIFont boldSystemFontOfSize:10]];
        UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.myTextView.image = theImage;
        //cell.myTextLabel.text = currentMemo.text;
        cell.dateLabel.text = [dateFormatter stringFromDate:currentMemo.creationDate];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || indexPath.row%2 == 0) {
        UIColor *altCellColor = [UIColor colorWithWhite:0.1 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
    else {
        UIColor *altCellColor = [UIColor colorWithWhite:0.7 alpha:0.1];
        cell.backgroundColor = altCellColor;
    }
}  

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
		[context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        // Save the context.
		NSError *error;
		if (![managedObjectContext save:&error]) {
			/*
			 Replace this implementation with code to handle the error appropriately.
			 
			 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
			 */
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
        }
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */
#pragma mark -
#pragma mark Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   [[NSNotificationCenter defaultCenter] postNotificationName:UITableViewSelectionDidChangeNotification object:[self.fetchedResultsController objectAtIndexPath:indexPath ]];   
}

#pragma mark -
#pragma mark Fetched Results Notifications

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch(type) {			
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"MemoTableViewController:FetchedResultsController ChangeInsert");
            break;
        case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"MemoTableViewController:FetchedResultsController: ChangeDelete");
            break;            
        case NSFetchedResultsChangeUpdate:
            [self.tableView cellForRowAtIndexPath:indexPath];
			//[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            NSLog(@"MemoTableViewController:FetchedResultsController: ChangeUpdate");
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"MemoTableViewController:FetchedResultsController ChangeMove");            
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;			
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
