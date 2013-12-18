//
//  ShareViewController.m
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

#import "ShareViewController.h"
#import "AFHTTPClient.h"
#import "AppDelegate.h"
#import "SHKiOSFacebook.h"
#import "SHKiOSTwitter.h"
#import "SHKConfiguration.h"
#import "DefaultSHKConfigurator.h"
#import "MySHKConfigurator.h"
#import <MessageUI/MessageUI.h>
#import "Toast+UIView.h"


#define COLLECTION_TITLE @"CollectionTitle"
#define COLLECTION_ID @"CollectionId"
#define COLLECTION_THUMBNAIL @"CollectionThumbnail"
#define COLLECTION_VIEWS @"CollectionViews"
#define COLLECTION_ASSETURI @"CollectionAssetURI"
#define COLLECTION_FOLDER @"CollectionFolder"
#define COLLECTION_NATIVEURL @"CollectionNativeURL"
#define COLLECTION_DESCRIPTION @"CollectionDescription"
#define COLLECTION_FLAG @"CollectionFlag"


#define RESOURCE_INSTANCE_ID @"ResourceInstanceId"
#define RESOURCE_NARRATION @"ResourceNarration"
#define RESOURCE_START @"ResourceStart"
#define RESOURCE_STOP @"ResourceStop"
#define RESOURCE_CATEGORY @"ResourceCategory"
#define RESOURCE_DESCRIPTION @"ResourceDescription"
#define RESOURCE_ACTUAL_ID @"ResourceActualId"
#define RESOURCE_TITLE @"ResourceTitle"
#define RESOURCE_THUMBNAIL @"ResourceThumbnail"
#define RESOURCE_URL @"ResourceUrl"
#define RESOURCE_TYPE @"ResourceType"
#define RESOURCE_FLAG @"ResourceFlag"

#define SHARE_FACEBOOK @"ShareFacebook"
#define SHARE_TWITTER @"ShareTwitter"
#define SHARE_EMAIL @"ShareEmail"

@interface ShareViewController ()

@end

NSMutableDictionary* dictDetails;
BOOL isCollection;
BOOL shouldOccupyFullScreen;

NSString* sessionToken;
NSUserDefaults* standardUserDefaults;
NSString* serverUrl;
AppDelegate* appDelegate;

//Share Item
SHKItem *shareItem;

//Flag to decide on share type
NSString* strShareUsing = @"NA";

