//
//  MXMapViewController.m
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "MXMapViewController.h"
#import "XTideConnector.h"
#import "MXStationDatabase.h"
#import "MXStationLinkedList.h"
#import "MXStation.h"

@interface MXMapViewController ()

@end

@implementation MXMapViewController
{
	// Base layer
	MaplyViewControllerLayer *baseLayer;
	MaplyComponentObject *latLonObj;
	MaplyComponentObject *stationMarkersObj;
    NSArray *stationObjects;
    //MaplyComponentObject *markersObj;
	NSDictionary *landVecDesc;
    //NSDictionary *landFineVecDesc;
    NSDictionary *waterVecDesc;
    NSArray *vecObjects;
    MaplyComponentObject *autoLabels;
    bool stationsHidden;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    stationsHidden = false;
    
	//load globe view
	globeViewC = [[WhirlyGlobeViewController alloc] init];;
    baseViewC = globeViewC;
    globeViewC.delegate = self;
    
	[self.view addSubview:baseViewC.view];
	baseViewC.view.frame = self.view.bounds;
	[self addChildViewController:baseViewC];
	// Set the background color for the globe
	//28 29 23
	baseViewC.clearColor = [UIColor colorWithRed:211/255. green:234/255. blue:238/255. alpha:1.0]; //[UIColor whiteColor];
    [baseViewC clearLights];
    
	// Start up over Seattle
	globeViewC.height = 1.0;
    globeViewC.keepNorthUp = true;
	[globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.335939, 47.623839) time:1.0];
    
	// Maximum number of objects for the layout engine to display
	[baseViewC setMaxLayoutObjects:1000];
    
	//setup observer for when xtide loads
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(handleXtideDidLoad)
	                                             name:@"xtide.index.loaded"
	                                           object:nil];
    
    UIColor *landColor = [UIColor colorWithRed:202/255. green:186/255. blue:118/255. alpha:1.];
	float vecWidth = 4.0;
    landVecDesc = @{ kMaplyColor: landColor,
                     kMaplyVecWidth: @(vecWidth),
                     kMaplyFade: @(1.0),
                     kMaplyFilled: @(1.0),
                     kMaplyLoftedPolyHeight: @(.001)};
    [self loadShapeFile:@"ne_110m_land" withKey:@"land" withDesc:landVecDesc];
    [self addLinesLon:20 lat:10 color:landColor];
}

- (void)addStationVectors {
	NSMutableArray *vectors = [[NSMutableArray alloc] init];
	NSDictionary *desc = @{ kMaplyColor: [UIColor redColor] };
    
    for (MXStation *stn in [[MXStationDatabase sharedDatabase] getStationsBetweenMinLat:@(45.1) maxLat:@(49.7) minLng:@(-124.2) maxLng:@(-120.1) OfType:TideStation]) {
        
        MaplyCoordinate coord = MaplyCoordinateMakeWithDegrees(stn.lng.floatValue, stn.lat.floatValue);
        
        MaplyVectorObject *vec = [[MaplyVectorObject alloc] initWithPoint:&coord attributes:nil];
        [vectors addObject:vec];
    }
    
	stationMarkersObj = [baseViewC addVectors:vectors desc:desc];
}

