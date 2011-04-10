//
//  RootViewController.h
//  PacMap
//
//  Created by P. Mark Anderson on 4/8/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import "LQConstants.h"
#import "Geoloqi.h"
#import "GeoloqiSocketClient.h"

@interface RootViewController : UITableViewController 
{
    LQHTTPRequestCallback geoloqiMessageBlock;
    GeoloqiSocketClient *geoloqiClient;
}

@end
