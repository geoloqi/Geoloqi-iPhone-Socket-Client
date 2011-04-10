//
//  LQAuthenticationManager.h
//  Geoloqi
//
//  Created by Jacob Bandes-Storch on 8/24/10.
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LQHTTPRequestLoader.h"
#import "Geoloqi.h"

@interface LQAuthenticationManager : NSObject {
    NSString *oauthClientID;
    NSString *oauthSecret;
	NSDate *tokenExpiryDate;
	LQHTTPRequestCallback tokenResponseBlock;
	LQHTTPRequestCallback initUsernameBlock;
    LQHTTPRequestCallback acceptInvitationBlock;
	LQHTTPRequestCallback setEmailBlock;
	LQHTTPRequestCallback friendUpdateCallback;
	NSTimer *friendUpdateTimer;
}

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *oauthClientID;
@property (nonatomic, retain) NSString *oauthSecret;

- (void)authenticateWithUsername:(NSString *)username
						password:(NSString *)password;

- (void)authenticateWithEmail:(NSString *)emailAddress 
					 password:(NSString *)password;

- (void)authenticateWithAuthCode:(NSString *)authCode;

- (void)createAccountWithUsername:(NSString *)username
                     emailAddress:(NSString *)emailAddress;

- (void)createAccountWithEmailAddress:(NSString *)emailAddress
								 name:(NSString *)name;

- (void)setAnonymousAccountEmail:(NSString *)emailAddress
							name:(NSString *)name;

- (void)createAnonymousAccount:(NSString *)name;

- (void)createAnonymousAccount;

- (void)initTokenAndGetUsername;

- (void)refreshAccessTokenWithCallback:(void (^)())callback;

- (void)errorProcessingAPIRequest;

- (void)startMonitoringFriends;

- (void)stopMonitoringFriends;

//- (void)createSharedLinkWithExpirationInMinutes:(NSString *)minutes
//								   withDelegate:(LQShareViewController *)delegate;

- (NSString *)refreshToken;
- (NSString *)serverURL;
- (BOOL)hasRefreshToken;

- (void)logOut;

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
 includeAccessToken:(BOOL)includeAccessToken
  includeClientCred:(BOOL)includeClientCred
		 parameters:(NSDictionary *)params
		   callback:(LQHTTPRequestCallback)callback
                url:(NSURL *)URL;

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
 includeAccessToken:(BOOL)includeAccessToken
  includeClientCred:(BOOL)includeClientCred
		 parameters:(NSDictionary *)params
		   callback:(LQHTTPRequestCallback)callback;

- (void)callAPIPath:(NSString *)path
			 method:(NSString *)httpMethod
 includeAccessToken:(BOOL)includeAccessToken
  includeClientCred:(BOOL)includeClientCred
			  array:(NSMutableArray *)array
		   callback:(LQHTTPRequestCallback)callback;

@end

