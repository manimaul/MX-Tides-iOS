//
//  MXStationDatabase.m
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//


#import "MXStationDatabase.h"
#import "MXStationLinkedList.h"
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
            [latitudes setObject:[MXStationLinkedList new] forKey:@(lat)];
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
    MXStationLinkedList *latList = [latitudes objectForKey:latKey];
    [latList addStation:station];
}   

-(NSArray*)getAllStationsOfType:(StationType)sType
{
    NSMutableArray *stnArr = [NSMutableArray new];
    for (MXStationLinkedList *llist in [latitudes allValues]) {
        MXStation *stn = [llist getFirstStation];
        while (stn) {
            if (sType == TideAndCurrentStations)
                [stnArr addObject:stn];
            else if (sType == [stn getStationType])
                [stnArr addObject:stn];
            stn = [stn nextStation];
        }
    }
    return [NSArray arrayWithArray:stnArr];
}

-(NSArray*)getStationsAtLatitude:(NSNumber*)latitude
{
    NSMutableArray *stnArr = [NSMutableArray new];
    MXStationLinkedList *llist = [latitudes objectForKey:@([latitude intValue])];
    MXStation *stn = [llist getFirstStation];

    while (stn) {
        [stnArr addObject:stn];
        stn = [stn nextStation];
    }
    
    return [NSArray arrayWithArray:stnArr];
}

-(NSArray*)getStationsBetweenMinLat:(NSNumber*)minLatitude maxLat:(NSNumber*)maxLatitude minLng:(NSNumber*)minLongitude maxLng:(NSNumber*)maxLongitude OfType:(StationType)sType
{
    NSMutableArray *stnArr = [NSMutableArray new];
    for (int i = minLatitude.intValue; i < maxLatitude.intValue; i++) {
        MXStationLinkedList *llist = [latitudes objectForKey:@(i)];
        MXStation *stn = [llist getFirstStation];
        //NSLog(@"Station linkedlist head at lat-key:%d %@ lat:%@ lng:%@", i, stn.name, stn.lat, stn.lng);
        while (stn) {
            if (stn.lat.doubleValue >= minLatitude.doubleValue &&
                stn.lat.doubleValue <= maxLatitude.doubleValue &&
                stn.lng.doubleValue >= minLongitude.doubleValue &&
                stn.lng.doubleValue <= maxLongitude.doubleValue) {
                
                if (sType == TideAndCurrentStations)
                    [stnArr addObject:stn];
                else if (sType == [stn getStationType])
                    [stnArr addObject:stn];
            }
            stn = [stn nextStation];
        }
    }
    
    return [NSArray arrayWithArray:stnArr];
}

@end
