//
//  DetailContainerViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailContainerViewController.h"
#import "ADhD_NotesAppDelegate.h"
#import "ListDetailViewController.h"
#import "MemoDetailViewController.h"
#import "AppointmentDetailViewController.h"
#import "ToDoDetailViewController.h"
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

@interface DetailContainerViewController ()
@property (nonatomic, retain) CustomToolBar *toolbar, *topToolbar;
@property (nonatomic, retain) ListDetailViewController *detailViewController;
@property (nonatomic, retain) EventsTableViewController2 *listTableViewController;
@property (nonatomic, retain) WEPopoverController *actionsPopover;
@end

@implementation DetailContainerViewController
@synthesize toolbar, detailViewController,listTableViewController, theList, theItem, saving, actionsPopover, topToolbar;


- (void)viewDidLoad {
    [super viewDidLoad];
    self.editing = NO;
    
    //View Setup
    self.view.backgroundColor = [UIColor blackColor];
    self.view.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    
    
    
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
