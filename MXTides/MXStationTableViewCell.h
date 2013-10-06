//
//  MXStationTableViewCell.h
//  MXTides
//
//  Created by William Kamp on 9/24/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MXStationTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *stationName;
@property (nonatomic, weak) IBOutlet UILabel *stationDist;
@property (nonatomic, weak) IBOutlet UIImageView *stationIcn;

@end
