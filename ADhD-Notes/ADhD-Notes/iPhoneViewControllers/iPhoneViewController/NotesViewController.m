//  NotesViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 7/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "NotesViewController.h"

#import "ADhD_NotesAppDelegate.h"
#import "ArchiveViewController.h"
#import "CustomToolBar.h"
#import "Constants.h"
#import "UINavigationController+NavControllerCategory.h"
#import "MailComposerViewController.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"
#import "CustomDatePlaceCell.h"
#import "MailComposerViewController.h"
#import "TagsDetailViewController.h"
#import "FilesTableViewController.h"
#import "FoldersTableViewController.h"
#import "ListViewAndTableViewController.h"
#import "EventsTableViewController2.h"
#import "CustomTopToolbarView.h"

@interface NotesViewController ()

@property (nonatomic, retain) CustomToolBar *bottomToolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *sortedStrings;
@property (nonatomic, retain) NSIndexPath *lastIndexPath,*selectedIndexPath;
@property (nonatomic, retain) UIButton *folderButton;
@property (nonatomic, retain) FoldersTableViewController *foldersTableViewController;
@property (nonatomic, retain) FilesTableViewController *filesTableViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) ListViewAndTableViewController *listAppendViewController;
@property (nonatomic, retain) UITextView *theTextView;
@property (nonatomic, retain) EventsTableViewController2 *listTableViewController;
@property (nonatomic, retain) CustomTopToolbarView *topToolbarView;

@end

@implementation NotesViewController

@synthesize theItem, saving;
@synthesize bottomToolbar, topToolbarView;
@synthesize actionsPopover;
@synthesize tableView;
@synthesize lastIndexPath, selectedIndexPath;
@synthesize sortedStrings;
@synthesize folderButton;
@synthesize foldersTableViewController;
@synthesize filesTableViewController;
@synthesize managedObjectContext;
@synthesize listAppendViewController;
@synthesize theTextView;
@synthesize listTableViewController;

CGFloat tfHeight;

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad]; 

    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.target = self;
    [self configNavigationTitleView];
  
    topToolbarView = [[CustomTopToolbarView alloc] init];
    [self.view addSubview:topToolbarView];
    
    if (!theTextView){
        CGSize size = [theItem.text sizeWithFont:[UIFont boldSystemFontOfSize:16.0f] constrainedToSize:CGSizeMake(300, 200) lineBreakMode:UILineBreakModeWordWrap];
        tfHeight = MAX (size.height+10, 45);
        theTextView = [[UITextView alloc] initWithFrame:CGRectMake(0,0,320,tfHeight)];
        theTextView.delegate = self;
        theTextView.editable = NO;
        theTextView.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(16.0)];
        theTextView.textColor = [UIColor whiteColor];
        //UIImage *patternImage = [[UIImage imageNamed:@"lined_paper4.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        //[theTextView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        theTextView.backgroundColor = [UIColor clearColor];
        theTextView.text = theItem.text;
    }
    
    if (!self.tableView) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
        tableView.dataSource = self;
        tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor blackColor];
        self.tableView.bounces = NO;
        self.tableView.allowsSelection = YES;
        self.tableView.allowsMultipleSelection = NO;
        self.tableView.allowsSelectionDuringEditing = YES;
        self.tableView.userInteractionEnabled = YES;
        self.tableView.separatorColor = [UIColor blackColor];
        [self.view addSubview:self.tableView];
    }
    if (!bottomToolbar) {
        bottomToolbar = [[CustomToolBar alloc] init];
        bottomToolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight, kScreenWidth, 50);     
        [bottomToolbar changeToDetailButtons];
        [self.view addSubview:bottomToolbar];    
    }
    [self changeTitle];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.tableView = nil;
    self.topToolbarView = nil;
    self.bottomToolbar = nil;
    self.lastIndexPath = nil;
    self.selectedIndexPath = nil;
    self.sortedStrings = nil;
    self.theTextView =nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    NSLog (@"NOTESVIEWCONTROLLER: viewWillAppear");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListSelection:) name:@"ListSelectedNotification" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFolderSelection:) name: @"FolderSelectedNotification" object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
 
    NSIndexPath *tempPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [[self.tableView cellForRowAtIndexPath:tempPath] setSelected:NO animated:NO]; 
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    NSManagedObjectContext *moc = theItem.addingContext;
    NSError *error;
    if(![moc save:&error]){ 
        NSLog(@"NotesViewController:viewWillDisappear -> moc: DID NOT SAVE");
    }  
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ListSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FolderSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];    
}

