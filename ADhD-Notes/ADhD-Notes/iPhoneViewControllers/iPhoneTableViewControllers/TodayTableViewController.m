//
//  TodayTableViewController.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 5/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TodayTableViewController.h"
#import "HorizontalCells.h"

@interface TodayTableViewController ()

@end

@implementation TodayTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.frame = CGRectMake (0, 0, 320, kCellHeight*2+40);
    self.tableView.rowHeight = kCellHeight;
    self.tableView.bounces = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor blackColor];
    /*
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    [headerLabel setBackgroundColor:[UIColor blackColor]];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"EEEE, MMM d"];
    
    [headerLabel setText:[dateformatter stringFromDate:[NSDate date]]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setTextAlignment:UITextAlignmentCenter];
    [headerView setBackgroundColor:[UIColor blackColor]];
    [headerView addSubview:headerLabel];

    [self.tableView setTableHeaderView:headerView];
    */
    
     self.clearsSelectionOnViewWillAppear = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL) animated {
    [super viewWillAppear:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{    
    CGFloat hHeight;
    if (section == 1) {
        hHeight = 20.0;
    }
    else {
        hHeight = 20.0;
    }
    return hHeight;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *hTitle = @"";
    if (section == 0) {
        hTitle = @"Notes, Lists and Documents";
    } else {
        hTitle = @"Appointments and To Dos";
    }
    return hTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSString *cellIdentifier = @"";
    if (indexPath.section == 0){
        cellIdentifier = @"firstCell";
    } else if (indexPath.section == 1){
        cellIdentifier = @"secondCell";
    }     
    HorizontalCells *cell;
    if (cellIdentifier == @"firstCell"){
        cell = (HorizontalCells *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil){
            cell = [[HorizontalCells alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:@"firstCell"];
        }
    } else if (cellIdentifier == @"secondCell"){
        cell = (HorizontalCells *)[self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil){            
            cell = [[HorizontalCells alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"secondCell"];            
        }
    }
    return cell;    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
}

@end
