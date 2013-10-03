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

- (void)viewDidLoad
{
    [super viewDidLoad];
    XTideConnector *xTideConn = [XTideConnector sharedConnector];
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
