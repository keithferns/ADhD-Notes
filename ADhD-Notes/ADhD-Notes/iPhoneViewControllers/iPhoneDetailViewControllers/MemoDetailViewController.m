//  MemoDetailViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "MemoDetailViewController.h"
#import "CustomToolBar.h"
#import "ArchiveViewController.h"
#import "Constants.h"
#import "TagsDetailViewController.h"

@interface MemoDetailViewController ()

@property (nonatomic, retain) UITextView *theTextView;
@property (nonatomic, retain) CustomToolBar *toolbar;
@end

@implementation MemoDetailViewController

@synthesize theItem, theTextView, toolbar;
@synthesize saving;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor blackColor];

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
    theTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,320,105)];
    theTextView.delegate = self;
    theTextView.editable = NO;
    theTextView.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(16.0)];
    theTextView.textColor = [UIColor whiteColor];
    UIImage *patternImage = [[UIImage imageNamed:@"lined_paper4.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    [theTextView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];

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

    [self.view addSubview:toolbar];
}

- (void) viewWillAppear:(BOOL) animated {
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
        case 0:// Text
            rows = 1;
            break;
        case 1://Folder/File
            rows = 1;
            break;
        case 2: //tags
            rows = 1;
            break;

        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat result;
    switch (indexPath.section) {
        case 0:
            result = 50;
            break;
        case 1:
            result = 110;
            break;
        case 2:
            result = 33;
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

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *temp;
    if (section == 2){
        temp = @"Tags";
    }
    return temp;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    CGFloat fHeight;
    if (section == 0) {
        fHeight = 5.0;
    }
    else {
        fHeight = 5.0;
    }
    return fHeight;
}
/*
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
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
     if (indexPath.section == 0){
         NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];   
         
         UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,2,180,15)];
         dateLabel.backgroundColor = [UIColor blackColor];
         dateLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
         dateLabel.textColor = [UIColor whiteColor];
         NSString *date = [dateFormatter stringFromDate:theItem.theSimpleNote.creationDate];
         dateLabel.textAlignment = UITextAlignmentLeft;
         NSString *temp = [NSString stringWithFormat:@"%@", date];
         dateLabel.text = temp;
         [cell.contentView addSubview: dateLabel];
         
         [dateFormatter setDateFormat:@"h::mm a"];   
         
         UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,17,180,15)];
         timeLabel.backgroundColor = [UIColor blackColor];
         timeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
         timeLabel.textColor = [UIColor whiteColor];
         date = [dateFormatter stringFromDate:theItem.theSimpleNote.creationDate];
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
         [cell.contentView addSubview: placeLabel];
         
         UIButton *folderButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 55, 45)];
         NSString *folderName = [[theItem.theSimpleNote.collection anyObject] name];
         [folderButton setTitle:folderName forState:UIControlStateNormal];
         folderButton.titleLabel.font = [UIFont systemFontOfSize: 12];
         folderButton.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
         folderButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
         [folderButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
         [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
         [folderButton addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
         [cell.contentView addSubview:folderButton];
        } else if (indexPath.section == 1){
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [theTextView setText:theItem.theSimpleNote.text];
      
        [cell.contentView addSubview: theTextView];        
        } else if (indexPath.section == 2){
            
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
        tempArray = [theItem.theSimpleNote.tags allObjects];
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



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:110]];;        
    }
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
        theItem.addingContext = theItem.theSimpleNote.managedObjectContext;
        if ([alertView.title isEqualToString:@"New Tag:"]){
            [theItem createNewTagFromText:theTextField.text forType:0];
        }
       // else if ([alertView.title isEqualToString:@"Select Tag:"]){
            //}
        }
        /*--Save the MOC--*/
    [theItem saveNewItem];
    [self.tableView reloadData];
}

#pragma mark - Editing
- (void) textViewDidBeginEditing:(UITextView *)textView {
    
    NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    
    [self.tableView scrollToRowAtIndexPath:textViewIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
    NSLog (@"TEXTVIEW DID BEGIN EDITING");
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    if(editing == YES){
        NSLog (@"IS  EDITING");

        theTextView.editable = self.editing;
        [toolbar removeFromSuperview];
        theTextView.inputAccessoryView = toolbar;
    }
	[self.navigationItem setHidesBackButton:editing animated:YES];
    
    if (editing == NO) {
        NSLog (@"IS NOT EDITING");
        [theTextView resignFirstResponder];
        theTextView.inputAccessoryView = nil;
        theTextView.editable = self.editing;
        theItem.addingContext = theItem.theSimpleNote.managedObjectContext;
        [theItem updateText:theTextView.text];
        [theItem saveNewItem];
        toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);
        [self.view addSubview:toolbar];
    }
}
                      
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 2) {
        editable = YES;
    } else{
        editable = NO;
    }
    return editable;
}

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
}/*
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



#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
    if (indexPath.section == 2){
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        detailViewController.theSimpleNote = theItem.theSimpleNote;
        [self.navigationController pushViewController:detailViewController animated:YES];
    
    }
}


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

- (void) toggleCalendar:(id) sender{
    //
    return;
}


- (void) presentActionsPopover:(id) sender{
    return;
}

@end
