//
//  ResourcePlayerViewController.m
//  Gooru
//
//  Created by Prasad Ram on 11/6/13.
//  Copyright (c) 2013 Gooru Admin. All rights reserved.
//

#import "ResourcePlayerViewController.h"
#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import "Toast+UIView.h"
#import "FlaggingPopupViewController.h"

#define SHARE_FACEBOOK @"ShareFacebook"
#define SHARE_TWITTER @"ShareTwitter"
#define SHARE_EMAIL @"ShareEmail"
#define FLAG @"Flag"

#define RESOURCE_TITLE @"ResourceTitle"
#define RESOURCE_CATEGORY @"ResourceCategory"
#define RESOURCE_THUMBNAIL @"ResourceThumbnail"
#define RESOURCE_URL @"ResourceUrl"
#define RESOURCE_ACTUAL_ID @"ResourceActualId"
#define RESOURCE_DESCRIPTION @"ResourceDescription"
#define RESOURCE_SOURCE @"ResourceSource"
#define RESOURCE_VIEWS @"ResourceViews"
#define RESOURCE_TAGS @"ResourceTags"

@interface ResourcePlayerViewController ()

@end

@implementation ResourcePlayerViewController


//Incoming Details
NSString* sessionToken;
NSString* serverUrl;

NSUserDefaults* standardUserDefaults;
NSString* resourceGooruId;
BOOL isAnonymous;
BOOL isTeacher;
BOOL isLoggedIn;
NSString* strResourceTitle;

AppDelegate* appDelegate;


#pragma mark Incoming Details
NSMutableDictionary* dictAppDetails;

//Question
DTAttributedTextView* txtViewAttrQuestionText;


//Question Selected Option Button
UIButton* btnOptionSelected;

//No of options in questions
int numOfOptions = 0;

//No of Hints
int numOfHints = 0;


//Share Item
SHKItem *shareItem;


//Flag to decide on share type
NSString* shareString = @"NA";



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAppDetails:(NSMutableDictionary*)dictIncomingAppDetails{
    
    self = [super initWithNibName:@"ResourcePlayerViewController" bundle:nil];
    
    dictAppDetails = dictIncomingAppDetails;
     standardUserDefaults = [NSUserDefaults standardUserDefaults];
    //Incoming Details
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    isLoggedIn = [[standardUserDefaults stringForKey:@"isLoggedIn"] boolValue];
    
    if (isLoggedIn) {
        NSLog(@"User Auth Status : User Logged In!");

       
    }else{
        NSLog(@"User Auth Status : User Logged Out!");
        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
    }
    
    serverUrl = [appDelegate getValueByKey:@"ServerURL"];
    resourceGooruId = [dictIncomingAppDetails valueForKey:RESOURCE_ACTUAL_ID];
    isAnonymous = [[dictIncomingAppDetails valueForKey:@"isAnonymous"] boolValue];
    
    return self;
    
}

- (IBAction)btnActionShareResource:(id)sender {
    
    switch ([sender tag]) {
        case 111:{
            shareString = SHARE_FACEBOOK;
            break;
        }
            
        case 222:{
            shareString = SHARE_TWITTER;
            break;
        }
            
        case 333:{
            shareString = SHARE_EMAIL;
            
            
            break;
        }
            
        default:
            break;
    }
    
    [self getBitlyUrlWithSender:sender];
}

- (IBAction)btnActionFlagging:(id)sender {
    
    FlaggingPopupViewController* flaggingPopupViewController = [[FlaggingPopupViewController alloc] initWithResourceInfo:dictAppDetails andParentViewController:self];
    
    [self presentDetailController:flaggingPopupViewController inMasterView:self.view];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Question Attributed text view
    txtViewAttrQuestionText = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(57, 96, 404, 300)];
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutRichTextViews:) name:@"DTAttributedTextContentViewDidFinishLayoutNotification" object:nil];
    
    [self getResourceDetails];
    
    [self updateViewsForResource:dictAppDetails];
    
}

