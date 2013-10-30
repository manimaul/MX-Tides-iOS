//
//  MXAboutViewController.m
//  MXTides
//
//  Created by William Kamp on 10/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXAboutViewController.h"

@interface MXAboutViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation MXAboutViewController


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(300., 630.)];
}

@end
