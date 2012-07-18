//  ListViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 6/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ListViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "ListStringDetailViewController.h"
#import "ArchiveViewController.h"
#import "CustomToolBar.h"
#import "Constants.h"
#import "UINavigationController+NavControllerCategory.h"
#import "EventsTableViewController2.h"
#import "MailComposerViewController.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"
#import "MailComposerViewController.h"

@interface ListViewController ()

@property (nonatomic, retain) CustomToolBar *toolbar, *topToolbar;
@property (nonatomic, retain) ListDetailViewController *detailViewController;
@property (nonatomic, retain) EventsTableViewController2 *listTableViewController;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;

@end

@implementation ListViewController

@synthesize toolbar, detailViewController,listTableViewController, theList, theItem, searchBar, saving, actionsPopover, topToolbar;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing = NO;
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    NSLog(@"The Text is %@", self.theItem.text);
    
    if (saving) {
        self.navigationItem.backBarButtonItem.target = self;
        self.navigationItem.backBarButtonItem.action = @selector(cancelSaving:);
        /*
        self.navigationItem.leftBarButtonItem = [self.navigationController addCancelButton];
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(cancelSaving:);
        
        self.navigationItem.rightBarButtonItem =[self.navigationController addDoneButton];
        [self.navigationItem.rightBarButtonItem setTarget:self];
        [self.navigationItem.rightBarButtonItem setAction:@selector(saveToDo:)];
        */
        
        
        listTableViewController = [[EventsTableViewController2 alloc]init];
        listTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-kTabBarHeight-44);
        listTableViewController.eventType = [NSNumber numberWithInt:1];
        [listTableViewController.tableView setSeparatorColor:[UIColor blackColor]];
        [listTableViewController.tableView setSectionHeaderHeight:13];
        listTableViewController.tableView.rowHeight = kCellHeight;        
        NSNumber *num = [NSNumber numberWithInt:1];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetEventTypeNotification" object:num userInfo:nil];
        [self.view addSubview:listTableViewController.tableView];
        
        UIToolbar *toolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0,kNavBarHeight, kScreenWidth,44)];
        [toolbar2 setBarStyle:UIBarStyleBlackTranslucent];
        [self.view addSubview: toolbar2];
        
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-85, 40)];
        searchBar.tintColor = [UIColor blackColor];
        [searchBar setTranslucent:YES];
        searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
        [searchBar setPlaceholder:@"Search for List"];
        
        UIBarButtonItem *leftNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showTextBox:)];
        leftNavButton.tag = 1;
        
        UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(presentActionsPopover:)];
        rightNavButton.tag = 2;    
        
        UIView *searchBarContainer = [[UIView alloc] initWithFrame:searchBar.frame];
        [searchBarContainer addSubview:searchBar];
        UIBarButtonItem *searchBarItem = [[UIBarButtonItem alloc] initWithCustomView:searchBarContainer];    
        NSArray *myItems = [NSArray arrayWithObjects:leftNavButton, searchBarItem, rightNavButton, nil];
        toolbar2.items = myItems;
        searchBar.delegate = listTableViewController;        
        }else {
            
            topToolbar = [[CustomToolBar alloc] init];
            topToolbar.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, 44);
            [topToolbar changeToTopButtons:@"title"];
            [self.view addSubview:topToolbar];
            
            detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
            detailViewController.saving = self.saving;
            detailViewController.theItem = self.theItem;
            detailViewController.theList = self.theList;    
            detailViewController.tableView.frame = CGRectMake(0, kNavBarHeight+44, kScreenWidth, kScreenHeight-kNavBarHeight-44);
            [self.view addSubview:detailViewController.tableView];
            
            self.navigationItem.rightBarButtonItem = self.editButtonItem;
            self.navigationItem.rightBarButtonItem.target = detailViewController;
        }
    
     if (toolbar == nil) {
         NSLog(@"Adding Toolbar");
         toolbar = [[CustomToolBar alloc] init];
         toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight, kScreenWidth, 50);     
         [toolbar changeToDetailButtons];
         [toolbar.firstButton setTarget:self];
         [toolbar.secondButton setTarget:self];
         [toolbar.thirdButton setTarget:self];
         [toolbar.fourthButton setTarget:self];
         [toolbar.fifthButton setTarget:self];
         [self.view addSubview:toolbar];    
        }
    self.saving = YES;

}

