//
//  FilesTableViewController.m
//  WriteNow
//
//  Created by Keith Fernandes on 10/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilesTableViewController.h"
#import "ADhD_NotesAppDelegate.h"

@implementation FilesTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize managedObjectContext, saving, theItem;


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
 
    _fetchedResultsController.delegate = self;
    
    self.tableView.frame = CGRectMake(0,kNavBarHeight+84,kScreenWidth, kScreenHeight-kNavBarHeight);
    self.tableView.backgroundColor = [UIColor blackColor];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    if (saving) {
        self.managedObjectContext = theItem.addingContext;
    }
    
    if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"After managedObjectContext: %@",  managedObjectContext);
	}
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    [searchBar setShowsCancelButton:YES animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartedSearching_Notification" object:nil];
}

- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EndedSearching_Notification" object:nil];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {    
    NSString * searchString = searchBar.text;
    NSLog(@"Search String is %@", searchString);    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat: @"name CONTAINS[c] %@", searchString];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:searchPredicate];
    
 	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    [self.tableView reloadData];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    
    [self.tableView reloadData];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Fetched Results Controller

- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate: (NSPredicate *) aPredicate {
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext]];
    [request setFetchBatchSize:10];
    [request setPredicate:aPredicate];
    
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
	[request setSortDescriptors:[NSArray arrayWithObjects:nameDescriptor, nil]];
    
    NSString *cacheName = @"Root";
    if (aPredicate) {
        cacheName = nil;
    }
	NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
	newController.delegate = self;
    NSError *anyError = nil;
    if (![newController performFetch:&anyError]){
        NSLog(@"Error Fetching:%@", anyError);
    }
    
	self.fetchedResultsController = newController;
	return _fetchedResultsController;
}


- (NSFetchedResultsController *) fetchedResultsController {
    if(_fetchedResultsController != nil){
        return _fetchedResultsController;
    }
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:nil];
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]){
        NSLog(@"Error Fetching:%@", error);
    }	
	return _fetchedResultsController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = [[_fetchedResultsController sections] count];
	if (count == 0) {
		count = 1;
	}
    return count;
}
/*
 - (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
 //id<NSFetchedResultsSectionInfo>  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
 
 //return [sectionInfo name];
 return @"My Files";
 }
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Document *theDocument = [_fetchedResultsController objectAtIndexPath:indexPath];	
    UILabel *docName = [[UILabel alloc] initWithFrame:CGRectMake(5,0,150,30)];
    docName.textAlignment = UITextAlignmentLeft;
    docName.backgroundColor = [UIColor clearColor];
    docName.textColor = [UIColor whiteColor];
    docName.font = [UIFont boldSystemFontOfSize:18.0];
    [cell.contentView addSubview:docName];
    
    [docName setText:theDocument.name];
}
    

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
	static NSString *CellIdentifier = @"DocumentCell";
    
    //Document *theDocument = [_fetchedResultsController objectAtIndexPath:indexPath];	
    
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:
                             CellIdentifier];
    if (cell == nil) {
        NSLog (@"Creating Cell");
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       // cell.textLabel.textColor = [UIColor whiteColor];
        }
	[self configureCell:cell atIndexPath:indexPath];
    return cell;
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
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */



- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing==YES) {
        NSNumber *ev = [NSNumber numberWithInt:3];
        NSLog(@"FolderTableViewController: editing = YES");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];
        
        
    } else if (editing==NO){
        NSLog(@"FolderTableViewController: editing = NO");
        NSNumber *ev = [NSNumber numberWithInt:2];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];
        
    }
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
            NSLog(@"FetchedResultsController ChangeInsert");
            break;
        case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"FetchedResultsController ChangeDelete");            
            break;
        case NSFetchedResultsChangeUpdate:
			[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            NSLog(@"FetchedResultsController ChangeUpdate");
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            NSLog(@"FetchedResultsController ChangeMove");
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FolderSavingNotification" object:[self.fetchedResultsController objectAtIndexPath:indexPath]];   
}

@end

//NOTE: THE FOLLOWING IS FROM THE EARLIER VERSION IN WHICH BOTH FOLDER AND FILES TABLE VIEW WERE CONTROLLER BY THE SAME TABLE VIEW CONTROLLER. 

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFiles:) name:@"HasToggledToFilesViewNotification" object:nil];

//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchFolders:) name:@"HasToggledToFoldersViewNotification" object:nil];

//isFolderView = YES;

/*
 - (void)fetchFiles:(NSNotification *)notification{
 isFolderView = NO;
 _fetchedResultsController = nil;
 NSLog(@"HAS TOGGLED TO FILES VIEW NOTIFICATION RECIEVED");
 [searchBar setPlaceholder:@"Search for File"];
 NSError *error;
 if (![[self fetchedResultsController] performFetch:&error]) {
 }
 [self.tableView reloadData];
 return;
 }
 
 - (void)fetchFolders:(NSNotification *)notification{
 isFolderView = YES;
 _fetchedResultsController = nil;
 NSLog(@"HAS TOGGLED TO FOLDERS VIEW NOTIFICATION RECIEVED");
 
 [searchBar setPlaceholder:@"Search for Folder"];
 NSError *error;
 if (![[self fetchedResultsController] performFetch:&error]) {
 }
 [self.tableView reloadData];
 
 return;
 }
 */

/*
 - (NSFetchedResultsController *) fetchedResultsControllerWithPredicate: (NSPredicate *) aPredicate {
 
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 if (isFolderView) {
 NSLog(@"SETTING NSENTITYDESCRIPTION TO FOLDER");
 [request setEntity:[NSEntityDescription entityForName:@"Folder" inManagedObjectContext:managedObjectContext]];
 }
 else if(!isFolderView){
 NSLog(@"SETTING NSENTITYDESCRIPTION TO FILE");
 
 [request setEntity:[NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext]];
 
 }
 [request setFetchBatchSize:10];
 [request setPredicate:aPredicate];
 
 NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
 [request setSortDescriptors:[NSArray arrayWithObjects:nameDescriptor, nil]];
 [nameDescriptor release];
 
 NSString *cacheName = @"Root";
 if (aPredicate) {
 cacheName = nil;
 }
 NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
 newController.delegate = self;
 NSError *anyError = nil;
 if (![newController performFetch:&anyError]){
 NSLog(@"Error Fetching:%@", anyError);
 }
 self.fetchedResultsController = newController;
 [newController release];
 [request release];
 return _fetchedResultsController;
 }
 
 - (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
 
 FileCustomCell *mycell;
 if([cell isKindOfClass:[UITableViewCell class]]){
 mycell = (FileCustomCell *) cell;
 }
 if (isFolderView) {
 Folder *aFolder = [_fetchedResultsController objectAtIndexPath:indexPath];	
 
 [mycell.folderName setText:aFolder.name];
 }
 else if (!isFolderView){
 File *aFile = [_fetchedResultsController objectAtIndexPath:indexPath];	
 
 [mycell.folderName setText:aFile.name];
 }
 
 }
 */
