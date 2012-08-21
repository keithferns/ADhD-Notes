//  AppointmentDetailViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "AppointmentDetailViewController.h"
#import "SchedulerViewController.h"
#import "CustomToolBar.h"
#import "TagsDetailViewController.h"
#import "MailComposerViewController.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"

@interface AppointmentDetailViewController ()

@property (nonatomic, retain) UITextView *theTextView;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;

@end

@implementation AppointmentDetailViewController

@synthesize theItem, saving, theTextView, toolbar, actionsPopover;

CGFloat tfHeight;


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.bounces = NO;
        self.tableView.separatorColor = [UIColor blackColor];
        self.tableView.allowsSelection = NO;
        self.tableView.allowsSelectionDuringEditing = YES;    }
        return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];    
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
    
    CGSize size = [theItem.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(300, 200) lineBreakMode:UILineBreakModeWordWrap];
    tfHeight = MAX (size.height, 45);
    
    theTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,320,tfHeight)];
    theTextView.delegate = self;
    theTextView.editable = NO;
    theTextView.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(16.0)];
    theTextView.textColor = [UIColor whiteColor];
    //UIImage *patternImage = [[UIImage imageNamed:@"lined_paper4.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //[theTextView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
    theTextView.backgroundColor = [UIColor clearColor];
    
    theItem.addingContext = theItem.theAppointment.managedObjectContext;
    theItem.aDate = theItem.theAppointment.aDate;
    theItem.startTime = theItem.theAppointment.startTime;
    theItem.endTime = theItem.theAppointment.endTime;
    theItem.recurring = theItem.theAppointment.recurrence;
    
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

- (void) goToMain: (id) sender {    

    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView  reloadData];
}

