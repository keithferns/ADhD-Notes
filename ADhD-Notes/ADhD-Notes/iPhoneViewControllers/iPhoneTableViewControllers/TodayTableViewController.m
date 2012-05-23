//
//  TodayTableViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TodayTableViewController.h"
#import "HorizontalCells.h"

@interface TodayTableViewController ()

@end

@implementation TodayTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.frame = CGRectMake (0, 0, 320, kCellHeight*2+40);
    self.tableView.rowHeight = kCellHeight;
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [headerLabel setBackgroundColor:[UIColor blackColor]];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEEE, MMM d"];
    
    [headerLabel setText:[dateformatter stringFromDate:[NSDate date]]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerView setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:headerLabel];

    [self.tableView setTableHeaderView:headerView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog (@"TODAY TABLE VIEW CONTROLLER LOADING HORIZONTAL CELLS");
    
    NSString *cellIdentifier = @"";
    
    if (indexPath.section == 0){
        cellIdentifier = @"firstCell";
        
    } else if (indexPath.section == 1){
        
        cellIdentifier = @"secondCell";
        
    }     
    HorizontalCells *cell;
    
    if (cellIdentifier == @"firstCell"){
        cell = (HorizontalCells *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil){
            cell = [[HorizontalCells alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"firstCell"];
        }
    } else if (cellIdentifier == @"secondCell"){
        cell = (HorizontalCells *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil){
            
            cell = [[HorizontalCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"secondCell"];            
            
        }
    }
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
