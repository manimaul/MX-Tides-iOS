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

-(IBAction)nextDay:(id)sender;
-(IBAction)prevDay:(id)sender;
-(IBAction)dateBtnSel:(id)sender;

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UITextView *txtView;
@property (nonatomic, weak) IBOutlet UILabel *stationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *stationPredictionLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIButton *dateButton;
@property (nonatomic) UIImage *dirImage;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation MXDetailsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"EEEE"];
    [self setupViewForSetDate];
}

-(void)setupViewForSetDate
{
    if (self.station) {
        XTideConnector *xtc = [XTideConnector sharedConnector];
        
        if (!self.predictionDate) {
            self.predictionDate = [NSDate date];
        }
        
        [xtc setupStation:self.station forDate:self.predictionDate];
        
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
        
        NSString *dateDay = [self.dateFormatter stringFromDate:self.predictionDate];
        [self.dateButton setTitle:dateDay forState:UIControlStateNormal];
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

-(IBAction)nextDay:(id)sender
{
    self.predictionDate = [self.predictionDate dateByAddingTimeInterval:86400];
    [self setupViewForSetDate];
}

-(IBAction)prevDay:(id)sender
{
    self.predictionDate = [self.predictionDate dateByAddingTimeInterval:-86400];
    [self setupViewForSetDate];
}

- (void)changeDate:(UIDatePicker *)sender {
    self.predictionDate = sender.date;
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
    [self setupViewForSetDate];
}

-(IBAction)dateBtnSel:(id)sender {
    if ([self.view viewWithTag:9]) {
        return;
    }
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    darkView.alpha = 0;
    darkView.backgroundColor = [UIColor blackColor];
    darkView.tag = 9;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)];
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    datePicker.backgroundColor = [UIColor whiteColor];
    datePicker.tag = 10;
    datePicker.date = self.predictionDate;
    [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datePicker];
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    datePicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
}

@end
