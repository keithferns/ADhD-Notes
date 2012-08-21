//  DocumentDetailViewController.m
//  ADhD-Notes
//  Created by Keith Fernandes on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "DocumentDetailViewController.h"
#import "CustomToolBar.h"
#import "WEPopoverController.h"
#import "CustomPopoverView.h"

@interface DocumentDetailViewController ()
@property (nonatomic, retain) NSMutableArray *sortedArray;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) CustomToolBar *toolbar;
@property (nonatomic, retain) WEPopoverController *actionsPopover;

@end

@implementation DocumentDetailViewController

@synthesize theDocument,theString, sortedArray, textView, toolbar, actionsPopover, appending, theItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (toolbar == nil) {
        toolbar = [[CustomToolBar alloc] init];
        toolbar.frame = CGRectMake(0, kScreenHeight-kTabBarHeight, kScreenWidth, 50);     
        [toolbar changeToDetailButtons];
        toolbar.firstButton.enabled = YES;
        toolbar.secondButton.enabled = YES;
        toolbar.fourthButton.enabled = YES;
    }
    [self.view addSubview:toolbar];
    /*
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
    sortedArray = [[NSMutableArray alloc] initWithArray:[theDocument.aStrings allObjects]];
    [sortedArray sortUsingDescriptors:sortDescriptors];  
    
    NSString *theString = @"";
    for (int i = 0; i < [sortedArray count]; i++) {
        if ([[sortedArray objectAtIndex:i] isKindOfClass:[Liststring class]]){
            Liststring *theNote  = [sortedArray objectAtIndex:i];
            NSString *temp = [NSString stringWithFormat:@"%@\n", theNote.aString];
            theString = [theString stringByAppendingString:temp];
        }
    }    
    */
    textView = [[UITextView alloc] initWithFrame:CGRectMake(0, kNavBarHeight, 320,kScreenHeight-kNavBarHeight-kTabBarHeight)];
    [self.view addSubview:textView];
    //textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"captex8.png"]];
    textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"54700.png"]];
    textView.font = [UIFont boldSystemFontOfSize:18.0];
    textView.editable = NO;
    
    if (appending == YES){
        NSLog(@"documentDetailView APPENDING = YES");
        
        NSString *tempString = @"";
        if (theDocument.text != nil) {
            tempString = theDocument.text;
        }
        NSString *temp = [NSString stringWithFormat:@"%@\n", theString.aString];
        tempString = [tempString stringByAppendingString:temp];
        self.textView.text = tempString;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:nil action:@selector(saveAppended)];
        self.navigationItem.rightBarButtonItem.target = self;
        
    }else {
        self.textView.text = theDocument.text;
        self.navigationItem.rightBarButtonItem = self.editButtonItem;

    }
}
- (void) saveAppended {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    if (theDocument.aStrings == nil) {
        theDocument.aStrings = [NSSet setWithObject:theString];
    } else {
        theDocument.aStrings = [theDocument.aStrings setByAddingObject:theString];
    }
    
    NSManagedObjectContext *context = theDocument.managedObjectContext;
    
    theDocument.text = self.textView.text;
    
    NSLog (@"the document text is %@", theDocument.text);

    NSError *error = nil;
    if (![context save:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();    
    }
    
    if (theItem.theSimpleNote != nil) {
        [self deleteSimpleNote];
    } else {
        return;
    }    
}

- (void) deleteSimpleNote {
    UIView *actionView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 240)];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Do you want to delete the original note or keep it?" delegate:self cancelButtonTitle:@"Keep Note" destructiveButtonTitle:@"Delete Note" otherButtonTitles:nil]; 
    [actionSheet showInView:actionView];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSLog(@"Checking Whether to Delete Note");
    
    NSString *string = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([string isEqualToString:@"Delete Note"]){
        NSLog(@"Deleting Note");
        
        [theItem deleteItem:theItem.theSimpleNote];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self.actionsPopover dismissPopoverAnimated:YES];
    self.actionsPopover = nil;
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name: UIKeyboardWillHideNotification object:nil];
    [self.actionsPopover dismissPopoverAnimated:YES];
    self.actionsPopover = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
	[self.navigationItem setHidesBackButton:editing animated:YES];
	
    if (editing == YES) {
        self.textView.editable = YES;
        [self.textView becomeFirstResponder];
        
    } else if (editing == NO) {
		NSManagedObjectContext *context = theDocument.managedObjectContext;

        theDocument.text = self.textView.text;
        
        NSLog (@"the document text is %@", theDocument.text);
        
		NSError *error = nil;
		if (![context save:&error]) {
			
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			abort();
		}
        self.textView.editable = NO;
	}
}


- (void) goToMain: (id) sender {  
    [self.navigationController popToRootViewControllerAnimated:YES];
}




#pragma mark - Responding to keyboard notifications

- (void)keyboardWillShow:(NSNotification *)notification {
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
    CGRect frame = self.textView.frame;
    frame.size.height = keyboardTop-frame.origin.y;
    self.textView.frame = frame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"Hiding Keyboard");
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    //Raise the bottomView
    CGRect frame = self.textView.frame;
    
    frame.size.height = kScreenHeight-kNavBarHeight-kTabBarHeight;
    self.textView.frame = frame;
    
    [UIView commitAnimations];
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
            {
                CGSize theSize = CGSizeMake(100, 120);
                viewCon.contentSizeForViewInPopover = theSize;                
                CustomPopoverView *addView = [[CustomPopoverView alloc] initWithFrame:CGRectMake(0, 0, theSize.width, theSize.height)];
                [addView toolbarPlanButton];
                viewCon.view = addView;
                actionsPopover = [[WEPopoverController alloc] initWithContentViewController:viewCon];
                [actionsPopover setDelegate:(id)self];
                if (self.editing) {
                    [actionsPopover presentPopoverFromRect:CGRectMake(20, 165, 50, 40) inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES ]; 
                }else {
                    
                    [actionsPopover presentPopoverFromRect:CGRectMake(20, 370, 50, 40) inView:self.view
                                  permittedArrowDirections: UIPopoverArrowDirectionDown animated:YES]; 
                }
            }
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
                                  permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES ]; 
                }else {
                    [actionsPopover presentPopoverFromRect:CGRectMake(205, 370, 50, 50) inView:self.view
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
