//
//  GeoloqiSocketClient.m
//
//  Created by P. Mark Anderson on 4/9/11.
//  Copyright 2011 Bordertown Labs, LLC. All rights reserved.
//

#import "GeoloqiSocketClient.h"
#import "Constants.h"
#import "CJSONDeserializer.h"
#import "NSDictionary+BSJSONAdditions.h"
#import "LQConstants.h"

#define TIMEOUT_SEC 3600

#define HANDSHAKE_PROMPT @"Enter access token: "

#define PACKET_LENGTH_LENGTH_TOKEN 4  // NSUInteger

#define TAG_ENTER_ACCESS_TOKEN 1
#define TAG_ACCESS_TOKEN_SENT 2
#define TAG_READ_PACKET_WITH_LENGTH 3
#define TAG_INCOMING_PACKET 4
#define TAG_SHOULD_BE_LOGGED_IN 5


@implementation GeoloqiSocketClient


- (void) listenForHandshakePrompt
{
    // "Enter access token: " is 21 chars.
    
    NSLog(@"Listening for handshake prompt '%@' with tag %i", HANDSHAKE_PROMPT, TAG_ENTER_ACCESS_TOKEN);
    
    NSInteger promptPacketLength = [HANDSHAKE_PROMPT length] + PACKET_LENGTH_LENGTH_TOKEN;
    
    [asyncSocket readDataToLength:promptPacketLength withTimeout:TIMEOUT_SEC tag:TAG_ENTER_ACCESS_TOKEN];
}


- (void) normalConnect
{
	NSError *error = nil;
	
	NSString *host = @"api.geoloqi.com";
    
    UInt16 port = 40000;
	
    NSLog(@"Connecting to %@:%i", host, port);
    
	if (![asyncSocket connectToHost:host onPort:port error:&error])
	{
		NSLog(@"Error connecting: %@", error);
	}
    else
    {
        [self listenForHandshakePrompt];
    }	
}

- (id) init
{
    if (self = [super init])
    {
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
        
        [self normalConnect];    
    }
    
    return self;
}

#pragma mark  -

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"localHost:%@ port:%hu", [sock localHost], [sock localPort]);	
}

- (void) socketDidSecure:(GCDAsyncSocket *)sock
{
	NSLog(@"socketDidSecure:%p", sock);
}

- (void) socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    
    // TODO: reconnect
}

- (void) validateLoginWith:(NSData *)data
{
    // Listen for "Logged in as: whateverman"
    
    NSString *packet = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
    
    NSLog(@"Login response: '%@'", packet);
    
    if ([[packet lowercaseString] hasPrefix:@"logged in"])
    {
        // Good.
        // Listen for incoming packets.
        
        NSLog(@"Login validated. Listening for new incoming packets for %i seconds.", TIMEOUT_SEC);
        
        [asyncSocket readDataToLength:PACKET_LENGTH_LENGTH_TOKEN withTimeout:TIMEOUT_SEC tag:TAG_INCOMING_PACKET];
        
    }
    else
    {
        // Bad.
        // Fail out.
        
        NSLog(@"Login failed.");
    }
}

- (void) parsePacketLengthFrom:(NSData *)data thenListenFor:(long)tag
{
    if ([data length] == PACKET_LENGTH_LENGTH_TOKEN)
    {
        // Make a new NSData with only the length token bytes.
        
        NSRange range = NSMakeRange(0, PACKET_LENGTH_LENGTH_TOKEN);
        NSData *packetLengthTokenData = [data subdataWithRange:range];                
        NSUInteger *lengthPointer = (NSUInteger *)[packetLengthTokenData bytes];
        NSUInteger packetLength = *lengthPointer;
        
        // Read that many bytes from the stream.
        
        
        NSLog(@"Reading next %u bytes", packetLength);
        [asyncSocket readDataToLength:packetLength withTimeout:TIMEOUT_SEC tag:tag];
        
    }
    else
    {
        NSLog(@"WARNING: Packet size %i does not match expected packet length token size %i", 
              [data length], PACKET_LENGTH_LENGTH_TOKEN);
    }
}

