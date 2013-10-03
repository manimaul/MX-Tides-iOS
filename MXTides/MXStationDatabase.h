//
//  MXStationDatabase.h
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MXStation.h"

@class MXStationLinkedList;

@interface MXStationDatabase : NSObject

+(MXStationDatabase *)sharedDatabase;

- (NSUInteger)count;
-(void)addStation:(MXStation*)station;
-(NSArray*)getStationsBetweenMinLat:(NSNumber*)minLatitude maxLat:(NSNumber*)maxLatitude minLng:(NSNumber*)minLongitude maxLng:(NSNumber*)maxLongitude OfType:(StationType)sType;
-(NSArray*)getAllStationsOfType:(StationType)sType;

@end