#pragma mark - API Connections -
#pragma mark Get Resource Details
-(void)getResourceDetails{
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/v2/resource/%@?sessionToken=%@",serverUrl,resourceGooruId,sessionToken];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"gooruapi/rest/v2/resource/%@",resourceGooruId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [self parseResourceDetails:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}





#pragma mark Parse Resource Details

-(void)parseResourceDetails:(NSString*)responseString{
    
    
    NSArray *results = [responseString JSONValue];
    int launchSwitch = 0;
    
    //'Resource' Sub level
    NSString* strServiceResource = [results valueForKey:@"resource"];
    strServiceResource = [self ifString:strServiceResource isNullReplaceWith:@"NA"];
    
    //Category
    NSString* strServiceResourceCategory = [strServiceResource valueForKey:@"category"];
    strServiceResourceCategory = [self ifString:strServiceResourceCategory isNullReplaceWith:@"NA"];
    
    //assetURI
    NSString* strServiceResourceAssetUri = [strServiceResource valueForKey:@"assetURI"];
    strServiceResourceAssetUri = [self ifString:strServiceResourceAssetUri isNullReplaceWith:@"NA"];
    
    //folder
    NSString* strServiceResourceFolder = [strServiceResource valueForKey:@"folder"];
    strServiceResourceFolder = [self ifString:strServiceResourceFolder isNullReplaceWith:@"NA"];
    
    //thumbnail
    NSString* strServicethumbnail = [strServiceResource valueForKey:@"thumbnail"];
    strServicethumbnail = [self ifString:strServiceResourceFolder isNullReplaceWith:@"NA"];
    
    //Resource Description
    NSString* strServiceResourceDescription = [strServiceResource valueForKey:@"description"];
    strServiceResourceDescription = [self ifString:strServiceResourceDescription isNullReplaceWith:@"NA"];
    
    //Resource Actual Id
    NSString* strServiceResourceActualId = [strServiceResource valueForKey:@"gooruOid"];
    strServiceResourceActualId = [self ifString:strServiceResourceActualId isNullReplaceWith:@"NA"];
    
    //Resource Title
    strResourceTitle = [strServiceResource valueForKey:@"title"];
    strResourceTitle = [self ifString:strResourceTitle isNullReplaceWith:@"NA"];
    
    //Resource Thumbnail
    NSString* strServiceResourceThumbnail = [[strServiceResource valueForKey:@"thumbnails"] valueForKey:@"url"];
    strServiceResourceThumbnail = [self ifString:strServiceResourceThumbnail isNullReplaceWith:@"NA"];
    
    //Resource Url
    NSString* strServiceResourceUrl = [strServiceResource valueForKey:@"url"];
    strServiceResourceUrl = [self ifString:strServiceResourceUrl isNullReplaceWith:@"NA"];
    
    //Resource Type
    NSString* strServiceResourceType = [[strServiceResource valueForKey:@"resourceType"] valueForKey:@"name"];
    strServiceResourceType = [self ifString:strServiceResourceType isNullReplaceWith:@"NA"];
    
    //--------------//
    //Check for resource types and adjust
    
    //Checking if asset uri and folder have to be appended
    
    if ([strServiceResourceUrl rangeOfString:@"http://"].location == NSNotFound) {
        
        strServiceResourceUrl = [NSString stringWithFormat:@"%@%@%@",strServiceResourceAssetUri,strServiceResourceFolder,strServiceResourceUrl];
    }
    
    //Checking for google viewer formats [str_newnativeUrl hasSuffix:@".pdf"]||
    if([strServiceResourceUrl hasSuffix:@".doc"]||[strServiceResourceUrl hasSuffix:@".docx"]||[strServiceResourceUrl hasSuffix:@".ppt"]||[strServiceResourceUrl hasSuffix:@".pptx"]){
        
        strServiceResourceUrl = [NSString stringWithFormat:@"http://docs.google.com/viewer?url=%@&embedded=true",strServiceResourceUrl];
        
    }
    
    //checking if youtube and adjusting start stop times using Resource Type
    
    if ([strServiceResourceUrl rangeOfString:@"youtube.com/"].location != NSNotFound) {
        
        
        NSString* youtubeId = [self extractYoutubeID:strServiceResourceUrl];
        NSLog(@"youtubeID : %@",youtubeId);
        
        
        strServiceResourceThumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg",youtubeId];
    }else if([strServiceResourceThumbnail rangeOfString:@".png"].location == NSNotFound && [strServiceResourceThumbnail rangeOfString:@".jpg"].location == NSNotFound && [strServiceResourceThumbnail rangeOfString:@".jpeg"].location == NSNotFound){
        
        strServiceResourceThumbnail = [NSString stringWithFormat:@"%@%@%@",strServiceResourceAssetUri,strServiceResourceFolder,strServicethumbnail];
    }
    
    
    [lblResourceTitle setText:[strServiceResource valueForKey:@"title"]];
    
    lblResourceTitle.frame = [self getWLabelFrameForLabel:lblResourceTitle withString:lblResourceTitle.text];
    
    activityIndicatorResourceLoading.frame = CGRectMake(lblResourceTitle.frame.origin.x + lblResourceTitle.frame.size.width + 15, activityIndicatorResourceLoading.frame.origin.y, activityIndicatorResourceLoading.frame.size.width, activityIndicatorResourceLoading.frame.size.height);
    
    [activityIndicatorResourceLoading startAnimating];
    
    if ([strServiceResourceCategory isEqualToString:@"Video"]) {
        if ([strServiceResourceUrl rangeOfString:@"youtube.com/"].location != NSNotFound){
            
            
            launchSwitch = 1;
            
        }else{
            launchSwitch = 3;
        }
    }else if([strServiceResourceCategory isEqualToString:@"Question"]){
        
        
        launchSwitch = 2;
    }else{
        
        launchSwitch = 3;
        
    }
    webViewResource.allowsInlineMediaPlayback=YES;
    webViewResource.mediaPlaybackRequiresUserAction=NO;
    webViewResource.mediaPlaybackAllowsAirPlay=YES;
    webViewResource.delegate=self;
    webViewResource.scrollView.bounces=NO;
    
    //checking for spaces
    strServiceResourceUrl = [strServiceResourceUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    switch (launchSwitch) {
        case 1:{
            
            [self hideWebviewControls:TRUE];
            
            NSLog(@"Youtube embed!");
             NSString *additionalFlags =@"rel=‌​0";
            strServiceResourceUrl = [NSString stringWithFormat:strServiceResourceUrl,additionalFlags];
            NSLog(@"linkObj1_________________%@",strServiceResourceUrl);
            NSString* youtubeId = [self extractYoutubeID:strServiceResourceUrl];

            NSString *embedHTML =[NSString stringWithFormat: @"<body style=\"margin:0\"><iframe id=\"ytplayer\" type=\"text/html\" width=\"1024\" height=\"660\"src=\"https://www.youtube.com/embed/%@?rel=0&showinfo=0\"frameborder=\"0\">",youtubeId];
            NSString *html = [NSString stringWithFormat:embedHTML, strServiceResourceUrl];
            [webViewResource loadHTMLString:html baseURL:nil];
        }
            break;
            
        case 2:{
            NSLog(@"Question Handler launch emminent!");
            [self hideWebviewControls:TRUE];

//            [self loadQuestionOn:viewMainParent withQuestionData:dictCurrentResourceInfo andKey:requiredKey forSummaryPage:FALSE];
            
        }
            break;
            
        case 3:{
            NSLog(@"Simple Webview launch emminent!");
            [self hideWebviewControls:FALSE];

            [webViewResource setBackgroundColor:[UIColor clearColor]];
            webViewResource.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            [webViewResource loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strServiceResourceUrl]]];
            webViewResource.scalesPageToFit = YES;
         //   webViewResource.scrollView.contentInset=UIEdgeInsetsMake(0, 0, 0,64);
            
            NSLog(@"webview : %@",[webViewResource description]);
            
            
        }
            break;
            
        default:
            break;
    }
    
    
    viewMainParent.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark Get Bitly URL
-(void)getBitlyUrlWithSender:(id)sender{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *realUrl;

        realUrl = [NSString stringWithFormat:@"%@/#!resource-play&id=%@&pn=resource",serverUrl,resourceGooruId];
   
    
    NSLog(@"Real Url : %@",realUrl);
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"realUrl", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken,realUrl, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/url/shorten/%@",resourceGooruId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSDictionary *results = [responseStr JSONValue];
        NSLog(@"Bitly results : %@",[results description]);
        NSString* strBitlyUrl = [results valueForKey:@"shortenUrl"];
        
        
            [self shareResource:sender withUrl:strBitlyUrl];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}


#pragma mark Share Resource
-(void)shareResource:(id)sender withUrl:(NSString*)urlToShare{
    
    shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n%@",strResourceTitle,urlToShare] contentType:SHKURLContentTypeWebpage];
    
    //Mixpanel track dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",strResourceTitle] forKey:@"ResourceTitle"];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",resourceGooruId] forKey:@"gooruOid"];
    
    
    if ([shareString isEqualToString:SHARE_FACEBOOK]) {
        
        [SHKiOSFacebook shareItem:shareItem];
        
          }else if([shareString isEqualToString:SHARE_TWITTER]){
        
        
        [SHKiOSTwitter shareItem:shareItem];
        
    }else if([shareString isEqualToString:SHARE_EMAIL]){
        
        NSString* strSubject = [NSString stringWithFormat:@"I've shared a Gooru Resource with you!"];
        
        NSString* strBody1 = [NSString stringWithFormat:@" Gooru Resource: %@\n ",strResourceTitle];
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
        
        
    }else{
        //Flag Resource
//        [self displayFlaggingPopupForCollection:FALSE];
        
    }
    
    
}

#pragma mark Set Flag for Resource/Collection
- (void)setFlagging{
    
    [btnFlag setSelected:TRUE];

}



#pragma mark - Webview Delegates -

-(void)webViewDidStartLoad:(UIWebView *)webView{
    
    NSLog(@"webViewDidStartLoad");
    [activityIndicatorResourceLoading startAnimating];
    
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    NSLog(@"webview did finish");
    [activityIndicatorResourceLoading stopAnimating];
    
}





#pragma mark Hide/Unhide Webview Control
-(void)hideWebviewControls:(BOOL)value{
    
    viewWebControls.frame = CGRectMake(viewWebControls.frame.origin.x, viewWebControls.frame.origin.y, viewWebControls.frame.size.width, viewWebControls.frame.size.height);
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    
    if (value) {
        
        viewWebControls.frame = CGRectMake(viewWebControls.frame.origin.x, 704, viewWebControls.frame.size.width, viewWebControls.frame.size.height);
        
    }else{
        
        viewWebControls.frame = CGRectMake(viewWebControls.frame.origin.x, 665, viewWebControls.frame.size.width, viewWebControls.frame.size.height);
        
    }
    
    [UIView commitAnimations];
    
}

#pragma mark Update Collection Views
-(void)updateViewsForResource:(NSMutableDictionary*)dictResource{
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/resource/update/views/%@.json",serverUrl,[dictResource valueForKey:RESOURCE_ACTUAL_ID]];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    int numberOfViews = [[dictResource valueForKey:RESOURCE_VIEWS] intValue];
    numberOfViews = numberOfViews + 1;
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"resourceViews", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, [NSString stringWithFormat:@"%i",numberOfViews], nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/resource/update/views/%@.json",[dictResource valueForKey:RESOURCE_ACTUAL_ID]] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"[HTTPClient Success] : views updated");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
    
    
}



#pragma mark - BA Webview controls -
- (IBAction)btnActionWebBack:(id)sender {
    
    NSLog(@"webControl_goBack");
    
    [webViewResource goBack];
    
}

- (IBAction)btnActionWebForward:(id)sender {
    
    NSLog(@"webControl_goForward");
    
    [webViewResource goForward];
}

- (IBAction)btnActionWebRefresh:(id)sender {
    
    NSLog(@"webControl_reload");
    
    
    [webViewResource reload];
}



#pragma mark Extarct youtube Id
- (NSString *)extractYoutubeID:(NSString *)youtubeURL{
    
    
    NSLog(@"youtubeURL : %@",youtubeURL);
    
    
    NSError *error = NULL;
    NSString *regexString = @"(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:youtubeURL options:0 range:NSMakeRange(0, [youtubeURL length])];
    if(!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0)))
    {
        NSString *substringForFirstMatch = [youtubeURL substringWithRange:rangeOfFirstMatch];
        
        return substringForFirstMatch;
    }
    return nil;
}



