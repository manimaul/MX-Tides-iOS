//
//  MXMapViewController.m
//  MXTides
//
//  Created by William Kamp on 10/30/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXMapViewController.h"
#import "MXStation.h"
#import "XTideConnector.hh"
#import "Constants.h"
#import "MXStationDatabase.h"

@interface MXMapViewController ()
{
    MaplyComponentObject *latLonObj;
    MaplyComponentObject *stationMarkersObj;
    NSArray *stationObjects;
    NSArray *vecObjects;
    NSDictionary *landVecDesc;
    BOOL showStationMarkers;
}

@property (weak, nonatomic) IBOutlet UIView *mapViewBg;

@end

@implementation MXMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    globeViewC = [[WhirlyGlobeViewController alloc] init];
    //globeViewC.shouldShowStationDelegate = self;

    baseViewC = globeViewC;
    
    [self.mapViewBg addSubview:baseViewC.view];
    baseViewC.view.frame = self.mapViewBg.bounds;
    [self addChildViewController:baseViewC];
    
    [baseViewC setHints:@{@"kMaplyRendererLightingMode": @"none"}];
    
    //remove default lighting
    //[baseViewC clearLights];
    
    // Set the background color for the globe
    baseViewC.clearColor = [UIColor clearColor];
    
    showStationMarkers = false;
    
    // We'll let the toolkit create a thread per image layer.
    baseViewC.threadPerLayer = true;
    
    baseViewC.frameInterval = 1;
    
    baseViewC.performanceOutput = false;
    
    globeViewC.keepNorthUp = true;
    
    showStationMarkers = false;
    
    // Start up over Seattle
    globeViewC.height = 0.8;
    [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(-122., 47.) time:1.0];
    
    // Maximum number of objects for the layout engine to display
    [baseViewC setMaxLayoutObjects:1000];
    
    [self addLinesLon:20 lat:10 color:themeDkBrownColor(255.)];
    UIColor *landColor = [UIColor colorWithRed:202/255. green:186/255. blue:118/255. alpha:1.];
    float vecWidth = 4.0;
    landVecDesc = @{ kMaplyColor: landColor,
                     kMaplyVecWidth: @(vecWidth),
                     kMaplyFade: @(1.0),
                     kMaplyFilled: @(1.0),
                     kMaplyLoftedPolyHeight: @(.001)};
    [self loadShapeFile:@"ne_110m_land" withKey:@"land" withDesc:landVecDesc];
    [self addStationScreenMarkers];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // This should release the globe view
    if (baseViewC)
    {
        [baseViewC.view removeFromSuperview];
        [baseViewC removeFromParentViewController];
        baseViewC = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        //NSLog(@"size of shapefile vector obj: %zd", malloc_size(vecObjects));
    });
}

- (void)addLinesLon:(float)lonDelta lat:(float)latDelta color:(UIColor *)color
{
    NSMutableArray *vectors = [[NSMutableArray alloc] init];
    NSDictionary *desc = @{kMaplyColor: color, kMaplySubdivType: kMaplySubdivSimple, kMaplySubdivEpsilon: @(0.001), kMaplyVecWidth: @(4.0)};
    // Longitude lines
    for (float lon = -180;lon < 180;lon += lonDelta)
    {
        MaplyCoordinate coords[3];
        coords[0] = MaplyCoordinateMakeWithDegrees(lon, -90);
        coords[1] = MaplyCoordinateMakeWithDegrees(lon, 0);
        coords[2] = MaplyCoordinateMakeWithDegrees(lon, +90);
        MaplyVectorObject *vec = [[MaplyVectorObject alloc] initWithLineString:coords numCoords:3 attributes:nil];
        [vectors addObject:vec];
    }
    // Latitude lines
    for (float lat = -90;lat < 90;lat += latDelta)
    {
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

- (void)addStationScreenMarkers {
    CGSize size = CGSizeMake(3, 3);
    //UIImage *pinImage = [UIImage imageNamed:@"tide"];
    
    NSMutableArray *markers = [NSMutableArray array];
    for (MXStation *stn in [[MXStationDatabase sharedDatabase] getAllStationsOfType:TideStation])
    {
        MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
        //marker.image = pinImage;
        marker.loc = MaplyCoordinateMakeWithDegrees(stn.lng.floatValue, stn.lat.floatValue);
        marker.size = size;
        marker.selectable = false;
        //marker.userObject = stn.name;
        [markers addObject:marker];
    }
    stationObjects = [NSArray arrayWithArray:markers];
    stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
    showStationMarkers = true;
}

#pragma mark - show and hide station markers
-(void)showStations
{
    NSLog(@"revealing markers");
    stationMarkersObj = [baseViewC addScreenMarkers:stationObjects desc:nil];
    showStationMarkers = true;
}

- (void)setStationMarkersShown:(BOOL)shown
{
    if (shown == showStationMarkers)
        return;
    
    if (shown) {
        [self performSelector:@selector(showStations) withObject:NULL afterDelay:3.];
    } else {
        NSLog(@"hiding markers");
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [baseViewC removeObject:stationMarkersObj];
        showStationMarkers = false;
    }
}

//#pragma mark - MaplyViewControllerDelegate
//
///// The user tapped at the given location.
///// This won't be called if they tapped and selected, just if they tapped.
//- (void)globeViewController:(WhirlyGlobeViewController *)viewC didTapAt:(WGCoordinate)coord
//{
//    NSLog(@"tap at coord");
//}
//
//#pragma mark - touches
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"+++++touches began with count %d", touches.count);
//    //[self setStationMarkersShown:false];
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"------touches ended with count %d", touches.count);
//    //[self setStationMarkersShown:true];
//}
//
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    NSLog(@"!!!!!touches cancelled with count %d", touches.count);
//}

@end
