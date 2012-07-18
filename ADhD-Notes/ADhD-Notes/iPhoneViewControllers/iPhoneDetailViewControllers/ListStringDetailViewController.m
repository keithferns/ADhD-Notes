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

@synthesize textView, theList, theString;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    NSString *theText = @"";
    if (theString != nil) {
         theText= theString.aString;
    }
    CGSize size = [theText sizeWithFont:[UIFont boldSystemFontOfSize:14.0f] constrainedToSize:CGSizeMake(300, 60) lineBreakMode:UILineBreakModeWordWrap];
    CGFloat tfHeight = MAX (size.height+27, 45);
    NSLog (@"tfHeight = %f", tfHeight);
    if (textView == nil) {
        textView = [[UITextView alloc] initWithFrame: CGRectMake (5,kNavBarHeight,300,tfHeight)];
        textView.textColor = [UIColor whiteColor];
        UIImage *patternImage = [UIImage imageNamed:@"54700.png"];
        [textView.layer setBackgroundColor:[UIColor colorWithPatternImage:patternImage].CGColor];
        textView.layer.cornerRadius = 5.0;
        [textView setFont:[UIFont systemFontOfSize:14]];
        textView.layer.borderWidth = 2.0;
        textView.layer.borderColor = [UIColor darkGrayColor].CGColor;      
    }
    textView.text = theText;
        
    [self.view addSubview:textView];
    [textView becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)save:(id)sender {
	NSLog (@"SAVING");
    if (![textView hasText]) {
        return;
    }
	NSManagedObjectContext *context = [theList managedObjectContext];

    if (!theString) {
        self.theString = [NSEntityDescription insertNewObjectForEntityForName:@"Liststring" inManagedObjectContext:context];
        [theList addAStringsObject:theString];
		theString.order = [NSNumber numberWithInteger:[theList.aStrings count]];
    }
    self.theString.aString = textView.text;
    
    NSString *theText = [theList.text stringByAppendingString:@"\n"];
    theList.text = [theText stringByAppendingString:self.theString.aString];
    theList.editDate = [[NSDate date] timelessDate];
	NSError *error = nil;
	if (![context save:&error]) {
				NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	}
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
