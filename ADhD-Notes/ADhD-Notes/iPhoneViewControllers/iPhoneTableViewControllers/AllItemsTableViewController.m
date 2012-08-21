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

@property (nonatomic, retain) NSDate *selectedDate;
@property (nonatomic, readwrite) NSInteger eventType;
@property (nonatomic, readwrite) BOOL calendarIsVisible;
@end

@implementation AllItemsTableViewController



@synthesize managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize selectedDate;
@synthesize eventType;
@synthesize calendarIsVisible;



- (void)viewDidLoad
{
    [super viewDidLoad];
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    _fetchedResultsController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDidSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:nil];    
    if (managedObjectContext == nil) { 
		managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        NSLog(@"AllItems TABLEVIEWCONTROLLER After managedObjectContext: %@",  managedObjectContext);
	}
	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"FETCHING ERROR");
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

- (void)viewDidUnload{
    [super viewDidUnload];
    
    self.managedObjectContext = nil;
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Fetched results controller

- (void) getSelectedCalendarDate: (NSNotification *) notification{
    // if (!calendarIsVisible){
    //     return;
    // }
    selectedDate = [notification object];
    self.fetchedResultsController = nil;
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
    }
    [self.tableView reloadData];
}

-(void) switchType: (NSInteger) type{    

    self.fetchedResultsController = nil;
    self.eventType = type;
    
    NSPredicate *eventTypePredicate = [NSPredicate predicateWithFormat: @"aType == %d", type];
    self.fetchedResultsController = [self fetchedResultsControllerWithPredicate:eventTypePredicate];
    
 	NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
	}
    [self.tableView reloadData];
}

- (NSFetchedResultsController *) fetchedResultsController {
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    
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


/*
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
*/
- (NSFetchedResultsController *) fetchedResultsControllerWithPredicate: (NSPredicate *) aPredicate {
    [NSFetchedResultsController deleteCacheWithName:@"Root"];
    if (_fetchedResultsController!=nil) {
        return _fetchedResultsController;
    }
    NSFetchRequest *request = [[NSFetchRequest alloc] init];    
    switch (eventType) {
        case 0:
             [request setEntity:[NSEntityDescription entityForName:@"SimpleNote" inManagedObjectContext:managedObjectContext]];
            break;
        case 1:
            [request setEntity:[NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext]];
            break;
        case 2:
            [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
            break;
        case 3:
            //
            break;
        default:
            break;
    }

    NSDate *currentDate;
    if (!calendarIsVisible) { 
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];    
        [gregorian setLocale:[NSLocale currentLocale]];
        [gregorian setTimeZone:[NSTimeZone localTimeZone]];
        
        NSDateComponents *timeComponents = [gregorian components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];  
        [timeComponents setYear:[timeComponents year]];
        [timeComponents setMonth:[timeComponents month]];
        [timeComponents setDay:[timeComponents day]];
        [timeComponents setHour:0];
        [timeComponents setMinute:0];
        [timeComponents setSecond:0];
        currentDate = [gregorian dateFromComponents:timeComponents];
        //NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"type = %@ AND aDate >= %@", eventType, currentDate];
        if (eventType  == 2) {
            
            NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate >= %@", currentDate];
            [request setPredicate:checkDate];
        }
    }
    else if (calendarIsVisible){
        /*
         if (selectedDate == nil) {
         NSLog(@"Selected Date is nil");
         NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate >= %@", currentDate];
         [request setPredicate:checkDate];
         checkDate = nil;
         }
         else {
         */
        
        NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"aDate == %@", selectedDate];
        [request setPredicate:checkDate];
        checkDate = nil;
        //     }
    }
    /*
     
     NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"type" ascending:YES  comparator:^NSComparisonResult(id obj1, id obj2) {
     NSComparisonResult compR;
     if ([[obj1 type] intValue] == 0 && [[obj1 type] intValue] < [[obj2 type] intValue]) { 
     compR =  NSOrderedAscending; 
     }
     else if ([[obj2 type] intValue] == 0 && [[obj1 type] intValue] > [[obj2 type] intValue])
     { compR =  NSOrderedDescending;}
     else if (obj1 == 0 && obj2 == 0){
     compR =  NSOrderedSame;}
     else if (obj1 != 0 && obj2 != 0){
     compR =  NSOrderedSame;
     }
     return compR;
     }];
     */
    if (eventType == 2) {
        
        NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"aDate" ascending:YES];// just here to test the sections and row calls
        
        NSSortDescriptor *timeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:dateDescriptor, timeDescriptor, nil]];
    }
    else {
        NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"aDate" ascending:NO];// just here to test the sections and row calls
        
        NSSortDescriptor *timeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObjects:dateDescriptor, timeDescriptor, nil]];
    }
    
    /*FIXME:  set Predicate to filter all tasks and appointments for a time after NOW --*/
    
    //NSArray *checkDateArray = [NSArray arrayWithObjects:@"memotext.savedAppointment.doDate",@"memotext.saveMemo.doDate", @"memotext.saveTask.doDate", nil];
    //NSPredicate *checkDate = [NSPredicate predicateWithFormat:@"'[NSDate date]' < %@" argumentArray:checkDateArray];
    //[request setPredicate:checkDate];
    /* -- --*/
    
    [request setFetchBatchSize:10];
    
    NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Root"];
    // NSFetchedResultsController *newController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:@"sectionIdentifier" cacheName:@"Root"];
    
    newController.delegate = self;
    self.fetchedResultsController = newController;    
    return _fetchedResultsController;
}



#pragma mark -
#pragma mark Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
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
