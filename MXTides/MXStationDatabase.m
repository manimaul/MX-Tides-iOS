//
//  MXStationDatabase.m
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//


#import "MXStationDatabase.h"
#import "MXStation.h"

@implementation MXStationDatabase {
    NSMutableDictionary *latitudes; //keys: 180 integers (-90 to 90)
    NSUInteger totalCount;
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
        totalCount = 0;
        //build dictionary with 180 integer keys for every degree latitude (-90 to 90)
        latitudes = [[NSMutableDictionary alloc] initWithCapacity:180];
        for (int lat = -90; lat < 91; lat++) {
            [latitudes setObject:[NSMutableArray new] forKey:@(lat)];
        }
    }
    return self;
}

- (NSUInteger)count
{
    return totalCount;
}

-(void)addStation:(MXStation*)station
{
    totalCount++;
    NSNumber *latKey = @(station.lat.intValue);
    NSMutableArray *latList = [latitudes objectForKey:latKey];
    [latList addObject:station];
    //[latList addStation:station];
}

-(NSArray*)getAllStationsOfType:(StationType)sType sortedByDistance:(CLLocation*)location
{
    NSArray *sArr = [self getAllStationsOfType:sType];
    
    //set the distances
    for (MXStation *stn in sArr) {
        CLLocation *stnLoc = [[CLLocation alloc] initWithLatitude:stn.lat.doubleValue longitude:stn.lng.doubleValue];
        stn.distMeters = @([location distanceFromLocation:stnLoc]);
    }
    
    //sort the array
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distMeters"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [sArr sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedArray;
}

-(NSArray*)getAllStationsOfType:(StationType)sType
{
    NSMutableArray *stnArr = [NSMutableArray new];
    
    //yep this is a nested for loop... you wanted "all" the stations
    for (NSMutableArray *llist in [latitudes allValues]) {
        for (MXStation *stn in llist) {
            if (!stn.name)
                continue;
            if (sType == TideAndCurrentStations)
                [stnArr addObject:stn];
            else if (sType == [stn getStationType])
                [stnArr addObject:stn];
        }
    }
    return [NSArray arrayWithArray:stnArr];
}

-(NSArray*)getStationsAtLatitude:(NSNumber*)latitude
{
    //NSMutableArray *stnArr = [NSMutableArray new];
    NSMutableArray *llist = [latitudes objectForKey:@([latitude intValue])];
    return [NSArray arrayWithArray:llist];
}

-(NSArray*)getStationsBetweenMinLat:(NSNumber*)minLatitude maxLat:(NSNumber*)maxLatitude minLng:(NSNumber*)minLongitude maxLng:(NSNumber*)maxLongitude OfType:(StationType)sType
{
    NSMutableArray *stnArr = [NSMutableArray new];
    for (int i = minLatitude.intValue; i < maxLatitude.intValue; i++) {
        NSMutableArray *llist = [latitudes objectForKey:@(i)];
        for (MXStation *stn in llist) {
            if (!stn.name)
                continue;
            if (stn.lat.doubleValue >= minLatitude.doubleValue &&
                stn.lat.doubleValue <= maxLatitude.doubleValue &&
                stn.lng.doubleValue >= minLongitude.doubleValue &&
                stn.lng.doubleValue <= maxLongitude.doubleValue) {
                
                if (sType == TideAndCurrentStations)
                    [stnArr addObject:stn];
                else if (sType == [stn getStationType])
                    [stnArr addObject:stn];
            }
        }
    }
    return [NSArray arrayWithArray:stnArr];
}

@end
