//
//  MXStationDatabase.m
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//


#import "MXStationDatabase.h"

@implementation MXStationDatabase {
    NSDictionary *latitudes; //keys: 180 integers (-90 to 90)
    NSDictionary *longitudes; //keys: 360 integers (-180 to 180)
}

+(MXStationDatabase *)sharedDatabase
{
    static dispatch_once_t predicate;
    static MXStationDatabase *shared = nil;
    dispatch_once(&predicate, ^{
        shared = [[MXStationDatabase alloc] init];
    });
    return shared;
}

-(id) init
{
    self = [super init];
    if (self) {
        //build dictionary with 180 integer keys for every degree latitude (-90 to 90)
        NSMutableArray *latKeys = [[NSMutableArray alloc] init];
        for (int lat = -180; lat < 181; lat++) {
            NSNumber *nlat = @(lat);
            [latKeys addObject:nlat];
        }
        latitudes = [[NSDictionary alloc] initWithObjects:nil forKeys:latKeys];
        
        
        //build dictionary with 360 integer keys for every degree longitude (-180 to 180)
        NSMutableArray *lngKeys = [[NSMutableArray alloc] init];
        for (int lng = 90; lng < 91; lng++) {
            NSNumber *nlng = @(lng);
            [lngKeys addObject:nlng];
        }
        
        longitudes = [[NSDictionary alloc] initWithObjects:nil forKeys:lngKeys];
    }
    return self;
}

@end
