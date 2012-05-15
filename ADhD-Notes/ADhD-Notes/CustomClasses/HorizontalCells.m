//
//  HorizontalCells.m
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HorizontalCells.h"
#import "Constants.h"
#import "EventsCell.h"

@implementation HorizontalCells

@synthesize memoTV, eventTV;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
     //  NSLog(@"Horizontal Cells:initWithTyle. EventType is %d", [myType intValue]);
    [self setFrame:CGRectMake(0, 0, kScreenWidth, kCellHeight)];
    
    if (reuseIdentifier == @"firstCell"){
    if(self.memoTV == nil) {
           NSLog(@"Horizontal Cells:initWithFrame: init memoTV");
          memoTV = [[MemoTableViewController alloc] init];
       }    
        self.memoTV.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kScreenWidth)];
        self.memoTV.tableView.showsVerticalScrollIndicator = NO;
        self.memoTV.tableView.showsHorizontalScrollIndicator = NO;
        self.memoTV.tableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        [self.memoTV.tableView setFrame:CGRectMake(kRowHorizontalPadding * 0.5, kRowVerticalPadding * 0.5, kScreenWidth - kRowHorizontalPadding, kCellHeight)];
        self.memoTV.tableView.rowHeight = kCellWidth;
        self.memoTV.tableView.backgroundColor = [UIColor blackColor];        
        self.memoTV.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.memoTV.tableView.separatorColor = [UIColor blackColor];

        [self addSubview:self.memoTV.tableView];
       }
       else if (reuseIdentifier == @"secondCell") {
        
            if (self.eventTV == nil){
            eventTV =[[EventTableViewController alloc] init];
            }
           self.eventTV.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight,kScreenWidth)];
           self.eventTV.tableView.showsVerticalScrollIndicator = NO;
           self.eventTV.tableView.showsHorizontalScrollIndicator = NO;
           self.eventTV.tableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
           [self.eventTV.tableView setFrame:CGRectMake(kRowHorizontalPadding * 0.5, kRowVerticalPadding * 0.5, kScreenWidth - kRowHorizontalPadding, kCellHeight)];
           self.eventTV.tableView.rowHeight = kCellWidth;
           self.eventTV.tableView.backgroundColor = [UIColor blackColor];        
           self.eventTV.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
           self.eventTV.tableView.separatorColor = [UIColor clearColor];
           
           [self addSubview:self.eventTV.tableView];
       }       
    return self;
}


           
@end