- (void) viewWillDisappear: (BOOL) animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
    self.tabBarController.selectedIndex = 0;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) startNewItem:(id) sender{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
            switch (section) {
                case 0://TEXT
                    rows = 1;
                    break;
                case 1: //INFO
                    rows = 1;
                    break;
                case 2: //TAGS
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
            result = tfHeight;
            break;
        case 1:
            result = 50;
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
    if (section == 2 || section == 3) {
        hHeight = 0.0;
    }
    else {
        hHeight = 0.0;
    }
    return hHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *temp;
    if (section == 2){
        temp = @"Reminders";
    }
    else if (section == 3){
        temp = @"Tags";
    }
    return temp;
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
    UIView  *hView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 15)];
    hView.backgroundColor = [UIColor blackColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 100, 20)];
    label.backgroundColor = [UIColor blackColor];
    label.textColor = [UIColor lightGrayColor];
    label.text = @"Tags";
    label.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
    [hView addSubview:label];
    if (section == 2){
        label.text = @"Reminders";
    }
    if (section == 3) {
        label.text = @"Tags";
    }
    return hView;    
}

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
       cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
       
       [theTextView setText:theItem.theAppointment.text];
       [cell.contentView addSubview: theTextView];
        }
    else if (indexPath.section == 1){
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];   
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,2,145,15)];
        dateLabel.backgroundColor = [UIColor blackColor];
        dateLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        dateLabel.textColor = [UIColor whiteColor];
        NSString *date = [dateFormatter stringFromDate:theItem.theAppointment.aDate];
        dateLabel.textAlignment = UITextAlignmentLeft;
        NSString *temp = [NSString stringWithFormat:@"%@", date];
        dateLabel.text = temp;
        [cell.contentView addSubview: dateLabel];
        
        [dateFormatter setDateFormat:@"h::mm a"];   
        NSString *startTime = [dateFormatter stringFromDate:theItem.theAppointment.startTime];
        NSString *endTime = [dateFormatter stringFromDate:theItem.theAppointment.endTime];
        temp = [NSString stringWithFormat:@"%@ - %@", startTime, endTime];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,17,145,15)];
        timeLabel.backgroundColor = [UIColor blackColor];
        timeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = UITextAlignmentLeft;
        timeLabel.text = temp;
        [cell.contentView addSubview: timeLabel];
        
        //FIXME: add the key theItem.theMemo.aPlace
        UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5,32,140,15)];
        placeLabel.backgroundColor = [UIColor blackColor];
        placeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        placeLabel.textColor = [UIColor whiteColor];
        placeLabel.textAlignment = UITextAlignmentLeft;
        temp = [NSString stringWithFormat:@"Some Place"];
        placeLabel.text = temp;
        //FIXME: add the key theItem.theMemo.aPlace
        [cell.contentView addSubview: placeLabel];
        
        UILabel *labelrepeat = [[UILabel alloc] initWithFrame:CGRectMake (160,2,45,15)];
        labelrepeat.text = @"Repeat";
        labelrepeat.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(13.0)];
        labelrepeat.backgroundColor = [UIColor blackColor];
        labelrepeat.enabled = NO;
        [cell.contentView addSubview:labelrepeat];
        
        UILabel *repeatLabel = [[UILabel alloc] initWithFrame: CGRectMake (205,2,105,15)];
        repeatLabel.text = @"Never";
        repeatLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        repeatLabel.backgroundColor = [UIColor blackColor];
        repeatLabel.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:repeatLabel];   
        
        UILabel *labelAlarm = [[UILabel alloc] initWithFrame:CGRectMake (160,17,45,15)];
        labelAlarm.text = @"Alerts";
        labelAlarm.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(13.0)];
        labelAlarm.backgroundColor = [UIColor blackColor];
        labelAlarm.enabled = NO;
        [cell.contentView addSubview:labelAlarm];
        
        UILabel *alarm1 = [[UILabel alloc] initWithFrame: CGRectMake (205,17,105,15)];
        alarm1.text = @"2 days before";
        alarm1.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        alarm1.backgroundColor = [UIColor blackColor];
        alarm1.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:alarm1];   
        
        UILabel *alarm2 = [[UILabel alloc] initWithFrame: CGRectMake (205,32,105,15)];
        alarm2.text = @"15 minutes before";
        alarm2.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        alarm2.backgroundColor = [UIColor blackColor];
        alarm2.textColor = [UIColor whiteColor];
        [cell.contentView addSubview:alarm2];   
        }
    else if (indexPath.section == 2){
        cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
        label.backgroundColor = [UIColor blackColor];
        label.textColor = [UIColor lightGrayColor];
        label.text = @"Tags";
        label.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(14.0)];
        [cell.contentView addSubview:label];      
        
        UILabel *tagLabel = [[UILabel alloc] initWithFrame: CGRectMake (45,0,225,40)];
        tagLabel.backgroundColor = [UIColor blackColor];
        tagLabel.textColor = [UIColor whiteColor];
        tagLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:(14.0)];
        NSArray *tempArray = [[NSArray alloc] init];
        tempArray = [theItem.theAppointment.tags allObjects];
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
    if (indexPath.section == 0) {
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
        theItem.addingContext = theItem.theAppointment.managedObjectContext;
        if ([alertView.title isEqualToString:@"New Tag:"]){
            [theItem createNewTagFromText:theTextField.text forType:2];
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
        theItem.addingContext = theItem.theAppointment.managedObjectContext;
        [theItem updateText:theTextView.text];
        [theItem saveNewItem];
        toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);
        [self.view addSubview:toolbar];
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 1) {
        editable = NO;
    } else{
        editable = YES;
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
    if (indexPath.section == 1){
        NSLog(@"TextView Selected");
    }
    else if (indexPath.section == 0){
        NSLog (@"DateTime Cell Selected");
        SchedulerViewController *scheduleViewController = [[SchedulerViewController alloc] init];
        scheduleViewController.hidesBottomBarWhenPushed = YES;
        scheduleViewController.theItem = self.theItem;
        [self.navigationController pushViewController:scheduleViewController animated:YES];
    }
    //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation: UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if(self.editing){
        if (indexPath.section == 2) {
            TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] init];
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            [tempArray addObjectsFromArray:[self.theItem.theAppointment.tags allObjects]];
            detailViewController.theArray = tempArray;
            detailViewController.theItem = (Item *)self.theItem.theAppointment;
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
    
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
        return;
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
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES ];  
                }else {
                    [addView.button1 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button2 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button3 addTarget:self action:@selector(appendToList:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button4 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [actionsPopover presentPopoverFromRect:CGRectMake(85, 370, 50, 40) inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES];  
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