#pragma mark - Responding to keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@" KeyboardWillShow Notification received");
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]; // Get the origin of the keyboard when it's displayed.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];//??
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];    //Check the height of the topView. If height is at minimum value, then grow
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:animationDuration];
    
    //move bottomView below toolbar.
    CGRect frame = self.tableView.frame;
    frame.size.height = frame.size.height - keyboardTop +100;
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@" KeyboardWillHide Notification received");
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    //Raise the bottomView
    CGRect frame = self.tableView.frame;
    frame.size.height = kScreenHeight - kNavBarHeight - kTabBarHeight - 44;
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}

#pragma mark - Configure Titles

- (void) configNavigationTitleView {
    
    switch ([theItem.type intValue]) {
        case 0:{ //Folder Button For NOTE
            folderButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 55, 45)];
            folderButton.titleLabel.font = [UIFont systemFontOfSize: 12];
            folderButton.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
            folderButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            [folderButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
            [folderButton setTitle:[[theItem.theSimpleNote.collection anyObject] name] forState:UIControlStateNormal];
            [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
            folderButton.tag = 10;
            [folderButton addTarget:self action:@selector(willSaveToFolderOrProject:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = folderButton;}
            break;
        case 2:{ //DATE for Appointment
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEEE, MMMM d"]; 
            NSString *title = [dateFormatter stringFromDate:theItem.aDate];
            UIButton *temp = [[UIButton alloc] initWithFrame:CGRectMake(0, 4,150, 40)];
            temp.layer.borderWidth = 2.0;
            temp.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.6].CGColor;
            temp.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            temp.titleLabel.shadowOffset    = CGSizeMake (1.0, 0.0); 
            temp.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            temp.showsTouchWhenHighlighted = YES;
            temp.tag = 11;
            [temp setTitle:title forState:UIControlStateNormal];

            [temp addTarget:self action:@selector(setEventTime:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = temp;
        }  
            break;
        default:
            break;
    }
}

- (void)changeTitle{
    
    if ([theItem.type intValue] == 0) {
        if (!theItem.name) {
            [self.topToolbarView setItemTitle: @"Title"];
        }
        else {
            [self.topToolbarView setItemTitle:theItem.name];
             }
        
        } else if ([theItem.type intValue] == 2) {
            [self.topToolbarView setAppointmentTimeFrom:theItem.theAppointment.startTime Till:theItem.theAppointment.endTime];
        }
}

- (void) setEventTime:(id) sender{
    NSLog(@"Set Event Time");
}

#pragma mark - Appending to List Or Document

- (void) willAppendToListOrDocument: (id) sender{
    NSLog(@"NOTESVIEWCONTROLLER: willAppendToList");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES]; }
    
    [self.topToolbarView setAppendOrSave:@"search"];
    
    //
    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSaving:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem =nil;
    
    if ([theItem.appendType intValue] == 1 || [sender tag] == 1) {       
        NSLog(@"Appending to LIST");
        listTableViewController = [[EventsTableViewController2 alloc]init];
        if ([sender tag] == 1) {
            listTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        }else {
            listTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        }
        [listTableViewController.tableView setSeparatorColor:[UIColor blackColor]];
        [listTableViewController.tableView setSectionHeaderHeight:13];
        listTableViewController.tableView.rowHeight = kCellHeight;        
        
        NSNumber *num = [NSNumber numberWithInt:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetEventTypeNotification" object:num userInfo:nil];
        [self.view addSubview:listTableViewController.tableView];     
    }else if ([theItem.appendType intValue] == 5 || [sender tag] == 5){
        NSLog(@"Appending to DOC");
        filesTableViewController =  [[FilesTableViewController alloc] initWithStyle:UITableViewStylePlain];
        filesTableViewController.theItem = self.theItem;
        filesTableViewController.saving = YES;
        filesTableViewController.tableView.rowHeight = 50.0;
        filesTableViewController.tableView.frame = CGRectMake(kScreenHeight, kNavBarHeight+44,kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        filesTableViewController.tableView.tag = 13;
        filesTableViewController.managedObjectContext = theItem.addingContext;
        [self.view addSubview:filesTableViewController.tableView];
        [topToolbarView.searchBar setPlaceholder:@"Search for Document"];
        topToolbarView.searchBar.delegate = filesTableViewController;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    if ([theItem.appendType intValue] == 1 || [sender tag] == 1) {    
        listTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        NSLog(@"Moving TableView into View");
    }else if ([theItem.appendType intValue] == 5 || [sender tag] == 5){
        [[self.view viewWithTag:13] setFrame: CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    }
    [UIView commitAnimations];    
}

- (void) handleListSelection: (NSNotification *) notification{ 
    NSLog(@"NOTESVIEWCONTROLLER: handleListSelection:");
    if ([theItem.type intValue] == 0) {
        theItem.theList = [notification object];
        theItem.addingContext = theItem.theList.managedObjectContext;
        [theItem createNewListString:theItem.text];
        theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
        //if (!theItem.listArray) { theItem.listArray = [[NSArray alloc] init];}
        //theItem.listArray = [theItem.theList.aStrings allObjects];
        //theItem.listArray = [theItem.listArray arrayByAddingObject:theItem.theString];
    }
    theItem.theList.editDate = [[NSDate date] timelessDate];
    theItem.saved = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseList:)];
}

- (void) chooseList:(id)sender{
    NSLog(@"NOTESVIEWCONTROLLER: chooseList");
    
    // Called by the Done Button over the ListsTableView (EventsTableViewController2)
    
    /*
     [UIView beginAnimations:nil context:nil];
     [UIView setAnimationDelegate:self];
     [UIView setAnimationDuration:0.5];
     [UIView setAnimationDidStopSelector:@selector(removeView:)];
     
     CGRect frame = listTableViewController.tableView.frame;
     frame.origin.x = kScreenWidth;
     listTableViewController.tableView.frame = frame;
     
     [UIView commitAnimations];
     */
    {theItem.appendType = [NSNumber numberWithInt:1];   
        listAppendViewController= [[ListViewAndTableViewController alloc] init];
        listAppendViewController.theItem = self.theItem;
        listAppendViewController.saving = YES;
        listAppendViewController.appending = YES;
        listAppendViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:listAppendViewController animated:YES];}
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAppended)];
    
}