- (void) sendAccessTokenAndListen
{
    NSString *accessToken = ACCESS_TOKEN_PMARK;
    NSData *data = [accessToken dataUsingEncoding:NSASCIIStringEncoding];
    
    NSLog(@"Writing access token: %@", data);
    [asyncSocket writeData:data withTimeout:TIMEOUT_SEC tag:TAG_ACCESS_TOKEN_SENT];
    
    NSLog(@"Listening for login response, but first for length token %i bytes.\n\n", PACKET_LENGTH_LENGTH_TOKEN);
    [asyncSocket readDataToLength:PACKET_LENGTH_LENGTH_TOKEN withTimeout:TIMEOUT_SEC tag:TAG_ACCESS_TOKEN_SENT];
}

- (void) readPacket:(NSData *)data
{
    NSString *packet = [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];    
    NSLog(@"Read packet:\n\n'%@'\n\n", packet);
    
    NSLog(@"Listening for more packets.");
    [asyncSocket readDataToLength:PACKET_LENGTH_LENGTH_TOKEN withTimeout:TIMEOUT_SEC tag:TAG_INCOMING_PACKET];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"\n\nINCOMING!!\n\ndidReadData with length %i, tag %i: %@", [data length], tag, data);
    
    switch (tag) 
    {
        case TAG_ENTER_ACCESS_TOKEN:
            
            // Handshake prompt received.
            
            [self sendAccessTokenAndListen];
            break;
            
            
        case TAG_ACCESS_TOKEN_SENT:
            
            // The access token was sent, so listen for a variable length packet size token,
            // then listen for the actual packet, which should be LOGGED_IN
            
            [self parsePacketLengthFrom:data thenListenFor:TAG_SHOULD_BE_LOGGED_IN];
            break;
            
            
        case TAG_SHOULD_BE_LOGGED_IN:
            
            // Confirm login was successful, then we're good to go.
            
            [self validateLoginWith:data];
            break;
            
            
        case TAG_INCOMING_PACKET:
            
            // Get the new packet's length, then read that many bytes.
            
            [self parsePacketLengthFrom:data thenListenFor:TAG_READ_PACKET_WITH_LENGTH];
            
            break;
            
        case TAG_READ_PACKET_WITH_LENGTH:
            
            // Do something with the packet.
            
            [self readPacket:data];
            
            break;
            
            
            
        default:
            break;
    }
}


/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"socketDidReadPartialDataOfLength %i with tag %i", partialLength, tag);
}


/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"socketDidWriteDataWithTag: %i", tag);
}


/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)socket:(GCDAsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"socketDidWritePartialDataOfLength: %i", partialLength);
}


/**
 * Called if a read operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the read's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the read will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been read so far for the read operation.
 * 
 * Note that this method may be called multiple times for a single read if you return positive numbers.
 **/
/*
 - (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag
 elapsed:(NSTimeInterval)elapsed
 bytesDone:(NSUInteger)length
 {
 
 }
 */

/**
 * Called if a write operation has reached its timeout without completing.
 * This method allows you to optionally extend the timeout.
 * If you return a positive time interval (> 0) the write's timeout will be extended by the given amount.
 * If you don't implement this method, or return a non-positive time interval (<= 0) the write will timeout as usual.
 * 
 * The elapsed parameter is the sum of the original timeout, plus any additions previously added via this method.
 * The length parameter is the number of bytes that have been written so far for the write operation.
 * 
 * Note that this method may be called multiple times for a single write if you return positive numbers.
 **/
/*
 - (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
 elapsed:(NSTimeInterval)elapsed
 bytesDone:(NSUInteger)length
 {
 
 }
 */


/**
 * Conditionally called if the read stream closes, but the write stream may still be writeable.
 * 
 * This delegate method is only called if autoDisconnectOnClosedReadStream has been set to NO.
 * See the discussion on the autoDisconnectOnClosedReadStream method for more information.
 **/
- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    NSLog(@"socketDidCloseReadStream");
}


@end
