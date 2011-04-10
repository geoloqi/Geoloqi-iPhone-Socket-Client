//
//  RootViewController.m
//  PacMap
//
//  Created by P. Mark Anderson on 4/8/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "RootViewController.h"
#import "CJSONDeserializer.h"

@implementation RootViewController


- (void) dealloc 
{
    [geoloqiClient release];
    [super dealloc];
}


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
                                                                                          NSASCIIStringEncoding]
                                                                                   error:&err];
           if (!res || [res objectForKey:@"error"] != nil) 
           {
               NSLog(@"Error deserializing response \"%@\": %@", responseBody, err);
               return;
           }
           
       } copy];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];

    geoloqiClient = [[GeoloqiSocketClient alloc] init];
}


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
                            //@"JG", @"user_id",  // username wraithan
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

@end

