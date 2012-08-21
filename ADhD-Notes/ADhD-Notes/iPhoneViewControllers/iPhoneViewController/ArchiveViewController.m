//  ArchiveViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ArchiveViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "FoldersTableViewController.h"
#import "FilesTableViewController.h"
#import "FolderDetailViewController.h"
#import "DocumentDetailViewController.h"
#import "CustomPopoverView.h"
#import "WEPopoverController.h"
#import "CustomTopToolbarView.h"
#import "NotesViewController.h"
#import "ListViewAndTableViewController.h"

@interface ArchiveViewController ()
@property (nonatomic, retain) FoldersTableViewController *foldersTableViewController;
@property (nonatomic, retain) FilesTableViewController *filesTableViewController;
@property (nonatomic, retain) Folder *theFolder;
@property (nonatomic, retain) Document *theDocument;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@property (nonatomic, retain) CustomTopToolbarView *topToolbarView;

@end;

@implementation ArchiveViewController

@synthesize actionsPopover, archivingControl, saving, theItem, foldersTableViewController, filesTableViewController, managedObjectContext, theFolder, theDocument, appending, topToolbarView;

#pragma mark - Memory Management
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    saving = NO;
    appending  =  NO;
    actionsPopover = nil;
    theItem = nil;    
    foldersTableViewController = nil;
    filesTableViewController = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {    
    [super viewDidLoad];
    
    self.title =@"Archive";    

    topToolbarView = [[CustomTopToolbarView alloc] init];
    [self.view addSubview:topToolbarView];
    [self.topToolbarView setAppendOrSave:@"search"];

    
    //UIBarButtonItem *leftNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showTextBox:)];
    //leftNavButton.tag = 1;
    
    //UIBarButtonItem *rightNavButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(presentActionsPopover:)];
    //rightNavButton.tag = 2;    
    
    

    
    if (foldersTableViewController == nil) {
        foldersTableViewController = [[FoldersTableViewController alloc] init];
        foldersTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+40, kScreenWidth, kScreenHeight);
        foldersTableViewController.theItem = self.theItem;
        foldersTableViewController.tableView.rowHeight = 35.0;
        foldersTableViewController.managedObjectContext = self.managedObjectContext;
    }
    if (filesTableViewController == nil) {
        filesTableViewController =  [[FilesTableViewController alloc] init];
        foldersTableViewController.tableView.frame = CGRectMake(0, kNavBarHeight+40, kScreenWidth, kScreenHeight);
        filesTableViewController.theItem = self.theItem;
        filesTableViewController.tableView.rowHeight = 35.0;
        filesTableViewController.managedObjectContext = self.managedObjectContext; 
    }
    
    if (managedObjectContext == nil){
            /*-- Point current instance of the MOC to the main managedObjectContext --*/
            managedObjectContext = [(ADhD_NotesAppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
        }     
        //Navigation Bar SetUP
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.navigationItem.rightBarButtonItem.target = foldersTableViewController;     
        
        NSArray *items = [NSArray arrayWithObjects:@"Folders", @"Documents", nil];
        archivingControl = [[UISegmentedControl alloc] initWithItems:items];
        [archivingControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [archivingControl setWidth:90 forSegmentAtIndex:0];
        [archivingControl setWidth:90 forSegmentAtIndex:1];
        [archivingControl addTarget:self action:@selector(toggleFoldersFilesView:)
           forControlEvents:UIControlEventValueChanged];
        [archivingControl setSelectedSegmentIndex:0];

        self.navigationItem.titleView = archivingControl;
        foldersTableViewController.saving = NO;
        filesTableViewController.saving = NO;
        
        [self.view addSubview:foldersTableViewController.tableView];
        [topToolbarView.searchBar setPlaceholder:@"Search for Folder"];//
        topToolbarView.searchBar.delegate = foldersTableViewController;        
}

- (void) viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewWillAppearNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:UITableViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFolderFileSelection:) name: @"FolderSavingNotification" object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneEditing:) name:@"EditDoneNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:@"FolderFileSelectedNotification" object:nil];


   // NSIndexPath *tableSelection = [foldersTableViewController.tableView indexPathForSelectedRow];
    //[foldersTableViewController.tableView deselectRowAtIndexPath:tableSelection animated:NO];
}

