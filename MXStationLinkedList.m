//
//  MXStationLinkedList.m
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXStationLinkedList.h"
#import "MXStation.h"

@implementation MXStationLinkedList {
    MXStation *head;
    MXStation *cursor;
}

-(id) init
{
    self = [super init];
    if (self) {
        head = nil;
        cursor = nil;
    }
    return self;
}

-(void) addStation:(MXStation*)station
{
    if (!head)
        head = station;
    
    station.nextStation = nil;
    
    if (cursor)
        cursor.nextStation = station;
    
    cursor = station;
}

-(MXStation*)getFirstStation
{
    return head;
}

@end
