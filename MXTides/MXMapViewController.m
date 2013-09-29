//
//  MXMapViewController.m
//  MXTides
//
//  Created by William Kamp on 9/23/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "MXMapViewController.h"
//#import "AFJSONRequestOperation.h"
#import "XTideConnector.h"
#import "MXStation.h"

@interface MXMapViewController ()

@end

@implementation MXMapViewController
{
	// Base layer
	MaplyViewControllerLayer *baseLayer;
	MaplyComponentObject *latLonObj;
	MaplyComponentObject *screenMarkersObj;
	NSDictionary *vectorDesc;
    NSArray *vecObjects;
    MaplyComponentObject *autoLabels;
    
	// If we're in 3D mode, how far the elevation goes
	int zoomLimit;
	bool requireElev;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
	//load globe view
	//globeViewC = [[WhirlyGlobeViewController alloc] init];
	//mapViewC.delegate = self;
	globeViewC = [[WhirlyGlobeViewController alloc] init];
    globeViewC.delegate = self;
	baseViewC = globeViewC;
	[self.view addSubview:baseViewC.view];
	baseViewC.view.frame = self.view.bounds;
	[self addChildViewController:baseViewC];
	// Set the background color for the globe
	//28 29 23
	baseViewC.clearColor = [UIColor colorWithRed:239/255. green:235/255. blue:218/255. alpha:1.0]; //[UIColor whiteColor];
    
	// Start up over Seattle
	globeViewC.height = 1.0;
	[globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122.335939, 47.623839) time:1.0];
    
	// Maximum number of objects for the layout engine to display
	[baseViewC setMaxLayoutObjects:1000];
    
	globeViewC.keepNorthUp = YES;
    
	UIColor *vecColor = [UIColor colorWithRed:123/255. green:113/255. blue:54/255. alpha:1.];
	float vecWidth = 4.0;
	vectorDesc = @{ kMaplyColor: vecColor,
		            kMaplyVecWidth: @(vecWidth),
		            kMaplyFade: @(1.0),
                    kMaplyFilled: @(0) };
    
	//setup observer for when xtide loads
	[[NSNotificationCenter defaultCenter] addObserver:self
	                                         selector:@selector(handleXtideDidLoad)
	                                             name:@"xtide.index.loaded"
	                                           object:nil];
    UIColor *lngLineColor = [UIColor colorWithRed:220/255. green:209/255. blue:172/255. alpha:1.];
	[self addLinesLon:20 lat:10 color:lngLineColor];
    [self loadWorldShp];
}

- (void)addScreenMarkers:(XTideConnector *)xtideConn {
	CGSize size = CGSizeMake(40, 40);
	UIImage *pinImage = [UIImage imageNamed:@"map_pin"];
    
	NSMutableArray *markers = [NSMutableArray array];
	for (MXStation *sta in[xtideConn stations]) {
		MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
		marker.image = pinImage;
		marker.loc = MaplyCoordinateMakeWithDegrees(sta.lng.floatValue, sta.lat.floatValue);
		marker.size = size;
		marker.userObject = sta.name;
		[markers addObject:marker];
	}
	screenMarkersObj = [baseViewC addScreenMarkers:markers desc:nil];
}

- (void)addLinesLon:(float)lonDelta lat:(float)latDelta color:(UIColor *)color {
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
- (void)loadWorldShp
{
    //NSMutableArray *locVecObjects = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MaplyVectorDatabase *shp = [MaplyVectorDatabase vectorDatabaseWithShape:@"world"];
        MaplyComponentObject *mco = [baseViewC addVectors:@[[shp fetchAllVectors]] desc:vectorDesc];
        if (mco) {
            vecObjects = @[mco];
        }
    });
}

- (void)handleXtideDidLoad {
	//place pins on map
    
    //this works but is too slow... TODO:
    
	//XTideConnector *xtideConn = [XTideConnector sharedConnector];
	//[self addScreenMarkers:xtideConn];
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

#pragma mark - MaplyViewControllerDelegate
/// Called when the user taps on or near an object.
/// You're given the object you passed in originally, such as a MaplyScreenMarker
- (void)maplyViewController:(MaplyViewController *)viewC didSelect:(NSObject *)selectedObj {
	//todo:
}

@end
