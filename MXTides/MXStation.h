//
//  MXStation.h
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    TideStation,
    CurrentStation,
    TideAndCurrentStations
} StationType;

@interface MXStation : NSObject

-(StationType)getStationType;

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSNumber *lng;
@property (nonatomic) NSNumber *distMeters;

-(id)copy;
-(void)discardDetails;
//detail properties to be discarded
@property BOOL rising;
@property CGFloat radians;
@property NSString *prediction;
@property NSString *predictionDetails;
@property NSString *predictionTime;

@end
