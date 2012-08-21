//  ListViewAndTableViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ListViewAndTableViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "CustomToolBar.h"
#import "Constants.h"
#import "UINavigationController+NavControllerCategory.h"
#import "ListStringDetailViewController.h"
#import "ArchiveViewController.h"
#import "EventsTableViewController2.h"
#import "MailComposerViewController.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"
#import "MailComposerViewController.h"
#import "CustomListCell.h"
#import "CustomDatePlaceCell.h"
#import "TagsDetailViewController.h"
#import "FilesTableViewController.h"
#import "FoldersTableViewController.h"
#import "CustomTopToolbarView.h"

@interface ListViewAndTableViewController ()

@property (nonatomic, retain) CustomToolBar *bottomToolbar;
@property (nonatomic, retain) EventsTableViewController2 *listTableViewController;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) NSMutableArray *sortedStrings;
@property (nonatomic, retain) NSIndexPath *lastIndexPath;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) UITextView *addTextView;
@property (nonatomic, retain) UIButton *folderButton;
@property (nonatomic, retain) FoldersTableViewController *foldersTableViewController;
@property (nonatomic, retain) FilesTableViewController *filesTableViewController;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) List *receivingList;
@property (nonatomic, retain) CustomTopToolbarView *topToolbarView;

@end

@implementation ListViewAndTableViewController

@synthesize theItem, saving, appending;
@synthesize bottomToolbar, topToolbarView;
@synthesize listTableViewController;
@synthesize actionsPopover;
@synthesize tableView;
@synthesize lastIndexPath, selectedIndexPath;
@synthesize sortedStrings;
@synthesize addTextView;
@synthesize folderButton;
@synthesize foldersTableViewController;
@synthesize filesTableViewController;
@synthesize managedObjectContext;
@synthesize receivingList;

CGFloat tHeight;

#pragma mark - View Management

- (void)viewDidLoad {
    [super viewDidLoad]; 
    if (!theItem.addingContext) {
        theItem.addingContext = theItem.theList.managedObjectContext;
    }
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.target = self;
    [self configNavigationTitleView];
    
    topToolbarView = [[CustomTopToolbarView alloc] init];
    [self.view addSubview:topToolbarView];
    
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
    self.addTextView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    NSLog (@"ListViewAndTableController: viewWillAppear");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListSelection:) name:@"ListSelectedNotification" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFolderSelection:) name: @"FolderSelectedNotification" object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    if (self.theItem.saved || self.theItem.theList) {
        
    [self getSortedStrings];
    }
    if (self.saving && self.appending) {
        if (theItem.theString || theItem.theSimpleNote){
        [self configureAppendingView];
        }
    }
    
    NSIndexPath *tempPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deselectRowAtIndexPath:tempPath animated:YES]; 
    
    
    switch ([theItem.type intValue]) {
        case 0:
            if (folderButton.titleLabel.text == nil && theItem.theSimpleNote.collection != nil) {
                NSString *folderName = [[theItem.theSimpleNote.collection anyObject] name];
                [folderButton setTitle:folderName forState:UIControlStateNormal];
            }
            break;
        case 1:
            if (folderButton.titleLabel.text == nil && theItem.theList.collection != nil) {
                NSString *folderName = [[theItem.theList.collection anyObject] name];
                [folderButton setTitle:folderName forState:UIControlStateNormal];
            }
            break;    
        default:
            break;
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSManagedObjectContext *moc = theItem.theList.managedObjectContext;    
       NSError *error;
    if(![moc save:&error]){ 
        NSLog(@"ListViewAndTableViewController:viewWillDisappear -> moc: DID NOT SAVE");
    }  
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ListSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FolderSelectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];
}

