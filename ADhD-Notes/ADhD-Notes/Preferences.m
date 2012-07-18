//
//  Preferences.m
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"



#define DEFAULT_TAB 0

@implementation Preferences


+ (BOOL)shouldSaveUsername
{
    // Does preference exist...
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"saveUsername"] != 0)
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"saveUsername"];
    else
        return NO;
}

/*---------------------------------------------------------------------------
 * Return the user preferred startup screen (which tab on tabbar)
 *--------------------------------------------------------------------------*/
+ (NSInteger)startupTab
{
    // Does preference exist...
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"startupTab"] != 0)
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"startupTab"];
    else
        return DEFAULT_TAB;   // Default startup tab
}

/*---------------------------------------------------------------------------
 * Write preferences to system
 *--------------------------------------------------------------------------*/
+ (BOOL) setPreferences:(BOOL)saveUsername startupTab:(NSInteger)tabIndex
{
    // Set values
    [[NSUserDefaults standardUserDefaults] setBool:saveUsername forKey:@"saveUsername"];
    [[NSUserDefaults standardUserDefaults] setInteger:tabIndex forKey:@"startupTab"];
    
    // Return the results of attempting to write preferences to system
    return [[NSUserDefaults standardUserDefaults] synchronize];
}



@end