//  WriteNowViewController.h
//  ADhD-Notes
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import <UIKit/UIKit.h>
 
@interface WriteNowViewController : UIViewController <UITextViewDelegate, UITextFieldDelegate, WEPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>{
}

@end
/*
 - connect toolbar buttons on the detailviewcontrollers
 - FIX: ALARMS
 - FIX: SCHEDULER FOR TODOs
 - change ordering for memos table on the main page to reflect frequency, recency etc.
 - change the todo scheduler to reflect values like someday, tomorrow, etc. 
 - provide option to add new todo items to an ongoing time-related todo list such as a list for tasks to be done Someday.
 - for text messages and emails, recover the addressee info etc. 
 - add slider to set priority ratings for ToDos
 - For a list of ToDos, the priority can be indicated by color or icons etc. 
 - For ToDo lists, add option to remove completed tasks from list
 - Add location data on a new thread. Need algorithm to group locations based on proximity. 
 - Update Reminder notifications on a separate thread before exiting the application
 - Add Day view for the Calendar
 - Folders: before deleting, put up an Alert warning. 
 - Events on the main page should be color coded for the day of the week. 
 - Add and retrieve iCal events. 
*/