- (void) getSortedStrings {
    if (self.tableView.editing && ![theItem.theList hasChanges]) {
        NSLog(@"getSortedStrings: No changes: DO NOTHING");
        return;
    }
    
    NSLog(@"GetSortedString: theItem.listArray count = %d", [theItem.listArray count]);
    if (!theItem.listArray || [[theItem.listArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
        theItem.listArray = [[NSArray alloc] init];
    }
    if (sortedStrings == nil) {
        if ([theItem.type intValue] == 0) {
            //if (!theItem.listArray) { theItem.listArray = [[NSArray alloc] init];}
            //theItem.listArray = [theItem.theList.aStrings allObjects];
            theItem.listArray = [theItem.listArray arrayByAddingObject:theItem.theString];
        }
        theItem.listArray = [theItem.listArray arrayByAddingObjectsFromArray:[theItem.theList.aStrings allObjects]];
    }else if (receivingList != nil){
        theItem.listArray = [theItem.listArray arrayByAddingObjectsFromArray:[self.receivingList.aStrings allObjects]];
        }
    else{
        theItem.listArray = [theItem.theList.aStrings allObjects];
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    sortedStrings = [[NSMutableArray alloc] init];
    [sortedStrings addObjectsFromArray:theItem.listArray];
    [sortedStrings sortUsingDescriptors:sortDescriptors];  
    NSLog(@"ListViewAndTableController: sortedStrings count = %d", [sortedStrings count]);  
    
    [self.tableView reloadData];   
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
        case 1:{
            //Folder Button For LIST
            folderButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 5, 55, 45)];
            folderButton.titleLabel.font = [UIFont systemFontOfSize: 12];
            folderButton.titleLabel.shadowOffset = CGSizeMake (1.0, 0.0);
            folderButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
            [folderButton setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
            [folderButton setTitle:[[theItem.theList.collection anyObject] name] forState:UIControlStateNormal];

            [folderButton setBackgroundImage:[UIImage imageNamed:@"folder.png"] forState:UIControlStateNormal];
            folderButton.tag = 10;
            [folderButton addTarget:self action:@selector(willSaveToFolderOrProject:) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.titleView = folderButton;}
            break;
        case 3:{
            //DATE for ToDo
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
    
    if ([theItem.type intValue] == 1) {
        if (!theItem.name) {
            [self.topToolbarView setItemTitle: @"List"];}
        else {          
            [self.topToolbarView setItemTitle:theItem.name];
        }
    } else if ([theItem.type intValue] == 3) {
        if (!theItem.name) {[self.topToolbarView setItemTitle: @"ToDo"];}
        [self.topToolbarView setItemTitle:theItem.name];
    }
}

- (void) setEventTime:(id) sender{
    NSLog(@"Set Event Time");
}

#pragma mark - Appending to List Or Document

- (void) configureAppendingView{
    
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: configureAppendingView");

    [self.navigationItem setHidesBackButton:YES animated:NO];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSaving:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    self.navigationItem.rightBarButtonItem =nil;
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAppended)];
    
}

- (void) willAppendToListOrDocument: (id) sender{
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: willAppendToListOrDocument");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    [self.topToolbarView setAppendOrSave:@"search"];
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
        listTableViewController.eventType = [NSNumber numberWithInt:1];
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
    }else if ([theItem.appendType intValue] == 5 || [sender tag] == 5){
        [[self.view viewWithTag:13] setFrame: CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    }
    [UIView commitAnimations];    
}

- (void) handleListSelection: (NSNotification *) notification{ NSLog(@"ListSelectedNotification Received");   
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: handleListSelection");

    if ([theItem.type intValue] == 0) {
        theItem.theList = [notification object];
        theItem.addingContext = theItem.theList.managedObjectContext;
        [theItem createNewListString:theItem.text];
        theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
        //if (!theItem.listArray) { theItem.listArray = [[NSArray alloc] init];}
        //theItem.listArray = [theItem.theList.aStrings allObjects];
        //theItem.listArray = [theItem.listArray arrayByAddingObject:theItem.theString];
    }else if ([theItem.type intValue] == 1){
        NSArray *tempArray = [[NSArray alloc] init];
        if (theItem.theList != nil) { NSLog(@"Appending a saved List");
            theItem.listArray = [theItem.theList.aStrings allObjects];
            NSLog(@"The Number of Receiving List Items are %d", [theItem.listArray count]);
            self.receivingList = [notification object];
            theItem.addingContext = receivingList.managedObjectContext;
            for (int i = 0; i<[theItem.listArray count]; i++) {
                Liststring *tempListString = [theItem.listArray objectAtIndex:i];
                NSString *temp = [NSString stringWithString:tempListString.aString];
                [theItem createNewListString:temp];
                theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]+i ];
                tempArray = [tempArray arrayByAddingObject:theItem.theString];
            }
            theItem.listArray = tempArray;
            NSLog(@"The Number of Final List Items are %d", [theItem.listArray count]);
        }else if (!theItem.theList){ NSLog(@"Appending an unsaved List");
            theItem.theList = [notification object];
            theItem.addingContext = theItem.theList.managedObjectContext;
            for (int i = 0; i<[theItem.listArray count]; i++) {
                [theItem createNewListString:[theItem.listArray objectAtIndex:i]];
                theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
                tempArray = [tempArray arrayByAddingObject:theItem.theString];
                //theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:theItem.theString];
            }
            tempArray = [tempArray arrayByAddingObjectsFromArray:[theItem.theList.aStrings allObjects]];
            theItem.listArray = tempArray;
        }
    }
    theItem.theList.editDate = [[NSDate date] timelessDate];
    theItem.saved = NO;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(chooseList:)];    
}

