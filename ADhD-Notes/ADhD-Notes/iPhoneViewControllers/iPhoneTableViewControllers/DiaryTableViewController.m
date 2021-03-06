//
//  DiaryTableViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiaryTableViewController.h"
#import "ADhD_NotesAppDelegate.h"

@implementation DiaryTableViewController


@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize selectedDate;

- (id)initWithStyle:(UITableViewStyle)style
{
self = [super initWithStyle:style];
if (self) {
    // Custom initialization
}
return self;
}

- (void)didReceiveMemoryWarning
{
// Releases the view if it doesn't have a superview.
[super didReceiveMemoryWarning];

// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];  
    [timeComponents setYear:[timeComponents year]];
    [timeComponents setMonth:[timeComponents month]];
    [timeComponents setDay:[timeComponents day]];
    [timeComponents setHour:0];
    [timeComponents setMinute:0];
    [timeComponents setSecond:0];
    selectedDate = [gregorian dateFromComponents:timeComponents];
    
[NSFetchedResultsController deleteCacheWithName:@"Root"];
_fetchedResultsController.delegate = self;


[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSelectedCalendarDate:) name:@"GetSelectedDateNotification" object:nil];

/*configure tableView, set its properties and add it to the main view.*/

//[tableView setTableHeaderView:headerView];
//[tableView setSectionFooterHeight:0.0];
//[tableView setSectionHeaderHeight:15.0];
//[self.tableView setSeparatorColor:[UIColor blackColor]];
//[self.tableView setSectionHeaderHeight:18];
//self.tableView.rowHeight = kCellHeight;

self.tableView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight-kTabBarHeight);
self.tableView.backgroundColor = [UIColor blackColor];

if (managedObjectContext == nil) { 
    managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    NSLog(@"Diary TABLEVIEWCONTROLLER After managedObjectContext: %@",  managedObjectContext);
}

NSError *error;
if (![[self fetchedResultsController] performFetch:&error]) {
}
    
    NSArray *theArray = [_fetchedResultsController fetchedObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetNotesArrayNotification" object:theArray];

//KVO (Key Value Observing). Do a search on "Key-Value Observing Quick Start" in the XCode help system for more info.  You would want to make objects that need to be notified of changes call observeValueForKeyPathfObject:change:context: on the data container object. Then, they will get notified automatically when the object changes.
}


- (void)handleDidSaveNotification:(NSNotification *)notification {
NSLog(@"NSManagedObjectContextDidSaveNotification Received By DiaryTableViewController");
    //FIXME: setting the fetchedResults controller to nil below is a temporary work-around for the problem created by having 1 row per section in the primary table view. 

    //self.fetchedResultsController = nil;

    [managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        }
    [self.tableView reloadData];
}

- (void) getSelectedCalendarDate: (NSNotification *) notification{
    NSLog(@"DiaryTableViewController:getSelectedCalendarDate: Notification Received");
    selectedDate = [notification object];
    self.fetchedResultsController = nil;
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
    }
    
    NSArray *theArray = [_fetchedResultsController fetchedObjects];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GetNotesArrayNotification" object:theArray];
    
    [self.tableView reloadData];
}

- (void)viewDidUnload{
    [super viewDidUnload];

    self.managedObjectContext = nil;
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated{
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


#pragma mark -
#pragma mark Fetched results controller


- (NSFetchedResultsController *) fetchedResultsController{
    NSLog(@"Fetching");

    [NSFetchedResultsController deleteCacheWithName:@"Root"];

    //check if an instance of fetchedResultsController exists.  If it does, return fetchedResultsController
    if (_fetchedResultsController != nil){
        return _fetchedResultsController;
        }
    //Else create a new fetchedResultsController
    //Create a new fetchRequest
        NSFetchRequest *request = [[NSFetchRequest alloc] init];

    //set the entity to retrieved by this fetchrequest
    [request setEntity:[NSEntityDescription entityForName:@"Note" inManagedObjectContext:managedObjectContext]];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];    
    [timeComponents setYear:[timeComponents year]];
    [timeComponents setMonth:[timeComponents month]];
    [timeComponents setDay:[timeComponents day]];
    
    NSDate *currentDate= [gregorian dateFromComponents:timeComponents];
    if (selectedDate == nil){
        NSLog(@"DiaryTableViewController: CurrentDate is %@", currentDate);

        NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate == %@", currentDate];
        [request setPredicate:checkDate];
        checkDate = nil;
    }else if (selectedDate != nil) {
    
        NSLog(@"DiaryTableViewController: SelectedDate is %@", selectedDate);
        NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate == %@", selectedDate];
        [request setPredicate:checkDate];
        checkDate = nil;
    }
    //create the sort descriptors which will sort rows in the table view

    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    //NSSortDescriptor *textDescriptor = [[NSSortDescriptor alloc] initWithKey:@"rNote.text" ascending:YES];


    [request setSortDescriptors:[NSArray arrayWithObjects:dateDescriptor, nil]];

    [request setFetchBatchSize:20];

    //Init a temp fetchedResultsController and set its fetchRequest to the current fetchRequest

    NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Root"];

    //set the controller delegate
    [newController setDelegate:self];
    self.fetchedResultsController = newController;

    NSLog(@"End Fetching");
    return _fetchedResultsController;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[_fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *cellIdentifier = @"";

    if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Appointment class]]){
        cellIdentifier = @"aCell";
    } else if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[ToDo class]]){
        cellIdentifier = @"tCell";
    
        } else if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Memo class]]){
        cellIdentifier = @"mCell";
        } 
/*
 Use a default table view cell to display the event's title.
 */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        if (cellIdentifier == @"aCell"){
        
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.imageView setImage:[UIImage imageNamed:@"clock_running.png"]];
        
        }
        else if (cellIdentifier == @"tCell"){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.imageView setImage:[UIImage imageNamed:@"todo_nav.png"]];
        } else if (cellIdentifier == @"mCell"){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell.imageView setImage:[UIImage imageNamed:@"NotePad_nav.png"]];
        }
    }

    if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Memo class]]){
        Memo *theMemo = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor lightTextColor];
    cell.textLabel.text = theMemo.text;
    
}
else if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[ToDo class]]){
    
    ToDo *theToDo = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor lightTextColor];
    cell.textLabel.text = theToDo.text;
}

else if ([[_fetchedResultsController objectAtIndexPath:indexPath] isKindOfClass:[Appointment class]]){
    
    Appointment *theAppointment = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = theAppointment.text;
    cell.textLabel.textColor = [UIColor lightTextColor];
}
return cell;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

id <NSFetchedResultsSectionInfo> theSection = [[_fetchedResultsController sections] objectAtIndex:section];

/*
 Section information derives from an event's sectionIdentifier, which is a string representing the number (year * 1000) + month.
 To display the section title, convert the year and month components to a string representation.
 */
static NSArray *monthSymbols = nil;

if (!monthSymbols) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setCalendar:[NSCalendar currentCalendar]];
    monthSymbols = [formatter monthSymbols];
}

NSInteger numericSection = [[theSection name] integerValue];
NSInteger year = numericSection / 10000;
NSInteger tempmonth = numericSection - (year * 10000);
NSInteger month = tempmonth/100;
NSInteger day = tempmonth - (month *100);
NSString *titleString = [NSString stringWithFormat:@"%@ %d, %d", [monthSymbols objectAtIndex:month-1],day,year];

return titleString;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
[tableView deselectRowAtIndexPath:indexPath animated:YES];    
}


@end