- (void) viewDidDisappear:(BOOL)animated{
    //[[NSNotificationCenter defaultCenter] removeObserver:self name: UITableViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ViewWillAppearNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITableViewSelectionDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FolderSavingNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EditDoneNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FolderFileSelectedNotification" object:nil];


    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
    }
}
- (void) doneEditing:(NSNotification *) notification {
    int myValue = [[notification object] intValue];
    switch (myValue) {
        case 0:
            self.navigationItem.rightBarButtonItem.title = @"Edit";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
            self.navigationItem.rightBarButtonItem.target = foldersTableViewController;  
            break;
        case 1:
            self.navigationItem.rightBarButtonItem.title = @"Done";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
            self.navigationItem.rightBarButtonItem.target = foldersTableViewController;   
            break;
        case 2:
            self.navigationItem.rightBarButtonItem.title = @"Edit";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
            self.navigationItem.rightBarButtonItem.target = filesTableViewController;  
            break;
        case 3:
            self.navigationItem.rightBarButtonItem.title = @"Done";
            self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
            self.navigationItem.rightBarButtonItem.target = filesTableViewController;   
            break;
            
        default:
            break;
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) toggleFoldersFilesView:(id) sender{
    switch (archivingControl.selectedSegmentIndex) {
        case 0:
            topToolbarView.searchBar.placeholder = @"Search for Folder";
            topToolbarView.searchBar.delegate = foldersTableViewController;
            [topToolbarView.leftButton setImage:[UIImage imageNamed:@"addFolder_nav.png"] forState:UIControlStateNormal];

            [filesTableViewController.tableView removeFromSuperview];
            [self.view addSubview:foldersTableViewController.tableView];
            if (saving) {
                self.navigationItem.rightBarButtonItem.target = self;
            }else {
            self.navigationItem.rightBarButtonItem.target = foldersTableViewController;
            }
            topToolbarView.searchBar.delegate = foldersTableViewController;
            break;
        case 1:
            topToolbarView.searchBar.placeholder = @"Search for Document";
            topToolbarView.searchBar.delegate = filesTableViewController;
            [topToolbarView.leftButton setImage:[UIImage imageNamed:@"addDoc_nav.png"] forState:UIControlStateNormal];


            [foldersTableViewController.tableView removeFromSuperview];
            [self.view addSubview:filesTableViewController.tableView];
            if (saving) {
                self.navigationItem.rightBarButtonItem.target = self;
            }else {
            self.navigationItem.rightBarButtonItem.target = filesTableViewController;
            }
            topToolbarView.searchBar.delegate = filesTableViewController;
            break;
    }
}

- (void) editFoldersFiles{
//    
}

- (void) showTextBox:(id) sender {
    //Check for visisble instance of actionsPopover. if yes dismiss.
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
        }
    UIAlertView *textBox = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
    [textBox setAlertViewStyle:UIAlertViewStylePlainTextInput];
    if (archivingControl.selectedSegmentIndex == 0 && appending == NO){
        textBox.title = @"New Folder:";    
        }else if (archivingControl.selectedSegmentIndex == 1 || appending == YES){
        textBox.title = @"New Document:";
        }
    [textBox show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *string = [alertView buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Save"]){    
        UITextField *theTextField = [alertView textFieldAtIndex:0];
        if ([alertView.title isEqualToString:@"New Folder:"]){
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Folder" inManagedObjectContext:managedObjectContext];
            theFolder = [[Folder alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
            theFolder.name = theTextField.text;
        if (saving) {
            theItem.theFolder = theFolder;
        }
        NSLog(@"Created new folder called %@", theFolder.name);
    }
    else if ([alertView.title isEqualToString:@"New Document:"]){
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Document" inManagedObjectContext:managedObjectContext];
        theDocument = [[Document alloc] initWithEntity:entity insertIntoManagedObjectContext:managedObjectContext];
        theDocument.name = theTextField.text;
        NSLog(@"Created new document called %@", theDocument.name);

        if (saving){
           // NSString *tempString = [NSString stringWithFormat:@"%@%@%@", theDocument.aText, @"\n", theItem.theNote.text];
            //tempString = [myFile.fileText stringByAppendingString:newMemoText.memoText];
            //theDocument.aText = tempString;
            //NSLog(@"Created new document called %@", theDocument.aTitle);
            //CHECKME: same issue as theFolder above
        }
    }
        /*--Save the MOC--*/
        NSLog(@"ArchiveViewController:AlertView -> ADDING MOC:  TRYING TO SAVE");
        NSError *error;
        if(![managedObjectContext save:&error]){ 
            NSLog(@"ArchiveViewController:AlertView -> ADDING MOC: DID NOT SAVE");
        }  
        NSLog(@"ArchiveViewController:AlertView -> ADDING MOC: SAVED");
    }
}

- (void) handleFolderFileSelection:(NSNotification *)notification{
    NSLog(@"ArchiveViewController:handleFolderFileSelection - FolderSavingNotification notification received");    
   if (!saving){
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

- (void) handleTableRowSelection:(NSNotification *)notification{
    NSLog(@"ArchiveViewController:handleTableRowSelection - FolderFileSelectedNotification notification received");
    
    if ([[notification object] isKindOfClass:[Folder class]]){
        NSLog(@"ArchiveViewController:handleTableRowSelection -  folder");
        Folder *thefolder = [notification object];
        FolderDetailViewController *detailViewController =[[FolderDetailViewController alloc] init];
        detailViewController.theFolder = thefolder;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else if ([[notification object] isKindOfClass:[SimpleNote class]]){
        NSLog(@"ArchiveViewController:handleTableRowSelection -  simplenote");

        SimpleNote *theNote = [notification object];
        NotesViewController *detailViewController =[[NotesViewController alloc] init];
        detailViewController.theItem.theSimpleNote = theNote;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
    } 
    else if ([[notification object] isKindOfClass:[List class]]){
        NSLog(@"ArchiveViewController:handleTableRowSelection -  list");

        List *theList  = [notification object];
        ListViewAndTableViewController *detailViewController =[[ListViewAndTableViewController alloc] init];
        detailViewController.theItem.theList = theList;
        detailViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailViewController animated:YES];
    }     
}

- (void) cancelSaving:(id) sender{
    NSLog(@"Cancelling Saving");
    theItem.saved = NO;
    saving = NO;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Popover Management
- (void) presentActionsPopover:(id) sender{
    
    if([actionsPopover isPopoverVisible]) {
        [actionsPopover dismissPopoverAnimated:YES];
        [actionsPopover setDelegate:nil];
        actionsPopover = nil;
        return;
        }
    if(!actionsPopover ) {
        UIViewController *viewCon = [[UIViewController alloc] init];    
        switch ([sender tag]) {
            /*
            case 1://ADDING NEW FOLDERS OR FILES
                {
                CGSize size = CGSizeMake(140, 160);
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView addItemsView];
                viewCon.view =  addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                [actionsPopover presentPopoverFromRect:CGRectMake(10, 44, 50, 40)
                    inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES name:@"Save"];
                }
                break;
             */
            case 2:
                {
                CGSize size = CGSizeMake(140, 180);
                viewCon.contentSizeForViewInPopover = size;
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
                [addView organizerView];
                viewCon.view =  addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:self];
                [actionsPopover presentPopoverFromRect:CGRectMake(280,44, 50, 40) inView:self.view permittedArrowDirections: UIPopoverArrowDirectionUp animated:YES];
                }
                break;
            default:
                break;
        }        
    }
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