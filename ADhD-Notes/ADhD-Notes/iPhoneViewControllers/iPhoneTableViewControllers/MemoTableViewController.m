//
//  MemoTableViewController.m
//  iDoit
//
//  Created by Keith Fernandes on 4/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MemoTableViewController.h"
#import "iDoitAppDelegate.h"
#import "Contants.h"
#import "EventsCell.h"

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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    [_fetchedResultsController release];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"MemoTableViewController:ViewDidLoad > loading");
    selectedDate = nil;
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSelectedCalendarDate:) name:@"GetDateNotification" object:nil];
    
    /*configure tableView, set its properties and add it to the main view.*/
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 320, 26)];
    [headerLabel setBackgroundColor:[UIColor lightGrayColor]];
    [headerLabel setText:@"MY STUFF"];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerView setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:headerLabel];
    //[tableView setTableHeaderView:headerView];
    //[tableView setSectionFooterHeight:0.0];
    //[tableView setSectionHeaderHeight:15.0];
    
    [headerLabel release];
    [headerView release];
    
    
    //[self.tableView setSeparatorColor:[UIColor blackColor]];
    //[self.tableView setSectionHeaderHeight:18];
    //self.tableView.rowHeight = kCellHeight;
    
    self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kBottomViewRect.size.height-kTabBarHeight);
    self.tableView.backgroundColor = [UIColor clearColor];
    
    if (managedObjectContext == nil) { 
		managedObjectContext = [(iDoitAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"MemoTABLEVIEWCONTROLLER After managedObjectContext: %@",  managedObjectContext);
	}
    
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"FETCHING ERROR");
	}
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 
}

- (void)handleDidSaveNotification:(NSNotification *)notification {
    NSLog(@"NSManagedObjectContextDidSaveNotification Received By WriteNowTableViewController");
    //FIXME: setting the fetchedResults controller to nil below is a temporary work-around for the problem created by having 1 row per section in the primary table view. 
    
    //self.fetchedResultsController = nil;
    
    [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
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
    NSLog(@"MemoTableViewController:fetchedResultsController -> Fetching");
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
    //check if an instance of fetchedResultsController exists.  If it does, return fetchedResultsController
    if (_fetchedResultsController!=nil) {
		return _fetchedResultsController;
	}
    //Else create a new fetchedResultsController
    //Create a new fetchRequest
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //set the entity to retrieved by this fetchrequest
    
    [request setEntity:[NSEntityDescription entityForName:@"Memo" inManagedObjectContext:managedObjectContext]];
    
    NSCalendar *gregorian = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];    
    [gregorian setLocale:[NSLocale currentLocale]];
    [gregorian setTimeZone:[NSTimeZone localTimeZone]];
    //[gregorian setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    //FIXME: Better way of setting the current timezone as the default and not as xx hours from GMT
    
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];    
    [timeComponents setYear:[timeComponents year]];
    [timeComponents setMonth:[timeComponents month]];
    [timeComponents setDay:[timeComponents day]];
    NSDate *currentDate= [gregorian dateFromComponents:timeComponents];
    
    NSLog(@"Current Date is %@", currentDate);
    
    if (selectedDate == nil) {
        NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate >= %@", currentDate];
        [request setPredicate:checkDate];
        checkDate = nil;
        NSLog(@"Repeat Current Date is %@", currentDate);

    }
    else {
        NSLog(@"SelectedDate is %@", selectedDate);
        
        //NSTimeZone *myTimeZone = [NSTimeZone localTimeZone];
        //NSInteger timeZoneOffset = [myTimeZone secondsFromGMT];
        //NSDate *temp = [selectedDate dateByAddingTimeInterval:-timeZoneOffset];
        
        
        NSDate *temp = [selectedDate dateByAddingTimeInterval:-kTimeZoneOffset];
        
        NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate == %@", temp];
        [request setPredicate:checkDate];
        checkDate = nil;
    }
        
	NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
 
    
	[request setSortDescriptors:[NSArray arrayWithObjects: dateDescriptor, nil]];
    //release the sort descriptors now that they are held by the request
    
    [dateDescriptor release];
    
	[request setFetchBatchSize:10];
    
    //Init a temp fetchedResultsController and set its fetchRequest to the current fetchRequest
    
	NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"aDate" cacheName:@"Root"];
    // NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Root"];
    
    
	newController.delegate = self;
	self.fetchedResultsController = newController;
    
    //release the temp fetchedResultsController and fetchrequest
    
	[newController release];
	[request release];
	
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
    //id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    //return [sectionInfo numberOfObjects];
    NSLog(@"Number of Objects = %d", [[_fetchedResultsController fetchedObjects] count]);

    return [[_fetchedResultsController fetchedObjects] count];
 
}



- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
    return @"Memos";
}



- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"MemoTableViewController: cellForRow - celling");
    static NSString * cellIdentifier = @"EventsCell";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    EventsCell *cell = (EventsCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[EventsCell alloc] init]autorelease];
    }
    
   
     if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Memo class]]){
         NSLog(@"MemoTableViewController: cellForRow - Object is a Memo");
        Memo *currentMemo = [_fetchedResultsController objectAtIndexPath:indexPath];
        CGSize itemSize=CGSizeMake(kCellWidth-4, kCellHeight-25);
        UIGraphicsBeginImageContext(itemSize);
        [[[currentMemo.rNote anyObject] text] drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height) withFont:[UIFont boldSystemFontOfSize:10]];
        UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.myTextView.image = theImage;
        //cell.myTextLabel.text = currentMemo.text;
        cell.dateLabel.text = [dateFormatter stringFromDate:currentMemo.creationDate];
    }
    [dateFormatter release];
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
            NSLog(@"WriteNowTableViewController:FetchedResultsController ChangeInsert");
            break;
            
        case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"WriteNowTableViewController:FetchedResultsController: ChangeDelete");
            
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self.tableView cellForRowAtIndexPath:indexPath];
			//[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            NSLog(@"WriteNowTableViewController:FetchedResultsController: ChangeUpdate");
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"WriteNowTableViewController:FetchedResultsController ChangeMove");
            
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