- (void) cancelAppending:(id) sender{ 
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: cancelAppending");
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

- (void) chooseList:(id)sender{
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: chooseList");

    // Called by the Done Button over the ListsTableView (EventsTableViewController2)
    
    [self getSortedStrings];
    [self.tableView reloadData];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDidStopSelector:@selector(removeView:)];
        
    CGRect frame = listTableViewController.tableView.frame;
    frame.origin.x = kScreenWidth;
    listTableViewController.tableView.frame = frame;
        
    [UIView commitAnimations];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAppended)];
}

- (void) saveAppended {
    NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER: saveAppended");

    //Called by the Save Button over the Appended List
    self.theItem.saved = YES;
    self.saving = YES;
    if ([theItem.type intValue] == 0) {
        theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:theItem.theString];
        [theItem saveNewItem];

    }else if ([theItem.type intValue]== 1){
        self.receivingList.aStrings = nil;
        self.receivingList.aStrings = [[NSSet alloc] initWithArray:theItem.listArray];
    }    
    
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    self.navigationItem.rightBarButtonItem.target = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = [self.navigationController addEditButton];;
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(setEditing:);
    [self.topToolbarView setItemTitle:theItem.name];
        
    [self deleteSimpleNote:nil];
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
    if (theItem.theSimpleNote) {
        UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 240)];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete Note?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil]; 
        [actionSheet showInView:actionView];
    } else if (theItem.theList && self.receivingList){
        NSLog(@"After Appending a List to another list");
        UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 240)];
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Delete List?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:nil]; 
        [actionSheet showInView:actionView];
    }
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

            theItem.addingContext = theItem.theList.managedObjectContext;
            
            [theItem deleteItem:theItem.theList];
        }
        self.theItem.theList = receivingList;
        self.theItem.addingContext = self.theItem.theList.managedObjectContext;
        [theItem saveNewItem];
        //self.receivingList.aStrings = [NSSet setWithArray:self.theItem.listArray];
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Saving To Folder
- (void) willSaveToFolderOrProject: (id) sender {
    //SAVE TO FOLDER
    NSLog(@"SAVING TO FOLDER");
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    
    [self.navigationItem setHidesBackButton:YES animated:NO];
    folderButton.enabled = NO;

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
    [topToolbarView setAppendOrSave:@"search"];
    
    topToolbarView.searchBar.delegate = foldersTableViewController;
    [topToolbarView.searchBar setPlaceholder:@"Search for Folder"];   
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSaving:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.navigationItem.rightBarButtonItem =[self.navigationController addDoneButton];
    [self.navigationItem.rightBarButtonItem setTarget:self];
    [self.navigationItem.rightBarButtonItem setAction:@selector(saveItemToFolder:)];
    
    [UIView commitAnimations];
}

- (void) handleFolderSelection:(NSNotification *)notification{
    self.saving = YES;
    NSLog(@"DETAILCONTAINERViewController:handleFolderSelection -  notification received");    
    if (self.saving == YES){
        NSLog(@"(SAVING");
        if ([[notification object] isKindOfClass:[Folder class]]) {
            theItem.theFolder = [notification object];
        }
    }
}

