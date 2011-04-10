//
//  PacMapAppDelegate.h
//  PacMap
//
//  Created by P. Mark Anderson on 4/8/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PacMapAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

- (void) connectToGeoloqi;

@end

