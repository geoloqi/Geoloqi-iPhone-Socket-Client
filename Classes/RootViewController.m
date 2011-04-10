//
//  RootViewController.m
//  PacMap
//
//  Created by P. Mark Anderson on 4/8/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "CJSONDeserializer.h"
#import "NSDictionary+BSJSONAdditions.h"

@implementation RootViewController

#define TIMEOUT_SEC 3600

#define HANDSHAKE_PROMPT @"Enter access token: "

#define PACKET_LENGTH_LENGTH_TOKEN 4  // NSUInteger

#define TAG_ENTER_ACCESS_TOKEN 1
#define TAG_ACCESS_TOKEN_SENT 2
#define TAG_READ_PACKET_WITH_LENGTH 3
#define TAG_INCOMING_PACKET 4
#define TAG_SHOULD_BE_LOGGED_IN 5


#pragma mark -
#pragma mark View lifecycle

- (LQHTTPRequestCallback)geoloqiMessageBlock 
{
	if (geoloqiMessageBlock) 
        return geoloqiMessageBlock;
    
	return geoloqiMessageBlock = [^(NSError *error, NSString *responseBody) 
       {
           NSLog(@"Geoloqi message response: %@", responseBody);
           
           NSError *err = nil;
           NSDictionary *res = [[CJSONDeserializer deserializer] deserializeAsDictionary:[responseBody dataUsingEncoding:
                                                                                          NSUTF8StringEncoding]
                                                                                   error:&err];
           if (!res || [res objectForKey:@"error"] != nil) 
           {
               NSLog(@"Error deserializing response \"%@\": %@", responseBody, err);
               return;
           }
           
       } copy];
}

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


- (void)viewDidLoad 
{
    [super viewDidLoad];

	dispatch_queue_t mainQueue = dispatch_get_main_queue();
	
	asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
	
	[self normalConnect];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */


#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// Configure the cell.
    cell.textLabel.text = @"Send message";

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"HW", @"user_id",  // username pmark
                            //@"Mi", @"user_id",  // username spampk
                            @"1aR", @"layer_id",
                            @"{'PING':'pong'}", @"data",
                            nil];
    
    NSLog(@"Sending geoloqi message...");
    
    [[Geoloqi sharedInstance].authManager callAPIPath:@"message/device" 
                                               method:@"POST" 
                                   includeAccessToken:YES 
                                    includeClientCred:NO 
                                           parameters:params 
                                             callback:[self geoloqiMessageBlock]];
                                                  
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


#pragma mark  -

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"localHost:%@ port:%hu", [sock localHost], [sock localPort]);	
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
	NSLog(@"socketDidSecure:%p", sock);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
}

- (void) validateLoginWith:(NSData *)data
{
    // Listen for "Logged in as: whateverman"
    
    NSString *packet = [NSString stringWithUTF8String:[data bytes]];    
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
        // Fail outl
        
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
    NSData *data = [accessToken dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"Writing access token: %@", data);
    [asyncSocket writeData:data withTimeout:TIMEOUT_SEC tag:TAG_ACCESS_TOKEN_SENT];
    
    NSLog(@"Listening for login response, but first for length token %i bytes.\n\n", PACKET_LENGTH_LENGTH_TOKEN);
    [asyncSocket readDataToLength:PACKET_LENGTH_LENGTH_TOKEN withTimeout:TIMEOUT_SEC tag:TAG_ACCESS_TOKEN_SENT];
}

- (void) readPacket:(NSData *)data
{
    /*
    // Strip length token.
    
    NSRange range = NSMakeRange(PACKET_LENGTH_LENGTH_TOKEN, [data length]-PACKET_LENGTH_LENGTH_TOKEN);
    NSData *packetData = [data subdataWithRange:range];                

    NSString *packet = [NSString stringWithUTF8String:[packetData bytes]];    
    NSLog(@"Incoming packet: '%@'", packet);
    */
    
    NSString *packet = [NSString stringWithUTF8String:[data bytes]];    
    NSLog(@"Read packet:\n\n'%@'\n\n", packet);

    NSLog(@"Listening for more packets.");
    [asyncSocket readDataToLength:PACKET_LENGTH_LENGTH_TOKEN withTimeout:TIMEOUT_SEC tag:TAG_INCOMING_PACKET];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"\n\nINCOMING!!\n\ndidReadData with length %i, tag %i", [data length], tag);
    
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

