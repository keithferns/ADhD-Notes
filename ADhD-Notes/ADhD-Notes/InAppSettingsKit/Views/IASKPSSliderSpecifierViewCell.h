//
//  IASKPSSliderSpecifierViewCell.h
//  http://www.inappsettingskit.com
//
//  Copyright (c) 2009:
//  Luc Vandal, Edovia Inc., http://www.edovia.com
//  Ortwin Gentz, FutureTap GmbH, http://www.futuretap.com
//  All rights reserved.
// 
//  It is appreciated but not required that you give credit to Luc Vandal and Ortwin Gentz, 
//  as the original authors of this code. You can give credit in a blog post, a tweet or on 
//  a info page of your app. Also, the original authors appreciate letting them know if you use this code.
//
//  This code is licensed under the BSD license that is available at: http://www.opensource.org/licenses/bsd-license.php
//

#import <UIKit/UIKit.h>

@class IASKSlider;

@interface IASKPSSliderSpecifierViewCell : UITableViewCell {
    __unsafe_unretained IASKSlider *_slider;
    __unsafe_unretained UIImageView *_minImage;
    __unsafe_unretained UIImageView *_maxImage;
}

@property (unsafe_unretained) IBOutlet IASKSlider *slider;
@property (unsafe_unretained) IBOutlet UIImageView *minImage;
@property (unsafe_unretained) IBOutlet UIImageView *maxImage;

@end