@implementation ShareViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initToShareCollection:(BOOL)value withDetails:(NSMutableDictionary*)dictIncomingDetails shouldOccupyFullScreen:(BOOL)value1{
    
    dictDetails = dictIncomingDetails;
    isCollection = value;
    shouldOccupyFullScreen = value1;
    
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    serverUrl = [appDelegate getValueByKey:@"ServerURL"];
    
    if ([sessionToken isEqualToString:@"NA"]) {
        NSLog(@"User Auth Status : User Logged Out!");
        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
    }else{
        NSLog(@"User Auth Status : User Logged In!");
    }
    
    if (!shouldOccupyFullScreen) {
        [self.view setFrame:CGRectMake(0, 0, 769, 700)];
    }
    
    [viewPopup setCenter:self.view.center];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnActionShareFacebook:(id)sender {
    
    strShareUsing = SHARE_FACEBOOK;
    
    [self getBitlyUrlWithSender:sender ifCollection:isCollection];
}

- (IBAction)btnActionShareTwitter:(id)sender {
    
    strShareUsing = SHARE_TWITTER;
    [self getBitlyUrlWithSender:sender ifCollection:isCollection];
}

- (IBAction)btnActionShareEmail:(id)sender {
    
    strShareUsing = SHARE_EMAIL;
    [self getBitlyUrlWithSender:sender ifCollection:isCollection];
}

- (IBAction)btnActionClosePopup:(id)sender {
    
    [self closeSharePopup];
}

- (void)closeSharePopup{
    
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    
    [self performSelector:@selector(removeCurrentDetailViewController) withObject:nil afterDelay:0.4];
    
}

#pragma mark Get Bitly URL
-(void)getBitlyUrlWithSender:(id)sender ifCollection:(BOOL)isCollection{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    NSString *realUrl;
    NSString *strIdToUse;
    if (isCollection) {
        realUrl = [NSString stringWithFormat:@"%@/#!collection-play&id=%@",serverUrl,[dictDetails valueForKey:COLLECTION_ID]];
        strIdToUse = [dictDetails valueForKey:COLLECTION_ID];
    }else{

        realUrl = [NSString stringWithFormat:@"%@/#!resource-play&id=%@&pn=resource",serverUrl,[dictDetails valueForKey:RESOURCE_ACTUAL_ID]];
        strIdToUse = [dictDetails valueForKey:RESOURCE_ACTUAL_ID];
    }
    
    NSLog(@"Real Url : %@",realUrl);
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"realUrl", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken,realUrl, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/url/shorten/%@",strIdToUse] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *results = [responseStr JSONValue];
        NSLog(@"Bitly results : %@",[results description]);
        NSString* strBitlyUrl = [results valueForKey:@"shortenUrl"];
        
        if (isCollection) {
            
            [self shareCollection:sender withUrl:strBitlyUrl];
            
        }else{
            
            [self shareResource:sender withUrl:strBitlyUrl];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}


#pragma mark Share Resource
-(void)shareResource:(id)sender withUrl:(NSString*)urlToShare{
    
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = dictDetails;
    
    
    shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n%@",[dictResourceInfo valueForKey:RESOURCE_TITLE],urlToShare] contentType:SHKURLContentTypeWebpage];
    
    //Mixpanel track dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictResourceInfo valueForKey:RESOURCE_TITLE]] forKey:@"ResourceTitle"];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID]] forKey:@"gooruOid"];
    
    
    if ([strShareUsing isEqualToString:SHARE_FACEBOOK]) {
        
        [SHKiOSFacebook shareItem:shareItem];
        
        //Mixpanel track Facebook
        //        [appDelegate logMixpanelforevent:@"Facebook Share - Resource" and:dictionary];
        
        
    }else if([strShareUsing isEqualToString:SHARE_TWITTER]){
        
        
        [SHKiOSTwitter shareItem:shareItem];
        
        //Mixpanel track Twitter
        //        [appDelegate logMixpanelforevent:@"Twitter Share - Resource" and:dictionary];
        
    }else if([strShareUsing isEqualToString:SHARE_EMAIL]){
        
        NSString* strSubject = [NSString stringWithFormat:@"I've shared a Gooru Resource with you!"];
        
        NSString* strBody1 = [NSString stringWithFormat:@" Gooru Resource: %@\n ",[dictResourceInfo valueForKey:RESOURCE_TITLE]];
        NSString* strBody2  = urlToShare;
        
        NSLog(@"Email");
        if ([MFMailComposeViewController canSendMail]) {
            // Show the composer
            MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
            emailController.mailComposeDelegate = self;
            [emailController setSubject:strSubject];
            
            
            // Fill out the email body text
            NSString *emailBody = [NSString stringWithFormat:@"<br>%@</br> <br><a href = '%@'>%@</a></br> <br/> <br />Sent using <a href = 'http://www.goorulearning.org'>Gooru</a>. Visit <a href = 'http://www.goorulearning.org'>goorulearning.org</a> for more great resources and collections. It's free!</p>", strBody1,strBody2,strBody2];
            
            
            [emailController setMessageBody:emailBody isHTML:YES];
            
            if (emailController) [self presentModalViewController:emailController animated:YES];
            
            //if you want to change its size but the view will remain centerd on the screen in both portrait and landscape then:
            emailController.view.superview.bounds = CGRectMake(0, 0, 320, 480);
            
            //or if you want to change it's position also, then:
            emailController.view.superview.frame = CGRectMake(236, 146, 540, 540);
            
            //Mixpanel track Email
            //            [appDelegate logMixpanelforevent:@"Share Email - Resource" and:dictionary];
        } else {
            // Handle the error
            
            [self.view makeToast:@"No e-mail client configured on the device."
                        duration:2.0
                        position:@"center"];
        }
        
        
    }
    
    
}

#pragma mark Share Collection
-(void)shareCollection:(id)sender withUrl:(NSString*)urlToShare{
    
    //Mixpanel track dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictDetails valueForKey:COLLECTION_TITLE]] forKey:@"CollectionTitle"];
    [dictionary setObject:[dictDetails valueForKey:COLLECTION_ID] forKey:@"gooruOid"];
    
    if ([strShareUsing isEqualToString:SHARE_FACEBOOK]) {
        
        shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n",[dictDetails valueForKey:COLLECTION_TITLE]] contentType:SHKURLContentTypeImage];
        
//        [shareItem setImage:imgViewCoverPage.image];
        
        [SHKiOSFacebook shareItem:shareItem];
        
        //Mixpanel track Facebook
        //        [appDelegate logMixpanelforevent:@"Facebook Share - Collection" and:dictionary];
        
    }else if([strShareUsing isEqualToString:SHARE_TWITTER]){
        
        shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n%@",[dictDetails valueForKey:COLLECTION_TITLE],urlToShare] contentType:SHKURLContentTypeWebpage];
        
//        [shareItem setImage:imgViewCoverPage.image];
        
        [SHKiOSTwitter shareItem:shareItem];
        
        //Mixpanel track Twitter
        //        [appDelegate logMixpanelforevent:@"Twitter Share - Collection" and:dictionary];
        
    }else if([strShareUsing isEqualToString:SHARE_EMAIL]){
        
        NSString* strSubject = [NSString stringWithFormat:@"I've shared a Gooru Collection with you!"];
        
        NSString* strBody1 = [NSString stringWithFormat:@"Gooru Collection: %@ ",[NSString stringWithFormat:@"%@\n",[dictDetails valueForKey:COLLECTION_TITLE]]];
        NSString* strBody2  = urlToShare;
        
        NSLog(@"Email");
        if ([MFMailComposeViewController canSendMail]) {
            // Show the composer
            MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
            emailController.mailComposeDelegate = self;
            [emailController setSubject:strSubject];
            
            
            // Fill out the email body text
            NSString *emailBody = [NSString stringWithFormat:@"<br>%@</br> <br><a href = '%@'>%@</a></br> <br/> <br />Sent using <a href = 'http://www.goorulearning.org'>Gooru</a>. Visit <a href = 'http://www.goorulearning.org'>goorulearning.org</a> for more great resources and collections. It's free!</p>", strBody1,strBody2,strBody2];
            
            
            [emailController setMessageBody:emailBody isHTML:YES];
            
            if (emailController) [self presentModalViewController:emailController animated:YES];
            
            //if you want to change its size but the view will remain centerd on the screen in both portrait and landscape then:
            emailController.view.superview.bounds = CGRectMake(0, 0, 320, 480);
            
            //or if you want to change it's position also, then:
            emailController.view.superview.frame = CGRectMake(236, 146, 540, 540);
            
            //Mixpanel track Email
            //            [appDelegate logMixpanelforevent:@"Email Share - Collection" and:dictionary];
        } else {
            // Handle the error
            
            [self.view makeToast:@"No e-mail client configured on the device."
                        duration:2.0
                        position:@"center"];
        }
        
    }
    
}

#pragma mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
    
}

#pragma mark - Remove ViewController -

- (void)removeCurrentDetailViewController{
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}




@end
