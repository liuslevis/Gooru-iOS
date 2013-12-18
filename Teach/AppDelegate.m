//
//  AppDelegate.m
// Gooru
//
//  Created by Gooru on 8/9/13.
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

#import "AppDelegate.h"
#import "Reachability.h"
#import "AFHTTPClient.h"
#import "Mixpanel.h"
#import "ViewController.h"
#import "MainClasspageViewController.h"
#import "SHKConfiguration.h"
#define MIXPANEL_TOKEN @""


@implementation AppDelegate

@synthesize progressHUD;
@synthesize progressHUDSuperview;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    NSURL *url = [NSURL URLWithString:[self getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* gooru__keysMyPost = [NSMutableArray arrayWithObjects:@"isGuestUser",@"apiKey", nil];
	NSMutableArray* gooru__objectsMyPost =  [NSArray arrayWithObjects:@"true", [self getValueByKey:@"APIKey"], nil];    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjects:gooru__objectsMyPost forKeys:gooru__keysMyPost];
    
    NSLog(@"params : %@",params);
    
    [httpClient postPath:@"/gooruapi/rest/account/signin.json?" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"getGuestSessionToken Request Successful, response '%@'", responseString);
        
        NSArray *results = [responseString JSONValue];
        NSLog(@"results %@",[results description]);
        NSString* token = [results valueForKey:@"token"];
        NSLog(@"token %@",token);
        

        [standardUserDefaults setObject:token forKey:@"defaultGooruSessionToken"];
        
        if ([standardUserDefaults objectForKey:@"token"] == nil) {
            [standardUserDefaults setObject:@"NA" forKey:@"token"];
            [standardUserDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"isLoggedIn"];
            
        }
       
        
        [self launchViewController];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getGuestSessionToken [HTTPClient Error]: %@", [error description]);
        
        if ([[standardUserDefaults stringForKey:@"defaultGooruSessionToken"] isEqualToString:@"NA"]) {
            [standardUserDefaults setObject:@"NA" forKey:@"defaultGooruSessionToken"];
        }
        
        if ([standardUserDefaults objectForKey:@"token"] == nil) {
            [standardUserDefaults setObject:@"NA" forKey:@"token"];
            [standardUserDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"isLoggedIn"];
        }

        
        [self launchViewController];
    }];

    
    return YES;
}

- (void)launchViewController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[MainClasspageViewController alloc] initWithNibName:@"MainClasspageViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    DefaultSHKConfigurator *configurator = [[DefaultSHKConfigurator alloc] init];
    [SHKConfiguration sharedInstanceWithConfigurator:configurator];
    // Initialize the library with your
    // Mixpanel project token, MIXPANEL_TOKEN
  


    // Tell iOS you want  your app to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];

}

// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    const void *devTokenBytes = [devToken bytes];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel.people addPushDeviceToken:devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}



- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Show alert for push notifications recevied while the app is running
    NSString *message = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSDate *thisMagicMoment = [NSDate date];
    NSDate *lastMagicMoment =  (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"AppOpened"];
    NSString* timeSpent;
    
    if (lastMagicMoment==nil) {
        NSLog (@"First launch!");
    } else {
       NSTimeInterval timeOfNoMagic = [thisMagicMoment timeIntervalSinceDate:lastMagicMoment]/60.0;
        NSLog (@"Application was running for %.1f minutes", timeOfNoMagic);
        timeSpent = [NSString stringWithFormat:@"%.1f minutes", timeOfNoMagic];
    }
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:timeSpent forKey:@"AppRunningTime"];
    [self logMixpanelforevent:@"App Closed" and:dictionary];
    

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self logMixpanelforevent:@"App Opened" and:nil];
        NSDate *thisMagicMoment = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:thisMagicMoment forKey:@"AppOpened"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self getGuestSessionToken];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // create a standardUserDefaults variable
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"isLoggedIn"];
}


#pragma mark getGuestSessionToken
-(void)getGuestSessionToken{
    NSURL *url = [NSURL URLWithString:[self getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* gooru__keysMyPost = [NSArray arrayWithObjects:@"isGuestUser",@"apiKey", nil];
    NSMutableArray* gooru__objectsMyPost =  [NSArray arrayWithObjects:@"true", @"d69ee13e-bbb6-11e2-ba82-123141016e2a", nil];
    
    
    NSMutableDictionary* params = [NSDictionary dictionaryWithObjects:gooru__objectsMyPost forKeys:gooru__keysMyPost];
    
    NSLog(@"params : %@",params);
    
    [httpClient postPath:@"/gooruapi/rest/account/signin.json?" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"getGuestSessionToken Request Successful, response '%@'", responseString);
        
        NSArray *results = [responseString JSONValue];
        NSLog(@"results %@",[results description]);
        NSString* token = [results valueForKey:@"token"];
        NSLog(@"token %@",token);
        
        // create a standardUserDefaults variable
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        
        
   
        [standardUserDefaults setObject:token forKey:@"defaultGooruSessionToken"];
        if ([standardUserDefaults valueForKey:@"token"] == nil)  {
            
            [standardUserDefaults setObject:@"NA" forKey:@"token"];

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"getGuestSessionToken [HTTPClient Error]: %@", [error description]);
        
    }];
    
    
}




