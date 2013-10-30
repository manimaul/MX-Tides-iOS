//
//  MXDetailsPageViewController.m
//  MXTides
//
//  Created by William Kamp on 10/28/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "MXDetailsPageViewController.h"
#import "MXDetailsViewController.h"
#import "MXStation.h"

typedef enum {
    mxpfwd,
    mxpbak
} MXPageDirection;

@interface MXDetailsPageViewController ()
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSDate *datePickerDate;
@property (nonatomic) MXDetailsViewController *queuedVcFwd;
@property (nonatomic) MXDetailsViewController *queuedVcBak;
@property (nonatomic) MXPageDirection directionWent;
-(IBAction)dateBtnSel:(id)sender;

@end

@implementation MXDetailsPageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.queuedVcFwd = [self.storyboard instantiateViewControllerWithIdentifier:@"tidedetails"];
    self.queuedVcBak = [self.storyboard instantiateViewControllerWithIdentifier:@"tidedetails"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setViewControllers:(NSArray *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    [super setViewControllers:viewControllers direction:direction animated:animated completion:completion];
    
    MXDetailsViewController *currentVC = [viewControllers objectAtIndex:0];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.queuedVcFwd.station = currentVC.station;
        self.queuedVcFwd.predictionDate = currentVC.predictionDate;
        [self.queuedVcFwd nextDay];
        self.queuedVcBak.station = currentVC.station;
        self.queuedVcBak.predictionDate = currentVC.predictionDate;
        [self.queuedVcBak prevDay];
        [self setPageGesturesEnabled:true];
    }];
    
    [self setTitleDateDay:currentVC];
}

- (void)setTitleDateDay:(MXDetailsViewController*)currentVC;
{
    [self.dateFormatter setDateFormat:@"eeee"];
    NSString *dateDay = [self.dateFormatter stringFromDate:currentVC.predictionDate];
    
    if (dateDay) {
        [self.navigationItem setTitle:dateDay];
    }
}

- (void)setPageGesturesEnabled:(BOOL)enabled
{
    if (enabled)
        self.dataSource = self;
    else
        self.dataSource = nil;
}

#pragma mark - datepicker

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)changeDate:(UIDatePicker *)sender
{
    self.datePickerDate = sender.date;
}

- (void)dismissDatePicker:(id)sender
{
    MXDetailsViewController *cvc = self.viewControllers[0];
    
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
    
    //animate the new selected view for date after dismissal of picker
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIPageViewControllerNavigationDirection pageDirection = UIPageViewControllerNavigationDirectionForward;
        
        //see if this is the same day so we can animate a page flip
        BOOL useAnimation = false;
        if (self.datePickerDate) {
            [self.dateFormatter setDateFormat:@"D"]; // mm/dd/yy
            NSString *currDateStr = [self.dateFormatter stringFromDate:self.datePickerDate];
            NSString *newDateStr = [self.dateFormatter stringFromDate:cvc.predictionDate];
            useAnimation = ![currDateStr isEqualToString:newDateStr];
            
            //now see which direction to flip
            if ([self.datePickerDate compare:cvc.predictionDate] == NSOrderedAscending) {
                pageDirection = UIPageViewControllerNavigationDirectionReverse;
            }
        }
        
        MXDetailsViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"tidedetails"];
        dvc.station = cvc.station;
        [dvc setupViewForDate:self.datePickerDate];
        [self setViewControllers:@[dvc] direction:pageDirection animated:useAnimation completion:Nil];
        [self setPageGesturesEnabled:true];
    }];
}

-(IBAction)dateBtnSel:(id)sender
{
    if ([self.view viewWithTag:9]) {
        return;
    }
    
    [self setPageGesturesEnabled:false];
    
    MXDetailsViewController *cvc = self.viewControllers[0];
    
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
    datePicker.backgroundColor = [UIColor colorWithRed:0.44493 green:0.645269 blue:0.512893 alpha:1.];
    datePicker.tag = 10;
    datePicker.date = cvc.predictionDate;
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

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    self.directionWent = mxpbak;
    return self.queuedVcBak;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    self.directionWent = mxpfwd;
    return self.queuedVcFwd;
}

#pragma mark - UIPageViewController delegate methods

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    [self setPageGesturesEnabled:false];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed) {
        MXDetailsViewController *currentVc = [pageViewController.viewControllers objectAtIndex:0];
        [self setTitleDateDay:currentVc];
        
        switch (self.directionWent) {
            case mxpfwd:
                self.queuedVcFwd = self.queuedVcBak;
                self.queuedVcBak = [previousViewControllers objectAtIndex:0];
                self.queuedVcFwd.predictionDate = currentVc.predictionDate;
                [self.queuedVcFwd nextDay];
                break;
                
            case mxpbak:
                self.queuedVcBak = self.queuedVcFwd;
                self.queuedVcFwd = [previousViewControllers objectAtIndex:0];
                self.queuedVcBak.predictionDate = currentVc.predictionDate;
                [self.queuedVcBak prevDay];
                break;
        }
    }
    
    if (finished) {
        
        [self setPageGesturesEnabled:true];
    }
}

- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    // Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to YES, so set it to NO here.
    UIViewController *currentViewController = self.viewControllers[0];
    NSArray *viewControllers = @[currentViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    self.doubleSided = NO;
    return UIPageViewControllerSpineLocationMin;
}

@end
