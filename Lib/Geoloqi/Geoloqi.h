//
//  Geoloqi.h
//  Geoloqi-iPhone-Library
//
//  Copyright 2010 Geoloqi.com. All rights reserved.
//

#define GEOLOQI_API_URL  @"https://api.geoloqi.com/1/"
//#define GEOLOQI_API_URL  @"http://api.geoloqi.local/1/"

static NSString *const LQLocationUpdateManagerDidUpdateLocationNotification = @"LQLocationUpdateManagerDidUpdateLocationNotification";
static NSString *const LQLocationUpdateManagerDidUpdateSingleLocationNotification = @"LQLocationUpdateManagerDidUpdateSingleLocationNotification";
static NSString *const LQLocationUpdateManagerDidUpdateFriendLocationNotification = @"LQLocationUpdateManagerDidUpdateFriendLocationNotification";
static NSString *const LQLocationUpdateManagerStartedSendingLocations = @"LQLocationUpdateManagerStartedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingLocations = @"LQLocationUpdateManagerFinishedSendingLocations";
static NSString *const LQLocationUpdateManagerFinishedSendingSingleLocation = @"LQLocationUpdateManagerFinishedSendingSingleLocation";
static NSString *const LQLocationUpdateManagerErrorSendingSingleLocation = @"LQLocationUpdateManagerErrorSendingSingleLocation";
static NSString *const LQTrackingStoppedNotification = @"LQTrackingStoppedNotification";
static NSString *const LQTrackingStartedNotification = @"LQTrackingStartedNotification";
static NSString *const LQAuthenticationSucceededNotification = @"LQAuthenticationSucceededNotification";
static NSString *const LQAuthenticationFailedNotification = @"LQAuthenticationFailedNotification";
static NSString *const LQAuthenticationLogoutNotification = @"LQAuthenticationLogoutNotification";
static NSString *const LQAnonymousSignupSucceededNotification = @"LQAnonymousSignupSucceededNotification";
static NSString *const LQAnonymousSignupFailedNotification = @"LQAnonymousSignupFailedNotification";
static NSString *const LQAPIUnknownErrorNotification = @"LQAPIUnknownErrorNotification";

enum {
	LQPresetBattery = 0,
	LQPresetRealtime
};

#import <Foundation/Foundation.h>
#import "LQAuthenticationManager.h"
#import "LQLocationUpdateManager.h"
#import "LQSingleLocationUpdateManager.h"
#import "ISO8601DateFormatter.h"

@interface Geoloqi : NSObject 
{
    LQAuthenticationManager *authManager;
	LQLocationUpdateManager *locationUpdateManager;
	LQSingleLocationUpdateManager *singleLocationUpdateManager;
	ISO8601DateFormatter *dateFormatter;
	NSString *apiUserAgentString;
}

// Is this an ok thing to do? authManager seemed to work before that. 
// Added this when LQLocationUpdateRequest needed to get a hold of the LQLocationUpdateManager -ap
@property (readonly, nonatomic, retain) LQAuthenticationManager *authManager;
@property (readonly, nonatomic, retain) LQLocationUpdateManager *locationUpdateManager;
@property (readonly, nonatomic, retain) LQSingleLocationUpdateManager *singleLocationUpdateManager;
@property (nonatomic, retain) NSDate *lastLocationTimestamp;
@property (nonatomic, retain) NSDate *lastUpdateTimestamp;
@property (nonatomic, retain, readonly) NSString* apiUserAgentString;
@property (nonatomic, retain) NSMutableArray *shutdownTimers;
//@property (readonly, nonatomic, retain) ISO8601DateFormatter *dateFormatter;

+ (Geoloqi *) sharedInstance;

#pragma mark Application

- (void)setUserAgentString:(NSString *)ua;

- (void)createGeonote:(NSString *)text latitude:(float)latitude longitude:(float)longitude radius:(float)radius callback:(LQHTTPRequestCallback)callback;

- (void)createLink:(NSString *)description minutes:(NSInteger)minutes callback:(LQHTTPRequestCallback)callback;

- (void)layerAppList:(LQHTTPRequestCallback)callback;

