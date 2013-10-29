//
//  MXDetailsViewController.h
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MXStation;

@interface MXDetailsViewController : UIViewController

-(void)nextDay;
-(void)prevDay;
-(void)setupViewForDate:(NSDate*)date;

@property (nonatomic, weak) MXStation *station;
@property (nonatomic) NSDate *predictionDate;

@end
