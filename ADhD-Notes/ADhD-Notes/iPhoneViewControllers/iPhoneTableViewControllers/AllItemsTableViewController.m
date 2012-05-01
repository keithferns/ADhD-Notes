//
//  AllItemsTableViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AllItemsTableViewController.h"
#import "ADhD_NotesAppDelegate.h"

@interface AllItemsTableViewController ()



@end

@implementation AllItemsTableViewController


@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];
    

    if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"CURRENT TABLEVIEWCONTROLLER After managedObjectContext: %@",  managedObjectContext);
	}
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}                                                            
    
}



- (void)handleDidSaveNotification:(NSNotification *)notification {
    NSLog(@"NSManagedObjectContextDidSaveNotification Received By NotesTableViewController");
    self.fetchedResultsController = nil;
    [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    [self.tableView reloadData];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *) fetchedResultsController {
	if (_fetchedResultsController!=nil) {
		return _fetchedResultsController;
	}
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext]];
    
	NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES];
	NSSortDescriptor *textDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];// just here to test the sections and row calls
    
	[request setSortDescriptors:[NSArray arrayWithObjects:typeDescriptor,textDescriptor, nil]];

    
	[request setFetchBatchSize:10];
    
	NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"type" cacheName:@"Root"];
    
	newController.delegate = self;
	self.fetchedResultsController = newController;

	return _fetchedResultsController;
}

#pragma mark -
#pragma mark Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_fetchedResultsController sections] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo>  sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    int mySection;
    NSString *temp = @"";
    
    mySection = [[sectionInfo name] intValue];
    if (mySection == 0){
        temp = @"Notes";
    }
    else if (mySection == 1){
         temp = @"Lists";
    }
    else if (mySection == 2) {
         temp = @"Appointments";
    }
    else if (mySection == 3) {
         temp = @"Tasks";
    }
   
    return temp;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
    //return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
    static NSString *CellIdentifier = @"MyCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
       
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMMM yyyy h:mm a"];
    //[dateFormatter setDateFormat:@"EEEE, dd MMMM yyyy h:mm a"]; //This format gives the Day of Week, followed by date and time
    Event *currentItem = [_fetchedResultsController objectAtIndexPath:indexPath];	

   UILabel *aDateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,0,160,14)];
    [aDateLabel1 setFont: [UIFont systemFontOfSize:12]];
   UILabel *aDateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(160,0,320,14)];
    [aDateLabel2 setFont: [UIFont systemFontOfSize:12]];
    
    [cell.contentView addSubview:aDateLabel1];
    [cell.contentView addSubview:aDateLabel2];
    
    aDateLabel1.text  = [dateFormatter stringFromDate: currentItem.aDate];
    aDateLabel2.text = [currentItem.aDate description];
    
   UILabel *creationDayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,14,100,16)];
   UILabel *myTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,14,320,16)];
    
    [cell.contentView addSubview:myTextLabel];
    [cell.contentView addSubview:creationDayLabel];
    
    creationDayLabel.text  = currentItem.creationDay;
    myTextLabel.text = currentItem.text;
    
    UILabel *creationDateLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0,30,160,14)];
    UILabel *creationDateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(160,30,160,14)];
    [creationDateLabel1 setFont: [UIFont systemFontOfSize:12]];
    
    [creationDateLabel2 setFont: [UIFont systemFontOfSize:12]];
    
    [cell.contentView addSubview:creationDateLabel1];
    [cell.contentView addSubview:creationDateLabel2];
    
    if ([currentItem isKindOfClass:[Memo class]]){
        creationDateLabel1.text = [dateFormatter stringFromDate: currentItem.creationDate];
        creationDateLabel2.text = [currentItem.creationDate description];
    }else if([currentItem isKindOfClass:[Event class]]){
       // creationDateLabel1.text = [dateFormatter stringFromDate: currentItem.creationDate];
        
        creationDateLabel1.text = [currentItem.startTime description];

        creationDateLabel2.text = [currentItem.endTime description];
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
