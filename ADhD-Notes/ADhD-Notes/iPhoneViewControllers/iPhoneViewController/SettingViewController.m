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
#import "TodayTableViewController.h"
#import "UINavigationController+NavControllerCategory.h"


@interface SettingViewController ()

@property (nonatomic, retain) AllItemsTableViewController *tvc;
@property (nonatomic, retain) CustomToolBar *toolbar, *toolbar2;
@property (nonatomic, retain) TodayTableViewController *todayTableViewController;

@end

@implementation SettingViewController

@synthesize tvc, toolbar, toolbar2;
@synthesize todayTableViewController;

- (void)viewDidLoad {
    [super viewDidLoad];
    todayTableViewController = [[TodayTableViewController alloc] init];
    todayTableViewController.tableView.frame = CGRectMake (kScreenWidth, 192, 320, 280);
    self.navigationController.delegate = self;
    
    UIImage *rightImage = [UIImage imageNamed:@"list_nav.png"];
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton setImage:rightImage forState:UIControlStateNormal];
    [rightNavButton setImage:rightImage forState:UIControlStateHighlighted];
    rightNavButton.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
    rightNavButton.tag = 2;
    [rightNavButton addTarget:self action:@selector(switchType:) forControlEvents:UIControlEventTouchUpInside];
    rightNavButton.layer.cornerRadius = 4.0;
    rightNavButton.layer.borderWidth = 1.0; 
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.tag = 2;
    
    if (tvc == nil){
        tvc = [[AllItemsTableViewController alloc] init];
        tvc.tableView.frame = CGRectMake (0, 44, 320, 400);
        tvc.tableView.rowHeight = 50.00;
    }
    [self.view setBackgroundColor:[UIColor blackColor]];
   // [self.view addSubview:tvc.tableView];        
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTableRowSelection:) name:UITableViewSelectionDidChangeNotification object:nil];    
}

- (void) handleTableRowSelection:(NSNotification *) notif{
    NSLog(@"LIST SELECTED");    
    if ([[notif object] isKindOfClass:[List class]]){        
        List *theList = [notif object];
        NSLog(@"LIST TEXT = %@", theList.text);
    }
}

- (void) switchType: (id) sender{
    NSLog(@"Switching Type");
    NSNumber *num = [NSNumber numberWithInt:1];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HandleTypeSelectionNotification" object:num];
    self.navigationItem.rightBarButtonItem = [self.navigationController addDoneButton];
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(revertType:);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    todayTableViewController.tableView.frame = CGRectMake (0, 192, 320, 280);
    [UIView commitAnimations];
}

- (void) revertType: (id) sender{
    NSLog(@"Reverting Type");

    NSNumber *num = [NSNumber numberWithInt:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HandleTypeSelectionNotification" object:num];
    UIImage *rightImage = [UIImage imageNamed:@"list_nav.png"];
    UIButton *rightNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavButton setImage:rightImage forState:UIControlStateNormal];
    [rightNavButton setImage:rightImage forState:UIControlStateHighlighted];
    rightNavButton.frame = CGRectMake(0, 0, rightImage.size.width, rightImage.size.height);
    rightNavButton.tag = 2;
    [rightNavButton addTarget:self action:@selector(switchType:) forControlEvents:UIControlEventTouchUpInside];
    rightNavButton.layer.cornerRadius = 4.0;
    rightNavButton.layer.borderWidth = 1.0; 
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightNavButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    self.navigationItem.rightBarButtonItem.tag = 2;    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.5];
    todayTableViewController.tableView.frame = CGRectMake (kScreenWidth, 192, 320, 280);
    [UIView commitAnimations];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view addSubview:todayTableViewController.tableView];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    todayTableViewController.tableView.frame = CGRectMake (0, kScreenHeight, 320, 280);
    [todayTableViewController.tableView removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   // return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
