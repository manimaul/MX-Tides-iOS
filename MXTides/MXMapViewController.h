//
//  MXMapViewController.h
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhirlyGlobeComponent.h"

@interface MXMapViewController : UIViewController <WhirlyGlobeViewControllerDelegate> //<MaplyViewControllerDelegate>
{
    /// This is the base class shared between the MaplyViewController and the WhirlyGlobeViewController
    MaplyBaseViewController *baseViewC;
    /// If we're displaying a globe, this is set
    WhirlyGlobeViewController *globeViewC;
    //MaplyViewController *mapViewC;
}

@end
