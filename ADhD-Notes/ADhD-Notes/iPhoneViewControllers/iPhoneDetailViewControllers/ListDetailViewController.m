//
//  ListDetailViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListDetailViewController.h"
#import "ArchiveViewController.h"

@interface ListDetailViewController ()

@end

@implementation ListDetailViewController
@synthesize theItem;
@synthesize saving;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog (@"ListDetailViewController:viewDidLoad -> loading");
    
    self.tableView.backgroundColor = [UIColor blackColor];
    //self.tableView.allowsSelection = NO;
    self.tableView.userInteractionEnabled = YES;
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    [tableHeaderView setBackgroundColor:[UIColor blackColor]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY h::mm a"];   
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(130,2,180,18)];
    dateLabel.backgroundColor = [UIColor blackColor];
    dateLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(12.0)];
    dateLabel.textColor = [UIColor whiteColor];
    NSString *date = [dateFormatter stringFromDate:theItem.theList.creationDate];
    dateLabel.textAlignment = UITextAlignmentRight;
    NSString *temp = [NSString stringWithFormat:@"%@", date];
    dateLabel.text = temp;
    [tableHeaderView addSubview: dateLabel];
    
    //FIXME: add the key theItem.theMemo.aPlace
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(130,22,180,18)];
    placeLabel.backgroundColor = [UIColor blackColor];
    placeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(12.0)];
    placeLabel.textColor = [UIColor whiteColor];
    placeLabel.textAlignment = UITextAlignmentRight;
    temp = [NSString stringWithFormat:@"Some Place"];
    placeLabel.text = temp;
    //FIXME: add the key theItem.theMemo.aPlace
    [tableHeaderView addSubview: placeLabel];
    
    
    UIButton *folderButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 80, 45)];
    NSString *folderName = [[theItem.theList.collection anyObject] name];
    [folderButton setTitle:folderName forState:UIControlStateNormal];
    [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
    [folderButton addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
    [tableHeaderView addSubview:folderButton];
    self.tableView.tableHeaderView = tableHeaderView;
    
    
    self.tableView.tableHeaderView = tableHeaderView;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    UITextField *headerText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 24)];
    // headerText.delegate = self;
    headerText.borderStyle = UITextBorderStyleNone;
    headerText.backgroundColor = [UIColor clearColor];
    headerText.placeholder = @"Title";
    [headerText setFont:[UIFont systemFontOfSize:20]];
    headerText.textColor = [UIColor whiteColor];
    headerText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    headerText.textAlignment = UITextAlignmentCenter;
    headerText.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    self.navigationItem.titleView = headerText;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    if (saving) {
        self.navigationItem.leftBarButtonItem = [self.navigationController addAddButton]; 
        self.navigationItem.leftBarButtonItem.action = @selector(startNewItem:);
        self.navigationItem.leftBarButtonItem.target = self;   
    }
}

- (void) viewWillAppear:(BOOL) animated {
    NSLog(@"ListDetailViewController - viewWillAppear");
    [self.tableView reloadData];
}


- (void) startNewItem:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
}

- (void) presentArchiver: (id) sender {    
    
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[theItem.addingContext persistentStoreCoordinator]];
    
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    //archiveViewController.managedObjectContext = addingContext;
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.saving = YES;
    archiveViewController.theItem = self.theItem;
    [self.navigationController pushViewController:archiveViewController animated:YES];
    NSLog(@"MemoDetailViewController -> Pushed ArchiveViewController");
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    //Memo has 3 sections
    switch (section) {
        case 0:// Text
            rows = [theItem.theList.aStrings count];
            break;
        case 1://tags
            rows = 1;
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    switch (indexPath.section)
    {
        case 0:
            result = 33;
            break;
        case 1:
            result = 22;
            break;
        default:
            break;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    CGFloat hHeight;
    
    if (section == 2) {
        hHeight = 0.0;
    }
    else {
        hHeight = 0.0;
    }
    return hHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fHeight;
    
    fHeight = 0.0;
    
    return fHeight;
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0){
        NSUInteger listCount = [theItem.theList.aStrings count];
        NSInteger row = indexPath.row;    
        //FIXME: GET ORDERING
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
        
        NSMutableArray *sortedStrings = [[NSMutableArray alloc] initWithArray:[theItem.theList.aStrings allObjects]];
        [sortedStrings sortUsingDescriptors:sortDescriptors];
        Liststring *listItem = [sortedStrings objectAtIndex:row];

        if (indexPath.row < listCount) {
			static NSString *ListCellIdentifier = @"ListCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
			
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ListCellIdentifier];
                
                
                UIButton *uncheckButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 20, 20)];
                [uncheckButton setBackgroundImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
                [uncheckButton addTarget:self action:@selector(handleChecking:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:uncheckButton];

                /*
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleChecking:)];
                [tap setNumberOfTapsRequired:1];
                [tap setNumberOfTouchesRequired:1];
                [tap setDelegate:self];
                [tap setEnabled:YES];
                
                [cell.imageView addGestureRecognizer:tap];
                 
                 */
                
                cell.contentView.backgroundColor = [UIColor blackColor];
                cell.textLabel.backgroundColor = [UIColor blackColor];
                cell.textLabel.textColor = [UIColor whiteColor];
                 /*
                if (listItem.checked) {
                    cell.imageView.image = [UIImage imageNamed:@"uncheck.png"];
                    }
                     else {
                        cell.imageView.image = [UIImage imageNamed:@"check.png"];
                        }
              */
                
			}
            cell.textLabel.text = listItem.aString;
      
        }
    }
    else if (indexPath.section == 1){
        UILabel *labeltag = [[UILabel alloc] initWithFrame:CGRectMake (0,0,55,24)];
        labeltag.text = @"Tags";
        labeltag.enabled = NO;
        labeltag.backgroundColor = [UIColor blackColor];
        [cell.contentView addSubview:labeltag];
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame: CGRectMake (55,0,245,24)];
        //NSString *temp = [NSString stringWithFormat:@"%@, %@, %@, %@", theItem.theSimpleNote.rTag etc
        tagLabel.backgroundColor = [UIColor blackColor];
        tagLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:tagLabel];      
        tagLabel.text = @"Tag1, Tag2"; 
    }
    return cell;
}
                                                     
 - (void) handleChecking:(id)sender {
     NSLog (@"LISTDETAILVIEWCONTROLLER - HANDLING CHECKING");
    // NSUInteger listCount = [theItem.theList.aStrings count];
     NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
     NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
     
     NSMutableArray *sortedStrings = [[NSMutableArray alloc] initWithArray:[theItem.theList.aStrings allObjects]];
     [sortedStrings sortUsingDescriptors:sortDescriptors];
     
          //  CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
          //  NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
     
           // Liststring *listItem = [sortedStrings objectAtIndex:tappedIndexPath.row];

                                                         
           //if (listItem.checked) {
           //    listItem.checked = [NSNumber numberWithInt:1];
           //     }
           //else {
           //    listItem.checked = [NSNumber numberWithInt:0];
           //     }
         //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
      
    }
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    /*
    if (indexPath.section == ????) {
        // If this is the last item, it's the insertion row.
        if (indexPath.row == [???? count]) {
            style = UITableViewCellEditingStyleInsert;
        }
        else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    */
    return style;
}

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