- (void)subscribeToLayer:(NSString *)layerID callback:(LQHTTPRequestCallback)callback;
- (void)unSubscribeFromLayer:(NSString *)layerID callback:(LQHTTPRequestCallback)callback;

- (void)sendAPNDeviceToken:(NSString *)deviceToken developmentMode:(NSString *)devMode callback:(LQHTTPRequestCallback)callback;

- (void)addShutdownTimer:(id)notification;
- (void)cancelShutdownTimers;

#pragma mark Location

// Completely separate from the idea of passive location tracking. 
// * Start location updates
// * wait for a point to be received more accurate than 300m
// * format in JSON format
// * send it up to Geoloqi
// * then shut down location tracking
- (void)singleLocationUpdate;

- (void)startOrStopMonitoringLocationIfNecessary;
- (void)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)setDistanceFilterTo:(CLLocationDistance)distance;
- (void)setTrackingFrequencyTo:(NSTimeInterval)frequency;
- (void)setSendingFrequencyTo:(NSTimeInterval)frequency;

- (void)startFriendUpdates;
- (void)stopFriendUpdates;

// Getters for location manager variables
- (NSDate *)lastLocationDate;
- (NSDate *)lastUpdateDate;
- (CLLocation *)currentSingleLocation;
- (CLLocation *)currentLocation;
- (BOOL)locationUpdatesState;
- (CLLocationDistance)distanceFilterDistance;
- (NSTimeInterval)trackingFrequency;
- (NSTimeInterval)sendingFrequency;
- (NSUInteger)locationQueueCount;

- (void)loadHistory:(NSDictionary *)params callback:(LQHTTPRequestCallback)callback;
// sendLocationData takes an array of formatted dictionaries, can be generated using dictionaryFromLocation:
- (void)sendLocationData:(NSMutableArray *)points callback:(LQHTTPRequestCallback)callback;
- (void)sendQueuedPoints;
- (NSDictionary *)dictionaryFromLocation:(CLLocation *)location;

- (void)getBannerForLocation:(CLLocation *)location withCallback:(LQHTTPRequestCallback)callback;

#pragma mark Authentication

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (void)createAccountWithUsername:(NSString *)username emailAddress:(NSString *)emailAddress;

- (void)authenticateWithEmail:(NSString *)emailAddress password:(NSString *)password;
- (void)createAccountWithEmailAddress:(NSString *)emailAddress name:(NSString *)name;

- (void)authenticateWithAuthCode:(NSString *)authCode;

- (void)createAnonymousAccount;
- (void)createAnonymousAccount:(NSString*)name;
- (void)setAnonymousAccountEmail:(NSString *)emailAddress name:(NSString *)name;

- (void)initTokenAndGetUsername;

#pragma mark Invitation

- (void)createInvitation:(LQHTTPRequestCallback)callback;

- (void)getInvitationAtHost:(NSString *)host token:(NSString *)invitationToken callback:(LQHTTPRequestCallback)callback;

- (void)claimInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)confirmInvitation:(NSString*)invitationToken host:(NSString*)host callback:(LQHTTPRequestCallback)callback;

- (void)getAccessTokenForInvitation:(NSString*)invitationToken callback:(LQHTTPRequestCallback)callback;

- (void)getLastPositions:(NSArray *)tokens callback:(LQHTTPRequestCallback)callback;

#pragma mark Share

- (void)postToFacebook:(NSString *)text url:(NSString *)url callback:(LQHTTPRequestCallback)callback;

- (void)postToTwitter:(NSString *)text callback:(LQHTTPRequestCallback)callback;

- (void)createPermanentAccessToken:(LQHTTPRequestCallback)callback;

#pragma mark -

- (void)setOauthClientID:(NSString*)clientID secret:(NSString*)secret;

- (void)setOauthAccessToken:(NSString *)accessToken;

- (void)errorProcessingAPIRequest;

- (NSString *)refreshToken;

- (NSString *)accessToken;

- (NSString *)serverURL;

- (BOOL)hasRefreshToken;

- (BOOL)hasAccessToken;

- (void)logOut;

- (NSString *)hardware;

+ (NSString *)base64encode:(NSData *)data;

@end
