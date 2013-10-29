//
//  XTideConnector.m
//  XTideConnector
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 William Kamp. All rights reserved.
//

#import "XTideConnector.hh"
#import "MXStation.h"
#import "MXStationDatabase.h"
#include "common.hh"

typedef struct {
    const char *value;
    const char *details;
    const char *time;
    bool rising;
    float radians;
} MXPrediction;

static StationIndex stationIndex;
static const double kPi = 3.14159265359;

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

            [XTideConnector sharedConnector].loaded = YES;

            //put the completion block back on the mainQueue so UI stuff can happen
            [[NSOperationQueue mainQueue] addOperationWithBlock:completionBlock];

            //notify listeners
            [[NSNotificationCenter defaultCenter] postNotificationName:@"xtide.index.loaded" object:self];
        });
    }
}

-(BOOL)isLoaded
{   
    return [XTideConnector sharedConnector].loaded ;
}

-(void)loadz
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"harmonics-dwf-20121224-free"
                                                         ofType:@"tcd"];
    NSLog(@"loading harmonics file: %@", filePath);
    loadHarmonics([filePath cStringUsingEncoding:NSUTF8StringEncoding]);
    //NSMutableArray *sarr = [NSMutableArray new];
    
    MXStationDatabase *db = [MXStationDatabase sharedDatabase];
    for (int i=0; i<stationIndex.size(); ++i) {
        MXStation *st = [[MXStation alloc] init];
        st.name = [NSString stringWithUTF8String:stationIndex.operator [](i)->name.aschar()];
        st.lat = [[NSNumber alloc] initWithDouble:stationIndex.operator [](i)->coordinates.lat()];
        st.lng = [[NSNumber alloc] initWithDouble:stationIndex.operator [](i)->coordinates.lng()];
        [db addStation:st];
	 }
}

-(void)setupStation:(MXStation*)station forDate:(NSDate*)date
{
    const char * cStrName = [station.name cStringUsingEncoding:NSUTF8StringEncoding];
    long epoch = [date timeIntervalSince1970];
    
    MXPrediction pred = getPrediction(cStrName, epoch);
    
    station.rising = pred.rising;
    station.radians = pred.radians;
    station.prediction = [NSString stringWithUTF8String:pred.value];
    station.predictionTime = [NSString stringWithUTF8String:pred.time];
    station.predictionDetails = [NSString stringWithUTF8String:getPlainTrimmedData(cStrName, epoch)];
    
}

#pragma mark - c++

static char* getAbout(Dstr station, long epoch) {
    Dstr data;
	Station *sa = (stationIndex.getStationRefByName(station))->load();
	sa->setUnits(Units::feet);
	Timestamp ts = Timestamp(epoch);
    
	sa->print(data, ts, ts, Mode::about, Format::text);
    
    delete sa;
    
    return data.utf8().asdupchar();
}

static MXPrediction getPrediction(Dstr station, long epoch) {
	Dstr data;
	Station *sa = (stationIndex.getStationRefByName(station))->load();
	sa->setUnits(Units::feet);
    
    //prediction now
	Timestamp ts = Timestamp(epoch);
    
    MXPrediction pred;
    
    Dstr timeStr;
    ts.print(timeStr, sa->timezone);
    pred.time = timeStr.utf8().asdupchar();
    
	PredictionValue value = sa->predictTideLevel(ts);
    double pNow = value.val();
    value.print(data);
    
    //prediction in another 5 minutes
    ts += Interval(300);
    double pLater = sa->predictTideLevel(ts).val();
    
    
    if (pNow >= 0) {
        pred.radians = (sa->maxCurrentBearing.mdegrees * kPi) / 180;
        if (sa->isCurrent) {
            Dstr ds;
            sa->maxCurrentBearing.print(ds);
            data += ", ";
            data += ds;
        }
    } else {
        pred.radians = (sa->minCurrentBearing.mdegrees * kPi) / 180;
        if (sa->isCurrent) {
            Dstr ds;
            sa->minCurrentBearing.print(ds);
            data += ", ";
            data += ds;
        }
    }
    
    if (pLater > pNow) {
        pred.rising = true;
        if (!sa->isCurrent)
            data += ", rising";
    } else {
        pred.rising = false;
        if (!sa->isCurrent)
            data += ", falling";
    }
    
    pred.value = data.utf8().asdupchar();
    
    delete sa;
    
    return pred;
}

static char* getPlainTrimmedData(Dstr station, long epoch)
{
    Dstr data;
    Station *sa = (stationIndex.getStationRefByName(station))->load();
    
    TideEventsOrganizer organizer;
    sa->predictTideEvents(getMorning(epoch), getEvening(epoch), organizer);
    TideEventsIterator it = organizer.begin();
    while (it != organizer.end()) {
        Dstr line;
        TideEvent te = it->second;
        te.eventTime.printTime(line, sa->timezone);
        line += ' ';
        
        if (!te.isSunMoonEvent()) {
            Dstr lvl;
            te.eventLevel.printnp(lvl);
            line += lvl;
            line += ' ';
        }
        
        line += te.longDescription();
        
        data += line;
        data += '\n';
        ++it;
    }
    
    delete sa;
    
    return data.utf8().asdupchar();
}

static Timestamp getMorning(long epoch) {
    tm morning;
    morning = *localtime(&epoch);
    
    //rewind to the begining of the day
	morning.tm_hour = 0;
	morning.tm_min = 0;
	morning.tm_sec = 0;
    
    return Timestamp(mktime(&morning));
}

static Timestamp getEvening(long epoch) {
    tm evening;
    evening = *localtime(&epoch);
    
    //fast forward to the end of the day
	evening.tm_hour = 24;
	evening.tm_min = 0;
	evening.tm_sec = 0;
    
    return Timestamp(mktime(&evening));
}

static void loadHarmonics(const char* path)
{
    stationIndex.addHarmonicsFile(path);
}

@end
