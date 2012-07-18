//
//  SettingViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingViewController.h"
#import "AllItemsTableViewController.h"
#import "CustomToolBar.h"

@interface SettingViewController ()

@property (nonatomic, retain) AllItemsTableViewController *tvc;
@property (nonatomic, retain) CustomToolBar *toolbar, *toolbar2;


@end

@implementation SettingViewController

@synthesize tvc, toolbar, toolbar2;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (tvc == nil){
        tvc = [[AllItemsTableViewController alloc] init];
        tvc.tableView.frame = CGRectMake (0, 88, 320, 330);
        tvc.tableView.rowHeight = 50.00;
    }
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:tvc.tableView];
    
    
     
    
        toolbar2 = [[CustomToolBar alloc] init];
        toolbar2.frame = CGRectMake(0, kScreenHeight-2*kTabBarHeight, kScreenWidth, 44);
        [toolbar2 changeToTopButtons:@"title"];
        toolbar2.titleView.text = @"MY TITLE";
        [self.view addSubview:toolbar2];
}

- (void) firstButtonAction:(id) sender{
    NSLog(@"FIRST BUTTON TOUCHED");
}

- (void) fifthButtonAction:(id) sender{
    NSLog(@"FIFTH BUTTON TOUCHED");
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
