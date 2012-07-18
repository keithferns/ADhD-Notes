//
//  HorizontalCellsWithSections.m
//  WriteNow
//
//  Created by Keith Fernandes on 11/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HorizontalCellsWithSections.h"
#import "Constants.h"
#import "EventsCellWithSections.h"

@implementation HorizontalCellsWithSections

@synthesize hTableView = _hTableView;
@synthesize myObjects, name;

- (id)initWithFrame:(CGRect)frame {
   if ((self = [super initWithFrame:frame])){
        self.hTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kCellHeight, kScreenWidth)];
        self.hTableView.showsVerticalScrollIndicator = NO;
        self.hTableView.showsHorizontalScrollIndicator = NO;
        self.hTableView.transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        [self.hTableView setFrame:CGRectMake(kRowHorizontalPadding * 0.5, kRowVerticalPadding * 0.5, kScreenWidth - kRowHorizontalPadding, kCellHeight)];
        self.hTableView.rowHeight = kCellWidth;
        self.hTableView.backgroundColor = [UIColor blackColor];        
        self.hTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.hTableView.separatorColor = [UIColor clearColor];
        self.hTableView.dataSource = self;
        self.hTableView.delegate = self;
        [self addSubview:self.hTableView];
     }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [self.hTableView reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numberOfRows;
    numberOfRows = [myObjects count];
    return numberOfRows;
}

- (NSString *) reuseIdentifier{
    return @"HorizontalCellsWithSections";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat result;
    if (name == nil) {
        result = 0 ;
    }else{
        result = 20;
        }
    return result;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *result;
    if (name == nil) {
        result = @"" ;
    }else{
        result =  name;
    }
    return result;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellIdentifier = @"EventsCell";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a"];
    EventsCellWithSections *cell = (EventsCellWithSections *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[EventsCellWithSections alloc] init];
    }

    if ([[myObjects objectAtIndex:0] isKindOfClass:[Appointment class]]) {
        Appointment *currentAppointment = [myObjects objectAtIndex:indexPath.row];
        CGSize itemSize=CGSizeMake(kCellWidth,kCellHeight-20);
        UIGraphicsBeginImageContext(itemSize);
        [currentAppointment.text drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height) withFont:[UIFont boldSystemFontOfSize:10]];
        UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.myTextView.image = theImage;
       // cell.myTextLabel.text = currentAppointment.text;
        cell.dateLabel.text = [dateFormatter stringFromDate:currentAppointment.startTime];
    }
    else if ([[myObjects objectAtIndex:0] isKindOfClass:[ToDo class]]) {
        ToDo *currentTask = [myObjects objectAtIndex:indexPath.row];
        CGSize itemSize=CGSizeMake(kCellWidth-4, kCellHeight-17);
        UIGraphicsBeginImageContext(itemSize);
        [currentTask.text drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height) withFont:[UIFont boldSystemFontOfSize:10]];
        UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.myTextView.image = theImage;
        //cell.myTextLabel.text = currentTask.text;
        //cell.dateLabel.text = [dateFormatter stringFromDate:currentTask.startTime];
    }
    else if ([[myObjects objectAtIndex:0] isKindOfClass:[Memo class]]){
        Memo *currentMemo = [myObjects objectAtIndex:indexPath.row];
        CGSize itemSize=CGSizeMake(kCellWidth-4, kCellHeight-25);
        UIGraphicsBeginImageContext(itemSize);
        [currentMemo.text drawInRect:CGRectMake(0, 0, itemSize.width, itemSize.height) withFont:[UIFont boldSystemFontOfSize:10]];
        UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        cell.myTextView.image = theImage;
        //cell.myTextLabel.text = currentMemo.text;
        cell.dateLabel.text = [dateFormatter stringFromDate:currentMemo.startTime];
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSIndexPath *myIndexPath = [tableView indexPathForSelectedRow];
    NSLog(@"Selected Row is %i", [myIndexPath row]);
    NSLog(@"Selected Section is %i", [myIndexPath section]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITableViewSelectionDidChangeNotification object:[myObjects objectAtIndex:indexPath.row]];

    if ([[myObjects objectAtIndex:indexPath.row] isKindOfClass:[Appointment class]]) {
        //
          } else if ([[myObjects objectAtIndex:indexPath.row] isKindOfClass:[ToDo class]]){
    } else if ([[myObjects objectAtIndex:indexPath.row] isKindOfClass:[List class]]) {
        
        NSLog(@"EventsTableViewController: didSelectRow");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ListSelectedNotification" object:[myObjects objectAtIndex:indexPath.row]];     
    }
}

@end