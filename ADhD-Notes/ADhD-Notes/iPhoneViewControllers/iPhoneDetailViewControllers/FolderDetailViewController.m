//
//  FolderDetailViewController.m
//  iDoit
//
//  Created by Keith Fernandes on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FolderDetailViewController.h"

@interface FolderDetailViewController ()

@end

@implementation FolderDetailViewController

@synthesize theFolder;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.title = theFolder.name;

 
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    NSInteger numberofrows = [self.theFolder.items count];
    NSLog(@"FOLDERSDETAILVIEW Number of Rows = %d", numberofrows);
    
    return numberofrows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat tfHeight;
    NSArray *tempArray = [theFolder.items allObjects];
    Note *theNote = [tempArray objectAtIndex:indexPath.row];
    CGSize size = [theNote.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 60) lineBreakMode:UILineBreakModeWordWrap];
    tfHeight = MAX (size.height+27, 44);
    NSLog (@"tfHeight = %f", tfHeight);
    
    return tfHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSArray *tempArray = [theFolder.items allObjects];
    // Note *theNote = [tempArray objectAtIndex:indexPath.row];

    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel setFont:[UIFont boldSystemFontOfSize:14]];
        }
    //cell.textLabel.text = theNote.text;
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
	static NSDateFormatter *dateFormatter = nil;
	if (dateFormatter == nil) {
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd MMMM yyyy h:mm a"];
        //[dateFormatter setDateFormat:@"EEEE, dd MMMM yyyy h:mm a"]; //This format gives the Day of Week, followed by date and time
    }
        NSArray *tempArray = [theFolder.items allObjects];
        Note *theNote = [tempArray objectAtIndex:indexPath.row];
    
	if ([theNote.type intValue] == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", theNote.text];	
		//[cell.detailTextLabel setText:[dateFormatter stringFromDate:theNote.creationDate]];
         cell.imageView.image = [UIImage imageNamed:@"NotePad_nav.png"];
    } 
	else if ([theNote.type intValue] == 1){
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", theNote.text]];	
		//[cell.detailTextLabel setText:[dateFormatter stringFromDate:theNote.creationDate]];
        cell.imageView.image = [UIImage imageNamed:@"list_nav.png"];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSManagedObjectContext *context = theFolder.managedObjectContext;
        NSArray *tempArray = [theFolder.items allObjects];

        [context deleteObject:[tempArray objectAtIndex:indexPath.row]];
        // Save the context.
        NSError *error;
        if (![context save:&error]) {
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

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
     [detailViewController release];
     */
}

@end
