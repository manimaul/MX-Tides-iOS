//
//  XTideConnector.h
//  XTideConnector
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 William Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MXStation;

@interface XTideConnector : NSObject

+(XTideConnector *)sharedConnector;
-(void) loadAsync:(void(^)(void))completionBlock;
-(BOOL) isLoaded;

//call theses after isLoaded
-(void)setupStation:(MXStation*)station forDate:(NSDate*)date;
//-(NSString*)getAboutWithStationName:(NSString*)name andDate:(NSDate*)date;
//-(NSString*)getPredictionWithStationName:(NSString*)name andDate:(NSDate*)date;
//-(NSString*)getPlainData:(NSString*)name andDate:(NSDate*)date;

@end