- (IBAction)btnActionClosePlayer:(id)sender {
    
   [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Get Required Min Label Width
-(CGRect)getWLabelFrameForLabel:(UILabel*)label withString:(NSString*)string{
    
    CGSize maximumLabelSize = CGSizeMake(9999,label.frame.size.height);
    
    CGSize expectedLabelSize = [string sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.width = expectedLabelSize.width;
    
    
    return newFrame;
    
}


#pragma mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
    
}



#pragma mark - Parse Helpers -
#pragma mark Null Handler
-(NSString*)ifString:(NSString*)strToCheck isNullReplaceWith:(NSString*)strToReplace{
    if(strToCheck == (id)[NSNull null] || strToCheck == NULL){
        return strToReplace;
    }else{
        return strToCheck;
    }
}

- (void)presentDetailController:(UIViewController*)detailVC inMasterView:(UIView*)viewMaster{
    
    
    [self addChildViewController:detailVC];
    
    //2. Define the detail controller's view size
    //    detailVC.view.frame = [self frameForDetailController];
    
    //3. Add the Detail controller's view to the Container's detail view and save a reference to the detail View Controller
    [viewMaster addSubview:detailVC.view];
    detailVC.view.alpha=0;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         detailVC.view.alpha = 1.0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    //  self.currentDetailViewController = detailVC;
    
    //4. Complete the add flow calling the function didMoveToParentViewController
    [detailVC didMoveToParentViewController:self];
}



@end
