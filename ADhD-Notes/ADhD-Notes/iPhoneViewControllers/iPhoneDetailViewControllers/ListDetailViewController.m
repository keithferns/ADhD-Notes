//  ListDetailViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ListDetailViewController.h"
#import "ListStringDetailViewController.h"
#import "TagsDetailViewController.h"
#import "ArchiveViewController.h"
#import "CustomToolBar.h"
#import "Constants.h"

@interface ListDetailViewController ()

@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) NSMutableArray *sortedStrings;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;


@end

@implementation ListDetailViewController

@synthesize theItem, saving, toolbar, sortedStrings, theList, lastIndexPath, selectedIndexPath;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self) {
        
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.bounces = NO;
        self.tableView.allowsSelection = YES;
        self.tableView.allowsSelectionDuringEditing = YES;
        self.tableView.userInteractionEnabled = YES;
        self.tableView.separatorColor = [UIColor blackColor];
        
        UITextField *headerText = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 140, 44)];
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

        if (toolbar == nil) {
            toolbar = [[CustomToolBar alloc] init];
            toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);            
            [toolbar.firstButton setTarget:self];
            [toolbar.secondButton setTarget:self];
            [toolbar.thirdButton setTarget:self];
            [toolbar.fourthButton setTarget:self];
            [toolbar.fifthButton setTarget:self];
            [toolbar changeToDetailButtons];
            toolbar.firstButton.enabled = YES;
            toolbar.secondButton.enabled = YES;
            toolbar.fourthButton.enabled = YES;
        }
        
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];    
    
    if (theItem == nil) {
        theItem = [[NewItemOrEvent alloc] init];
        theItem.theList = self.theList;
    }
    if (self.saving == NO){
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (void) viewWillAppear:(BOOL) animated {
    NSLog (@"ListDetailViewController: viewWillAppear");
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    sortedStrings = [[NSMutableArray alloc] initWithArray:[theList.aStrings allObjects]];
    [sortedStrings sortUsingDescriptors:sortDescriptors];  
    NSLog(@"ListDetailViewController: sortedStrings count = %d", [sortedStrings count]);
    [self.tableView reloadData];
}

- (void) startNewItem:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
}

