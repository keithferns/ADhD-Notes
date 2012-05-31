//  ADhD_NotesAppDelegate.m
//  ADhD-Notes
//  Created by Keith Fernandes on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "ADhD_NotesAppDelegate.h"
#import "WriteNowViewController.h"
#import "DiaryViewController.h"
#import "CalendarViewController.h"
#import "ArchiveViewController.h"
#import "SettingViewController.h"
#import "Constants.h"

@implementation ADhD_NotesAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize tabBarController = _tabBarController;

- (NSArray *) arrayWithnavigationControllerWrappingsForTabbedViewControllers {
    //Creates the viewController array for the tabBarController
    
    NSLog(@"ADhd_NotesAppDelegate - creating the array");

    NSMutableArray *theArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {

        NSLog(@"ADhd_NotesAppDelegate - the iphone array");
    WriteNowViewController *viewController1 = [[WriteNowViewController alloc] initWithNibName:nil bundle:nil];
    viewController1.tabBarItem.title = @"Write Now";
    viewController1.tabBarItem.image = [UIImage imageNamed:@"tab_notepad.png"];
    viewController1.tabBarItem.tag = 1;    
    UINavigationController *tempNavController1 = [[UINavigationController alloc] initWithRootViewController:viewController1];
    tempNavController1.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [theArray addObject:tempNavController1];
    
    DiaryViewController *viewController2 = [[DiaryViewController alloc] initWithNibName:nil bundle:nil];
    viewController2.tabBarItem.title = @"Diary";
    viewController2.tabBarItem.image = [UIImage imageNamed:@"nav_book.png"];
    viewController2.tabBarItem.tag = 2;    
    UINavigationController *tempNavController2 = [[UINavigationController alloc] initWithRootViewController:viewController2];
    tempNavController2.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [theArray addObject:tempNavController2];
    
    CalendarViewController *viewController3 = [[CalendarViewController alloc] initWithNibName:nil bundle:nil];

    viewController3.tabBarItem.title = @"Calendar";
    viewController3.tabBarItem.image = [UIImage imageNamed:@"nav-calendar.png"];
    viewController3.tabBarItem.tag = 3;    
    UINavigationController *tempNavController3 = [[UINavigationController alloc] initWithRootViewController:viewController3];
    tempNavController3.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [theArray addObject:tempNavController3];
    
    ArchiveViewController *viewController4 = [[ArchiveViewController alloc] initWithNibName:nil bundle:nil];
    //viewController4.saving = NO;
    viewController4.tabBarItem.title = @"Archive";
    viewController4.tabBarItem.image = [UIImage imageNamed:@"nav_cabinet.png"];
    viewController4.tabBarItem.tag = 4;    
    UINavigationController *tempNavController4 = [[UINavigationController alloc] initWithRootViewController:viewController4];
    tempNavController4.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [theArray addObject:tempNavController4];
    
    SettingViewController  *viewController5 = [[SettingViewController alloc] initWithNibName:nil bundle:nil];
    viewController5.tabBarItem.title = @"Settings";
    viewController5.tabBarItem.image = [UIImage imageNamed:@"nav_configuration.png"];
    viewController5.tabBarItem.tag = 5;    
    UINavigationController *tempNavController5 = [[UINavigationController alloc] initWithRootViewController:viewController5];
    tempNavController5.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [theArray addObject:tempNavController5];
    }
     else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
         //
    }
    return theArray;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSTimeZone resetSystemTimeZone];
 
    [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"EST"]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    //Initialize the tabBarController and set the frame to the application screen
    _tabBarController = [[UITabBarController alloc] initWithNibName:nil bundle:nil];
    _tabBarController.view.frame = kScreenRect;
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background.png"]];
    
    _tabBarController.viewControllers = [self arrayWithnavigationControllerWrappingsForTabbedViewControllers];
    self.window.rootViewController = self.tabBarController;

    // Add the tab bar controller's current view as a subview of the window
   // [self.window addSubview:_tabBarController.view];
    [self.window makeKeyAndVisible];
    
    // Handle launching from a notification
    UILocalNotification *notification = [launchOptions objectForKey: UIApplicationLaunchOptionsLocalNotificationKey];
    
    if (notification) {
        //NSString *reminderText = [notification.userInfo  objectForKey:kRemindMeNotificationDataKey];
        //[viewController showReminder:reminderText];
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //[window addSubview:viewController.view];
    return YES;    
}

- (void)application:(UIApplication *)application 
didReceiveLocalNotification:(UILocalNotification *)notification {
    
[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    //NSString *reminderText = [notification.userInfo objectForKey:kRemindMeNotificationDataKey];
    //[viewController showReminder:reminderText];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ADhD_Notes" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ADhD_Notes.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
