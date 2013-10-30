//
//  MXDetailsViewController.m
//  MXTides
//
//  Created by William Kamp on 10/3/13.
//  Copyright (c) 2013 Will Kamp. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
{
    UINavigationController *navC;
}

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //use launch image for bg
//    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LaunchImage"]];
//    iv.contentMode = UIViewContentModeScaleAspectFill;
//    CGRectMake(self.window.bounds.origin.x, self.window.bounds.origin.y+64., self.window.bounds.size.width, self.window.bounds.size.height-64.);
//    [iv setFrame:self.window.bounds];
//    [self.window addSubview:iv];
//
//    self.window.backgroundColor = [UIColor grayColor];
    
//    CGFloat version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    NSLog(@"version %f", version);
//    if (version <= 6.1) {
//        NSLog(@"setting navbar style to black");
//        self.window.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
//    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