- (void) goToMain: (id) sender {    
    self.tabBarController.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    theItem = nil;
    theList = nil;
    saving = NO;
    detailViewController = nil;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableViewEditing:) name:@"TableViewIsEditingNotification"  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleListSelection:) name:@"ListSelectedNotification" object:nil];      
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:@"ListItemSelectedNotification" object:nil];
    NSLog(@"ListViewController:viewWillAoppear: theItem.listArray = %@", theItem.listArray);
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TableViewIsEditingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ListSelectedNotification" object:nil];
    if (self.saving == YES){
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StartNewItemNotification" object:nil];
    }
    [self.actionsPopover dismissPopoverAnimated:YES];
    self.actionsPopover = nil;
    if (self.saving == NO) {
        [self cancelSaving:nil];
    }
}
- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ListItemSelectedNotification" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) appendToList: (id) sender{
    if ([actionsPopover isPopoverVisible]){
        [actionsPopover dismissPopoverAnimated:YES];   
    }
    ListViewController *listDetailViewController = [[ListViewController alloc] init]; 
    //Appending a note:
    if (theItem == nil) {
        theItem = [[NewItemOrEvent alloc] init];
    }
    if (theItem.listArray == nil){
        theItem.listArray = [[NSArray alloc] init];
        theItem.listArray = [theItem.listArray arrayByAddingObject:self.theList.text];
    }
    listDetailViewController.theItem = self.theItem;
    listDetailViewController.saving = YES;
    listDetailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:listDetailViewController animated:YES];
}

- (void) sendItem:(id)sender {
    NSLog(@"Sending SimpleNote text");
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
    mailDetailViewController.theText = self.theList.text;
    [self.navigationController pushViewController: mailDetailViewController animated:YES];
}

#pragma mark - Actions

- (void) showTextBox:(id) sender {
    
    UIAlertView *textBox = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [textBox setAlertViewStyle:UIAlertViewStylePlainTextInput];
    textBox.title = @"New List:";    
    [textBox show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{    
    NSManagedObjectContext *managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
    
    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Save"]){    
        UITextField *theTextField = [alertView textFieldAtIndex:0];
        if ([alertView.title isEqualToString:@"New List:"]){
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"List" inManagedObjectContext:managedObjectContext];
            theList = [[List alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            theList.name = theTextField.text;
        }
    theItem.theList = theList;
    theItem.addingContext = theList.managedObjectContext;
    [theItem createListstringsFromArray];
    theItem.theList.text = [theItem.listArray objectAtIndex:0];
    theItem.theList.editDate = [[NSDate date] timelessDate];

    [theItem saveNewItem];
    
    detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.saving = YES;
    detailViewController.theItem = self.theItem;
    detailViewController.theList = self.theList;    
    detailViewController.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight -44);
    [self.view addSubview:detailViewController.tableView];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.target = detailViewController;
    self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void) handleListSelection: (NSNotification *) notification{
    theList = [notification object];
    theItem.theList = theList;
    theItem.addingContext = theList.managedObjectContext;
    [theItem createNewListString:theItem.text];
    theItem.theList.aStrings = [theList.aStrings setByAddingObject:theItem.theString];
    theItem.theList.editDate = [[NSDate date] timelessDate];
    
    detailViewController = [[ListDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    detailViewController.saving = YES;
    detailViewController.theItem = self.theItem;
    detailViewController.theList = self.theList;    
    detailViewController.tableView.frame = CGRectMake(0, kNavBarHeight, kScreenWidth, kScreenHeight-kNavBarHeight -44);
    [self.view addSubview:detailViewController.tableView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:nil action:@selector(saveAppended)];
    self.navigationItem.rightBarButtonItem.target = self;
}

- (void) saveAppended {
    NSLog(@"ListDetailViewController: Saving Appended");
    self.saving = YES;
    [theItem saveNewItem];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AppendedNotification" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"ListDetailViewController: Saved Appended");
}

- (void) cancelSaving:(id) sender{
    [theItem deleteItem:theItem.theString];
    NSLog(@"Cancelling Saving");
}

- (void)saveToDo: (id) sender{
    saving = NO;
    [self.navigationController popViewControllerAnimated:YES];
        
}
- (void) presentArchiver: (id) sender {    
    NSManagedObjectContext *addingContext = [[NSManagedObjectContext alloc] init];    
    [addingContext setPersistentStoreCoordinator:[theList.managedObjectContext persistentStoreCoordinator]];    
    ArchiveViewController *archiveViewController = [[ArchiveViewController alloc] init];
    archiveViewController.hidesBottomBarWhenPushed = YES;
    archiveViewController.saving = YES;
    archiveViewController.theItem = self.theItem;
    [self.navigationController pushViewController:archiveViewController animated:YES];
}

- (void) handleTableViewEditing: (NSNotification *)notification{
    self.editing = !self.editing;
    [self setEditing:self.editing animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {    
    [super setEditing:editing animated:animated];
    if (editing) {
        NSLog (@"ListViewController is Editing");
        [self.navigationItem setHidesBackButton:YES animated:YES];

    } else {
        NSLog (@"ListViewController is NOT Editing");
        [self.navigationItem setHidesBackButton:NO animated:YES];
    }
}

- (void) handleTableRowSelection: (NSNotification *) notification {
    if ([notification object] == nil) {
        [self presentArchiver:nil];
        return;
    }    
    ListStringDetailViewController *stringDetailViewController = [[ListStringDetailViewController alloc] init];
    stringDetailViewController.theList = self.theList;
    
    if ([[notification object] isKindOfClass:[Liststring class]]) {
        stringDetailViewController.theString = [notification object];
    }
    [self.navigationController pushViewController:stringDetailViewController animated:YES];
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
                    [addView.button3 addTarget:self action:@selector(appendToList:) forControlEvents:UIControlEventTouchUpInside];
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
