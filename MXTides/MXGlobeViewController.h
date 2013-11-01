//
//  MXGlobeViewController.h
//  MXTides
//
//  Created by William Kamp on 10/31/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "WhirlyGlobeViewController.h"

@protocol MXShoudShowStationDelegate <NSObject>

- (void)setStationMarkersShown:(BOOL)shown;

@end

@interface MXGlobeViewController : WhirlyGlobeViewController

@property (nonatomic) id <MXShoudShowStationDelegate> shouldShowStationDelegate;

@end
