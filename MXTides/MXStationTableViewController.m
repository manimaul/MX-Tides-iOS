//
//  MXStationTableViewController.m
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXStationTableViewController.h"
#import "MXStationDatabase.h"
#import "XTideConnector.hh"
#import "MXStation.h"
#import "MXStationTableViewCell.h"
#import "MXDetailsViewController.h"
#import "MXDetailsPageViewController.h"

@interface MXStationTableViewController ()

@property (nonatomic) NSArray *stationList;
@property (nonatomic) UIImage *tideImg;
@property (nonatomic) UIImage *currImg;
@property (nonatomic) StationType sType;

@end

@implementation MXStationTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage"]];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    [iv setFrame:self.view.frame];
    [self.tableView setBackgroundView:iv];
    
    NSString *tp = [[NSBundle mainBundle] pathForResource:@"tide" ofType:@"png"];
    self.tideImg = [UIImage imageWithContentsOfFile:tp];
    NSString *cp = [[NSBundle mainBundle] pathForResource:@"current" ofType:@"png"];
    self.currImg = [UIImage imageWithContentsOfFile:cp];
}

- (void)setupData:(StationType)stationType withLocation:(CLLocation*)location
{
    self.sType = stationType;
    self.stationList = [[[MXStationDatabase sharedDatabase] getAllStationsOfType:stationType sortedByDistance:location] subarrayWithRange:NSMakeRange(0, 10)];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stationList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StationCell";
    MXStationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    MXStation *stn = [self.stationList objectAtIndex:indexPath.row];
    cell.stationName.text = stn.name;
    cell.stationDist.text = [NSString stringWithFormat:@"Distance: %.1fmi",(stn.distMeters.doubleValue/1609.344)];
    switch (self.sType) {
        case TideStation:
            cell.stationIcn.image = self.tideImg;
            break;
        case CurrentStation:
            cell.stationIcn.image = self.currImg;
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MXDetailsViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"tidedetails"];
    dvc.station = [self.stationList objectAtIndex:indexPath.row];
    MXDetailsPageViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"tidedetailspages"];
    [vc setViewControllers:@[dvc] direction:UIPageViewControllerNavigationDirectionForward animated:false completion:Nil];
    
    [self.navigationController pushViewController:vc animated:true];
}

@end
