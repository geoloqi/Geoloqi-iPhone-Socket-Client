//
//  PacMapAppDelegate.m
//  PacMap
//
//  Created by P. Mark Anderson on 4/8/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "PacMapAppDelegate.h"
#import "RootViewController.h"
#import "Geoloqi.h"
#import "LQConstants.h"
#import "Constants.h"

@implementation PacMapAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];

    [self connectToGeoloqi];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark Geoloqi

- (void) connectToGeoloqi
{
    
    [[Geoloqi sharedInstance] setOauthClientID:LQ_OAUTH_CLIENT_ID secret:LQ_OAUTH_SECRET];
    
    
    NSString *storedAccessToken = ACCESS_TOKEN_PMARK; // [[NSUserDefaults standardUserDefaults] stringForKey:CONFIG_PERMANENT_ACCESS_TOKEN];
    NSLog(@"\n\n\nStored access token: %@\n\n\n", storedAccessToken);
    
    //NSLog(@"\n\n\nWARNING: Using hard coded access token instead of: %@\n\n\n", storedAccessToken);
    //storedAccessToken = @"4a6-6525b138045d3502c1db910305a320151ee9b6d5"; 
    
    if ([storedAccessToken length] == 0)
    {
        // If user not logged in
        // log them in
        
    }
    else
    {
        NSLog(@"Setting geoloqi access token: %@", storedAccessToken);
        [[Geoloqi sharedInstance] setOauthAccessToken:storedAccessToken];
    }
    
}

@end