#pragma mark Mixpanel tracking
- (void)logMixpanelforevent:(NSString*)eventTitle and:(NSMutableDictionary*)properties{
    
    if ([self getValueByKey:@"isMixpanelEnabled"]) {
        //Mixpanel Tracking
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:eventTitle properties:properties];
    }else{
        NSLog(@"Mixpanel Disabled");
    }

    
}



#pragma mark Set Resource Type Image
- (UIImage*) imageForResourceType:(NSString*)type{
    NSString *strIconName=@"";
    if ([type isEqualToString:@"Video"]) {
        strIconName = @"Video_2x.png";
        
    }else if ([type  isEqualToString:@"Interactive"]) {
        strIconName = @"Interactive_2x.png";
        
    }else if ([type  isEqualToString:@"Textbook"]) {
        strIconName = @"Textbook_2x.png";
        
    }else if ([type  isEqualToString:@"Exam"]) {
        strIconName = @"Exam_2x.png";
        
    }else if ([type  isEqualToString:@"Website"]) {
        strIconName = @"Website_2x.png";
        
    }else if ([type  isEqualToString:@"Handout"]) {
        strIconName = @"Handout_2x.png";
        
    }else if ([type  isEqualToString:@"Lesson"]) {
        strIconName = @"Lesson_2x.png";
        
    }else if ([type  isEqualToString:@"Slide"]) {
        strIconName = @"Slide_2x.png";
        
    }else{
        strIconName = @"Question_2x.png";
    }
    return [UIImage imageNamed:strIconName];
}

#pragma mark Get from pList
-(NSString*) getValueByKey:(NSString*)key{
    //    NSLog(@"initialize Resources.m");
	BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"mylist.plist"];
	success = [fileManager fileExistsAtPath:filePath];
    //	NSLog(@"%@", filePath);
	
	if(!success){
        //		NSLog(@"not success");
		NSError *error;
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mylist.plist"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:filePath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create Messages.plist file with message '%@'.", [error localizedDescription]);
		}
	}
	
	//plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSString *value =  [plistDictionary objectForKey:key];
	return value;
}


#pragma mark Library Hud Metods
- (void)showLibProgressOnView:(UIView *)pView andMessage:(NSString *) message {
	if (![pView isEqual:self.progressHUDSuperview]) {
		self.progressHUDSuperview = pView;
		self.progressHUD = [[MBProgressHUD alloc] initWithFrame:pView.bounds];
		self.progressHUD.labelText = message;
		[pView addSubview:self.progressHUD];
		[self.progressHUD show:YES];
        pView.userInteractionEnabled = FALSE;
	}
}

- (void)removeLibProgressView:(UIView *)pView {
	if (self.progressHUD) {
		[self.progressHUD hide:YES];
		[self.progressHUD removeFromSuperview];
		self.progressHUDSuperview = nil;
        pView.userInteractionEnabled = TRUE;
	}
}

#pragma mark - Create Sorted Array for Dictionary Integer Keys
-(NSArray*)sortedIntegerKeysForDictionary:(NSMutableDictionary*)dict{
    
    
    NSArray* unsortedKeys = [dict allKeys];
    NSMutableArray* unsortedKeysInInt = [[NSMutableArray alloc]initWithCapacity:[unsortedKeys count]];
    
    for (int l=0; l<[unsortedKeys count]; l++) {
        [unsortedKeysInInt addObject:[NSNumber numberWithInt:[[unsortedKeys objectAtIndex:l]intValue]]];
    }
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
    
    
    NSArray *sortedKeysInInt =  [unsortedKeysInInt sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    
    NSMutableArray* sortedKeysInString = [[NSMutableArray alloc]initWithCapacity:[sortedKeysInInt count]];
    
    for (int l=0; l<[sortedKeysInInt count]; l++) {
        [sortedKeysInString addObject:[[sortedKeysInInt objectAtIndex:l]stringValue]];
    }
    
    
    return sortedKeysInString;
}

#pragma mark Null Check for Strings
-(NSString*)ifNullStrReplace:(NSString*)strOriginal With:(NSString*)strToReplace{
    
    NSString* strToReturn = strOriginal;
    if (strOriginal == (id)[NSNull null]) {
        strToReturn = strToReplace;
    }
    
    return strToReturn;
}

#pragma mark Label Height Estimation
-(CGRect)getHLabelFrameForLabel:(UILabel*)label withString:(NSString*)string{
    
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width,99999);
    
    CGSize expectedLabelSize = [string sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    
    //    NSLog(@"in meth : %f :: %f",expectedLabelSize.width,expectedLabelSize.height);
    
    
    return newFrame;
    
}

#pragma mark Label Width Estimation
-(CGRect)getWLabelFrameForLabel:(UILabel*)label withString:(NSString*)string{
    
    CGSize maximumLabelSize = CGSizeMake(99999,label.frame.size.height);
    
    CGSize expectedLabelSize = [string sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    
    
    return newFrame;
    
}
@end
