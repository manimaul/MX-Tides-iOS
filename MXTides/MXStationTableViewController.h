//
//  MXStationTableViewController.h
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MXStation.h"

@interface MXStationTableViewController : UITableViewController <UITableViewDelegate>

- (void)setupData:(StationType)stationType withLocation:(CLLocation*)location;

@end
