//
//  MXMapNavigationController.m
//  MXTides
//
//  Created by William Kamp on 9/25/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXMapNavigationController.h"
#import "XTideConnector.h"

@interface MXMapNavigationController ()

@end

@implementation MXMapNavigationController
{
    __weak XTideConnector *xTideConn;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    xTideConn = [XTideConnector sharedConnector];
    if (![xTideConn isLoaded]) {
        [xTideConn loadAsync:^{
            NSLog(@"xtide connector finished loading");
        }];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
