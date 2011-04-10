//
//  GeoloqiSocketClient.h
//
//  Created by P. Mark Anderson on 4/9/11.
//  Copyright 2011 Bordertown Labs, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"


@interface GeoloqiSocketClient : NSObject 
{
	GCDAsyncSocket *asyncSocket;
    GeoloqiSocketClient *geoloqiClient;
}

// TODO: Make a delegate protocol.
// TODO: Send CLLocation to server.

@end
