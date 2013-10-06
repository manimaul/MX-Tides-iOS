//
//  MXStationTabBarController.m
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXStationTabBarController.h"
#import "MXDetailsViewController.h"
#import "MXGraphViewController.h"

@interface MXStationTabBarController ()

@property (nonatomic) MXGraphViewController *gvc;
@property (nonatomic) MXDetailsViewController *dvc;

@end

@implementation MXStationTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dvc = [self.viewControllers objectAtIndex:0];
    self.gvc = [self.viewControllers objectAtIndex:1];
    //self.dvc.stationName = self.stationName;
	//NSLog(@"tabbar vcs: %lu", (unsigned long)self.viewControllers.count);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