-(void)saveItemToFolder:(id) sender{
    
    self.theItem.saved = YES;
    if (theItem.theList == nil && [theItem.type intValue] == 1){
        theItem.addingContext = theItem.theFolder.managedObjectContext;
        NSLog(@"Creating List");
        [theItem createNewList];
    }
    if (theItem.theFolder != nil) {
        if (theItem.theList != nil){
            NSLog(@"ListViewAndTableController: theList text = %@", theItem.theList.text);
            if (theItem.theFolder.items == nil) {
                theItem.theFolder.items = [NSSet setWithObject:theItem.theList];
            } else {
                theItem.theFolder.items = [theItem.theFolder.items setByAddingObject:theItem.theList];
            }
            theItem.theList.editDate = [[NSDate date] timelessDate];
        }
    }    
    saving = NO;
    NSError *error;
    
    if(![managedObjectContext save:&error]){ 
        NSLog(@"ListViewAndTableController  MOC:SaveFolder -> DID NOT SAVE");
    }
    [theItem saveNewItem];
    
   
    if (folderButton.titleLabel.text == nil && theItem.theList.collection != nil) {
    [folderButton setTitle:theItem.theFolder.name forState:UIControlStateNormal];
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    
    [topToolbarView setAppendOrSave:@"search"];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //[self.navigationItem.rightBarButtonItem setTarget:memoDetailViewController];
    self.navigationItem.leftBarButtonItem = nil;
    [self.navigationItem setHidesBackButton:NO animated:YES];
    //foldersTableViewController.tableView.frame = CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    [[self.view viewWithTag:12] setFrame:CGRectMake(kScreenWidth, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44)];
    
    //memoDetailViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
    
    [UIView commitAnimations];    
}

- (void) presentArchiver: (id) sender {//FOLDER SELECTED
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    UIButton *tempButton = sender;
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.theItem = self.theItem;
    
    if (tempButton.titleLabel.text == nil || [sender tag] == 3){//Save to Folder Button
        archiveViewController.appending = NO;
        archiveViewController.saving = YES;
    }                      
    else if ([sender tag] == 5) {//Save to Document Button
        archiveViewController.appending = YES;
        archiveViewController.saving = YES;
    }else {
        archiveViewController.saving = NO;
    }
    
    [self.navigationController pushViewController:archiveViewController animated:YES];
}


- (void) cancelSaving:(id) sender{
    NSLog(@"LISTVIEWANDTABLECONTROLLER cancelSaving");
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
    NSLog(@"GOING TO PRECEDING ITEM");}

- (void) goToFollowingItem:(id) sender{
    NSLog(@"GOING TO FOLLOWING ITEM"); }

- (void) showTextBox:(id) sender {
    
    UIAlertView *textBox = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [textBox setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if ([sender tag] == 1){
        textBox.title = @"New Tag:";
        textBox.message = @"This is a new tag"; 
        return;
    }if ([sender tag] == 7) {
        textBox.title = @"New List:";    
    }
    else {
        switch ([theItem.appendType intValue]) {
            case 1:
                textBox.title = @"New List:";    
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
            self.theItem.name = self.theItem.theList.name;
        
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
            theItem.addingContext = theItem.theSimpleNote.managedObjectContext;
            theItem.theSimpleNote.name = theTextField.text;
            [theItem saveNewItem];
            [self changeTitle];

        } 
    }
}

#pragma mark - BottomToolBar Actions


- (void) goToMain: (id) sender {    
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows;
    switch (section) {
        case 0:// Text
            rows = [sortedStrings count];
            if (self.tableView.editing == YES) {
                NSLog(@"NumberOfRowsInSection -> adding a row");
                rows++;
            }
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
                result = 50;
            }  else {                
                Liststring *listItem = [sortedStrings objectAtIndex:indexPath.row];
                CGSize size = [listItem.aString sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 80) lineBreakMode:UILineBreakModeWordWrap];
                NSLog(@"Row %d tHeight is %f", indexPath.row, size.height);
                tHeight = MAX (size.height+50, 80);
                return tHeight;   
            }
            break;
        case 1:
            result = 40;
            break;
        case 2:
            result = 50;
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
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,300)];
    footerView.backgroundColor = [UIColor blackColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    if (indexPath.section == 2){
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE, MMM d, YYYY"];   
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,2,180,15)];
        dateLabel.backgroundColor = [UIColor blackColor];
        dateLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        dateLabel.textColor = [UIColor whiteColor];
        NSString *date = [dateFormatter stringFromDate:theItem.theList.creationDate];
        dateLabel.textAlignment = UITextAlignmentLeft;
        NSString *temp = [NSString stringWithFormat:@"%@", date];
        dateLabel.text = temp;
        [cell.contentView addSubview: dateLabel];
        
        [dateFormatter setDateFormat:@"h::mm a"];   
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,17,180,15)];
        timeLabel.backgroundColor = [UIColor blackColor];
        timeLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldItalicMT" size:(14.0)];
        timeLabel.textColor = [UIColor whiteColor];
        date = [dateFormatter stringFromDate:theItem.theList.creationDate];
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
        return cell;
        
    } else if (indexPath.section == 0){
        NSInteger listCount = [sortedStrings count];
        
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
            
            //UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
            
			static NSString *ListCellIdentifier = @"ListCell";
			CustomListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ListCellIdentifier];
			if (cell == nil) {
				cell = [[CustomListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ListCellIdentifier];                
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            }else
            {
                // the cell is being recycled, remove old embedded controls
                UIView *viewToRemove = nil;
                viewToRemove = [cell.contentView viewWithTag:1];
                if (viewToRemove)
                    [viewToRemove removeFromSuperview];
                //cell.textLabel.text = listItem.aString;
                
               
                cell.accessoryView = button;
            }
            cell.textView.text = listItem.aString;
            cell.theRow = [NSNumber numberWithInt:indexPath.row];
            
            return cell;
        }  else if (indexPath.row == listCount){
            // If the row is outside the range, it's the row that was added to allow insertion (see tableView:numberOfRowsInSection:) so give it an appropriate label.
			static NSString *AddItemCellIdentifier = @"AddItemCell";
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AddItemCellIdentifier];
			if (cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AddItemCellIdentifier];
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                //[cell.contentView addSubview:addTextView];
                cell.textLabel.text = @"Add Item";
			}
            return cell;
        }
        
    }else if (indexPath.section == 1){
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *tagLabel;
        UIButton *tagButton;
        UILabel *label; 
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            
            label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 40, 40)];
            label.backgroundColor = [UIColor blackColor];
            label.textColor = [UIColor lightGrayColor];
            label.text = @"Tags";
            label.font = [UIFont fontWithName:@"TimesNewRomanPS-ItalicMT" size:(14.0)];
            [cell.contentView addSubview:label];     
            label.tag = 8;
            
            tagLabel = [[UILabel alloc] initWithFrame: CGRectMake (45,0,225,40)];
            tagLabel.backgroundColor = [UIColor blackColor];
            tagLabel.textColor = [UIColor whiteColor];
            tagLabel.font = [UIFont fontWithName:@"TimesNewRomanPS-BoldMT" size:(14.0)];
            tagLabel.tag = 7;
            
            tagButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 0, 40, 40)];
            [tagButton setImage:[UIImage imageNamed:@"tag_add_24"] forState:UIControlStateNormal];
            [tagButton addTarget:self action:@selector(showTextBox:) forControlEvents:UIControlEventTouchUpInside];
            tagButton.tag = 1;
            [cell.contentView addSubview:tagButton]; 

        }else {
        
            // the cell is being recycled, remove old embedded controls
            if (tagLabel){
                [[cell.contentView viewWithTag:7] removeFromSuperview];
            }
            if (tagButton) {
                [[cell.contentView viewWithTag:1] removeFromSuperview];
            }
            if (label) {
                [[cell.contentView viewWithTag:8] removeFromSuperview];
            }
            //cell.textLabel.text = listItem.aString;

        }
                
        NSArray *tempArray = [[NSArray alloc] init];
        tempArray = [theItem.theList.tags allObjects];
        NSString *tempString = @"";
        for (int i = 0; i<[tempArray count]; i++) {
            tempString = [tempString stringByAppendingString:[[tempArray objectAtIndex:i] name]];
            tempString = [tempString stringByAppendingString:@" / "];

        }
        tagLabel.text = tempString;
        
        return cell;
    }
    //return cell;
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