- (void) presentArchiver {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemSelectedNotification" object:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:// Text
            rows = [theList.aStrings count];
            if (self.editing == YES) {
                NSLog (@"ListDetailViewController:numberOfRows -> adding a row");
                rows++;
            }
            break;
        case 2://tags
            rows = 1;
            break;
        default:
            break;
    }

    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    switch (indexPath.section) {
        case 0:
            result = 50;
            break;
        case 1:
            if (indexPath.row != self.selectedIndexPath.row){
                result = 40;
            }
            else {
                
             Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];

            CGSize size = [listItem.aString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 60) lineBreakMode:UILineBreakModeWordWrap];
            result = MAX (size.height+20, 40);
                
           }
            break;
        case 2:
            result = 40;
            break;
        default:
            break;
    }
    return result;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{    
    CGFloat hHeight;
    if (section == 0) {
        hHeight = 0.0;
    }
    else if (section == 1){
        hHeight = 0.0;
    }
    else {
        hHeight = 0.0;
    }
    return hHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fHeight;
    if (section == 2) {
        fHeight = 20.0;
    }
    else if (section == 1){
        fHeight = 5.0;
    } else {
        fHeight = 5.0;
    }
    return fHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *hView;
    if (section == 2) {
        hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
        hView.backgroundColor = [UIColor blackColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 20)];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"Tags";
        label.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        [hView addSubview:label];
    }
    return hView;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *temp;
    if (section == 2){
        
        temp = @"Tags";
    }
    return temp;
}
 */

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,130)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.section == 0){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];   
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,2,180,15)];
        dateLabel.backgroundColor = [UIColor blackColor];
        dateLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        dateLabel.textColor = [UIColor whiteColor];
        NSString *date = [dateFormatter stringFromDate:theList.creationDate];
        dateLabel.textAlignment = UITextAlignmentLeft;
        NSString *temp = [NSString stringWithFormat:@"%@", date];
        dateLabel.text = temp;
        [cell.contentView addSubview: dateLabel];
        
        [dateFormatter setDateFormat:@"h::mm a"];   
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,17,180,15)];
        timeLabel.backgroundColor = [UIColor blackColor];
        timeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        timeLabel.textColor = [UIColor whiteColor];
        date = [dateFormatter stringFromDate:theList.creationDate];
        timeLabel.textAlignment = UITextAlignmentLeft;
        temp = [NSString stringWithFormat:@"%@", date];
        timeLabel.text = temp;
        [cell.contentView addSubview: timeLabel];
        
        //FIXME: add the key theItem.theMemo.aPlace
        
        UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,32,180,15)];
        placeLabel.backgroundColor = [UIColor blackColor];
        placeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        placeLabel.textColor = [UIColor whiteColor];
        placeLabel.textAlignment = UITextAlignmentLeft;
        temp = [NSString stringWithFormat:@"Some Place"];
        placeLabel.text = temp;
        //FIXME: add the key theItem.theMemo.aPlace
        [cell.contentView addSubview: placeLabel];
        
        UIButton *folderButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 55, 45)];
        NSString *folderName = [[theList.collection anyObject] name];
        [folderButton setTitle:folderName forState:UIControlStateNormal];
        folderButton.titleLabel.font = [UIFont systemFontOfSize: 12];
        folderButton.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
        folderButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [folderButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
        [folderButton addTarget:self action:@selector(presentArchiver) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:folderButton];
    } else if (indexPath.section == 1){
        NSInteger listCount = [theList.aStrings count];
       
        if (indexPath.row < listCount) {
            Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
            
            BOOL checked = [listItem.checked boolValue];
            UIImage *image = (checked) ? [UIImage imageNamed:@"check.png"] : [UIImage imageNamed:@"uncheck.png"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
            button.frame = frame;	// match the button's size with the image size
            
            [button setBackgroundImage:image forState:UIControlStateNormal];
            // set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
            [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
            button.backgroundColor = [UIColor clearColor];
            
			static NSString *ListCellIdentifier = @"ListCell";
			cell = [tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ListCellIdentifier];
                cell.textLabel.textColor = [UIColor whiteColor];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];

            }
            cell.textLabel.text = listItem.aString;
            cell.accessoryView = button;
            cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else {
            // If the row is outside the range, it's the row that was added to allow insertion (see tableView:numberOfRowsInSection:) so give it an appropriate label.
			static NSString *AddItemCellIdentifier = @"AddItemCell";
			cell = [tableView dequeueReusableCellWithIdentifier:AddItemCellIdentifier];
			if (cell == nil) {
                // Create a cell to display "Add Item".
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddItemCellIdentifier];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            cell.textLabel.text = @"Add Item";
        }
          
    }else if (indexPath.section == 2){
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"Tags";
        label.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(14.0)];
        [cell.contentView addSubview:label];      
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame: CGRectMake (45,0,225,40)];
        //NSString *temp = [NSString stringWithFormat:@"%@, %@, %@, %@", theItem.theSimpleNote.rTag etc
        tagLabel.backgroundColor = [UIColor blackColor];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:(14.0)];
        NSArray *tempArray = [[NSArray alloc] init];
        tempArray = [theList.tags allObjects];
        NSString *tempString = @"";
        for (int i = 0; i<[tempArray count]; i++) {
            tempString = [tempString stringByAppendingString:[[tempArray objectAtIndex:i] name]];
            tempString = [tempString stringByAppendingString:@" / "];
        }
        tagLabel.text = tempString;
        [cell.contentView addSubview:tagLabel];      
        
        UIButton *tagButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
        [tagButton setImage:[UIImage imageNamed:@"tag_add_24"] forState:UIControlStateNormal];
        [tagButton addTarget:self action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];
        tagButton.tag = 1;
        [cell.contentView addSubview:tagButton]; 
    }
    return cell;
}

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
    
	Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
	BOOL checked = [listItem.checked boolValue];
	listItem.checked = [NSNumber numberWithBool:!checked];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
}

