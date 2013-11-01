//
//  MXGlobeViewController.m
//  MXTides
//
//  Created by William Kamp on 10/31/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXGlobeViewController.h"

@interface MXGlobeViewController ()

@end

@implementation MXGlobeViewController


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"############touches began with count %d", touches.count);
    [self.shouldShowStationDelegate setStationMarkersShown:true];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches ended with count %d", touches.count);
    [self.shouldShowStationDelegate setStationMarkersShown:false];
}

//-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    
//}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches cancelled with count %d", touches.count);
    [self.shouldShowStationDelegate setStationMarkersShown:false];
}

@end
