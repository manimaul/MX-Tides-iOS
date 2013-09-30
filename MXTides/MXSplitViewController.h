//
//  MXSplitViewController.h
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXTideStationDataController;

@interface MXSplitViewController : UISplitViewController

@property (nonatomic) MXTideStationDataController *tideStationDataController;

@end
