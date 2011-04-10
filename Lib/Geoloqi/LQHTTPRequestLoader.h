//
//  LQHTTPRequestLoader.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LQHTTPRequestCallback)(NSError *error, NSString *responseBody);

@interface LQHTTPRequestLoader : NSObject {
	NSURLConnection *connection;
	NSMutableData *data;
	LQHTTPRequestCallback callback;
}

+ (void)loadRequest:(NSURLRequest *)request
		   callback:(LQHTTPRequestCallback)block;

@end
