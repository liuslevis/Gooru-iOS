//
//  MySHKConfigurator.m
//  SocialShare
//
//  Created by Gooru on 6/18/13.
//  Copyright (c) 2013 Gooru. All rights reserved.
//  http://www.goorulearning.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//

#import "MySHKConfigurator.h"

@implementation MySHKConfigurator
/*
 App Description
 ---------------
 These values are used by any service that shows 'shared from XYZ'
 */
- (NSString*)appName {
	return [appDelegate getValueByKey:@"MessageTitle"];
}

- (NSString*)appURL {
	return @"https://www.goorulearning.org";
}

/*
 API Keys
 --------
 This is the longest step to getting set up, it involves filling in API keys for the supported services.
 It should be pretty painless though and should hopefully take no more than a few minutes.
 
 Each key below as a link to a page where you can generate an api key.  Fill in the key for each service below.
 
 A note on services you don't need:
 If, for example, your app only shares URLs then you probably won't need image services like Flickr.
 In these cases it is safe to leave an API key blank.
 
 However, it is STRONGLY recommended that you do your best to support all services for the types of sharing you support.
 The core principle behind ShareKit is to leave the service choices up to the user.  Thus, you should not remove any services,
 leaving that decision up to the user.
 */


// Vkontakte
// SHKVkontakteAppID is the Application ID provided by Vkontakte
- (NSString*)vkontakteAppId {
	return @"";
}

// Facebook - https://developers.facebook.com/apps
// SHKFacebookAppID is the Application ID provided by Facebook
// SHKFacebookLocalAppID is used if you need to differentiate between several iOS apps running against a single Facebook app. Useful, if you have full and lite versions of the same app,
// and wish sharing from both will appear on facebook as sharing from one main app. You have to add different suffix to each version. Do not forget to fill both suffixes on facebook developer ("URL Scheme Suffix"). Leave it blank unless you are sure of what you are doing.
// The CFBundleURLSchemes in your App-Info.plist should be "fb" + the concatenation of these two IDs.
// Example:
//    SHKFacebookAppID = 555
//    SHKFacebookLocalAppID = lite
//
//    Your CFBundleURLSchemes entry: fb555lite
- (NSString*)facebookAppId {
	return @"589695654396740";
}

- (NSString*)facebookLocalAppId {
	return @"";
}

- (NSNumber*)forcePreIOS6FacebookPosting {
	return [NSNumber numberWithBool:false];
}

/*
 Create a project on Google APIs console,
 https://code.google.com/apis/console . Under "API Access", create a
 client ID as "Installed application" with the type "iOS", and
 register the bundle ID of your application.
 */
- (NSString*)googlePlusClientId {
    return @"";
}

//Pocket v3 consumer key. http://getpocket.com/developer/apps/. If you have old read it later app, you should obtain new key.
- (NSString *)pocketConsumerKey {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return @"";
    } else {
        return @"";
    }
}

// Diigo - http://diigo.com/api_dev
-(NSString*)diigoKey {
    return @"";
}
// Twitter - http://dev.twitter.com/apps/new
/*
 Important Twitter settings to get right:
 
 Differences between OAuth and xAuth
 --
 There are two types of authentication provided for Twitter, OAuth and xAuth.  OAuth is the default and will
 present a web view to log the user in.  xAuth presents a native entry form but requires Twitter to add xAuth to your app (you have to request it from them).
 If your app has been approved for xAuth, set SHKTwitterUseXAuth to 1.
 
 Callback URL (important to get right for OAuth users)
 --
 1. Open your application settings at http://dev.twitter.com/apps/
 2. 'Application Type' should be set to BROWSER (not client)
 3. 'Callback URL' should match whatever you enter in SHKTwitterCallbackUrl.  The callback url doesn't have to be an actual existing url.  The user will never get to it because ShareKit intercepts it before the user is redirected.  It just needs to match.
 */

- (NSNumber*)forcePreIOS5TwitterAccess {
    return [NSNumber numberWithBool:false];
}

- (NSString*)twitterConsumerKey {
	return @"WIEu1AgUuegM4AB25aqoNQ";
}

- (NSString*)twitterSecret {
	return @"tsw8lNuWjsnAq2McPldhUQCouCbeQ3eOULiqkjfvfE";
}
// You need to set this if using OAuth, see note above (xAuth users can skip it)
- (NSString*)twitterCallbackUrl {
	return @"http://www.goorulearning.org";
}
// To use xAuth, set to 1
- (NSNumber*)twitterUseXAuth {
	return [NSNumber numberWithInt:0];
}
// Enter your app's twitter account if you'd like to ask the user to follow it when logging in. (Only for xAuth)
- (NSString*)twitterUsername {
	return @"";
}
// Evernote - http://www.evernote.com/about/developer/api/
/*	You need to set to sandbox until you get approved by evernote
 // Sandbox
 #define SHKEvernoteUserStoreURL    @"https://sandbox.evernote.com/edam/user"
 #define SHKEvernoteNetStoreURLBase @"http://sandbox.evernote.com/edam/note/"
 
 // Or production
 #define SHKEvernoteUserStoreURL    @"https://www.evernote.com/edam/user"
 #define SHKEvernoteNetStoreURLBase @"http://www.evernote.com/edam/note/"
 */

