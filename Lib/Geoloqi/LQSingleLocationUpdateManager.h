//
//  LQSingleLocationUpdateManager.h
//  Geoloqi-iPhone-Library
//
//  Created by Aaron Parecki on 12/8/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "LQHTTPRequestLoader.h"

@interface LQSingleLocationUpdateManager : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	CLLocation *currentLocation;
	LQHTTPRequestCallback locationUpdateCallback;
}

@property (nonatomic, retain) CLLocation *currentLocation;

- (void)startSingleLocationUpdate;
- (LQHTTPRequestCallback)locationUpdateCallback;

@end
