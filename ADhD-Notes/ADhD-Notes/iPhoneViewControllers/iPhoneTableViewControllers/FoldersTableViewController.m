//  FoldersTableViewController.m
//  iDoit
//  Created by Keith Fernandes on 1/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ADhD_NotesAppDelegate.h"
#import "FoldersTableViewController.h"
#import "HorizontalCellsWithSections.h"

@interface FoldersTableViewController ()
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSNumber *deleting;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end

@implementation FoldersTableViewController
@synthesize lastIndexPath, fetchedResultsController = _fetchedResultsController, managedObjectContext, saving, deleting, theItem;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        //
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
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    _fetchedResultsController.delegate = self;
        
    self.tableView.frame = CGRectMake(0,kNavBarHeight+84,kScreenWidth, kScreenHeight-84);
    self.tableView.backgroundColor = [UIColor blackColor];

    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.separatorColor = [UIColor clearColor];
    if (saving) {
        NSLog(@"FolderTableViewController:viewDidLoad -> managedObjectContext is %@", self.managedObjectContext);
        self.managedObjectContext = [[NSManagedObjectContext alloc] init];
        self.managedObjectContext = theItem.addingContext;
        NSLog(@"FolderTableViewController:viewDidLoad -> theItem.addingContext is %@", self.managedObjectContext);
        NSLog(@"FolderTableViewController:viewDidLoad -> managedObjectContext is %@", self.managedObjectContext);
    }
    
    if (managedObjectContext == nil) { 
        NSLog(@"FolderTableViewController:viewDidLoad -> managedObjectContext is nil");
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"FoldersTableViewController:viewDidLoad -> After managedObjectContext: %@",  managedObjectContext);
        }
    
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:@"ViewWillAppearNotification" object:nil];
    
}
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