- (void) cancelAppending:(id) sender{
    NSLog(@"NOTESVIEWCONTROLLER: cancelAppending");

    // Called by the Cancel Button over the ListsTableView (EventsTableViewController2)
    if (theItem.saved == NO) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.target = self;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDidStopSelector:@selector(removeViews)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    listTableViewController.tableView.frame=CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    
    [UIView commitAnimations];        
}


- (void) removeViews {
    if ([listTableViewController.tableView superview] != nil) {
        [listTableViewController.tableView removeFromSuperview];
        listTableViewController = nil;
    } else if ([foldersTableViewController.tableView superview] != nil) {
        [foldersTableViewController.tableView removeFromSuperview];
        foldersTableViewController = nil;
    } else  if ([filesTableViewController.tableView superview] != nil) {
        [filesTableViewController.tableView removeFromSuperview];
        filesTableViewController = nil;
    }
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
        
        if ([actionSheet.title isEqualToString:@"Delete Note?"]) {
            NSLog(@"Deleting Note");
            
            theItem.addingContext = theItem.theSimpleNote.managedObjectContext;
            
            [theItem deleteItem:theItem.theSimpleNote];
            
        }else if ([actionSheet.title isEqualToString:@"Delete List?"]) {
            NSLog(@"Deleting List");
            
            theItem.addingContext = theItem.theSimpleNote.managedObjectContext;
            
            [theItem deleteItem:theItem.theList];
        }
        self.theItem.addingContext = self.theItem.theList.managedObjectContext;        [theItem saveNewItem];
        //self.receivingList.aStrings = [NSSet setWithArray:self.theItem.listArray];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Saving To Folder Or Project
- (void) willSaveToFolderOrProject: (id) sender {
    //SAVE TO FOLDER
    NSLog(@"SAVING TO FOLDER");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    
    self.theItem.appendType = [NSNumber numberWithInt:4];
    foldersTableViewController = [[FoldersTableViewController alloc] initWithStyle:UITableViewStylePlain];
    foldersTableViewController.theItem = self.theItem;
    foldersTableViewController.saving = YES;
    foldersTableViewController.managedObjectContext = theItem.addingContext;
    foldersTableViewController.tableView.rowHeight = 50.0;
    foldersTableViewController.tableView.tag = 12;
    foldersTableViewController.tableView.frame = CGRectMake(320, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    [self.view addSubview:foldersTableViewController.tableView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    //[[self.view viewWithTag:12] setFrame:CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    
    NSLog(@"Setting New Frame for foldertable using view.tag");
     foldersTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    [self.topToolbarView setAppendOrSave:@"search"];
    
    topToolbarView.searchBar.delegate = foldersTableViewController;
    [topToolbarView.searchBar setPlaceholder:@"Search for Folder"];   
    
    folderButton.enabled = NO;
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSaving:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
        
    self.navigationItem.rightBarButtonItem =[self.navigationController addDoneButton];
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(saveItemToFolder:)];
    
    [UIView commitAnimations];
}


- (void) handleFolderSelection:(NSNotification *)notification{
    self.saving = YES;
    NSLog(@"DETAILCONTAINERViewController:handleFolderFileSelection -  notification received");    
    if (self.saving == YES){
        NSLog(@"(SAVING");
        if ([[notification object] isKindOfClass:[Folder class]]) {
            theItem.theFolder = [notification object];
        }
   
    }
}


-(void)saveItemToFolder:(id) sender{
    
    self.theItem.saved = YES;
    if (theItem.theSimpleNote == nil && [theItem.type intValue] == 0){
        theItem.addingContext = theItem.theFolder.managedObjectContext;
        NSLog(@"Creating SimpleNote");
        [theItem createNewSimpleNote];
    }
    if (theItem.theFolder != nil) {
        if (theItem.theSimpleNote != nil){
            NSLog(@"ArchiveViewController: theSimpleNote text = %@", theItem.theSimpleNote.text);
            if (theItem.theFolder.items == nil) {
                theItem.theFolder.items = [NSSet setWithObject:theItem.theSimpleNote];
            } else {
                theItem.theFolder.items = [theItem.theFolder.items setByAddingObject:theItem.theSimpleNote];
            }
            theItem.theSimpleNote.editDate = [[NSDate date] timelessDate];
        } 
    }
    self.saving = NO;
    NSError *error;
    if(![managedObjectContext save:&error]){ 
        NSLog(@"ARCHIVE VIEW MOC:SaveFolderFile -> DID NOT SAVE");
    }
    [theItem saveNewItem];
    
    if (folderButton.titleLabel.text == nil && theItem.theSimpleNote.collection != nil) {
        NSString *folderName = [[theItem.theSimpleNote.collection anyObject] name];
        [folderButton setTitle:folderName forState:UIControlStateNormal];
            }
    theItem.theFolder.name = [[theItem.theSimpleNote.collection anyObject] name];
    [self changeTitle];    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDidStopSelector:@selector(removeView:)];

    [topToolbarView setAppendOrSave:@"search"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationItem.rightBarButtonItem setTarget:self];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    //foldersTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    [[self.view viewWithTag:12] setFrame:CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    folderButton.enabled = YES;
    [UIView commitAnimations];    
}

- (void) presentArchiver: (id) sender {//FOLDER SELECTED
    if ([actionsPopover isPopoverVisible]){[actionsPopover dismissPopoverAnimated:YES];}
    UIButton *tempButton = sender;
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.theItem = self.theItem;
    
    if (tempButton.titleLabel.text == nil || [sender tag] == 3){//Save to Folder Button
        archiveViewController.appending = NO;
        archiveViewController.saving = YES;}                      
    else if ([sender tag] == 5) {//Save to Document Button
        archiveViewController.appending = YES;
        archiveViewController.saving = YES;}
    else {archiveViewController.saving = NO;}
    [self.navigationController pushViewController:archiveViewController animated:YES];
}

- (void) cancelSaving:(id) sender{
    NSLog(@"NOTESVIEWCONTROLLER cancelSaving");
    
    if (theItem.saved == NO) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDidStopSelector:@selector(removeViews)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    if ([self.foldersTableViewController.tableView superview]){
        foldersTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        folderButton.enabled = YES;
    }else if ([self.filesTableViewController.tableView superview]){
        filesTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    }
    [UIView commitAnimations];        
}

#pragma mark - SEND

- (void) sendItem:(id)sender { //Bottom toolbar FourthButtonAction
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    MailComposerViewController *mailDetailViewController = [[MailComposerViewController alloc] init];
    if([sender tag] == 6){
        mailDetailViewController.sendType = [NSNumber numberWithInt:1];
    }
    else if ([sender tag] == 7){
        mailDetailViewController.sendType = [NSNumber numberWithInt:2];
    }
    mailDetailViewController.theText = self.theItem.text;
    [self.navigationController pushViewController: mailDetailViewController animated:YES];
}


#pragma mark - TopToolBar Actions

- (void) goToPrecedingItem:(id) sender{
    NSLog(@"GOING TO PRECEDING ITEM");
}

- (void) goToFollowingItem:(id) sender{
    NSLog(@"GOING TO FOLLOWING ITEM");
}

- (void) showTextBox:(id) sender {
    UIAlertView *textBox = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [textBox setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([sender tag] == 1){
        textBox.title = @"New Tag:";
        textBox.message = @"This is a new tag"; 
        return;
    }if ([sender tag] == 7) {
        textBox.title = @"New Note:";    
    }
    else {
        switch ([theItem.appendType intValue]) {
            case 1:
                textBox.title = @"New Note:";    
                break;
            case 4:
                textBox.title = @"New Folder:";
                break;
            case 5:
                textBox.title = @"New Document:"; 
                break;
            default:
                break;
        }
    }
    [textBox show];
}


- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Save"]){    
        UITextField *theTextField = [alertView textFieldAtIndex:0];
        if ([alertView.title isEqualToString:@"New Folder:"]){
            /*
             NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:managedObjectContext];
             self.theItem.theFolder = [[Folder alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
             */
            NSLog(@"Creating New Folder in theItem.addingContext= %@", self.theItem.addingContext);
            
            [self.theItem createNewFolder];
            self.theItem.theFolder.name = theTextField.text;
            NSLog(@"Created new folder called %@", self.theItem.theFolder.name);
        }
        else if ([alertView.title isEqualToString:@"New Document:"]){
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
            self.theItem.theDocument = [[Document alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            self.theItem.theDocument.name = theTextField.text;
            NSLog(@"Created new document called %@", self.theItem.theDocument.name);
            
            if (saving){
                // NSString *tempString = [NSString stringWithFormat:@"%@%@%@", theDocument.aText, @"\n", theItem.theNote.text];
                //tempString = [myFile.fileText stringByAppendingString:newMemoText.memoText];
                //theDocument.aText = tempString;
                //NSLog(@"Created new document called %@", theDocument.aTitle);
                //CHECKME: same issue as theFolder above
            }
        }else if ([alertView.title isEqualToString:@"New List:"]){
            if (!theItem.theList) {
                NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
                self.theItem.theList = [[List alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
                self.theItem.addingContext = self.theItem.theList.managedObjectContext;
            }
            
            NSManagedObjectContext *moc = theItem.theList.managedObjectContext;
            
            [self.theItem.theList setValue:theTextField.text forKey:@"name"];  
            
            [self changeTitle];
            
            if ([self.theItem.theList hasChanges]){
                NSLog(@"theItem.theList has Changes");
            }
            
            
            
            NSLog(@" theItem.theList isUpdated = %d ",[theItem.theList isUpdated]);
            
            NSError *error;
            if(![moc save:&error]){ 
                NSLog(@"ListViewAndTableViewController:AlertView -> moc: DID NOT SAVE");
            }  
            
        }else if ([alertView.title isEqualToString:@"New Tag:"]){
            theItem.addingContext = theItem.theList.managedObjectContext;
            [theItem createNewTagFromText:theTextField.text forType:1];
            [theItem saveNewItem];
            NSIndexPath *tempPath = [NSIndexPath indexPathForRow:0 inSection:1];
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:tempPath] withRowAnimation:UITableViewRowAnimationTop];
        } else if ([alertView.title isEqualToString:@"New Note:"]){
            theItem.theSimpleNote.name = theTextField.text;
            theItem.name = theItem.theSimpleNote.name;
            [theItem saveNewItem];
            [self changeTitle];
            
        } 
    }
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
        case 1://tags
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat result;
    switch (indexPath.section) {
        case 0:
            if (indexPath.row != self.selectedIndexPath.row){
                result = 30;
            }  else {  
                /* Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
                 CGSize size = [listItem.aString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 80) lineBreakMode:UILineBreakModeWordWrap];
                 tHeight = MAX (size.height+20, 40);*/
              
                return tfHeight +10;   
            }
            break;
        case 1:
            result = 50;
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
        fHeight = 5.0;
    }
    else if (section == 1){
        fHeight = 5.0;
    } else {
        fHeight = 5.0;
    }
    return fHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,300)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {  
    if (indexPath.section == 0){
        static NSString *CellIdentifier = @"CellIdentifier";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.contentView.layer.borderWidth = 2.0;
            cell.contentView.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.6].CGColor;

            }
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.contentView addSubview: theTextView];
        return cell;
        }
    else if (indexPath.section == 1){
        static NSString *DatePlaceCellIdentifier = @"DatePlaceCell";
        CustomDatePlaceCell * cell = [self.tableView dequeueReusableCellWithIdentifier:DatePlaceCellIdentifier];
        if (cell == nil) {
            cell = [[CustomDatePlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DatePlaceCellIdentifier];
            cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            cell.contentView.layer.borderWidth = 2.0;
            cell.contentView.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.6].CGColor;

        }
        return cell;
    }
    else if (indexPath.section == 2){
        static NSString *CellIdentifier = @"TagCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            cell.contentView.layer.borderWidth = 2.0;
            cell.contentView.layer.borderColor = [UIColor colorWithWhite:0.15 alpha:0.6].CGColor;
        }
        
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
        return cell;
    }
