//
//  DiaryViewController.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TKCalendarDayTimelineView.h"

#import "TKCalendarMonthView.h"


@interface DiaryViewController : UIViewController<TKCalendarMonthViewDelegate>{
}

@property (nonatomic, retain) TKCalendarMonthView *calendarView;
/*
<TKCalendarDayTimelineViewDelegate>{
    TKCalendarDayTimelineView *_calendarDayTimelineView;

}

@property (nonatomic, unsafe_unretained) TKCalendarDayTimelineView *calendarDayTimelineView;
*/

@end
