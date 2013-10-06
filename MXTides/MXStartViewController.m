//
//  MXStartViewController.m
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXStartViewController.h"
#import "MXStationTableViewController.h"
#import "MXStation.h"
#import "XTideConnector.h"
#import "MXStationDatabase.h"

static bool haveLocation = false;
static bool debug = true;

@interface MXStartViewController ()

@property (nonatomic) StationType sType;

@property (nonatomic, weak) IBOutlet UILabel *latLabel;
@property (nonatomic, weak) IBOutlet UILabel *lngLabel;
@property (nonatomic, weak) IBOutlet UIButton *currentButton;
@property (nonatomic, weak) IBOutlet UIButton *tideButton;
@property (nonatomic) CLLocation* location;

@end

@implementation MXStartViewController {
    CLLocationManager *locMan;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    locMan = [CLLocationManager new];
    locMan.delegate = self;
    
    [self startLocationOrShowAlert];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(startLocationOrShowAlert)
                                               name:UIApplicationWillEnterForegroundNotification
                                             object:nil];
    
    XTideConnector *xc = [XTideConnector sharedConnector];
    //completion block is posted on main threads
    [xc loadAsync:^{
        [MXStationDatabase sharedDatabase]; //builds a searchable database
        if (haveLocation) {
            [self.currentButton setEnabled:true];
            [self.tideButton setEnabled:true];
        }
    }];
}

- (void)startLocationOrShowAlert
{
    if( [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        if (debug) {
            [self.currentButton setEnabled:true];
            [self.tideButton setEnabled:true];
            self.location = [[CLLocation alloc] initWithLatitude:47.25 longitude:-122.3];
        }
    } else {
        [locMan startUpdatingLocation];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(IBAction)tideButtonPress:(id)sender
{
    //NSLog(@"setting sType Tide");    
    self.sType = TideStation;
    MXStationTableViewController *vc =[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"StationTable"];
    [vc setupData:self.sType withLocation:self.location];
    [self.navigationController pushViewController:vc animated:true];
}

-(IBAction)currentButtonPress:(id)sender
{
    //NSLog(@"setting sType Current");
    self.sType = CurrentStation;
    MXStationTableViewController *vc =[self.navigationController.storyboard instantiateViewControllerWithIdentifier:@"StationTable"];
    [vc setupData:self.sType withLocation:self.location];
    [self.navigationController pushViewController:vc animated:true];
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    [super prepareForSegue:segue sender:sender];
//    MXStationTableViewController *vc = segue.destinationViewController;
//    [vc setupData:self.sType withLocation:self.location];
//}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    self.location = [locations lastObject];
    NSDate* eventDate = self.location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (!haveLocation) {
        self.latLabel.text = [NSString stringWithFormat:@"%+.6f", self.location.coordinate.latitude];
        self.lngLabel.text = [NSString stringWithFormat:@"%+.6f", self.location.coordinate.longitude];
        haveLocation = true;
        
        if ([[XTideConnector sharedConnector] isLoaded]) {
            [self.currentButton setEnabled:true];
            [self.tideButton setEnabled:true];
        }
        
    }
    
    if (abs(howRecent) < 15.0) {
        self.latLabel.text = [NSString stringWithFormat:@"%+.6f", self.location.coordinate.latitude];
        self.lngLabel.text = [NSString stringWithFormat:@"%+.6f", self.location.coordinate.longitude];
    }
}

@end
