//
//  XTideConnector.h
//  XTideConnector
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 William Kamp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XTideConnector : NSObject

+(XTideConnector *)sharedConnector;
-(void) loadAsync:(void(^)(void))completionBlock;
-(BOOL) isLoaded;

//call theses after isLoaded
-(NSString*)getAboutWithStationName:(NSString*)name andDate:(NSDate*)date;
-(NSString*)getPredictionWithStationName:(NSString*)name andDate:(NSDate*)date;

@end
