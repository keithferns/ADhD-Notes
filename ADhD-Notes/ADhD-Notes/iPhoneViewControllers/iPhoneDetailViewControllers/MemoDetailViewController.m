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
#import "MailComposerViewController.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"
#import "NSDate+TKCategory.h"
#import "ListViewController.h"

@interface MemoDetailViewController ()

@property (nonatomic, retain) UITextView *theTextView;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;

@end

@implementation MemoDetailViewController

@synthesize theItem, theTextView, toolbar, theSimpleNote, actionsPopover;
@synthesize saving;

#pragma mark - Initializing

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
       //      
    }
    return self;
}

#pragma mark - View Management

- (void)viewDidUnload {
    [super viewDidUnload];
    self.theItem = nil;
    self.theTextView = nil;
    self.toolbar = nil;
    self.actionsPopover = nil;
    self.theSimpleNote = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AppendedNotification" object:nil];   

}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    if (theItem == nil) {
        NSLog(@"MemoDetailViewController: viewDidLoad -> theItem is nil");

        theItem = [[NewItemOrEvent alloc] init];
        theItem.theSimpleNote = theSimpleNote;
        theItem.text = theSimpleNote.text;
        theItem.type = [NSNumber numberWithInt:0];
        theItem.addingContext = theSimpleNote.managedObjectContext;
    }
    NSLog(@"theItem.addingContext is %@", theItem.addingContext);
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    [backButton setTintColor:[UIColor redColor]];
    [backButton setAction:@selector(cancelSaving:)];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.bounces = NO;
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.allowsSelection = NO;
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
  
    theTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,320,105)];
    theTextView.delegate = self;
    theTextView.editable = NO;
    theTextView.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(16.0)];
    theTextView.textColor = [UIColor whiteColor];
    UIImage *patternImage = [[UIImage imageNamed:@"lined_paper4.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [theTextView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        
    if (toolbar == nil) {
        NSLog(@"Adding Toolbar");
        toolbar = [[CustomToolBar alloc] init];
        toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);
        [toolbar changeToDetailButtons];
        [toolbar.firstButton setTarget:self];
        [toolbar.secondButton setTarget:self];
        [toolbar.thirdButton setTarget:self];
        [toolbar.fourthButton setTarget:self];
        [toolbar.fifthButton setTarget:self];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteSimpleNote:) name:@"AppendedNotification" object:nil];    

}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    [self.view addSubview:toolbar];
    
}

- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
    
    if (actionsPopover) {
        [self.actionsPopover dismissPopoverAnimated:YES];
        self.actionsPopover = nil;
    }
    //self.tabBarController.selectedIndex = 0;    
}

- (void) goToMain: (id) sender {  
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) presentArchiver: (id) sender {    
        
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    archiveViewController.hidesBottomBarWhenPushed = YES;
    
    archiveViewController.theItem = self.theItem;
    
    archiveViewController.saving = YES;
    if ([sender tag] == 5) {
        archiveViewController.appending = YES;
    }else if ([sender tag] == 3){
    archiveViewController.appending = NO;
    }
    [self.navigationController pushViewController:archiveViewController animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) appendToList: (id) sender{
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    self.theItem.text = self.theSimpleNote.text;
    
    ListViewController *detailViewController = [[ListViewController alloc] init]; 
    detailViewController.theItem = self.theItem;
    detailViewController.saving = YES;
    detailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void) deleteSimpleNote:(NSNotification *)notification {
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 240)];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Note?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil]; 
    [actionSheet showInView:actionView];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  
    NSLog(@"Checking Whether to Delete Note");
    
    NSString *string = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Delete"]){
        NSLog(@"Deleting Note");

        [theItem deleteItem:theItem.theSimpleNote];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


