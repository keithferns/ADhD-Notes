//
//  SettingViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AllItemsTableViewController.h"


@interface SettingViewController ()

@property (nonatomic, retain) AllItemsTableViewController *tvc;

@end

@implementation SettingViewController

@synthesize tvc;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (tvc == nil){
        tvc = [[AllItemsTableViewController alloc] init];
        tvc.tableView.frame = CGRectMake (0, 44, 320, 380);
    }
    [self.view addSubview:tvc.tableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
