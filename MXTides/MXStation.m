//
//  MXStation.m
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXStation.h"

@implementation MXStation

-(id)copy
{
    MXStation *stn = [MXStation new];
    stn.name = [NSString stringWithString:self.name];
    return stn;
}

-(StationType)getStationType
{
    if ([self.name rangeOfString:@"Current"].location != NSNotFound) {
        return CurrentStation;
    }    
    return TideStation;
}

-(void)discardDetails
{
    self.prediction = Nil;
    self.predictionTime = Nil;
    self.predictionDetails = Nil;
}

@end
