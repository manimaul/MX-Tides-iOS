//
//  MXStationLinkedList.h
//  MXTides
//
//  Created by William Kamp on 9/29/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXStation;

@interface MXStationLinkedList : NSObject

-(MXStation*)getFirstStation;
-(void)addStation:(MXStation*)station;

@end