#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    NSLog(@"LISTDETAILVIEWCONTROLLER: SET EDITING CALLED");
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];	//KJF: This was just a chance fix. Don't know why it works
    
	[self.navigationItem setHidesBackButton:editing animated:YES];
  
	[self.tableView beginUpdates];
    NSArray *itemsInsertIndexPath = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[sortedStrings count] inSection:0]];
    if (editing) {        
        NSLog (@"LISTVIEWANDTABLEVIEWCONTROLLER: setEditing -> Is Editing");
        //NSNumber *ev = [NSNumber numberWithInt:1];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];
        //add row for Adding Items
        [self.tableView insertRowsAtIndexPaths:itemsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    } else {
        NSLog (@"LISTVIEWANDTABLEVIEWCONTROLLER: setEditing -> Is NOT Editing");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TableViewIsEditingNotification" object:nil];  

        [self.tableView deleteRowsAtIndexPaths:itemsInsertIndexPath withRowAnimation:UITableViewRowAnimationTop];
    }
    [self.tableView endUpdates];

    //If editing is finished, save the managed object context.
	if (editing == NO) {
        /*
        if (![addTextView.text isEqualToString:@"Add Item"]) {
            NSLog(@"Saving New Items");
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liststring" inManagedObjectContext:context];
            Liststring *newliststring = [[Liststring alloc] initWithEntity:entity insertIntoManagedObjectContext:context];
            newliststring.aString = addTextView.text;
            newliststring.order = [NSNumber numberWithInt:[sortedStrings count]];
            theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:newliststring];
            [sortedStrings addObject:newliststring];
            [self.tableView reloadData];
        }
         */
        if (selectedIndexPath != nil && selectedIndexPath.row < [sortedStrings count]) {
            NSManagedObjectContext *context = theItem.theList.managedObjectContext;        
            CustomListCell *tempCell = (CustomListCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];

            if (![tempCell.thetext isEqualToString:tempCell.textView.text]){
                NSLog(@"LISTVIEWANDTABLEVIEWCONTROLLER:setEditing -> SelectedIndexPath is %d", selectedIndexPath.row);
                theItem.theString = [sortedStrings objectAtIndex:selectedIndexPath.row];
                theItem.theString.aString = tempCell.textView.text;                        
                //Update the Array
                [[sortedStrings objectAtIndex:selectedIndexPath.row] setAString:tempCell.textView.text];
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationBottom];                
                [[self.tableView cellForRowAtIndexPath:selectedIndexPath] setSelected:NO animated:YES];
            }
        
        //NSNumber *ev = [NSNumber numberWithInt:0];
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"EditDoneNotification" object:ev];        
		NSError *error = nil;
		if (![context save:&error]) {
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
        addTextView.userInteractionEnabled = NO;
        [self.tableView reloadData];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL editable;
    if (indexPath.section == 2) {
        editable = NO;
    } else{
        editable = YES;
    }
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

- (void) changeTextInListItemAtIndexPath: (NSIndexPath *) indexPath {
    NSLog(@"Changing Text at IndexPath.row = %d", indexPath.row);
    CustomListCell *tempCell = (CustomListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    theItem.theString = [sortedStrings objectAtIndex:indexPath.row];
    NSManagedObjectContext *context = theItem.theString.managedObjectContext;
    
    //Update and Save the new value of the List Item
    theItem.theString.aString = tempCell.textView.text;
    
    //Update the Array
    [[sortedStrings objectAtIndex:indexPath.row] setAString:tempCell.textView.text];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];    
}

- (void) handleTableViewEditing: (NSNotification *)notification{
    NSLog(@"TableViewEditingNotification Received");
    self.editing = !self.editing;
    [self setEditing:self.editing animated:YES];
}

- (void) doneEditing:(NSNotification *) notification {
    NSLog(@"DONE EDITING NOTIFICATION RECEIVED");
    int myValue = [[notification object] intValue];
    switch (myValue) {
        case 0:
            self.navigationItem.rightBarButtonItem.title = @"Edit";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
            //self.navigationItem.rightBarButtonItem.target = listDetailViewController;  
            break;
        case 1:
            self.navigationItem.rightBarButtonItem.title = @"Done";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
            //self.navigationItem.rightBarButtonItem.target = listDetailViewController;   
            break;
            
        default:
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.selectedIndexPath = indexPath;
        if (!self.editing) {            
            if (indexPath.row < [sortedStrings count]) {
                NSLog(@"didSelectRowAtIndexPath.row = %d and NOT editing", indexPath.row);
                
                if (indexPath.row != lastIndexPath.row) {   
                    //[[self.tableView cellForRowAtIndexPath:lastIndexPath] setSelected:NO];
                    //[self.tableView deselectRowAtIndexPath:lastIndexPath animated:NO];
                    //[[self.tableView cellForRowAtIndexPath:lastIndexPath] setHighlighted:NO];
                    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,lastIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
                    [[self.tableView cellForRowAtIndexPath:selectedIndexPath] setSelected:YES];

                    [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES];
                }
            }
        } else if (self.editing){
            NSLog(@"DIDSELECTROW AND EDITING at IndexPath.row = %d", indexPath.row);
            if (indexPath.row < [sortedStrings count]) {
                if (lastIndexPath != nil) {
                    [self changeTextInListItemAtIndexPath:lastIndexPath];
                }
            }else  {
                NSLog(@"ADD ITEM CELL");
                ListStringDetailViewController *stringDetailViewController = [[ListStringDetailViewController alloc] init];
                stringDetailViewController.theList = self.theItem.theList;
        
                [self.navigationController pushViewController:stringDetailViewController animated:YES];
                /*
                UIView *stringView = [[UIView alloc] initWithFrame:CGRectMake(0, -44, 320, kScreenHeight-kNavBarHeight-kTabBarHeight)];
                
                stringView.backgroundColor = [UIColor blackColor];
                                addTextView = [[UITextView alloc] initWithFrame: CGRectMake (5,10,300,100)];
                addTextView.textColor = [UIColor whiteColor];
                UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
                [addTextView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
                addTextView.layer.cornerRadius = 5.0;
                [addTextView setFont:[UIFont systemFontOfSize:14]];
                addTextView.layer.borderWidth = 2.0;
                addTextView.layer.borderColor = [UIColor darkGrayColor].CGColor;      
                [stringView addSubview:addTextView];
                [self.view addSubview:stringView];
                //addTextView.text = nil;
                //addTextView.userInteractionEnabled = YES;
                //[addTextView becomeFirstResponder];
                
                */
                /*
                 [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
                 [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                 */
                //[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            }            
        }
        //[[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemSelectedNotification" object:self.theList];
        //}else if (indexPath.row < listCount) {
        //  [[NSNotificationCenter defaultCenter] postNotificationName:@"ListItemSelectedNotification" object:[sortedStrings objectAtIndex:indexPath.row]];
        //}
        
    } else if (indexPath.section == 1) {
        TagsDetailViewController *detailViewController = [[TagsDetailViewController alloc] init];
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        
        [tempArray addObjectsFromArray:[self.theItem.theList.tags allObjects]];
        detailViewController.theArray = tempArray;
        detailViewController.theItem = (Item *)self.theItem.theList;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
    self.lastIndexPath = indexPath;
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
                
            case 2:{
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
            case 4:{
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
 
 
 
 
 - (void) handleListSelection: (NSNotification *) notification{
 
 NSLog(@"ListSelectedNotification Received");
 if ([theItem.type intValue] == 0) {
 theItem.theList = [notification object];
 theItem.addingContext = theItem.theList.managedObjectContext;
 [theItem createNewListString:theItem.text];
 theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
 if (!theItem.listArray) {
 theItem.listArray = [[NSArray alloc] init];
 }
 theItem.listArray = [theItem.theList.aStrings allObjects];
 theItem.listArray = [theItem.listArray arrayByAddingObject:theItem.theString];
 
 }else if ([theItem.type intValue] == 1){
 NSArray *tempArray = [[NSArray alloc] init];
 
 if (theItem.theList != nil) {
 NSLog(@"Appending a saved List");
 theItem.listArray = [theItem.theList.aStrings allObjects];
 //Receiving List    
 theItem.theList = [notification object];
 theItem.addingContext = theItem.theList.managedObjectContext;
 
 for (int i = 0; i<[theItem.listArray count]; i++) {
 Liststring *tempListString = [theItem.listArray objectAtIndex:i];
 NSString *temp = [NSString stringWithString:tempListString.aString];
 [theItem createNewListString:temp];
 theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]+i ];
 tempArray = [tempArray arrayByAddingObject:theItem.theString];
 //theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:theItem.theString];
 }
 tempArray = [tempArray arrayByAddingObjectsFromArray:[theItem.theList.aStrings allObjects]];
 theItem.listArray = tempArray;
 
 }else if (!theItem.theList){
 NSLog(@"Appending an unsaved List");
 
 theItem.theList = [notification object];
 theItem.addingContext = theItem.theList.managedObjectContext;
 for (int i = 0; i<[theItem.listArray count]; i++) {
 [theItem createNewListString:[theItem.listArray objectAtIndex:i]];
 theItem.theString.order = [NSNumber numberWithInt:[theItem.theList.aStrings count]];
 tempArray = [tempArray arrayByAddingObject:theItem.theString];
 //theItem.theList.aStrings = [theItem.theList.aStrings setByAddingObject:theItem.theString];
 }
 tempArray = [tempArray arrayByAddingObjectsFromArray:[theItem.theList.aStrings allObjects]];
 theItem.listArray = tempArray;
 }
 }
 theItem.theList.editDate = [[NSDate date] timelessDate];
 theItem.saved = NO;
 ListDetailViewController *detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
 detailViewController.saving = YES;
 detailViewController.theItem = self.theItem;
 detailViewController.theList = self.theItem.theList;    
 detailViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-44);
 //[self.view addSubview:detailViewController.tableView];
 [self.navigationController pushViewController:detailViewController animated:YES];
 self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAppended)];
 }
 
 - (void) handleFolderFileSelection:(NSNotification *)notification{
 self.saving = YES;
 
 NSLog(@"DETAILCONTAINERViewController:handleFolderFileSelection -  notification received");    
 if (self.saving == YES){
 NSLog(@"(SAVING");
 if ([[notification object] isKindOfClass:[Folder class]]) {
 theItem.theFolder = [notification object];
 }
 else if ([[notification object] isKindOfClass:[Document class]]) {
 theItem.theDocument  = [notification object];
 
 if (theItem.text != nil){
 NSEntityDescription *entity = [NSEntityDescription entityForName:@"Liststring" inManagedObjectContext:theItem.theDocument.managedObjectContext];
 Liststring *theString = [[Liststring alloc] initWithEntity:entity insertIntoManagedObjectContext:theItem.theDocument.managedObjectContext]; 
 theString.aString = theItem.text;       
 theString.order = [NSNumber numberWithInt:[theItem.theDocument.aStrings count]];
 theItem.theDocument.editDate = [[NSDate date] timelessDate];
 DocumentDetailViewController *detailViewController = [[DocumentDetailViewController alloc] init];
 detailViewController.theDocument = theItem.theDocument;
 detailViewController.theString = theString;
 detailViewController.appending = YES;
 detailViewController.theItem = theItem;
 detailViewController.hidesBottomBarWhenPushed = YES;
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 }
 } else if (!saving){
 if ([[notification object] isKindOfClass:[Document class]]) {
 NSLog(@"ArchiveViewController:handleTableRowSelection -  document");
 Document *thedocument = [notification object];
 DocumentDetailViewController *detailViewController = [[DocumentDetailViewController alloc] init];
 detailViewController.theDocument = thedocument;
 detailViewController.hidesBottomBarWhenPushed = YES;
 [self.navigationController pushViewController:detailViewController animated:YES];
 }   
 }
 }
 
 

 
 pragma mark - Responding To TableView Selection Notifications
 - (void) handleTableRowSelection: (NSNotification *) notification {
 if ([notification object] == nil) {
 [self presentArchiver:nil];
 return;
 }    
 stringDetailViewController = [[ListStringDetailViewController alloc] init];
 [stringDetailViewController.view setFrame:CGRectMake(0,44, 320, 400)];
 stringDetailViewController.theList = self.theItem.theList;
 
 if ([[notification object] isKindOfClass:[Liststring class]]) {
 stringDetailViewController.theString = [notification object];
 }
 
 [self.view addSubview:stringDetailViewController.view];
 
 UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
 self.navigationItem.leftBarButtonItem = cancelButton;
 
 UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
 self.navigationItem.rightBarButtonItem = saveButton;
 
 }

 
 
 - (void) handleTableRowSelection: (NSNotification *) notification {
 if ([notification object] == nil) {
 [self presentArchiver:nil];
 return;
 }    
 ListStringDetailViewController *stringDetailViewController = [[ListStringDetailViewController alloc] init];
 if ([[notification object] isKindOfClass:[List class]]) {
 stringDetailViewController.theList = [notification object];
 }
 
 if ([[notification object] isKindOfClass:[Liststring class]]) {
 stringDetailViewController.theString = [notification object];
 }
 [self.navigationController pushViewController:stringDetailViewController animated:YES];
 }
 
 */
