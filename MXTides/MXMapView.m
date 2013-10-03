//
//  MXMapView.m
//  MXTides
//
//  Created by William Kamp on 10/2/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXMapView.h"
#import "XTideConnector.h"

@implementation MXMapView {
    bool stationsHidden;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        stationsHidden = false;
    }
    return self;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[XTideConnector sharedConnector] isLoaded] && stationsHidden && touches.count > 1) {
        NSLog(@"hiding stations on touchesBegan (multiple touches)");
        //[baseViewC removeObject:stationMarkersObj];
        stationsHidden = true;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches ended");
    if ([[XTideConnector sharedConnector] isLoaded] && stationsHidden) {
        NSLog(@"showing stations on touchesEnded");
        //stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
        stationsHidden = false;
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!stationsHidden) {
        NSLog(@"hiding stations on touchesMoved");
        //[baseViewC removeObject:stationMarkersObj];
        stationsHidden = true;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[XTideConnector sharedConnector] isLoaded] && stationsHidden) {
        NSLog(@"showing stations on touchesCancelled");
        //stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
        stationsHidden = false;
    }
}

@end