- (void) sendItem:(id)sender {
    NSLog(@"Sending SimpleNote text");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    MailComposerViewController *detailViewController = [[MailComposerViewController alloc] init];
    if([sender tag] == 6){
        detailViewController.sendType = [NSNumber numberWithInt:1];
    }
    else if ([sender tag] == 7){
        detailViewController.sendType = [NSNumber numberWithInt:2];
    }
    detailViewController.theText = self.theSimpleNote.text;
    [self.navigationController pushViewController: detailViewController animated:YES];
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
        case 1:
            rows = 1;
            break;
        case 2: 
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
        fHeight = 0.0;
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
         NSString *date = [dateFormatter stringFromDate:theSimpleNote.creationDate];
         dateLabel.textAlignment = UITextAlignmentLeft;
         NSString *temp = [NSString stringWithFormat:@"%@", date];
         dateLabel.text = temp;
         [cell.contentView addSubview: dateLabel];
         
         [dateFormatter setDateFormat:@"h::mm a"];   
         
         UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,17,180,15)];
         timeLabel.backgroundColor = [UIColor blackColor];
         timeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
         timeLabel.textColor = [UIColor whiteColor];
         date = [dateFormatter stringFromDate:theSimpleNote.creationDate];
         timeLabel.textAlignment = UITextAlignmentLeft;
         temp = [NSString stringWithFormat:@"%@", date];
         timeLabel.text = temp;
         [cell.contentView addSubview: timeLabel];
         
         //FIXME: add the key.aPlace
         UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,32,180,15)];
         placeLabel.backgroundColor = [UIColor blackColor];
         placeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
         placeLabel.textColor = [UIColor whiteColor];
         placeLabel.textAlignment = UITextAlignmentLeft;
         temp = [NSString stringWithFormat:@"Some Place"];
         placeLabel.text = temp;
         [cell.contentView addSubview: placeLabel];
         
         UIButton *folderButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 55, 45)];
         NSString *folderName = [[theSimpleNote.collection anyObject] name];
         [folderButton setTitle:folderName forState:UIControlStateNormal];
         folderButton.titleLabel.font = [UIFont systemFontOfSize: 12];
         folderButton.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
         folderButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
         [folderButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
         [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
         folderButton.tag = 3;
         [folderButton addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
         [cell.contentView addSubview:folderButton];
        } else if (indexPath.section == 1){
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [theTextView setText:theSimpleNote.text];
      
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
        //NSString *temp = [NSString stringWithFormat:@"%@, %@, %@, %@", theSimpleNote.rTag etc
        tagLabel.backgroundColor = [UIColor blackColor];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:(14.0)];
        NSArray *tempArray = [[NSArray alloc] init];
        tempArray = [theSimpleNote.tags allObjects];
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
        theItem.addingContext = theSimpleNote.managedObjectContext;
        if ([alertView.title isEqualToString:@"New Tag:"]){
            [theItem createNewTagFromText:theTextField.text forType:0];
        }
    }
        /*--Save the MOC--*/
    [theItem saveNewItem];
    [self.tableView reloadData];
}

#pragma mark - Editing
- (void) textViewDidBeginEditing:(UITextView *)textView {
    NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];    
    [self.tableView scrollToRowAtIndexPath:textViewIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing == YES){
        theTextView.editable = self.editing;
        [toolbar removeFromSuperview];
        theTextView.inputAccessoryView = toolbar;
    }
	[self.navigationItem setHidesBackButton:editing animated:YES];
    
    if (editing == NO) {
        NSLog(@"Simple Note is Not  Editing");
        [theTextView resignFirstResponder];
        theTextView.inputAccessoryView = nil;
        theTextView.editable = self.editing;
        theItem.addingContext = theSimpleNote.managedObjectContext;
        [theItem updateText:theTextView.text];
        theItem.theSimpleNote.editDate = [[NSDate date ]timelessDate];
        [theItem saveNewItem];
        NSLog(@"Simple Note Editdate = %@", theItem.theSimpleNote.editDate);
        toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);
        [self.view addSubview:toolbar];
    }
}
                      
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 2) {
        editable = YES;
    } else {
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

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {	
    if (indexPath.section == 2){
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.editing){
    if (indexPath.section == 2) {
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObjectsFromArray:[self.theSimpleNote.tags allObjects]];
        detailViewController.theArray = tempArray;
        detailViewController.theItem = (Item *)self.theItem.theSimpleNote;
        [self.navigationController pushViewController:detailViewController animated:YES];
        }
    }
}

- (void) toggleCalendar:(id) sender{
    //
    return;
}

#pragma mark - Popover Management
- (void) presentActionsPopover:(id) sender{
    
    if (actionsPopover) {
        [self.actionsPopover dismissPopoverAnimated:YES];
        self.actionsPopover = nil;
    }
    if(!actionsPopover) {
        UIViewController *viewCon = [[UIViewController alloc] init];
        switch ([sender tag]) {
            case 1:
           
                break;
                
            case 2:
                {
                CGSize size = CGSizeMake(200, 120);
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView toolbarSaveButton];
                viewCon.view = addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:(id)self];
                if (self.editing){
                [actionsPopover presentPopoverFromRect:CGRectMake(85, 165, 50, 40) inView:self.view
                              permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES];  
                }else {
                    [addView.button1 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button2 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button3 addTarget:self action:@selector(appendToList:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button4 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    
                [actionsPopover presentPopoverFromRect:CGRectMake(85, 370, 50, 40) inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES ];  
                }
            }
                break;
                
            case 3:
                break;        
            case 4:
            {
                CGSize size = CGSizeMake(100, 120);
                viewCon.contentSizeForViewInPopover = size;                
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView toolbarSendButton];
                viewCon.view = addView;
                
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:(id)self];
                if (self.editing) {
                    [actionsPopover presentPopoverFromRect:CGRectMake(205, 165, 50, 50) inView:self.view
                              permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES]; 
                }else {
                    [addView.button1 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button2 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];

                    [actionsPopover presentPopoverFromRect:CGRectMake(205, 370, 50, 50) inView:self.view
                                permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES]; 

                }
            }
                break;
            default:
                break;
        }   
    }
    return;
}

#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.actionsPopover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
    [self popoverControllerDidDismissPopover:actionsPopover];
	return YES;
}


@end
