//
//  Preferences.h
//  ADhD-Notes
//
//  Created by Keith Fernandes on 6/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

+ (BOOL)shouldSaveUsername;
+ (NSInteger)startupTab;
+ (BOOL) setPreferences:(BOOL)saveUsername startupTab:(NSInteger)tabIndex;

@end
