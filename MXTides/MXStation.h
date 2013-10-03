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

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *lat;
@property (nonatomic) NSNumber *lng;

//to store in a linked list
@property (nonatomic, retain) MXStation *nextStation;

-(StationType)getStationType;
-(bool)hasNext;

@end
