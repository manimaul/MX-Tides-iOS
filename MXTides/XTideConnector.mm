//
//  XTideConnector.m
//  XTideConnector
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 William Kamp. All rights reserved.
//

#import "XTideConnector.h"
#import "MXStation.h"
#include "common.hh"

static StationIndex si;
static Dstr data;

@interface XTideConnector ()

@property (nonatomic) BOOL loaded;

@end

@implementation XTideConnector

#pragma mark - singleton constructor

+(XTideConnector *)sharedConnector
{
    static dispatch_once_t predicate;
    static XTideConnector *shared = nil;
    dispatch_once(&predicate, ^{
        shared = [[XTideConnector alloc] init];
    });
    return shared;
}

#pragma mark - objc

-(void)loadAsync:(void(^)(void))completionBlock;
{
    if (![XTideConnector sharedConnector].loaded) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self loadz];
            
            //put the completion block back on the mainQueue so UI stuff can happen
            [[NSOperationQueue mainQueue] addOperationWithBlock:completionBlock];
            
            //notify listeners
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xtide.index.loaded" object:self];
        });
    }
    [XTideConnector sharedConnector].loaded = YES;
}

-(BOOL)isLoaded
{
    if ([XTideConnector sharedConnector].loaded  && [[XTideConnector sharedConnector].stations count] == 0)
        NSLog(@"Error: XtideConnector is loaded but there are no stations in array!");
    
    return [XTideConnector sharedConnector].loaded ;
}

-(void)loadz
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"ocpnHarmonic"
                                                         ofType:@"tcd"];
    NSLog(@"loading harmonics file: %@", filePath);
    loadHarmonics([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
    NSMutableArray *sarr = [NSMutableArray new];
	 for (int i=0; i<si.size(); ++i) {
        MXStation *st = [[MXStation alloc] init];
        st.name = [NSString stringWithUTF8String:si.operator [](i)->name.aschar()];
        st.lat = [[NSNumber alloc] initWithDouble:si.operator [](i)->coordinates.lat()];
        st.lng = [[NSNumber alloc] initWithDouble:si.operator [](i)->coordinates.lng()];
        [sarr addObject:st];
	 }
    [XTideConnector sharedConnector].stations = [NSArray arrayWithArray:sarr];
}

-(NSString*)getAboutWithStationName:(NSString*)name andDate:(NSDate*)date
{
    getAbout([name cStringUsingEncoding:NSUTF8StringEncoding], [date timeIntervalSince1970]);
    return [NSString stringWithUTF8String:data.utf8().aschar()];
}

-(NSString*)getPredictionWithStationName:(NSString*)name andDate:(NSDate*)date
{
    getPrediction([name cStringUsingEncoding:NSUTF8StringEncoding], [date timeIntervalSince1970]);
    return [NSString stringWithUTF8String:data.utf8().aschar()];
}

#pragma mark - c++
static void getStationIndex() {
	//si.sort(si.sortByName);
	data = "";
	for (int i=0; i<si.size(); ++i) {
		si.operator[](i)->name.aschar();
		data += si.operator [](i)->name.aschar();
		data += ";";
		data += si.operator [](i)->coordinates.lat();
		data += ";";
		data += si.operator [](i)->coordinates.lng();
		data += "\n";
	}
}

static void getAbout(Dstr station, long epoch) {
	StationRef *sr = si.getStationRefByName(station);
	Station *sa = sr->load();
    
	sa->setUnits(Units::feet);
	Timestamp ts = Timestamp(epoch);
    
	data = "";
	sa->print(data, ts, ts, Mode::about, Format::text);
}

static void getPrediction(Dstr station, long epoch) {
	StationRef *sr = si.getStationRefByName(station);
	Station *sa = sr->load();
    
	sa->setUnits(Units::feet);
	Timestamp ts = Timestamp(epoch);
    
	PredictionValue value = sa->predictTideLevel(ts);
    
	data = "";
	value.print(data);
}

static void getData(Dstr station, long epoch, Mode::Mode mode) {
	StationRef *sr = si.getStationRefByName(station);
	Station *sa = sr->load();
	sa->setUnits(Units::feet);
    
	struct tm morning;
	struct tm evening;
    
	//time(&rawtime);
	morning = *localtime(&epoch);
	evening = *localtime(&epoch);
    
	//rewind to the begining of the day
	morning.tm_hour = 0;
	morning.tm_min = 0;
	morning.tm_sec = 0;
    
	//fast forward to the end of the day
	evening.tm_hour = 24;
	evening.tm_min = 0;
	evening.tm_sec = 0;
    
	Timestamp starttime = Timestamp(mktime(&morning));
	Timestamp endtime = Timestamp(mktime(&evening));
    
	data = "";
	sa->print(data, starttime, endtime, mode, Format::text);
}

static void getTimestamp(Dstr station, long epoch) {
	StationRef *sr = si.getStationRefByName(station);
	Station *sa = sr->load();
	Timestamp t = Timestamp(epoch);
    
	data = "";
	t.print(data, sa->timezone);
}

static void loadHarmonics(const char* path)
{
    si.addHarmonicsFile(path);
}

@end
