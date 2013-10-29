//
//  MXDetailsViewController.m
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXDetailsViewController.h"
#import "XTideConnector.hh"
#import "MXStation.h"
#import "UIImage+Rotate.h"

@interface MXDetailsViewController () <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UITextView *txtView;
@property (nonatomic, weak) IBOutlet UILabel *stationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *stationPredictionLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic) UIImage *dirImage;

@end

@implementation MXDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewForSetDate];
}

-(void)setupViewForDate:(NSDate*)date
{
    self.predictionDate = date;
    [self setupViewForSetDate];
}

-(void)setupViewForSetDate
{
    if (self.station) {
        
        if (!self.predictionDate) {
            self.predictionDate = [NSDate date];
        }
        
        [[XTideConnector sharedConnector] setupStation:self.station forDate:self.predictionDate];
        
        self.stationNameLabel.text = self.station.name;
        self.txtView.text = self.station.predictionDetails;
        self.dateLabel.text = self.station.predictionTime;
        self.stationPredictionLabel.text = self.station.prediction;
        
        if (self.station.getStationType == TideStation) {
            if (self.station.rising) {
                NSString *risingPath = [[NSBundle mainBundle] pathForResource:@"arrowup" ofType:@"png"];
                self.dirImage = [UIImage imageWithContentsOfFile:risingPath];
            } else {
                NSString *fallingPath = [[NSBundle mainBundle] pathForResource:@"arrowdown" ofType:@"png"];
                self.dirImage = [UIImage imageWithContentsOfFile:fallingPath];
            }
        } else {
            NSString *risingPath = [[NSBundle mainBundle] pathForResource:@"arrowup" ofType:@"png"];
            self.dirImage = [[UIImage imageWithContentsOfFile:risingPath] imageRotatedByRadians:self.station.radians];
        }
        self.imgView.image = self.dirImage;
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    [self.station discardDetails];
}

-(void)nextDay
{
    self.predictionDate = [self.predictionDate dateByAddingTimeInterval:86400];
    [self setupViewForSetDate];
}

-(void)prevDay
{
    self.predictionDate = [self.predictionDate dateByAddingTimeInterval:-86400];
    [self setupViewForSetDate];
}

@end
