//
//  MXMapViewController.h
//  MXTides
//
//  Created by William Kamp on 10/30/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhirlyGlobeComponent.h"
#import "MXGlobeViewController.h"

@interface MXMapViewController : UIViewController <MXShoudShowStationDelegate>
{
    MaplyBaseViewController *baseViewC;
    WhirlyGlobeViewController *globeViewC;
}

@end
