//
//  HorizontalCells.m
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HorizontalCells.h"
#import "Contants.h"
#import "EventsCell.h"

@implementation HorizontalCells

@synthesize eventType;
@synthesize memoTV, eventTV;

- (void) dealloc{
    self.memoTV.tableView = nil;
    eventType = nil;
    [self.memoTV.tableView release];
    [eventType release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
   eventType = [NSNumber numberWithInt:1];
   if ((self = [super initWithFrame:frame])){
       NSLog(@"Horizontal Cells:initWithFrame. EventType is %d", [eventType intValue]);
       
       if ([eventType intValue] == 0){
       if(self.memoTV == nil) {
           NSLog(@"Horizontal Cells:initWithFrame: init memoTV");

           memoTV = [[MemoTableViewController alloc] init];
       }
        self.memoTV.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kScreenWidth)] autorelease];
        self.memoTV.tableView.showsVerticalScrollIndicator = NO;
        self.memoTV.tableView.showsHorizontalScrollIndicator = NO;
        self.memoTV.tableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        [self.memoTV.tableView setFrame:CGRectMake(kRowHorizontalPadding * 0.5, kRowVerticalPadding * 0.5, kScreenWidth - kRowHorizontalPadding, kCellHeight)];
        self.memoTV.tableView.rowHeight = kCellWidth;
        self.memoTV.tableView.backgroundColor = [UIColor blackColor];        
        self.memoTV.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.memoTV.tableView.separatorColor = [UIColor clearColor];

        [self addSubview:self.memoTV.tableView];
       }
       else if ([eventType intValue] == 1) {
           if(self.eventTV == nil) {
               NSLog(@"Horizontal Cells:initWithFrame: init eventTV");
               
               eventTV = [[EventTableViewController alloc] init];
           }
           self.eventTV.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kScreenWidth)] autorelease];
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
       
       
     }

    return self;

}
           


@end