- (NSString *)evernoteHost {
    return @"";
}

- (NSString*)evernoteConsumerKey {
	return @"";
}

- (NSString*)evernoteSecret {
	return @"";
}
// Flickr - http://www.flickr.com/services/apps/create/
/*
 1 - This requires the CFNetwork.framework
 2 - One needs to setup the flickr app as a "web service" on the flickr authentication flow settings, and enter in your app's custom callback URL scheme.
 3 - make sure you define and create the same URL scheme in your apps info.plist. It can be as simple as yourapp://flickr */
- (NSString*)flickrConsumerKey {
    return @"";
}

- (NSString*)flickrSecretKey {
    return @"";
}
// The user defined callback url
- (NSString*)flickrCallbackUrl{
    return @"";
}

// Bit.ly for shortening URLs in case you use original SHKTwitter sharer (pre iOS5). If you use iOS 5 builtin framework, the URL will be shortened anyway, these settings are not used in this case. http://bit.ly/account/register - after signup: http://bit.ly/a/your_api_key If you do not enter credentials, URL will be shared unshortened.
- (NSString*)bitLyLogin {
	return @"";
}

- (NSString*)bitLyKey {
	return @"";
}

// LinkedIn - https://www.linkedin.com/secure/developer
- (NSString*)linkedInConsumerKey {
	return @"";
}

- (NSString*)linkedInSecret {
	return @"";
}

- (NSString*)linkedInCallbackUrl {
	return @"";
}

- (NSString*)readabilityConsumerKey {
	return @"";
}

- (NSString*)readabilitySecret {
	return @"";
}

//Only supports XAuth currently
- (NSNumber*)readabilityUseXAuth {
    return [NSNumber numberWithInt:1];;
}
// Foursquare V2 - https://developer.foursquare.com
- (NSString*)foursquareV2ClientId {
    return @"";
}

- (NSString*)foursquareV2RedirectURI {
    return @"";
}

// Tumblr - http://www.tumblr.com/docs/en/api/v2
- (NSString*)tumblrConsumerKey {
	return @"";
}
// Plurk - http://www.plurk.com/API
- (NSString *)plurkAppKey {
    return @"";
}

- (NSString*)tumblrSecret {
	return @"";
}

- (NSString*)tumblrCallbackUrl {
	return @"";
}

// Hatena - https://www.hatena.com/yours12345/config/auth/develop
- (NSString*)hatenaConsumerKey {
	return @"";
}

- (NSString*)hatenaSecret {
	return @"";
}

- (NSString *)plurkAppSecret {
    return @"";
}

- (NSString *)plurkCallbackURL {
    return @"";
}

// Dropbox - https://www.dropbox.com/developers/apps
- (NSString *) dropboxAppKey {
    return @"";
}
- (NSString *) dropboxAppSecret {
    return @"";
}

/*
 This setting should correspond with permission type set during your app registration with Dropbox. You can choose from these two values:
 @"sandbox" (set if you chose permission type "App folder" == kDBRootAppFolder. You will have access only to the app folder you set in  https://www.dropbox.com/developers/apps)
 @"dropbox" (set if you chose permission type "Full dropbox" == kDBRootDropbox)
 */
- (NSString *) dropboxRootFolder {
    return @"";
}
-(BOOL)dropboxShouldOverwriteExistedFile {
    return NO;
}
-(NSString *)youTubeConsumerKey
{
    return @"";
}

-(NSString *)youTubeSecret
{
    return @"";
}

// Buffer
/*
 1 - Set up an app at https://bufferapp.com/developers/apps/create
 2 - Once the app is set up this requires a URL Scheme to be set up within your apps info.plist. bufferXXXX where XXXX is your client ID, this will enable Buffer authentication.
 3 - Set bufferShouldShortenURLS. NO will use ShareKit's shortening (if available). YES will use Buffer's shortener once the sheet is autheorised and presented.
 */

- (NSString*)bufferClientID
{
	return @"";
}

- (NSString*)bufferClientSecret
{
	return @"";
}

-(BOOL)bufferShouldShortenURLS {
    return YES;
}


/*
 UI Configuration : Basic
 ------------------------
 These provide controls for basic UI settings.  For more advanced configuration see below.
 */

- (UIColor*)barTintForView:(UIViewController*)vc {
	
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKTwitter"])
        return [UIColor colorWithRed:0 green:151.0f/255 blue:222.0f/255 alpha:1];
    
    if ([NSStringFromClass([vc class]) isEqualToString:@"SHKFacebook"])
        return [UIColor colorWithRed:59.0f/255 green:89.0f/255 blue:152.0f/255 alpha:1];
    
    return nil;
}

@end

