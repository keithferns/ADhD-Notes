//
//  ListStringDetailViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ListStringDetailViewController.h"
#import "Constants.h"

@interface ListStringDetailViewController ()

@end

@implementation ListStringDetailViewController

@synthesize textField, theList, theString;

- (id)init {
    if (self = [super init]) {
        UINavigationItem *navigationItem = self.navigationItem;
        navigationItem.title = @"List Item";
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    if (textField == nil) {
        textField = [[UITextField alloc] initWithFrame: CGRectMake (5,kNavBarHeight,310,45)];
        textField.textColor = [UIColor whiteColor];
        UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
        [textField.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        textField.layer.cornerRadius = 5.0;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        
        [textField setFont:[UIFont systemFontOfSize:18]];
        textField.layer.borderWidth = 2.0;
        textField.layer.borderColor = [UIColor darkGrayColor].CGColor;      
        [textField setDelegate:self];
        textField.placeholder = @"tap 'return' to add item";
        [textField setReturnKeyType:UIReturnKeyDefault];
    }
    [self.view addSubview:textField];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)save:(id)sender {
	NSLog (@"SAVING");
    /*
	NSManagedObjectContext *context = [listString managedObjectContext];

    if (!listString) {
        self.theString = [NSEntityDescription insertNewObjectForEntityForName:@"Liststring" inManagedObjectContext:context];
        [theList.aStrings addAStringObject:theString];
		theString.order = [NSNumber numberWithInteger:[theList.aStrings count]];
    }
	

	NSError *error = nil;
	if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
	*/
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)cancel:(id)sender {
    NSLog (@"CANCELLING");

    [self.navigationController popViewControllerAnimated:YES];
}




@end