//    return cell;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        cell.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"54700.png"]stretchableImageWithLeftCapWidth:320 topCapHeight:33]];
        [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
        [[cell detailTextLabel] setBackgroundColor:[UIColor clearColor]];
    }
}

#pragma mark - Editing
- (void) textViewDidBeginEditing:(UITextView *)textView {
    NSIndexPath *textViewIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];    
    [self.tableView scrollToRowAtIndexPath:textViewIndexPath atScrollPosition: UITableViewScrollPositionBottom animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if(editing == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];
        NSLog (@"MemoDetailViewController: setEditing -> Is Editing");
        
        theTextView.editable = self.editing;
        //toolbar = [[CustomToolBar alloc] init];
        //theTextView.inputAccessoryView = toolbar;
    }
	[self.navigationItem setHidesBackButton:editing animated:YES];
    
    if (editing == NO) {
        NSLog (@"MemoDetailViewController: setEditing -> Is NOT Editing");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];  
        
        NSLog(@"Simple Note is Not  Editing");
        [theTextView resignFirstResponder];
        theTextView.inputAccessoryView = nil;
        theTextView.editable = self.editing;
        [theItem updateText:theTextView.text];
        theItem.theSimpleNote.editDate = [[NSDate date ]timelessDate];
        [theItem saveNewItem];
        NSLog(@"Simple Note Editdate = %@", theItem.theSimpleNote.editDate);
        //toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight-kNavBarHeight, kScreenWidth, kTabBarHeight);
        //[self.view addSubview:toolbar];
        
        NSManagedObjectContext *context = theItem.theSimpleNote.managedObjectContext;
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 2) { editable = NO;} 
    else{ editable = YES; }
    return editable;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCellEditingStyle style = UITableViewCellEditingStyleNone;
    if (indexPath.section == 0) {
        // If this is the last item, it's the insertion row.
        
        if (indexPath.row == [sortedStrings count]) {
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
    
    if (editingStyle == UITableViewCellEditingStyleDelete && indexPath.section == 0) {
        // Delete the row from the data source
        //FIXME: GET ORDERING        
        Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
        [theItem.theList removeAStringsObject:listItem];
        theItem.theList.editDate = [[NSDate date] timelessDate];
        [sortedStrings removeObject:listItem];
        
        NSManagedObjectContext *context = listItem.managedObjectContext;
        [context deleteObject:listItem];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.selectedIndexPath = indexPath;
                  
    } else if (indexPath.section == 2) {
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [tempArray addObjectsFromArray:[self.theItem.theList.tags allObjects]];
        detailViewController.theArray = tempArray;
        detailViewController.theItem = (Item *)self.theItem.theList;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }else if (indexPath.section == 1) {
        //
    }
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
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES ];  
                }else {
                    
                    [addView.button1 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button2 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button3 addTarget:self action:@selector(willAppendToListOrDocument:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button4 addTarget:self action:@selector(presentArchiver:) forControlEvents:UIControlEventTouchUpInside];
                    [actionsPopover presentPopoverFromRect:CGRectMake(85, 412, 50, 40) inView:self.view
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
                                  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES ]; 
                }else {
                    [addView.button1 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
                    [addView.button2 addTarget:self action:@selector(sendItem:) forControlEvents:UIControlEventTouchUpInside];
                    
                    [actionsPopover presentPopoverFromRect:CGRectMake(205, 412, 50, 50) inView:self.view
                                  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES ]; 
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