- (void)addLinesLon:(float)lonDelta lat:(float)latDelta color:(UIColor *)color
{
	NSMutableArray *vectors = [[NSMutableArray alloc] init];
	NSDictionary *desc = @{ kMaplyColor: color, kMaplySubdivType: kMaplySubdivSimple, kMaplySubdivEpsilon: @(0.001), kMaplyVecWidth: @(4.0) };
	// Longitude lines
	for (float lon = -180; lon < 180; lon += lonDelta) {
		MaplyCoordinate coords[3];
		coords[0] = MaplyCoordinateMakeWithDegrees(lon, -90);
		coords[1] = MaplyCoordinateMakeWithDegrees(lon, 0);
		coords[2] = MaplyCoordinateMakeWithDegrees(lon, +90);
		MaplyVectorObject *vec = [[MaplyVectorObject alloc] initWithLineString:coords numCoords:3 attributes:nil];
		[vectors addObject:vec];
	}
	// Latitude lines
	for (float lat = -90; lat < 90; lat += latDelta) {
		MaplyCoordinate coords[5];
		coords[0] = MaplyCoordinateMakeWithDegrees(-180, lat);
		coords[1] = MaplyCoordinateMakeWithDegrees(-90, lat);
		coords[2] = MaplyCoordinateMakeWithDegrees(0, lat);
		coords[3] = MaplyCoordinateMakeWithDegrees(90, lat);
		coords[4] = MaplyCoordinateMakeWithDegrees(+180, lat);
		MaplyVectorObject *vec = [[MaplyVectorObject alloc] initWithLineString:coords numCoords:5 attributes:nil];
		[vectors addObject:vec];
	}
    
	latLonObj = [baseViewC addVectors:vectors desc:desc];
}

// Add world shapefile
- (void)loadShapeFile:(NSString*)shapeFile withKey:(NSString*)theKey withDesc:(NSDictionary*)desc
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MaplyVectorDatabase *shp = [MaplyVectorDatabase vectorDatabaseWithShape:shapeFile];
        MaplyComponentObject *mco = [baseViewC addLoftedPolys:@[[shp fetchAllVectors]] key:theKey cache:shp desc:desc];
        NSMutableArray *vecObj = [NSMutableArray arrayWithArray:vecObjects];
        if (mco) {
            [vecObj addObject:mco];
        }
        vecObjects = vecObj;
    });
}

- (void)handleXtideDidLoad
{
    [self addStationScreenMarkers];
}

- (void)addStationScreenMarkers {
    CGSize size = CGSizeMake(20, 20);
	UIImage *pinImage = [UIImage imageNamed:@"tide"];

	NSMutableArray *markers = [NSMutableArray array];
    for (MXStation *stn in [[MXStationDatabase sharedDatabase] getAllStationsOfType:TideStation])
    {
		MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
		marker.image = pinImage;
		marker.loc = MaplyCoordinateMakeWithDegrees(stn.lng.floatValue, stn.lat.floatValue);
		marker.size = size;
		marker.userObject = stn.name;
		[markers addObject:marker];
	}
    stationObjects = [NSArray arrayWithArray:markers];
	stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
}

- (void)viewDidUnload {
	[super viewDidUnload];
    
	// This should release the globe view
	if (baseViewC) {
		[baseViewC.view removeFromSuperview];
		[baseViewC removeFromParentViewController];
		baseViewC = nil;
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	// This should release the globe view
	if (baseViewC) {
		[baseViewC.view removeFromSuperview];
		[baseViewC removeFromParentViewController];
		baseViewC = nil;
	}
}

-(void)showStations
{
    //globeViewC ge
    if (stationsHidden) {
        stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
        stationsHidden = false;
    }
    
}

-(void)showStationsDelayed
{
    if (stationsHidden) {
        [self performSelector:@selector(showStations) withObject:NULL afterDelay:0.25];
    }
}

-(void)hideStations
{
    //todo: only hide if there are more than 200
    //we will need to be listening to map movement events to populate stations when camera changes
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showStations) object:nil];
    if (!stationsHidden) {
        [baseViewC removeObject:stationMarkersObj];
        stationsHidden = true;
    }
}

#pragma mark - MaplyViewControllerDelegate

/// The user tapped at the given location.
/// This won't be called if they tapped and selected, just if they tapped.
- (void)globeViewController:(WhirlyGlobeViewController *)viewC didTapAt:(WGCoordinate)coord
{
    NSLog(@"tapat coord");
    //todo
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideStations];
//    if (!stationsHidden) {
//        NSLog(@"hiding stations on touchesBegan");
//        [self hideStations];
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showStationsDelayed];
//    if (stationsHidden) {
//        NSLog(@"showing stations on touchesEnded");
//        [self showStationsDelayed];
//    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideStations];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showStationsDelayed];\
}

@end