- (void)viewDidUnload {
    [super viewDidUnload];
    self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
        NSLog(@"VIEW WILL APPEAR");
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    NSLog(@"IndexPath.row for selected Row = %d", tableSelection.row);
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
    if (lastIndexPath != nil){
        NSLog(@"APPEARING AND RELOADING");
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tableSelection, lastIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    lastIndexPath = nil;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (theItem.theSimpleNote != nil){
        NSLog(@"ArchiveViewController: theSimpleNote text = %@", theItem.theSimpleNote.text);
        if (theItem.theFolder.items == nil) {
            theItem.theFolder.items = [NSSet setWithObject:theItem.theSimpleNote];
        } else {
            theItem.theFolder.items = [theItem.theFolder.items setByAddingObject:theItem.theSimpleNote];
        }
        theItem.theSimpleNote.editDate = [[NSDate date] timelessDate];
    } 
    NSLog(@"The Item text is %@", theItem.theSimpleNote.text);
    
    saving = NO;
    NSError *error;
    if(![managedObjectContext save:&error]){ 
        NSLog(@"Folders VIEW MOC:SaveFolderFile -> DID NOT SAVE");
    }
    [theItem saveNewItem];
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
    //if (isFolderView) {
    //    NSLog(@"SETTING NSENTITYDESCRIPTION TO FOLDER");
    [request setEntity:[NSEntityDescription entityForName:@"Folder" inManagedObjectContext:managedObjectContext]];
    //}
    //else if(!isFolderView){
    //    NSLog(@"SETTING NSENTITYDESCRIPTION TO FILE");
    
    //    [request setEntity:[NSEntityDescription entityForName:@"File" inManagedObjectContext:managedObjectContext]];
    
    //}
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows = 0;
    if ([[_fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
        numberOfRows = [sectionInfo numberOfObjects];
    }
    return numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat rowh = 0;
    Folder *theFolder = [_fetchedResultsController objectAtIndexPath:indexPath];
    if ([self.theItem.theFolder.name isEqualToString:theFolder.name]) {
        rowh =110;
    }else{
        rowh = 80;
    }
    return rowh;
}
/*
- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Folder *aFolder = [_fetchedResultsController objectAtIndexPath:indexPath];	
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"folder.png"]];
    imageView.frame = CGRectMake (0,0,120,80);
    [cell.contentView addSubview:imageView];

    UILabel *folderName = [[UILabel alloc] initWithFrame:CGRectMake(20,0,100,40)];
    folderName.textAlignment = UITextAlignmentCenter;
    folderName.backgroundColor = [UIColor clearColor];
    folderName.textColor = [UIColor whiteColor];
    folderName.font = [UIFont boldSystemFontOfSize:20];
    [cell.contentView addSubview:folderName];
    
    [folderName setText:aFolder.name];    
}
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"FolderCell";
    Folder *aFolder = [_fetchedResultsController objectAtIndexPath:indexPath];	
    UILabel *folderName;
	UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([[tableView cellForRowAtIndexPath:indexPath] isSelected]) {
        usleep(150000);
        
        static NSString * CellIdentifier = @"HorizontalCell";
        HorizontalCellsWithSections *cell = (HorizontalCellsWithSections *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil){
            cell = [[HorizontalCellsWithSections alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.frame.size.height)];

        }
        NSArray *objects = [aFolder.items allObjects];
        cell.myObjects = objects;
        cell.name = aFolder.name;

        return cell;
    }else if (cell == nil) {		
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        UIImage *folderImage = [[UIImage imageNamed:@"folder.png"] stretchableImageWithLeftCapWidth:60 topCapHeight:10];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:folderImage];
        imageView.frame = CGRectMake (0,0,200,80);
        [cell.contentView addSubview:imageView];
        
        UIImage *image = [UIImage imageNamed:@"folder_open_go.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width+10, image.size.height);
        button.frame = frame;	// match the button's size with the image size
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
        [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];

        cell.accessoryView = button;
        
        folderName = [[UILabel alloc] initWithFrame:CGRectMake(5,20,180,40)];
        folderName.textAlignment = UITextAlignmentCenter;
        folderName.backgroundColor = [UIColor clearColor];
        folderName.textColor = [UIColor whiteColor];
        folderName.font = [UIFont boldSystemFontOfSize:20];
        [cell.contentView addSubview:folderName];
			}          
            [folderName setText:aFolder.name];    
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

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button Index is %d", buttonIndex);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //UIAlertView *confirmDelete = [[UIAlertView alloc] initWithTitle:@"DELETE FOLDER" message:@"Deleting the folder will also delete its contents" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
        //[confirmDelete show];
     
        // Delete the row from the data source.
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        // Save the context.
        NSError *error;
        if (![context save:&error]) {
            
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
    //
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
        NSNumber *ev = [NSNumber numberWithInt:1];
        NSLog(@"FolderTableViewController: editing = YES");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];
        
        
    } else if (editing==NO){
        NSLog(@"FolderTableViewController: editing = NO");
        NSNumber *ev = [NSNumber numberWithInt:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];
    }
}

#pragma mark - Table view delegate

- (void)checkButtonTapped:(id)sender event:(id)event {
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil) {
		[self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"FolderFileSelectedNotification" object:[self.fetchedResultsController objectAtIndexPath:indexPath ]];   
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"FOLDER SELECTED");
    theItem.theFolder = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (saving) {
    self.theItem.saved = YES;
    if (theItem.theSimpleNote == nil && [theItem.type intValue] == 0){
        theItem.addingContext = theItem.theFolder.managedObjectContext;
        NSLog(@"Creating SimpleNote");
        [theItem createNewSimpleNote];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FolderSavingNotification" object:[self.fetchedResultsController objectAtIndexPath:indexPath ]];   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FolderSelectedNotification" object:[self.fetchedResultsController objectAtIndexPath:indexPath ]];   

    [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];

    
    //[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, lastIndexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
    self.lastIndexPath = indexPath;
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
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
			//[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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



@end