- (void) showTextBox:(id) sender {
    UIAlertView *textBox = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save",nil];
    [textBox setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([sender tag] == 1){
        textBox.title = @"New Tag:";
        textBox.message = @"This is a new tag";        
    }else if ([sender tag] == 2){
        textBox.title = @"New Document:";
    }
    [textBox show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Save"]){
        UITextField *theTextField = [alertView textFieldAtIndex:0];
        theItem.addingContext = theList.managedObjectContext;
        if ([alertView.title isEqualToString:@"New Tag:"]){
            [theItem createNewTagFromText:theTextField.text forType:1];
        }
        // else if ([alertView.title isEqualToString:@"Select Tag:"]){
        //}
    }
    /*--Save the MOC--*/
    [theItem saveNewItem];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
    cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:33]];;        
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"SET EDITING CALLED");
    [super setEditing:editing animated:animated];
	[self.navigationItem setHidesBackButton:editing animated:YES];
	
	[self.tableView beginUpdates];
	
    NSUInteger itemsCount = [theList.aStrings count];
    NSArray *itemsInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:itemsCount inSection:1]];
    
    if (editing == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];
            NSLog (@"ListDetailViewController: setEditing -> Is Editing");
            [self.tableView insertRowsAtIndexPaths:itemsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
        } else {
            NSLog (@"ListDetailViewController: setEditing -> Is NOT Editing");
              [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];  
            [self.tableView deleteRowsAtIndexPaths:itemsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tableView endUpdates];
	
	 //If editing is finished, save the managed object context.
	 
	if (editing == NO) {
		NSManagedObjectContext *context = theList.managedObjectContext;
		NSError *error = nil;
		if (![context save:&error]) {
			
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 0) {
        editable = NO;
    } else{
        editable = YES;
    }
    return editable;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (indexPath.section == 1) {
        // If this is the last item, it's the insertion row.
        
         if (indexPath.row == [theList.aStrings count]) {
            style = UITableViewCellEditingStyleInsert;
        }
        else {
            style = UITableViewCellEditingStyleDelete;
        }
    }
    return style;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 1) {
        // Delete the row from the data source
        //FIXME: GET ORDERING
       
        Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
        [theList removeAStringsObject:listItem];
        theList.editDate = [[NSDate date] timelessDate];
        [sortedStrings removeObject:listItem];
        
        NSManagedObjectContext *context = listItem.managedObjectContext;
        [context deleteObject:listItem];
    
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    
    }   
   // else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    //}   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!self.editing && indexPath.section == 1){

        if (indexPath.section == lastIndexPath.section && indexPath.row == lastIndexPath.row) {
            NSLog(@"Same Cell selected");
            return;
        }
        self.selectedIndexPath = indexPath;
        [self.tableView deselectRowAtIndexPath:lastIndexPath animated:YES];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, lastIndexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        self.lastIndexPath = indexPath;
        /*
        [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
         */
    }else {
        
    NSInteger listCount = [theList.aStrings count];
    if (indexPath.section == 1) {
        if (indexPath.row == listCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemSelectedNotification" object:self.theList];
        }else if (indexPath.row < listCount) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemSelectedNotification" object:[sortedStrings objectAtIndex:indexPath.row]];
        }
    }
    if (indexPath.section == 2) {
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
       [tempArray addObjectsFromArray:[self.theList.tags allObjects]];
        detailViewController.theArray = tempArray;
        detailViewController.theItem = (Item *)self.theItem.theList;
        [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

- (void) toggleCalendar:(id) sender{
    //
    return;
}

- (void) presentActionsPopover:(id) sender{
    return;
}


@end


/*
 - (void) handleChecking:(id)sender {
 NSLog (@"LISTDETAILVIEWCONTROLLER - HANDLING CHECKING");
 // NSInteger listCount = [theItem.theList.aStrings count];
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
 NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
 NSMutableArray *sortedStrings = [[NSMutableArray alloc] initWithArray:[theItem.theList.aStrings allObjects]];
 [sortedStrings sortUsingDescriptors:sortDescriptors];
 
 NSIndexPath *tappedIndexPath = [NSIndexPath indexPathForRow:[sender tag] inSection:1];
 NSLog (@"INDEX PATH = %@", tappedIndexPath);
 //  CGPoint tapLocation = [tapRecognizer locationInView:self.tableView];
 //  NSIndexPath *tappedIndexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
 Liststring *listItem = [sortedStrings objectAtIndex:tappedIndexPath.row];
 NSLog (@"INDEX PATH = %d", tappedIndexPath.row);
 if ([listItem.checked intValue] == 0) {
 listItem.checked = [NSNumber numberWithInt:1];
 }
 else {
 listItem.checked = [NSNumber numberWithInt:0];
 }
 [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tappedIndexPath] withRowAnimation: UITableViewRowAnimationFade];
 
 }
 */

