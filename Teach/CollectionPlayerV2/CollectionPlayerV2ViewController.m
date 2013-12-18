//
//  CollectionPlayerV2ViewController.m
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

#import "CollectionPlayerV2ViewController.h"
#import "AFHTTPClient.h"
#import "iCarousel.h"
#import "LBYouTubePlayerViewController.h"
#import "Toast+UIView.h"
#import "NSString_stripHtml.h"
#import "AppDelegate.h"
#import "DTCoreText.h"
#import "DTAttributedLabel.h"
#import "DTAttributedTextView.h"

#import "NSString_stripHtml.h"

#import "SummaryPageViewController.h"
#import "FlaggingPopupViewController.h"

#define COLLECTION_TITLE @"CollectionTitle"
#define COLLECTION_ID @"CollectionId"
#define COLLECTION_THUMBNAIL @"CollectionThumbnail"
#define COLLECTION_VIEWS @"CollectionViews"
#define COLLECTION_ASSETURI @"CollectionAssetURI"
#define COLLECTION_FOLDER @"CollectionFolder"
#define COLLECTION_NATIVEURL @"CollectionNativeURL"
#define COLLECTION_DESCRIPTION @"CollectionDescription"
#define COLLECTION_FLAG @"CollectionFlag"


#define SESSION_TOKEN @"SessionToken"
#define SERVER_URL @"ServerUrl"




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

#define QUESTION_TEXT @"QuestionText"
#define QUESTION_ANSWERS @"QuestionAnswers"
#define QUESTION_HINTS @"QuestionHints"
#define QUESTION_EXPLANATION @"QuestionExplanation"
#define QUESTION_CORRECTANSWER @"CorrectAnswer"
#define QUESTION_USERANSWER @"UserAnswer"
#define QUESTION_TYPE @"Type"

#define RESOURCE_REACTION @"ResourceReaction"

#define SHARE_FACEBOOK @"ShareFacebook"
#define SHARE_TWITTER @"ShareTwitter"
#define SHARE_EMAIL @"ShareEmail"
#define FLAG @"Flag"


#define TAG_RESOURCE_ADDITIVE 21
#define TAG_RESOURCE_MULTIPLIER 31

#define ANSWER_OPTIONVIEW_TAG_START 11
#define MULTIPLIER_VALIDATOR 1000
#define MULTIPLIER_OPTION_BTN 10
#define MULTIPLIER_ANSWER_TEXT 100
#define ADDITIVE_ANSWER_TEXT_LABEL 5

//#define Hint_LABEL_TAG_START 7
#define MULTIPLIER_HINT_LABEL 37
#define MULTIPLIER_HINT_ATTR_LABEL 23

//Question Text Tag
#define TAG_QUESTION_TEXT 123321

//Resource Navigation
#define MULTIPLIER_RESOURCE_NAVIGATION 789

//Navigation Bar
#define NAV_SELECTOR_WIDTH_FOR_END 136
#define NAV_SELECTOR_WIDTH 96
#define NAV_X_SCROLLOFFSET 149
#define NAV_X_ITEM_RECURRANCE 100



@interface CollectionPlayerV2ViewController ()
@property UIViewController  *currentDetailViewController;


@end

@implementation CollectionPlayerV2ViewController


//Incoming Details
NSString* sessionToken;
NSString* serverUrl;
NSString* collectionGooruId;
NSString* resourceInstanceId;
BOOL isAnonymous;
BOOL isTeacher;
BOOL shouldAutoloadNarration;

AppDelegate* appDelegate;


#pragma mark Universal Collection Dictionary
NSMutableDictionary* dictCollection;

#pragma mark Universal Resource Dictionary
NSMutableDictionary* dictAllResources;

#pragma mark Current Resource Dictionary
NSMutableDictionary* dictCurrentResourceInfo;

#pragma mark Incoming Details
NSMutableDictionary* dictAppDetails;

#pragma mark iCarousel
iCarousel* carousel;

#pragma mark Previous Page Index
int previousIndex = -1;

#pragma mark LBYouTubePlayerViewController
LBYouTubePlayerViewController* lbYouTubePlayerViewController;

//Flag to launch video on Narration Close
BOOL flagLaunchVideoOnNarrationDismiss = FALSE;

//Question
DTAttributedTextView* txtViewAttrQuestionText;

//No of options in questions
int noOfOptions = 0;

//No of Hints
int noOfHints1 = 0;

// Narration Settings

UIColor* narrationBackgroundColor;
UIColor* narrationTextBackgroundColor;
UIFont *narrationFont;

//Share Item
SHKItem *shareItem;

//Check if already initialized
BOOL isViewInitialized = FALSE;

//Flag to decide on share type
NSString* strShareTo = @"NA";

//Question Selected Option Button
UIButton* btnOptionSelected;




#pragma mark - View Lifecycle -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithAppDetails:(NSMutableDictionary*)dictIncomingAppDetails{
    
    dictAppDetails = dictIncomingAppDetails;
    
    //Incoming Details
    sessionToken = [dictIncomingAppDetails valueForKey:@"SessionToken"];
    serverUrl = [dictIncomingAppDetails valueForKey:@"ServerUrl"];
    collectionGooruId = [dictIncomingAppDetails valueForKey:@"CollectionGooruId"];
    resourceInstanceId = [dictIncomingAppDetails valueForKey:@"ResourceInstanceId"];
    isAnonymous = [[dictIncomingAppDetails valueForKey:@"isAnonymous"] boolValue];
    isTeacher = [[dictIncomingAppDetails valueForKey:@"isTeacher"] boolValue];
    shouldAutoloadNarration = [[dictIncomingAppDetails valueForKey:@"shouldAutoloadNarration"] boolValue];
    
//    NSLog(@"dictAppDetails : %@",dictAppDetails);
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated{

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    previousIndex = -1;
    
    //Question Attributed text view
    txtViewAttrQuestionText = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(57, 96, 404, 300)];
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(relayoutRichTextViews:) name:@"DTAttributedTextContentViewDidFinishLayoutNotification" object:nil];
    
    isViewInitialized = FALSE;
    
    [viewMain addSubview:viewCoverPage];
    [activivtyIndicatorCollectionLoading startAnimating];
    [btnStartCollection setEnabled:FALSE];
    viewNavigation.hidden = FALSE;
    
    [self.view addSubview:viewRCChooser];
    [viewRCChooser setHidden:TRUE];

    [self loadNarrationSettings];
    
    [self getCollectionDetails];
    
    
}

-(void)findNameWhenColumnIs:(int)columnNo andRowIs:(int)rowNo{
    //Sid Example
}

- (void)dealloc{
//    NSLog(@"Dealloc");
//    
//    carousel.dataSource = nil;
//    carousel.delegate = nil;
//    
//    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
//    
//    UIWebView* webview;
//    
//    for (UIView *aView in [view subviews]){
//        if([aView isKindOfClass:[UIWebView class]]){
//            webview = (UIWebView*)aView;
//        }
//    }
//
//    webview.delegate = nil;
//    
//    scrollNarrationOverlay.delegate = nil;
//    lbYouTubePlayerViewController.delegate = nil;
    
    
}

#pragma mark - API Connections -
#pragma mark Get Collection Details
-(void)getCollectionDetails{
    
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/scollection/%@.json?fltNot.mediaType=not_ipad_friendly&skipCache=true&sessionToken=%@&skipSkeletonSegments=1",serverUrl,collectionGooruId,sessionToken];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/scollection/%@.json?fltNot.mediaType=not_ipad_friendly&skipCache=true&skipSkeletonSegments=1",collectionGooruId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [self parseCollectionDetails:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
    
}

#pragma mark Parse Collection Details
-(void)parseCollectionDetails:(NSString*)responseString{
    
    
    NSArray *results = [responseString JSONValue];
    
    dictCollection = [[NSMutableDictionary alloc] init];
    
    //Collection Title
    NSString* strServiceCollectionTitle = [results valueForKey:@"title"];
    strServiceCollectionTitle = [self ifString:strServiceCollectionTitle isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceCollectionTitle : %@",strServiceCollectionTitle);
    
    //Collection GooruOid
    NSString* strServiceCollectionId = [results valueForKey:@"gooruOid"];
    strServiceCollectionId = [self ifString:strServiceCollectionId isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceCollectionId : %@",strServiceCollectionId);
    
    //Collection Thumbnails
    NSString* strServiceCollectionThumbnail = [[results valueForKey:@"thumbnails"] valueForKey:@"url"];
    strServiceCollectionThumbnail = [self ifString:strServiceCollectionThumbnail isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceCollectionThumbnail : %@",strServiceCollectionThumbnail);
    
    //Collection Views
    NSString* strServiceCollectionViews = [results valueForKey:@"views"];
    strServiceCollectionViews = [self ifString:strServiceCollectionViews isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceCollectionViews : %@",strServiceCollectionViews);
    
    //Collection AssetURI
    NSString* strServiceAssetURI = [results valueForKey:@"assetURI"];
    strServiceAssetURI = [self ifString:strServiceAssetURI isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceAssetURI : %@",strServiceAssetURI);
    
    //Collection Folder
    NSString* strServiceFolder = [results valueForKey:@"folder"];
    strServiceFolder = [self ifString:strServiceFolder isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceFolder : %@",strServiceFolder);
    
    //Collection Native URL
    NSString* strServiceNativeURL = [results valueForKey:@"url"];
    strServiceNativeURL = [self ifString:strServiceNativeURL isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceNativeURL : %@",strServiceNativeURL);
    
    //Collection Description
    NSString* strServiceDescription = [results valueForKey:@"goals"];
    strServiceDescription = [self ifString:strServiceDescription isNullReplaceWith:@"NA"];
//    NSLog(@"strServiceDescription : %@",strServiceDescription);
    
    [dictCollection setValue:strServiceCollectionTitle forKey:COLLECTION_TITLE];
    [dictCollection setValue:strServiceCollectionId forKey:COLLECTION_ID];
    [dictCollection setValue:strServiceCollectionThumbnail forKey:COLLECTION_THUMBNAIL];
    [dictCollection setValue:strServiceCollectionViews forKey:COLLECTION_VIEWS];
    [dictCollection setValue:strServiceAssetURI forKey:COLLECTION_ASSETURI];
    [dictCollection setValue:strServiceFolder forKey:COLLECTION_FOLDER];
    [dictCollection setValue:strServiceNativeURL forKey:COLLECTION_NATIVEURL];
    [dictCollection setValue:strServiceDescription forKey:COLLECTION_DESCRIPTION];
    
    [dictCollection setValue:@"No" forKey:COLLECTION_FLAG];
    
    
    [dictCollection setValue:sessionToken forKey:SESSION_TOKEN];
    [dictCollection setValue:serverUrl forKey:SERVER_URL];


    
    
    //Populating Cover Page Items
    [lblCoverPageTitle setText:[dictCollection valueForKey:COLLECTION_TITLE]];
    [imgViewCoverPage setImageWithURL:[NSURL URLWithString:[dictCollection valueForKey:COLLECTION_THUMBNAIL]] placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
    [txtViewDescription setText:[[dictCollection valueForKey:COLLECTION_DESCRIPTION] stripHtml]];
    
    //----------//
    //Resource Parsing
    NSArray* arrServiceCollectionItem = [results valueForKey:@"collectionItems"];
    //    NSLog(@"arrServiceCollectionItem : %@",arrServiceCollectionItem);
    
    int countArrServiceCollectionItem = [arrServiceCollectionItem count];
    
    dictAllResources = [[NSMutableDictionary alloc] init];
    
    if (countArrServiceCollectionItem > 0) {
        //Parse Resources
        
        for (int i=0; i<countArrServiceCollectionItem; i++) {
            
            int tag = TAG_RESOURCE_ADDITIVE+(i*TAG_RESOURCE_MULTIPLIER);
            
            //Collection Item Id
            NSString* strServiceResourceInstanceId = [[arrServiceCollectionItem objectAtIndex:i] valueForKey:@"collectionItemId"];
            strServiceResourceInstanceId = [self ifString:strServiceResourceInstanceId isNullReplaceWith:@"NA"];
            
            //Collection Item Narration
            NSString* strServiceResourceNarration = [[arrServiceCollectionItem objectAtIndex:i] valueForKey:@"narration"];
            strServiceResourceNarration = [self ifString:strServiceResourceNarration isNullReplaceWith:@"NA"];
            
            //Time Start
            NSString* strServiceResourceTimeStart = [[arrServiceCollectionItem objectAtIndex:i] valueForKey:@"start"];
            strServiceResourceTimeStart = [self ifString:strServiceResourceTimeStart isNullReplaceWith:@"NA"];
            
            //Time Stop
            NSString* strServiceResourceTimeStop = [[arrServiceCollectionItem objectAtIndex:i] valueForKey:@"stop"];
            strServiceResourceTimeStop = [self ifString:strServiceResourceTimeStop isNullReplaceWith:@"NA"];
            
            
            //'Resource' Sub level
            NSString* strServiceResource = [[arrServiceCollectionItem objectAtIndex:i] valueForKey:@"resource"];
            strServiceResource = [self ifString:strServiceResource isNullReplaceWith:@"NA"];
            
            //Category
            NSString* strServiceResourceCategory = [strServiceResource valueForKey:@"category"];
            strServiceResourceCategory = [self ifString:strServiceResourceCategory isNullReplaceWith:@"NA"];
            
            //assetURI
            NSString* strServiceResourceAssetUri = [strServiceResource valueForKey:@"assetURI"];
            strServiceResourceAssetUri = [self ifString:strServiceResourceAssetUri isNullReplaceWith:@"NA"];
            
            NSString* strServiceResourceAssetName;
            NSMutableArray* arrServiceAssets = [strServiceResource valueForKey:@"assets"];
            if ([arrServiceAssets count] > 0) {
                strServiceResourceAssetName = [[[arrServiceAssets objectAtIndex:0] valueForKey:@"asset"] valueForKey:@"name"];
                strServiceResourceAssetName = [self ifString:strServiceResourceAssetName isNullReplaceWith:@"NA"];
            }
            
            //folder
            NSString* strServiceResourceFolder = [strServiceResource valueForKey:@"folder"];
            strServiceResourceFolder = [self ifString:strServiceResourceFolder isNullReplaceWith:@"NA"];
            
            //Resource Description
            NSString* strServiceResourceDescription = [strServiceResource valueForKey:@"description"];
            strServiceResourceDescription = [self ifString:strServiceResourceDescription isNullReplaceWith:@"NA"];
            
            //Resource Actual Id
            NSString* strServiceResourceActualId = [strServiceResource valueForKey:@"gooruOid"];
            strServiceResourceActualId = [self ifString:strServiceResourceActualId isNullReplaceWith:@"NA"];
            
            //Resource Title
            NSString* strServiceResourceTitle = [strServiceResource valueForKey:@"title"];
            strServiceResourceTitle = [self ifString:strServiceResourceTitle isNullReplaceWith:@"NA"];
            
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
//            if ([strServiceResourceType isEqualToString:@"video/youtube"]) {
            if ([strServiceResourceUrl rangeOfString:@"youtube.com/"].location != NSNotFound) {
                if (![strServiceResourceTimeStart isEqualToString:@"NA"]) {
                    strServiceResourceTimeStart = [self computeTimeInSecondsFor:strServiceResourceTimeStart];
                }
                
                if (![strServiceResourceTimeStop isEqualToString:@"NA"]) {
                    strServiceResourceTimeStop = [self computeTimeInSecondsFor:strServiceResourceTimeStop];
                }
                
                
                NSString* youtubeId = [self extractYoutubeID:strServiceResourceUrl];
                NSLog(@"youtubeID : %@",youtubeId);
                
                
                strServiceResourceThumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg",youtubeId];
            }else if([strServiceResourceThumbnail rangeOfString:@".png"].location == NSNotFound && [strServiceResourceThumbnail rangeOfString:@".jpg"].location == NSNotFound && [strServiceResourceThumbnail rangeOfString:@".jpeg"].location == NSNotFound){
                
                strServiceResourceThumbnail = [NSString stringWithFormat:@"%@%@%@",strServiceResourceAssetUri,strServiceResourceFolder,strServiceResourceAssetName];
            }

                    
            NSArray* arrServiceAnswers = [[NSArray alloc] init];
            NSString* strServiceQuestionText = [[NSString alloc] init];
            NSArray* arrServiceHints = [[NSArray alloc] init];
            NSString* strServiceExplanation = [[NSString alloc] init];
            NSString* strServiceQuestionType = [[NSString alloc] init];
            
            if ([strServiceResourceCategory isEqualToString:@"Question"]) {
//                strServiceResourceTitle = @"Question";
                
                //Answer Array
                arrServiceAnswers = [strServiceResource valueForKey:@"answers"];
                
                //Question Text
                strServiceQuestionText = [strServiceResource valueForKey:@"questionText"];
                strServiceQuestionText = [self ifString:strServiceQuestionText isNullReplaceWith:@"NA"];
                
                //Hints Array
                arrServiceHints = [strServiceResource valueForKey:@"hints"];
                
                //Explanation
                strServiceExplanation = [strServiceResource valueForKey:@"explanation"];
                strServiceExplanation = [self ifString:strServiceExplanation isNullReplaceWith:@"NA"];
                
                //Questio0n Type
                strServiceQuestionType = [strServiceResource valueForKey:@"type"];
                
            }
            
            
            //checking for spaces
            strServiceResourceUrl = [strServiceResourceUrl stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            NSMutableDictionary* dictResourceInstance = [[NSMutableDictionary alloc] init];
            
            [dictResourceInstance setValue:strServiceResourceInstanceId forKey:RESOURCE_INSTANCE_ID];//1
            [dictResourceInstance setValue:strServiceResourceNarration forKey:RESOURCE_NARRATION];//2
            [dictResourceInstance setValue:strServiceResourceTimeStart forKey:RESOURCE_START];//3
            [dictResourceInstance setValue:strServiceResourceTimeStop forKey:RESOURCE_STOP];//4
            [dictResourceInstance setValue:strServiceResourceCategory forKey:RESOURCE_CATEGORY];//5
            [dictResourceInstance setValue:strServiceResourceDescription forKey:RESOURCE_DESCRIPTION];//6
            [dictResourceInstance setValue:strServiceResourceActualId forKey:RESOURCE_ACTUAL_ID];//7
            [dictResourceInstance setValue:[strServiceResourceTitle stripHtml] forKey:RESOURCE_TITLE];//8
            [dictResourceInstance setValue:strServiceResourceThumbnail forKey:RESOURCE_THUMBNAIL];//9
            [dictResourceInstance setValue:strServiceResourceUrl forKey:RESOURCE_URL];//10
            [dictResourceInstance setValue:strServiceResourceType forKey:RESOURCE_TYPE];//11
            
            [dictResourceInstance setValue:@"No" forKey:RESOURCE_FLAG];
            
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_TEXT];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_ANSWERS];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_HINTS];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_EXPLANATION];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_CORRECTANSWER];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_USERANSWER];
            [dictResourceInstance setValue:@"Invalid" forKey:QUESTION_TYPE];
            
            [dictResourceInstance setValue:@"NA" forKey:RESOURCE_REACTION];
            
            //Check for Question
            if ([strServiceResourceCategory isEqualToString:@"Question"]) {
                
                [dictResourceInstance setValue:strServiceQuestionText forKey:QUESTION_TEXT];
                [dictResourceInstance setValue:arrServiceAnswers forKey:QUESTION_ANSWERS];
                [dictResourceInstance setValue:arrServiceHints forKey:QUESTION_HINTS];
                [dictResourceInstance setValue:strServiceExplanation forKey:QUESTION_EXPLANATION];
                [dictResourceInstance setValue:@"NA" forKey:QUESTION_CORRECTANSWER];
                [dictResourceInstance setValue:@"NA" forKey:QUESTION_USERANSWER];
                [dictResourceInstance setValue:[NSString stringWithFormat:@"%@", strServiceQuestionType] forKey:QUESTION_TYPE];
                
                
            }
            
            
            //Adding Resource Instance Dictionary to All Resource Dictionary
            [dictAllResources setValue:dictResourceInstance forKey:[NSString stringWithFormat:@"%i",tag]];
            
        }
        
        //        NSLog(@"dictAllResources : %@",[dictAllResources description]);
        
    }
    
    [btnStartCollection setEnabled:TRUE];
    [activivtyIndicatorCollectionLoading stopAnimating];
    
    
    [self populateNavigationDrawer];
    
}

#pragma  mark BA Start Collection
- (IBAction)btnActionStartCollection:(id)sender {
    
    [self updateViews];
    [self prepCarousel];
    [self shouldHideView:viewCoverPage :TRUE];
    
    [self shouldShowReactions:TRUE];
    
    [appDelegate logMixpanelforevent:@"Tap Study" and:nil];
    
}

#pragma mark Update Collection Views
-(void)updateViews{
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/resource/update/views/%@.json",serverUrl,collectionGooruId];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    int numberOfViews = [[dictCollection valueForKey:COLLECTION_VIEWS] intValue];
    numberOfViews = numberOfViews + 1;
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"resourceViews", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, [NSString stringWithFormat:@"%i",numberOfViews], nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/resource/update/views/%@.json",collectionGooruId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"[HTTPClient Success] : views updated");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAssignmentItemViews" object:nil userInfo:nil];
    
}

- (void)prepCarousel{
    
    //configure carousel
    carousel = [[iCarousel alloc] initWithFrame:CGRectMake(0, 0, 1024, 660)];
    carousel.type = iCarouselTypeLinear;
    [carousel setPagingEnabled:TRUE];
    
    carousel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    carousel.dataSource = self;
    carousel.delegate = self;
    
    [carousel setBounceDistance:0.4f];
    [carousel setDecelerationRate:0.8];
    
    
    
    [viewCarouselParent addSubview:carousel];
    
}

#pragma mark - Carousel Enable/Disable -
- (void)enableCarousel:(BOOL)value{
    
    if (value) {
        [carousel setScrollEnabled:TRUE];
    }else{
        [carousel setScrollEnabled:FALSE];
    }
 
}


#pragma mark - Carousel Delegates -

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    //return the total number of items in the carousel
    
    int totalCount = [dictAllResources count] + 1;
    return totalCount;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel{
    
    NSLog(@"index did change index : %i",carousel.currentItemIndex);
    
//    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
//    [self renderResourceOnView:view];
    
    
}

- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel{
    
    NSLog(@"carouselDidEndScrollingAnimation : %i",carousel.currentItemIndex);
    
    if (previousIndex != carousel.currentItemIndex) {
        if(carousel.currentItemIndex == [dictAllResources count]){
            
            [self prepForSummaryPageAndRender:TRUE];
            
        }else{
            
            [self prepForSummaryPageAndRender:FALSE];
            UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
            
            [self renderResourceOnView:view];
            
            
        }
        
        
    }
    
    
}


- (void)carouselWillBeginDragging:(iCarousel *)carousel{
    
    NSLog(@"carouselWillBeginDragging : %i",carousel.currentItemIndex);
    previousIndex = carousel.currentItemIndex;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    NSLog(@"index : %i",index);
    //    UILabel *label = nil;
    //    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)];
    
    //create new view if no view is available for recycling
    if (view != nil)
    {
        //        [[[carousel itemViewAtIndex:previousIndex] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        
    }
    else
    {
        //        [[[carousel itemViewAtIndex:previousIndex] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    //    label.text = [_items[index] stringValue];
    
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 660)];
    [view setBackgroundColor:[UIColor whiteColor]];
    view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    UIActivityIndicatorView* activityIndicatorResourceLoad = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    activityIndicatorResourceLoad.center = view.center;
    [activityIndicatorResourceLoad setHidesWhenStopped:TRUE];
    [activityIndicatorResourceLoad startAnimating];
    [view addSubview:activityIndicatorResourceLoad];
    //    [view addSubview:webView];
    //    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.youtube.com/watch?v=XTcr1-eQr1Q"]]];
//    if(index == 0){
//        [self renderResourceOnView:view];
//    }
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if (option == iCarouselOptionSpacing)
    {
        return value * 1.1f;
    }
    return value;
}



#pragma mark - Render Resource on Carousel View -
- (void)renderResourceOnView:(UIView*)view{
    
    if (previousIndex != -1) {
        if (previousIndex != [dictAllResources count]) {
            [self pauseVideoPlayerForIndex:previousIndex];
            
            UIWebView* webview;
            
            for (UIView *aView in [[carousel itemViewAtIndex:previousIndex] subviews]){
                if([aView isKindOfClass:[UIWebView class]]){
                        webview = (UIWebView*)aView;
                }
            }
            webview.delegate = nil;
            lbYouTubePlayerViewController.delegate = nil;
            
            [[[carousel itemViewAtIndex:previousIndex] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }else{
            
            
            
        }
        
        
    }
    
    
    
    [self manageSelector];
    
    [self manageReactionsOnLoad];
    
    [self manageFlagOnLoad];
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    dictCurrentResourceInfo = [dictAllResources objectForKey:requiredKey];
    
    NSLog(@"Dict to load : %@",[dictCurrentResourceInfo description]);
    
    //Check if Webview renderable resource or Youtube or Question
    
    int launchSwitch = 0;
    
    [lblResourceTitle setText:[dictCurrentResourceInfo valueForKey:RESOURCE_TITLE]];
    
    CGRect frame;
   frame = [self getWLabelFrameForLabel:lblResourceTitle withString:lblResourceTitle.text];
    if (frame.size.width>764) {
        lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y, 764, lblResourceTitle.frame.size.height);
       
    }else{
       lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y,frame.size.width, lblResourceTitle.frame.size.height);
    }
    
    activityIndicatorResourceLoading.frame = CGRectMake(lblResourceTitle.frame.origin.x + lblResourceTitle.frame.size.width + 15, activityIndicatorResourceLoading.frame.origin.y, activityIndicatorResourceLoading.frame.size.width, activityIndicatorResourceLoading.frame.size.height);
    
    [activityIndicatorResourceLoading startAnimating];
    
    if ([[dictCurrentResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Video"]) {
//        if ([[dictResourceInfo valueForKey:RESOURCE_TYPE] isEqualToString:@"video/youtube"]) {
        if ([[dictCurrentResourceInfo valueForKey:RESOURCE_URL] rangeOfString:@"youtube.com/"].location != NSNotFound){
            
            
            launchSwitch = 1;
            
        }else{
            launchSwitch = 3;
        }
    }else if([[dictCurrentResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Question"]){
        
        
        launchSwitch = 2;
    }else{
        
        launchSwitch = 3;
        
    }
    
    //Clearing out all subviews
    for (UIView* aView in [view subviews]){
        [aView removeFromSuperview];
    }
    
    switch (launchSwitch) {
        case 1:{
            NSLog(@"LBYoutube launch emminent!");
            
            if ([[dictCurrentResourceInfo valueForKey:RESOURCE_NARRATION] isEqualToString:@"NA"] || !shouldAutoloadNarration) {
                
                [self loadYouTubePlayerOn:view withURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]] withStartTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_START] intValue] andStopTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_STOP] intValue]];
                
                flagLaunchVideoOnNarrationDismiss = FALSE;
            }else{
                
                flagLaunchVideoOnNarrationDismiss = TRUE;
                
            }
            
            
            [self hideWebviewControls:TRUE];
            
            }
            break;
            
        case 2:{
            NSLog(@"Question Handler launch emminent!");
            
            [self loadQuestionOn:view withQuestionData:dictCurrentResourceInfo andKey:requiredKey forSummaryPage:FALSE];
            flagLaunchVideoOnNarrationDismiss = FALSE;
            [self hideWebviewControls:TRUE];
            
            }
            break;
            
        case 3:{
            NSLog(@"Simple Webview launch emminent!");
            
            flagLaunchVideoOnNarrationDismiss = FALSE;
            
            UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, view.frame.size.height)];
            
            [webView setTag:321123];
            
            webView.delegate = self;
            [webView setBackgroundColor:[UIColor clearColor]];
            webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]]]];
       
            webView.scalesPageToFit = YES;
            
            NSLog(@"webview : %@",[webView description]);
            
            [view insertSubview:webView belowSubview:viewNarrationOverlay];
//            [view addSubview:webView];
            
            [self updateWebviewControlFor:webView];

        }
            break;
            
        default:
            break;
    }
    
    
    view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [self populateNarrationOverlay:view withNarration:[dictCurrentResourceInfo valueForKey:RESOURCE_NARRATION]];
        

    
    
}

#pragma mark Reload Resource on Carousel View 
- (void)reloadResourceOnView:(UIView*)view{
    
    [self manageSelector];
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    dictCurrentResourceInfo = [dictAllResources objectForKey:requiredKey];
    
    NSLog(@"Dict to load : %@",[dictCurrentResourceInfo description]);
    
    //Check if Webview renderable resource or Youtube or Question
    
    int launchSwitch = 0;
    
    [lblResourceTitle setText:[dictCurrentResourceInfo valueForKey:RESOURCE_TITLE]];
    
    
    CGRect frame;
    frame = [self getWLabelFrameForLabel:lblResourceTitle withString:lblResourceTitle.text];
    if (frame.size.width>764) {
        lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y, 764, lblResourceTitle.frame.size.height);
        
    }else{
        lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y,frame.size.width, lblResourceTitle.frame.size.height);
    }
    
    activityIndicatorResourceLoading.frame = CGRectMake(lblResourceTitle.frame.origin.x + lblResourceTitle.frame.size.width + 15, activityIndicatorResourceLoading.frame.origin.y, activityIndicatorResourceLoading.frame.size.width, activityIndicatorResourceLoading.frame.size.height);
    
    [activityIndicatorResourceLoading startAnimating];
    
    if ([[dictCurrentResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Video"]) {
        //        if ([[dictResourceInfo valueForKey:RESOURCE_TYPE] isEqualToString:@"video/youtube"]) {
        if ([[dictCurrentResourceInfo valueForKey:RESOURCE_URL] rangeOfString:@"youtube.com/"].location != NSNotFound){
            
            
            launchSwitch = 1;
            
        }else{
            launchSwitch = 3;
        }
    }else if([[dictCurrentResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Question"]){
        
        
        launchSwitch = 2;
    }else{
        
        launchSwitch = 3;
        
    }
    
    //Clearing out all subviews
    for (UIView* aView in [view subviews]){
        [aView removeFromSuperview];
    }
    
    switch (launchSwitch) {
        case 1:{
            NSLog(@"LBYoutube launch emminent!");

            [self loadYouTubePlayerOn:view withURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]] withStartTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_START] intValue] andStopTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_STOP] intValue]];

        }
            break;
            
        case 2:{
            NSLog(@"Question Handler launch emminent!");
            
            [self loadQuestionOn:view withQuestionData:dictCurrentResourceInfo andKey:requiredKey forSummaryPage:FALSE];
            
        }
            break;
            
        case 3:{
            NSLog(@"Simple Webview launch emminent!");
            
            
            UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024, view.frame.size.height)];
            
            webView.delegate = self;
            [webView setBackgroundColor:[UIColor clearColor]];
            webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            
            [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]]]];
            //    webView.delegate = self;
            webView.scalesPageToFit = YES;
            
            NSLog(@"webview : %@",[webView description]);
            
            [view insertSubview:webView belowSubview:viewNarrationOverlay];
            //            [view addSubview:webView];
            
            [viewNarrationOverlay bringSubviewToFront:webView];
            
        }
            break;
            
        default:
            break;
    }
    
    
    view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    
    

    
}

#pragma mark - Load Narration Settings -

-(void) loadNarrationSettings {
    
    
    float red,green,blue;
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary  = [standardUserDefaults objectForKey:@"teacherNarrationBackgroundColor"];
    
    red = [[dictionary objectForKey:@"red"] floatValue];
    green = [[dictionary objectForKey:@"green"] floatValue];
    blue = [[dictionary objectForKey:@"blue"] floatValue];
    
    narrationBackgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    
    
    if ([standardUserDefaults objectForKey:@"teacherNarrationTextColor"] == nil) {
        narrationTextBackgroundColor = [UIColor whiteColor];
    }else{
        NSDictionary *dictionaryText  = [standardUserDefaults objectForKey:@"teacherNarrationTextColor"];
        
        red = [[dictionaryText objectForKey:@"red"] floatValue];
        green = [[dictionaryText objectForKey:@"green"] floatValue];
        blue = [[dictionaryText objectForKey:@"blue"] floatValue];
        
        narrationTextBackgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        
    }
    NSString* fontForType = [standardUserDefaults objectForKey:@"teacherNarrationFontType"];
    NSLog(@"fontForType : %@",fontForType);
    
    NSString* fontForSize = [standardUserDefaults objectForKey:@"teacherNarrationTextSize"];
    NSLog(@"fontForSize : %@",fontForSize);
    
    narrationFont = [UIFont fontWithName:fontForType size:[fontForSize floatValue]];
    
}

#pragma mark - Narration Overlay -

#pragma mark Populate Narration Overlay
-(void)populateNarrationOverlay:(UIView*)view withNarration:(NSString*)strNarration{
    
    [viewNarrationOverlay removeFromSuperview];
    
    
    [scrollNarrationOverlay scrollRectToVisible:CGRectMake(0, scrollNarrationOverlay.contentSize.height/2, scrollNarrationOverlay.frame.size.width, scrollNarrationOverlay.frame.size.height) animated:NO];
    
    viewNarrationOverlay.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    viewNarrationOverlayChild.frame = CGRectMake(0, 0, viewNarrationOverlayChild.frame.size.width, viewNarrationOverlayChild.frame.size.height);
    [scrollNarrationOverlay addSubview:viewNarrationOverlayChild];
    [scrollNarrationOverlay setContentSize:CGSizeMake(viewNarrationOverlayChild.frame.size.width, viewNarrationOverlayChild.frame.size.height *2)];
    
    
    
//    [view addSubview:viewNarrationOverlay];
    [viewNarrationOverlay setHidden:TRUE];
    
    
    //    lblNarrationOverlay.frame = CGRectMake(18, 188, 985, 100);
    
    
    lblNarrationOverlay.backgroundColor = [UIColor clearColor];
    strNarration = [strNarration stripHtml];
    lblNarrationOverlay.text = strNarration;
    
    //    [lblNarrationOverlay setBackgroundColor:[UIColor yellowColor]];
    [lblNarrationOverlay setTextAlignment:NSTextAlignmentCenter];
    
    [lblNarrationOverlay setNumberOfLines:0];
    
    //    lblNarrationOverlay.frame = [self getHLabelFrameForLabel:lblNarrationOverlay withString:strNarration];
    
    if (!isTeacher && !isAnonymous) {
        [viewNarrationOverlayChild setBackgroundColor:narrationBackgroundColor];
        lblNarrationOverlay.font = narrationFont;
        lblNarrationOverlay.textColor = narrationTextBackgroundColor;
    }else{
        lblNarrationOverlay.textColor = [UIColor whiteColor];
        
    }
    
    [viewNarrationOverlay setHidden:TRUE];
    scrollNarrationOverlay.delegate = self;
    
    if (shouldAutoloadNarration) {
        
        if (![strNarration isEqualToString:@"NA"]) {
            [btnNarration setEnabled:TRUE];
            [btnNarration sendActionsForControlEvents:UIControlEventTouchUpInside];
        }else{
            [btnNarration setEnabled:FALSE];

        }
        
        
        
    }else{
        
        if (![strNarration isEqualToString:@"NA"]) {
            [btnNarration setEnabled:TRUE];
            [btnNarration setSelected:FALSE];
        }else{
            [btnNarration setEnabled:FALSE];
            
        }
        
       
    }
    
}

#pragma mark Manage Narration Overlay
-(void)manageNarrationOverlay{
    
    if ([viewNarrationOverlay isHidden]) {
        [viewNarrationOverlay setHidden:FALSE];
        
        
//        [scrollNarrationOverlay scrollRectToVisible:CGRectMake(0, scrollNarrationOverlay.contentSize.height/2, scrollNarrationOverlay.frame.size.width, scrollNarrationOverlay.frame.size.height) animated:NO];
        [btnNarration setSelected:TRUE];
        [scrollNarrationOverlay scrollRectToVisible:CGRectMake(0, 0, scrollNarrationOverlay.frame.size.width, scrollNarrationOverlay.frame.size.height) animated:YES];
        
        
        [self pauseVideoPlayerForIndex:carousel.currentItemIndex];
        
        
        
        
    }else{
        [scrollNarrationOverlay scrollRectToVisible:CGRectMake(0, scrollNarrationOverlay.contentSize.height/2, scrollNarrationOverlay.frame.size.width, scrollNarrationOverlay.frame.size.height) animated:YES];
        [btnNarration setSelected:FALSE];
        
        //To wait for Curtain Raise on Narration overlay to complete
        [viewNarrationOverlay performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:TRUE] afterDelay:0.3];
        
        if (flagLaunchVideoOnNarrationDismiss) {
            [self loadYouTubePlayerOn:[carousel itemViewAtIndex:carousel.currentItemIndex] withURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]] withStartTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_START] intValue] andStopTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_STOP] intValue]];
            
            flagLaunchVideoOnNarrationDismiss = FALSE;
        }else{
            
           [self playVideoPlayerForIndex:carousel.currentItemIndex];
            
        }
        
    }
    
}

#pragma mark BA Narration In Top Bar
- (IBAction)btnActionNarration:(id)sender{
    
    [[carousel itemViewAtIndex:carousel.currentItemIndex] addSubview:viewNarrationOverlay];
    [appDelegate logMixpanelforevent:@"Tap Narration" and:nil];

    [self manageNarrationOverlay];
    
}


#pragma mark - ScrollView Delegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    NSLog(@"Content Offset : %f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y == 660) {
        [viewNarrationOverlay setHidden:TRUE];
        [btnNarration setSelected:FALSE];
        
        if (flagLaunchVideoOnNarrationDismiss) {
            
            [self loadYouTubePlayerOn:[carousel itemViewAtIndex:carousel.currentItemIndex] withURL:[NSURL URLWithString:[dictCurrentResourceInfo valueForKey:RESOURCE_URL]] withStartTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_START] intValue] andStopTime:[[dictCurrentResourceInfo valueForKey:RESOURCE_STOP] intValue]];
            
            flagLaunchVideoOnNarrationDismiss = FALSE;
        }else{
            [self playVideoPlayerForIndex:carousel.currentItemIndex];
        }
        
    }
    
}

#pragma mark - Navigation Drawer -

#pragma mark BA Navigation Drawer
-(IBAction)btnActionNavigation:(id)sender{
    
        [appDelegate logMixpanelforevent:@"Tap Navigation" and:nil];
        
    viewNavigation.frame = CGRectMake(viewNavigation.frame.origin.x, viewNavigation.frame.origin.y, viewNavigation.frame.size.width, viewNavigation.frame.size.height);
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    
    if (![btnNavigation isSelected]) {
        
        viewNavigation.frame = CGRectMake(viewNavigation.frame.origin.x, viewNavigation.frame.origin.y + viewNavigation.frame.size.height + 44, viewNavigation.frame.size.width, viewNavigation.frame.size.height);
        [btnNavigation setSelected:TRUE];
        [self shouldHideView:viewNavigationOverlayChild :FALSE];

    }else{
        
        viewNavigation.frame = CGRectMake(viewNavigation.frame.origin.x, viewNavigation.frame.origin.y - viewNavigation.frame.size.height - 44, viewNavigation.frame.size.width, viewNavigation.frame.size.height);

        [btnNavigation setSelected:FALSE];
        [self shouldHideView:viewNavigationOverlayChild :TRUE];
    }
    
    [UIView commitAnimations];
    
    
   
}

-(void)unhideView{
    
    if (![btnNavigation isSelected]) {
        viewNavigationOverlayChild.hidden = TRUE;
    }else{
        viewNavigationOverlayChild.hidden = FALSE;
        
    }

    
}

#pragma mark Populate Navigation Drawer
-(void)populateNavigationDrawer{
    
     if (!isViewInitialized) {
    
        UIButton* btnCollectionHome = [[UIButton alloc] init];
        btnCollectionHome.frame = CGRectMake(17, 15, 120, 90);
        [btnCollectionHome setBackgroundColor:[UIColor clearColor]];
        
        [btnCollectionHome setImageWithURL:[NSURL URLWithString:[dictCollection valueForKey:COLLECTION_THUMBNAIL]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
        [btnCollectionHome addTarget:self action:@selector(btnActionReplayCollection:) forControlEvents:UIControlEventTouchUpInside];
        UILabel* lblCollectionHome = [[UILabel alloc] init];
        lblCollectionHome.frame = CGRectMake(0, 0, btnCollectionHome.frame.size.width, btnCollectionHome.frame.size.height);
        [lblCollectionHome setBackgroundColor:[UIColor blackColor]];
        [lblCollectionHome setAlpha:0.75];
        [lblCollectionHome setText:@"Collection\nHome"];
        [lblCollectionHome setFont:[UIFont fontWithName:@"Arial" size: 12.0]];
        [lblCollectionHome setTextColor:[UIColor whiteColor]];
        [lblCollectionHome setTextAlignment:NSTextAlignmentCenter];
        [lblCollectionHome setNumberOfLines:0];
        
        UIImageView* imgViewAccentCollection = [[UIImageView alloc] init];
        imgViewAccentCollection.frame = CGRectMake(0, 0, 10, btnCollectionHome.frame.size.height);
        [imgViewAccentCollection setImage:[UIImage imageNamed:@"btnaccentcollection.png"]];
        
        [btnCollectionHome addSubview:lblCollectionHome];
        [btnCollectionHome addSubview:imgViewAccentCollection];
        
        [scrollNavigation addSubview:btnCollectionHome];
        
        
        int lastXordinate = btnCollectionHome.frame.origin.x + btnCollectionHome.frame.size.width + 12;
        NSLog(@"lastXordinate : %i",lastXordinate);
        
        viewSelector.frame = CGRectMake(lastXordinate, viewSelector.frame.origin.y, viewSelector.frame.size.width, viewSelector.frame.size.height);
        
        
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        
        
        for (int i=0; i<[keysDictAllResources count]; i++) {
            
            //Get key for the resource to be Loaded
            NSString* requiredKey = [keysDictAllResources objectAtIndex:i];
            
            //Hitting Dictionary For the Resource Details
            NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
            
            //Populating Buttons
            UIButton* btnNavigateResources = [[UIButton alloc] init];
            btnNavigateResources.frame = CGRectMake(lastXordinate, 7, 96, 107);
            btnNavigateResources.imageEdgeInsets = UIEdgeInsetsMake(10, 8, 37, 8);
            [btnNavigateResources setBackgroundColor:[UIColor clearColor]];
            
            NSURL* urlThumbnail = [NSURL URLWithString:[dictResourceInfo valueForKey:RESOURCE_THUMBNAIL]];
            
            
            [btnNavigateResources setImageWithURL:urlThumbnail forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
            
            btnNavigateResources.tag = [requiredKey intValue]*MULTIPLIER_RESOURCE_NAVIGATION;
            [btnNavigateResources addTarget:self action:@selector(btnActionNavigateResources:) forControlEvents:UIControlEventTouchUpInside];

            
            //Populating labels
            UILabel* lbl_resourceLabel = [[UILabel alloc] init];
            lbl_resourceLabel.frame = CGRectMake(8, 73, 80, 29);
            
            lbl_resourceLabel.textColor = [UIColor colorWithRed:81.0/255 green:81.0/255 blue:81.0/255 alpha:1.0f];
            lbl_resourceLabel.backgroundColor = [UIColor clearColor];
            lbl_resourceLabel.text = [dictResourceInfo valueForKey:RESOURCE_TITLE];
            
            lbl_resourceLabel.font = [UIFont fontWithName:@"Arial" size: 12.0];
            if([[dictResourceInfo valueForKey:RESOURCE_TITLE] length] > 11){
                lbl_resourceLabel.numberOfLines = 2;
            }else {
                [lbl_resourceLabel sizeToFit];
            }
            
            lastXordinate = lastXordinate + NAV_X_ITEM_RECURRANCE;
            
            //Resource Type Icons
            UIImageView* imgView_resourceTypeIcon = [[UIImageView alloc] init];
            imgView_resourceTypeIcon.frame = CGRectMake(58, 48, 30, 22);
            
            imgView_resourceTypeIcon.image = [self imageForResourceType:[dictResourceInfo valueForKey:RESOURCE_CATEGORY]];
            
            [btnNavigateResources addSubview:imgView_resourceTypeIcon];
            
            [btnNavigateResources addSubview:lbl_resourceLabel];
            [scrollNavigation addSubview:btnNavigateResources];
            
            
        }
         
         
         //End Screen Item
         lastXordinate = lastXordinate + 8;
         
         UIButton* btnCollectionEnd = [[UIButton alloc] init];
         btnCollectionEnd.frame = CGRectMake(lastXordinate, 15, 120, 90);
         [btnCollectionEnd setBackgroundColor:[UIColor clearColor]];
         
         [btnCollectionEnd addTarget:self action:@selector(btnActionNavigationEndScreen:) forControlEvents:UIControlEventTouchUpInside];
         
         UILabel* lblCollectionEnd = [[UILabel alloc] init];
         lblCollectionEnd.frame = CGRectMake(0, 0, btnCollectionHome.frame.size.width, btnCollectionHome.frame.size.height);
         [lblCollectionEnd setBackgroundColor:[UIColor blackColor]];
         [lblCollectionEnd setText:@"Collection\nEnd"];
         [lblCollectionEnd setFont:[UIFont fontWithName:@"Arial" size: 12.0]];
         [lblCollectionEnd setTextColor:[UIColor whiteColor]];
         [lblCollectionEnd setTextAlignment:NSTextAlignmentCenter];
         [lblCollectionEnd setNumberOfLines:0];
         
         
         [btnCollectionEnd addSubview:lblCollectionEnd];
         [scrollNavigation addSubview:btnCollectionEnd];
         
         
         lastXordinate = lastXordinate + 130;
         
         [scrollNavigation setContentSize:CGSizeMake(lastXordinate,scrollNavigation.frame.size.height)];
         
         isViewInitialized = TRUE;
         
        
     }else{
         
         
         
     }
    
}

-(void)btnActionReplayCollection:(id)sender{
    
    [self shouldShowReactions:FALSE];
    
    [self prepForSummaryPageAndRender:FALSE];
    
    [self shouldHideView:viewCoverPage :FALSE];
    
    if ([[dictCollection valueForKey:COLLECTION_FLAG] isEqualToString:@"Yes"]) {
        [btnFlag setSelected:TRUE];
    }else{
        [btnFlag setSelected:FALSE];
    }
    
    [carousel removeFromSuperview];
    
}

-(void)btnActionNavigationEndScreen:(id)sender{
    
    previousIndex = carousel.currentItemIndex;
    [carousel scrollToItemAtIndex:[dictAllResources count] animated:YES];
    [btnNavigation sendActionsForControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark BA Navigate Resources

-(void)btnActionNavigateResources:(id)sender{
    
    int tag = [sender tag];
    
    tag = tag/MULTIPLIER_RESOURCE_NAVIGATION;
    tag = tag - TAG_RESOURCE_ADDITIVE;
    tag = tag/TAG_RESOURCE_MULTIPLIER;

    if (tag != carousel.currentItemIndex) {
        previousIndex = carousel.currentItemIndex;
        [carousel scrollToItemAtIndex:tag animated:YES];
    }else{
        flagLaunchVideoOnNarrationDismiss = FALSE;
        
        [self renderResourceOnView:[carousel itemViewAtIndex:carousel.currentItemIndex]];
    }
    
    
}

#pragma mark Manage Selector in Navigation
-(void)manageSelector{
    viewSelector.frame = CGRectMake(viewSelector.frame.origin.x, viewSelector.frame.origin.y, viewSelector.frame.size.width, viewSelector.frame.size.height);
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    
    if (carousel.currentItemIndex == [dictAllResources count]) {

        viewSelector.frame = CGRectMake(carousel.currentItemIndex*NAV_X_ITEM_RECURRANCE + NAV_X_SCROLLOFFSET, viewSelector.frame.origin.y, NAV_SELECTOR_WIDTH_FOR_END, viewSelector.frame.size.height);
    }else{
        viewSelector.frame = CGRectMake(carousel.currentItemIndex*NAV_X_ITEM_RECURRANCE + NAV_X_SCROLLOFFSET, viewSelector.frame.origin.y, NAV_SELECTOR_WIDTH, viewSelector.frame.size.height);
    }
    
    
    
    
    
    [UIView commitAnimations];
    
    
    
    //Auto scroll to keep selector in view
    
    CGPoint offset_navigationScroll = [scrollNavigation contentOffset];
    int rangeInView = offset_navigationScroll.x + scrollNavigation.frame.size.width;
    
    if (viewSelector.frame.origin.x+viewSelector.frame.size.width > rangeInView) {
        [scrollNavigation scrollRectToVisible:CGRectMake(viewSelector.frame.origin.x, scrollNavigation.frame.origin.y, scrollNavigation.frame.size.width, scrollNavigation.frame.size.height) animated:YES];
    }else if(viewSelector.frame.origin.x < offset_navigationScroll.x){
        [scrollNavigation scrollRectToVisible:CGRectMake(viewSelector.frame.origin.x-scrollNavigation.frame.size.width-viewSelector.frame.size.width, scrollNavigation.frame.origin.y, scrollNavigation.frame.size.width, scrollNavigation.frame.size.height) animated:YES];
    }
    
    
    //    if(currentPage%7 == 0){
    //
    //            [scroll_navigationScroll scrollRectToVisible:CGRectMake(scroll_navigationScroll.frame.origin.x, MIN(scroll_navigationScroll.contentSize.height,currentPage*110), scroll_navigationScroll.frame.size.width, scroll_navigationScroll.frame.size.height) animated:YES];
    //        }
    
    //    if(previousPage>currentPage){
    //        if(currentPage%6 == 0){
    //            if(scroll_navigationScroll.contentOffset.y+748>scroll_navigationScroll.contentSize.height){
    //                [scroll_navigationScroll scrollRectToVisible:CGRectMake(scroll_navigationScroll.frame.origin.x, view_selector.frame.origin.x-748-110, scroll_navigationScroll.frame.size.width, scroll_navigationScroll.frame.size.height) animated:YES];
    //            }else{
    //                [scroll_navigationScroll scrollRectToVisible:CGRectMake(scroll_navigationScroll.frame.origin.x, currentPage*110-7*110, scroll_navigationScroll.frame.size.width, scroll_navigationScroll.frame.size.height) animated:YES];
    //            }
    //
    //        }
    //    }
    
}

#pragma mark - Youtube Loader -
-(void)loadYouTubePlayerOn:(UIView*)view withURL:(NSURL*)url withStartTime:(int)startTime andStopTime:(int)stopTime{
    
//    [appDelegate showLibProgressOnView:self.view andMessage:@"Loading your video.."];
    
    NSLog(@"loadYouTubePlayer for url : %@",url);
    
    lbYouTubePlayerViewController = [[LBYouTubePlayerViewController alloc] initWithYouTubeURL:url quality:LBYouTubeVideoQualityLarge];
    lbYouTubePlayerViewController.delegate = self;

    if (startTime !=0) {
        lbYouTubePlayerViewController.startTime=startTime;
    }
    
    if (stopTime !=0) {
        lbYouTubePlayerViewController.endTime=stopTime;
    }
    
    
    //    self.controller.view.center = webView.center;
    
    //Setting dimensions for youtube player
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = view.frame.size.width;
    frame.size.height = view.frame.size.height;
    
    lbYouTubePlayerViewController.view.frame = frame;
    [lbYouTubePlayerViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];

    
    [view insertSubview:lbYouTubePlayerViewController.view belowSubview:viewNarrationOverlay];
    [viewNarrationOverlay bringSubviewToFront:lbYouTubePlayerViewController.view];
    
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL {
    NSLog(@"youTubePlayerViewController Did extract video source:%@", videoURL);
    [activityIndicatorResourceLoading stopAnimating];

}

-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL{
    
    NSLog(@"Did extract video source:%@", videoURL);
}


-(void)youTubeExtractor:(LBYouTubeExtractor *)extractor failedExtractingYouTubeURLWithError:(NSError *)error{
    
    NSLog(@"Failed extract video source:%@", [error description]);
}


-(void)pauseVideoPlayerForIndex:(int)index{
    NSLog(@"pauseVideoPlayer");
    if(index != [dictAllResources count]){
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        //Get key for the resource to be Loaded
        NSString* requiredKey = [keysDictAllResources objectAtIndex:index];
        
        //Hitting Dictionary For the Resource Details
        NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
        
        
        NSRange range = [[dictResourceInfo valueForKey:RESOURCE_URL] rangeOfString:@"youtube.com"];
        
        if (range.length > 0) {
            [lbYouTubePlayerViewController.view pauseVideo];
        }

    }
}

-(void)playVideoPlayerForIndex:(int)index{
    NSLog(@"playVideoPlayer");
    if(index != [dictAllResources count]){
        
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        //Get key for the resource to be Loaded
        NSString* requiredKey = [keysDictAllResources objectAtIndex:index];
        
        //Hitting Dictionary For the Resource Details
        NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
        
        
        NSRange range = [[dictResourceInfo valueForKey:RESOURCE_URL] rangeOfString:@"youtube.com"];
        
        if (range.length > 0) {
            [lbYouTubePlayerViewController.view playVideo];
        }
    }
}


#pragma mark - Question Loader -
-(void)loadQuestionOn:(UIView*)view withQuestionData:(NSMutableDictionary*)dictQuestionData andKey:(NSString*)requiredKey forSummaryPage:(BOOL)forSummaryPage{
    
    NSLog(@"Question Load Emminent!");
    
    [self resetQuestionTemplate];
    
    //Remove view Contents
    for (UIView *aView in [view subviews]){
        [aView removeFromSuperview];
    }
    
    //Question Text
    
    //    lblQuestionText.frame = [self getHLabelFrameForLabel:lblQuestionText withString:[arrQuestionData objectAtIndex:GET_RESOURCE_QUESTIONTEXT]];
    //    [lblQuestionText setHidden:TRUE];
    
    NSData *data = [[dictQuestionData valueForKey:QUESTION_TEXT] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"image data to string : %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    txtViewAttrQuestionText.textDelegate = self;
    
    [txtViewAttrQuestionText.attributedTextContentView setTag:TAG_QUESTION_TEXT];
    [txtViewAttrQuestionText setTag:TAG_QUESTION_TEXT];
    
    // Set our builder to use the default native font face and size
    NSDictionary *builderOptions = @{
                                     DTDefaultFontFamily: @"Arial",
                                     DTDefaultFontSize:@"16",
                                     DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
                                     };
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data options:builderOptions documentAttributes:nil];
    
    txtViewAttrQuestionText.shouldDrawImages = YES;
    [scrollViewQuestionLhs addSubview:txtViewAttrQuestionText];
    
    [txtViewAttrQuestionText setAttributedString:attrString];
    
    
    //    [txtViewAttrQuestionText setBackgroundColor:[UIColor yellowColor]];
    
    CGSize size = [txtViewAttrQuestionText.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:txtViewAttrQuestionText.frame.size.width];
    
    CGRect frameToSet = txtViewAttrQuestionText.frame;
    frameToSet.size.width = size.width;
    frameToSet.size.height = size.height;
    
    txtViewAttrQuestionText.frame = frameToSet;
    lblQuestionText.frame = txtViewAttrQuestionText.frame;
    
    //Question Image
    imgViewQuestionImage.frame = CGRectMake(imgViewQuestionImage.frame.origin.x, txtViewAttrQuestionText.frame.origin.y + txtViewAttrQuestionText.frame.size.height + 21, imgViewQuestionImage.frame.size.width, imgViewQuestionImage.frame.size.height);
    NSString* strThumbnail = [dictQuestionData valueForKey:RESOURCE_THUMBNAIL];
    
    NSLog(@"strThumbnail : %@",strThumbnail);
    
    if ([strThumbnail rangeOfString:@".png"].location==NSNotFound && [strThumbnail rangeOfString:@".jpg"].location==NSNotFound && [strThumbnail rangeOfString:@".jpeg"].location==NSNotFound) {
        
        [imgViewQuestionImage setHidden:TRUE];
        
    }else{
        [imgViewQuestionImage setImageWithURL:[NSURL URLWithString:strThumbnail] placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
        [imgViewQuestionImage setHidden:FALSE];
    }
    
    [self setUpHintsAndExplanationWithHintsData:[dictQuestionData valueForKey:QUESTION_HINTS] andExplanationData:[dictQuestionData valueForKey:QUESTION_EXPLANATION]];
    
    //Answer Text
    
//    NSArray* keys = [self sortedIntegerKeysForDictionary:dictAllResources];
//    NSString* requiredKey = [keys objectAtIndex:carousel.currentItemIndex];
    
    NSArray* arrAnswers = [dictQuestionData valueForKey:QUESTION_ANSWERS];
    int sizeArrAnswers = [arrAnswers count];
    noOfOptions = sizeArrAnswers;
    
    if ([[dictQuestionData valueForKey:QUESTION_TYPE] isEqualToString:@"6"]) {
        
        [viewOEQuestion setHidden:FALSE];
        [btnCheckAnswer setHidden:TRUE];
        
        if (forSummaryPage) {
            
            [txtViewOEAnswer setText:[dictQuestionData valueForKey:QUESTION_USERANSWER]];
            
            if ([txtViewOEAnswer.text isEqualToString:@"NA"]) {
                [txtViewOEAnswer setText:@""];
            }
            [txtViewOEAnswer setEditable:FALSE];
            [btnOESubmit setHidden:TRUE];
            
            
        }else{
            
            [dictQuestionData setValue:@"NA" forKey:QUESTION_USERANSWER];
            [txtViewOEAnswer setDelegate:self];
                        
            [txtViewOEAnswer setText:@""];
            [txtViewOEAnswer setEditable:TRUE];
            [btnOESubmit setHidden:FALSE];
            
            
           
        }
        
    }else{
        
        [viewOEQuestion setHidden:TRUE];
        if (!forSummaryPage) {
            [btnCheckAnswer setHidden:FALSE];
        }
        
        
    }
    
    
    
    for(int i =0;i < sizeArrAnswers;i++){
        
        NSLog(@"arrAnswers : %@",[arrAnswers objectAtIndex:i]);
        
        //Populating answer text in labels
        //[[[arrAnswers objectAtIndex:i] valueForKey:@"sequence"] intValue]
        
        //Resetting User Answer
        if (!forSummaryPage) {
            [dictQuestionData setValue:@"NA" forKey:QUESTION_USERANSWER];

        }
                
        switch (i+1) {
                
                
            
            case 1:{
                NSLog(@"Option 1");
                
                UIView* viewOption = (UIView*)[scrollViewQuestionRhs viewWithTag:11];
                viewOption.hidden = false;
                
                btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, viewOption.frame.origin.y + viewOption.frame.size.height + 25, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);

                UILabel* lblOption1 = (UILabel*)[viewOption viewWithTag:11*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
                [lblOption1 setText:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"]];
                
                //Rich Text!
                NSMutableDictionary* dictParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"11",@"Tag",[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"],@"AnswerText", nil];
                
                DTAttributedTextView* txtViewAttrOption = [self makeOptionViewForParameters:dictParameters forSummaryPage:forSummaryPage];
                
                [viewOption addSubview:txtViewAttrOption];
                frameToSet = viewOption.frame;
                frameToSet.size.height = txtViewAttrOption.frame.size.height;
                if (frameToSet.size.height > 58) {
                    viewOption.frame = frameToSet;
                }
                
                //                [viewOption setBackgroundColor:[UIColor blueColor]];
                
                
                //Set proper validator image proper images to button states
                UIImageView* imgValidator = (UIImageView*)[viewOption viewWithTag:11*MULTIPLIER_VALIDATOR];
                UIButton* btnOption = (UIButton*)[viewOption viewWithTag:11*MULTIPLIER_OPTION_BTN];
                
                //Experimental centering
                [txtViewAttrOption setCenter:CGPointMake(txtViewAttrOption.center.x, btnOption.center.y)];
                
                UILabel* lblLetter = (UILabel*)[viewOption viewWithTag:111];
                [lblLetter setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1]];
                
                if (forSummaryPage) {
                    [btnOption setHidden:TRUE];
                    
                }else{
                    [btnOption setHidden:FALSE];
                    
                }

                
 
                if ([[[arrAnswers objectAtIndex:i] valueForKey:@"isCorrect"] intValue] == 1) {
                    [imgValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"1" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        [lblLetter setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1]];
                        [imgValidator setHidden:FALSE];
                        
                        
                    }
                    
                    if ([[dictQuestionData valueForKey:QUESTION_CORRECTANSWER] isEqual:@"NA"]) {
                        NSLog(@"dictQuestionData before: %@",[dictQuestionData description]);
                        //                        [arrQuestionData insertObject:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] atIndex:GET_RESOURCE_RIGHTANSWER];
                        
                        [dictQuestionData setValue:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] forKey:QUESTION_CORRECTANSWER];
                        
                        NSLog(@"dictQuestionData after: %@",[dictQuestionData description]);
                    }
                    
                }else{
                    [imgValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
//                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"0" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        if ([[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] isEqualToString:[dictQuestionData valueForKey:QUESTION_USERANSWER]]) {
                            
                            [lblLetter setTextColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:59.0/255.0 alpha:1]];
                            [imgValidator setHidden:FALSE];
                            
                            
                        }
                    }
                }
                
                break;
            }
                
                
            case 2:{
                NSLog(@"Option 2");
                
                UIView* viewOption = (UIView*)[scrollViewQuestionRhs viewWithTag:22];
                viewOption.hidden = false;
                
                btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, viewOption.frame.origin.y + viewOption.frame.size.height + 25, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);
                
                
                
                UILabel* lblOption1 = (UILabel*)[viewOption viewWithTag:22*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
                [lblOption1 setText:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"]];
                
                NSMutableDictionary* dictParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"22",@"Tag",[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"],@"AnswerText", nil];
                
                DTAttributedTextView* txtViewAttrOption = [self makeOptionViewForParameters:dictParameters forSummaryPage:forSummaryPage];
                
                [viewOption addSubview:txtViewAttrOption];
                frameToSet = viewOption.frame;
                frameToSet.size.height = txtViewAttrOption.frame.size.height;
                
                if (frameToSet.size.height > 58) {
                    viewOption.frame = frameToSet;
                }
                
                //                [viewOption setBackgroundColor:[UIColor blueColor]];
                
                //Set proper validator image proper images to button states
                UIImageView* imgValidator = (UIImageView*)[viewOption viewWithTag:22*MULTIPLIER_VALIDATOR];
                UIButton* btnOption = (UIButton*)[viewOption viewWithTag:22*MULTIPLIER_OPTION_BTN];
                
                //Experimental centering
                [txtViewAttrOption setCenter:CGPointMake(txtViewAttrOption.center.x, btnOption.center.y)];
            
                UILabel* lblLetter = (UILabel*)[viewOption viewWithTag:111];
                [lblLetter setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1]];
                
                if (forSummaryPage) {
                    [btnOption setHidden:TRUE];
                    
                }else{
                    [btnOption setHidden:FALSE];
                    
                }


                
                if ([[[arrAnswers objectAtIndex:i] valueForKey:@"isCorrect"] intValue] == 1) {
                    [imgValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
//                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"1" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        [lblLetter setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1]];
                        [imgValidator setHidden:FALSE];
                        
                    }

                    
                    if ([[dictQuestionData valueForKey:QUESTION_CORRECTANSWER] isEqual:@"NA"]) {
                        NSLog(@"dictQuestionData before: %@",[dictQuestionData description]);
                        //                        [arrQuestionData insertObject:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] atIndex:GET_RESOURCE_RIGHTANSWER];
                        
                        [dictQuestionData setValue:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] forKey:QUESTION_CORRECTANSWER];
                        
                        NSLog(@"dictQuestionData after: %@",[dictQuestionData description]);
                    }
                    
                    
                    
                }else{
                    [imgValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
//                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"0" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        if ([[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] isEqualToString:[dictQuestionData valueForKey:QUESTION_USERANSWER]]) {
                            
                            [lblLetter setTextColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:59.0/255.0 alpha:1]];
                            [imgValidator setHidden:FALSE];
                            
                            
                        }
                    }
                    
                }
                
                break;
            }
                
                
                
                
            case 3:{
                NSLog(@"Option 3");
                
                UIView* viewOption = (UIView*)[scrollViewQuestionRhs viewWithTag:33];
                viewOption.hidden = false;
                
                btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, viewOption.frame.origin.y + viewOption.frame.size.height + 25, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);
                
                UILabel* lblOption1 = (UILabel*)[viewOption viewWithTag:33*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
                [lblOption1 setText:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"]];
                
                //Rich Text!
                NSMutableDictionary* dictParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"33",@"Tag",[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"],@"AnswerText", nil];
                
                DTAttributedTextView* txtViewAttrOption = [self makeOptionViewForParameters:dictParameters forSummaryPage:forSummaryPage];
                
                [viewOption addSubview:txtViewAttrOption];
                frameToSet = viewOption.frame;
                frameToSet.size.height = txtViewAttrOption.frame.size.height;
                if (frameToSet.size.height > 58) {
                    viewOption.frame = frameToSet;
                }
                
                //                [viewOption setBackgroundColor:[UIColor blueColor]];
                
                //Set proper validator image proper images to button states
                UIImageView* imgValidator = (UIImageView*)[viewOption viewWithTag:33*MULTIPLIER_VALIDATOR];
                UIButton* btnOption = (UIButton*)[viewOption viewWithTag:33*MULTIPLIER_OPTION_BTN];
                
                //Experimental centering
                [txtViewAttrOption setCenter:CGPointMake(txtViewAttrOption.center.x, btnOption.center.y)];
                
                UILabel* lblLetter = (UILabel*)[viewOption viewWithTag:111];
                [lblLetter setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1]];
                
                if (forSummaryPage) {
                    [btnOption setHidden:TRUE];
                    
                }else{
                    [btnOption setHidden:FALSE];
                    
                }


                
                if ([[[arrAnswers objectAtIndex:i] valueForKey:@"isCorrect"] intValue] == 1) {
                    [imgValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"1" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        [lblLetter setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1]];
                        [imgValidator setHidden:FALSE];
                        
                    }
                    
                    
                    if ([[dictQuestionData valueForKey:QUESTION_CORRECTANSWER] isEqual:@"NA"]) {
                        NSLog(@"dictQuestionData before: %@",[dictQuestionData description]);
                        //                        [arrQuestionData insertObject:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] atIndex:GET_RESOURCE_RIGHTANSWER];
                        
                        [dictQuestionData setValue:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] forKey:QUESTION_CORRECTANSWER];
                        
                        NSLog(@"dictQuestionData after: %@",[dictQuestionData description]);
                    }
                    
                }else{
                    [imgValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"0" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        if ([[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] isEqualToString:[dictQuestionData valueForKey:QUESTION_USERANSWER]]) {
                            
                            [lblLetter setTextColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:59.0/255.0 alpha:1]];
                            [imgValidator setHidden:FALSE];
                            
                            
                        }
                    }
                    
                }
                
                break;
            }
                
                
            case 4:{
                NSLog(@"Option 4");
                
                UIView* viewOption = (UIView*)[scrollViewQuestionRhs viewWithTag:44];
                viewOption.hidden = false;

                
                btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, viewOption.frame.origin.y + viewOption.frame.size.height + 25, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);
                
                UILabel* lblOption1 = (UILabel*)[viewOption viewWithTag:44*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
                [lblOption1 setText:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"]];
                
                //Rich Text!
                NSMutableDictionary* dictParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"44",@"Tag",[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"],@"AnswerText", nil];
                
                DTAttributedTextView* txtViewAttrOption = [self makeOptionViewForParameters:dictParameters forSummaryPage:forSummaryPage];
                
                [viewOption addSubview:txtViewAttrOption];
                frameToSet = viewOption.frame;
                frameToSet.size.height = txtViewAttrOption.frame.size.height;
                if (frameToSet.size.height > 58) {
                    viewOption.frame = frameToSet;
                }
                
                //                [viewOption setBackgroundColor:[UIColor blueColor]];
                
                //Set proper validator image proper images to button states
                UIImageView* imgValidator = (UIImageView*)[viewOption viewWithTag:44*MULTIPLIER_VALIDATOR];
                UIButton* btnOption = (UIButton*)[viewOption viewWithTag:44*MULTIPLIER_OPTION_BTN];
                
                //Experimental centering
                [txtViewAttrOption setCenter:CGPointMake(txtViewAttrOption.center.x, btnOption.center.y)];
                
                UILabel* lblLetter = (UILabel*)[viewOption viewWithTag:111];
                [lblLetter setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1]];
                
                if (forSummaryPage) {
                    [btnOption setHidden:TRUE];
                    
                }else{
                    [btnOption setHidden:FALSE];
                    
                }

                
                if ([[[arrAnswers objectAtIndex:i] valueForKey:@"isCorrect"] intValue] == 1) {
                    [imgValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"1" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        [lblLetter setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1]];
                        [imgValidator setHidden:FALSE];
                        
                    }
                    
                    if ([[dictQuestionData valueForKey:QUESTION_CORRECTANSWER] isEqual:@"NA"]) {
                        NSLog(@"dictQuestionData before: %@",[dictQuestionData description]);
                        //                        [arrQuestionData insertObject:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] atIndex:GET_RESOURCE_RIGHTANSWER];
                        
                        [dictQuestionData setValue:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] forKey:QUESTION_CORRECTANSWER];
                        
                        NSLog(@"dictQuestionData after: %@",[dictQuestionData description]);
                    }
                    
                }else{
                    [imgValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"0" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        if ([[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] isEqualToString:[dictQuestionData valueForKey:QUESTION_USERANSWER]]) {
                            
                            [lblLetter setTextColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:59.0/255.0 alpha:1]];
                            [imgValidator setHidden:FALSE];
                            
                            
                        }
                    }
                }
                
                break;
            }
                
            case 5:{
                NSLog(@"Option 5");
                
                UIView* viewOption = (UIView*)[scrollViewQuestionRhs viewWithTag:55];
                viewOption.hidden = false;

                
                btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, viewOption.frame.origin.y + viewOption.frame.size.height + 25, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);
                
                UILabel* lblOption1 = (UILabel*)[viewOption viewWithTag:55*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
                [lblOption1 setText:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"]];
                
                //Rich Text!
                NSMutableDictionary* dictParameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"55",@"Tag",[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"],@"AnswerText", nil];
                
                DTAttributedTextView* txtViewAttrOption = [self makeOptionViewForParameters:dictParameters forSummaryPage:forSummaryPage];
                
                [viewOption addSubview:txtViewAttrOption];
                frameToSet = viewOption.frame;
                frameToSet.size.height = txtViewAttrOption.frame.size.height;
                if (frameToSet.size.height > 58) {
                    viewOption.frame = frameToSet;
                }
                
                //                [viewOption setBackgroundColor:[UIColor blueColor]];
                
                //Set proper validator image proper images to button states
                UIImageView* imgValidator = (UIImageView*)[viewOption viewWithTag:55*MULTIPLIER_VALIDATOR];
                UIButton* btnOption = (UIButton*)[viewOption viewWithTag:55*MULTIPLIER_OPTION_BTN];
                
                //Experimental centering
                [txtViewAttrOption setCenter:CGPointMake(txtViewAttrOption.center.x, btnOption.center.y)];
                
                UILabel* lblLetter = (UILabel*)[viewOption viewWithTag:111];
                [lblLetter setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1]];
                
                if (forSummaryPage) {
                    [btnOption setHidden:TRUE];
                    
                }else{
                    [btnOption setHidden:FALSE];
                    
                }

                
                if ([[[arrAnswers objectAtIndex:i] valueForKey:@"isCorrect"] intValue] == 1) {
                    [imgValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"1" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        [lblLetter setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1]];
                        [imgValidator setHidden:FALSE];
                        
                    }
                    
                    if ([[dictQuestionData valueForKey:QUESTION_CORRECTANSWER] isEqual:@"NA"]) {
                        NSLog(@"dictQuestionData before: %@",[dictQuestionData description]);
                        //                        [arrQuestionData insertObject:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] atIndex:GET_RESOURCE_RIGHTANSWER];
                        
                        [dictQuestionData setValue:[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] forKey:QUESTION_CORRECTANSWER];
                        
                        NSLog(@"dictQuestionData after: %@",[dictQuestionData description]);
                    }
                    
                    
                }else{
                    [imgValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
                    [btnOption setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
                    [btnOption setTitle:@"0" forState:UIControlStateNormal];
                    
                    if (forSummaryPage) {
                        
                        if ([[[arrAnswers objectAtIndex:i] valueForKey:@"answerText"] isEqualToString:[dictQuestionData valueForKey:QUESTION_USERANSWER]]) {
                            
                            [lblLetter setTextColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:59.0/255.0 alpha:1]];
                            [imgValidator setHidden:FALSE];
                            
                            
                        }
                    }
                }
                
                break;
            }
                
                
            default:
                break;
        }
        
        [dictAllResources setObject:dictQuestionData forKey:requiredKey];
    }
    
//    lbl_WVControl_resourceTitle.text = [arrQuestionData objectAtIndex:GET_RESOURCE_LABEL];
    
    view_Question.frame = CGRectMake(0, 0, view_Question.frame.size.width, view.frame.size.height);
    
    if (forSummaryPage) {
//        view_Question.frame = CGRectMake(0, 37, view.frame.size.width, view.frame.size.height);
    }
//    [view addSubview:view_Question];
    
    [view insertSubview:view_Question belowSubview:viewNarrationOverlay];
    
    [viewNarrationOverlay bringSubviewToFront:view_Question];

    
    [activityIndicatorResourceLoading stopAnimating];
    
    
    
}

-(DTAttributedTextView*)makeOptionViewForParameters:(NSMutableDictionary*)parameters forSummaryPage:(BOOL)forSummaryPage{
    
    NSLog(@"parameters : %@",[parameters description]);
    
    //Rich Text Support
    DTAttributedTextView* txtViewAttrOption = [[DTAttributedTextView alloc]initWithFrame:CGRectMake(110, 5, 371, 58)];
    txtViewAttrOption.textDelegate = self;
    [txtViewAttrOption.attributedTextContentView setTag:[[parameters valueForKey:@"Tag"] intValue]*MULTIPLIER_ANSWER_TEXT];
    
    [txtViewAttrOption setTag:[[parameters valueForKey:@"Tag"] intValue]*MULTIPLIER_ANSWER_TEXT];
    
    NSData *data = [[parameters valueForKey:@"AnswerText"]dataUsingEncoding:NSUTF8StringEncoding];
    // Set our builder to use the default native font face and size
    NSDictionary *builderOptions = @{
                                     DTDefaultFontFamily: @"Arial",
                                     DTDefaultFontSize:@"16",
                                     DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
                                     };
    
//    if (forSummaryPage) {
//        
//        builderOptions = @{
//                           DTDefaultFontFamily: @"Arial",
//                           DTDefaultFontSize:@"16",
//                           DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
//                           DTDefaultTextColor: [UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1],
//                           };
//
//        
//    }else{
//        
//        builderOptions = @{
//                           DTDefaultFontFamily: @"Arial",
//                           DTDefaultFontSize:@"16",
//                           DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
//                           DTDefaultTextColor: [UIColor blackColor],
//                           };
//
//        
//    }
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data options:builderOptions documentAttributes:nil];
    
    txtViewAttrOption.shouldDrawImages = YES;
    
    [txtViewAttrOption setAttributedString:attrString];
    
    
    //    [txtViewAttrOption setBackgroundColor:[UIColor greenColor]];
    
    CGSize size = [txtViewAttrOption.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:txtViewAttrOption.frame.size.width];
    
    CGRect frameToSet = txtViewAttrOption.frame;
    frameToSet.size.width = size.width;
    frameToSet.size.height = size.height;
    
    txtViewAttrOption.frame = frameToSet;
    
    
    
    
    return txtViewAttrOption;
    
}

-(void)setUpHintsAndExplanationWithHintsData:(NSArray*)arrHints andExplanationData:(NSString*)strExplanation{
    
    NSLog(@"arrHints : %@",[arrHints description]);
    NSLog(@"strExplanation : %@",strExplanation);
//    int topMarginYordinate = 92;
//    int optionHeight = 73;
    
    //Set Check Answer Frame
//    btnCheckAnswer.frame = CGRectMake(btnCheckAnswer.frame.origin.x, (optionHeight*noOfOptions) + 95, btnCheckAnswer.frame.size.width, btnCheckAnswer.frame.size.height);
    NSLog(@"noOfOptions : %i",noOfOptions);
    
    if ([imgViewQuestionImage isHidden]) {
        viewHints.frame  = CGRectMake(viewHints.frame.origin.x, lblQuestionText.frame.origin.y + lblQuestionText.frame.size.height + 20, viewHints.frame.size.width, viewHints.frame.size.height);
    }else{
        viewHints.frame  = CGRectMake(viewHints.frame.origin.x, imgViewQuestionImage.frame.origin.y + imgViewQuestionImage.frame.size.height + 20, viewHints.frame.size.width, viewHints.frame.size.height);
    }
    
    
    viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewHints.frame.origin.y + viewHints.frame.size.height + 25, viewExplanation.frame.size.width, viewExplanation.frame.size.height);
    
    //Temporarily Store Hints according to sequence
    noOfHints1 = [arrHints count];
    
    //    NSMutableArray* arrHintText = [[NSMutableArray alloc] initWith];
    NSMutableDictionary* dictHintText = [[NSMutableDictionary alloc] init];
    for (int i=0; i<noOfHints1; i++) {
        
        [dictHintText setValue:[[arrHints objectAtIndex:i] valueForKey:@"hintText"] forKey:[[[arrHints objectAtIndex:i] valueForKey:@"sequence"] stringValue]];
        
    }
    
    //Set Hints Button Title Label
    [lblBtnHints setText:[NSString stringWithFormat:@"Hints (%i left)",noOfHints1]];
    [btnHints setTitle:[NSString stringWithFormat:@"%i",noOfHints1] forState:UIControlStateNormal];
    
    //    [viewHints setBackgroundColor:[UIColor greenColor]];
    
    //Populate Hints into labels
    
    
    if (noOfHints1 == 0) {
        btnHints.enabled = FALSE;
        [lblBtnHints setTextColor:[UIColor colorWithRed:153.0/225.0 green:153.0/225.0 blue:153.0/225.0 alpha:1.0]];
    }else{
        [btnHints setEnabled:TRUE];
    }
    
    int lastYordinateHints = btnHints.frame.size.height + 16;
    for (int i = 0; i < noOfHints1; i++) {
        
        DTAttributedTextView* attrTxtViewHint = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, lastYordinateHints, viewHints.frame.size.width, 20)];
        attrTxtViewHint.textDelegate = self;
        [attrTxtViewHint.attributedTextContentView setTag:(i+1)*MULTIPLIER_HINT_ATTR_LABEL];
        
        NSData *data = [[NSString stringWithFormat:@"Hint %i: %@",i+1,[dictHintText valueForKey:[NSString stringWithFormat:@"%i",i+1]]] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *builderOptions = @{
                                         DTDefaultFontFamily: @"Arial",
                                         DTDefaultFontSize:@"16",
                                         DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
                                         };
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data options:builderOptions documentAttributes:nil];
        [attrTxtViewHint setAttributedString:attrString];
        //        [attrTxtViewHint setBackgroundColor:[UIColor brownColor]];
        [viewHints addSubview:attrTxtViewHint];
        
        CGSize size = [attrTxtViewHint.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:attrTxtViewHint.frame.size.width];
        
        CGRect frameToSet = attrTxtViewHint.frame;
        frameToSet.size.height = size.height;
        
        attrTxtViewHint.frame = frameToSet;
        
        lastYordinateHints = lastYordinateHints + attrTxtViewHint.frame.size.height + 15;
        
        
        
        
    }
    
    
    if ([strExplanation isEqualToString:@"NA"] || [strExplanation isEqualToString:@""]) {
        [btnExplanation setEnabled:FALSE];
    }else{
        [btnExplanation setEnabled:TRUE];
    }
    
    NSLog(@"Populate Explanation into label");
    
    DTAttributedTextView* attrTxtViewExplanation = [[DTAttributedTextView alloc] initWithFrame:CGRectMake(0, btnExplanation.frame.size.height + 16, viewHints.frame.size.width, 20)];
    attrTxtViewExplanation.textDelegate = self;
    [attrTxtViewExplanation.attributedTextContentView setTag:2123];
    
    NSData *data = [strExplanation dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *builderOptions = @{
                                     DTDefaultFontFamily: @"Arial",
                                     DTDefaultFontSize:@"16",
                                     DTUseiOS6Attributes: [NSNumber numberWithBool:YES],
                                     };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithHTMLData:data options:builderOptions documentAttributes:nil];
    [attrTxtViewExplanation setAttributedString:attrString];
    //    [attrTxtViewExplanation setBackgroundColor:[UIColor brownColor]];
    [viewExplanation addSubview:attrTxtViewExplanation];
    
    CGSize size = [attrTxtViewExplanation.attributedTextContentView suggestedFrameSizeToFitEntireStringConstraintedToWidth:attrTxtViewExplanation.frame.size.width];
    
    CGRect frameToSet = attrTxtViewExplanation.frame;
    frameToSet.size.height = size.height;
    
    attrTxtViewExplanation.frame = frameToSet;
    
    [scrollViewQuestionLhs setContentSize:CGSizeMake(scrollViewQuestionLhs.frame.size.width, (viewExplanation.frame.origin.y + viewExplanation.frame.size.height)+ 20)];
    
    
}

- (IBAction)btnAction_answerOptions:(id)sender {
    
    UIButton *btnOptionPressed= (UIButton*)sender;
    NSLog(@"The button title is %@ ", btnOptionPressed.titleLabel.text);
    
    UIView* viewOption = [btnOptionPressed superview];
    
    NSArray* keys = [self sortedIntegerKeysForDictionary:dictAllResources];
    NSString* requiredKey = [keys objectAtIndex:carousel.currentItemIndex];
    
    NSMutableDictionary* dictQuestionInfo = [dictAllResources valueForKey:requiredKey];
    UILabel* lblAnswerSelected = (UILabel*)[viewOption viewWithTag:viewOption.tag*MULTIPLIER_ANSWER_TEXT+ADDITIVE_ANSWER_TEXT_LABEL];
    
    //    [arrQuestionInfo insertObject:lblAnswerSelected.text atIndex:GET_RESOURCE_USERANSWER];
    [dictQuestionInfo setValue:lblAnswerSelected.text forKey:QUESTION_USERANSWER];
    
    [dictAllResources setValue:dictQuestionInfo forKey:requiredKey];
    
    NSLog(@"new question info : %@",[[dictAllResources valueForKey:requiredKey] valueForKey:QUESTION_USERANSWER]);
    
    [btnCheckAnswer setEnabled:TRUE];
    
    btnOptionSelected = (UIButton*)sender;
    
    [self manageAnswerOptionsButtonSelection:sender];
}


- (IBAction)btnActionCheckAnswer:(id)sender {
    
    UIView* optionView = [btnOptionSelected superview];
    
    int i = btnOptionSelected.tag/(ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_OPTION_BTN);
    int tagValidatorView = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_VALIDATOR;
    
    UIImageView* validatorViewToHideUnhide = (UIImageView*)[optionView viewWithTag:tagValidatorView];
    
    [validatorViewToHideUnhide setHidden:FALSE];
    
    if ([btnOptionSelected.titleLabel.text isEqualToString:@"1"]) {
        
        [btnOptionSelected setImage:[UIImage imageNamed:@"Answer_correct@2x.png"] forState:UIControlStateSelected];
       
    }else{
        
        [btnOptionSelected setImage:[UIImage imageNamed:@"Answer_incorrect@2x.png"] forState:UIControlStateSelected];
        
        [imgViewAnswerComment setFrame:CGRectMake(btnCheckAnswer.frame.origin.x, btnCheckAnswer.frame.origin.y + btnCheckAnswer.frame.size.height + 20, imgViewAnswerComment.frame.size.width, imgViewAnswerComment.frame.size.height)];
        
//        [self shouldHideView:imgViewAnswerComment :FALSE];
        [imgViewAnswerComment setImage:[UIImage imageNamed:@"lblWrongAnswer.png"]];
    }
}

- (void)manageAnswerOptionsButtonSelection:(id)sender{
    
    for (int i = 1; i < 6; i++) {
        
        int tagBtn = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_OPTION_BTN;
        int tagValidatorView = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_VALIDATOR;
        
        UIView* optionView = (UIView*)[scrollViewQuestionRhs viewWithTag:ANSWER_OPTIONVIEW_TAG_START*i];
        UIButton* btnToSelectDeselect = (UIButton*)[optionView viewWithTag:tagBtn];
        UIImageView* validatorViewToHideUnhide = (UIImageView*)[optionView viewWithTag:tagValidatorView];
        
        UILabel* lblOption = (UILabel*)[optionView viewWithTag:111];
        
        [btnToSelectDeselect setImage:[UIImage imageNamed:@"btnOptionSelected.png"] forState:UIControlStateSelected];
        
//        [self shouldHideView:imgViewAnswerComment :TRUE];
        
        if (tagBtn != [sender tag]) {
            
            [btnToSelectDeselect setSelected:FALSE];
            validatorViewToHideUnhide.hidden = TRUE;
            [lblOption setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            
            
        }else{
            
            [btnToSelectDeselect setSelected:TRUE];
            [lblOption setTextColor:[UIColor whiteColor]];
            //            validatorViewToHideUnhide.hidden = FALSE;
            
        }
        
        
    }
    
}

- (IBAction)btnActionOESubmit:(id)sender {
    

    NSString *strToCheck = [txtViewOEAnswer.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if ([sender isEnabled]) {
        if (strToCheck == (id)[NSNull null] || strToCheck == NULL || [strToCheck  isEqual: @""]) {
            
           // [self.view makeToast:@"Answer text should not be empty." duration:3.0 pointPosition:CGPointMake(564, 600)];
            [self shouldHideView: lblEmptyText : FALSE];
            
            
        }else{
        
        NSArray* keys = [self sortedIntegerKeysForDictionary:dictAllResources];
        
        NSString* requiredKey = [keys objectAtIndex:carousel.currentItemIndex];
        
        NSMutableDictionary* dictQuestionInfo = [dictAllResources valueForKey:requiredKey];
        
        [dictQuestionInfo setValue:txtViewOEAnswer.text forKey:QUESTION_USERANSWER];
        
        [dictAllResources setValue:dictQuestionInfo forKey:requiredKey];
        [sender setEnabled:FALSE];
        
        [txtViewOEAnswer setEditable:FALSE];
        

    }
    
    }
    
    
    
}




- (IBAction)btnAction_hints:(id)sender {
    
    UIButton *btnHint= (UIButton*)sender;
    NSLog(@"The btnHints title is %@ ", btnHint.titleLabel.text);
    
    int int_btnHintTitle = [btnHint.titleLabel.text intValue];
    NSLog(@"int_btnHintTitle %i ", int_btnHintTitle);
    
    int hintCountToShow = noOfHints1 - (int_btnHintTitle -1);
    NSLog(@"hintCountToShow %i ", hintCountToShow);
    
    for (UIView *aView in [viewHints subviews]){
        
        if ([aView isKindOfClass:[DTAttributedTextView class]]) {
            
            DTAttributedTextView* attrTxtViewHint = (DTAttributedTextView*)aView;
            
            NSLog(@"attrStr : %@",[NSString stringWithFormat:@"%@", attrTxtViewHint.attributedString]);
            
            
            NSRange range = [[NSString stringWithFormat:@"%@", attrTxtViewHint.attributedString] rangeOfString:[NSString stringWithFormat:@"Hint %i",hintCountToShow]];
            
            if (range.location != NSNotFound) {
                
                NSLog(@"Range Found!");
                [self expandHintsViewTo:attrTxtViewHint.frame.origin.y + attrTxtViewHint.frame.size.height];
                
                int_btnHintTitle--;
                [btnHint setTitle:[NSString stringWithFormat:@"%i",int_btnHintTitle]  forState:UIControlStateNormal];
                
                [lblBtnHints setText:[NSString stringWithFormat:@"Hints (%i left)",int_btnHintTitle]];
                [lblBtnHints setTextColor:[UIColor colorWithRed:16.0/225.0 green:118.0/225.0 blue:186.0/225.0 alpha:1.0]];
                
                if (int_btnHintTitle == 0) {
                    btnHints.enabled = FALSE;
                    [lblBtnHints setTextColor:[UIColor colorWithRed:153.0/225.0 green:153.0/225.0 blue:153.0/225.0 alpha:1.0]];
                }
                
            }
            
        }
        
        
    }
    
    
}

- (IBAction)btnAction_explanation:(id)sender {
    
    int yOrdinateToExpandTo = 0;
    
    for (UIView *aView in [viewExplanation subviews]){
        
        if ([aView isKindOfClass:[DTAttributedTextView class]]) {
            
            yOrdinateToExpandTo = aView.frame.origin.y + aView.frame.size.height;
            
        }
        
    }
    
    btnExplanation.enabled = FALSE;
    [self expandExplanationViewTo:yOrdinateToExpandTo];
    
}

- (void)expandHintsViewTo:(int)yOrdinate{
    
    
    viewHints.frame = CGRectMake(viewHints.frame.origin.x, viewHints.frame.origin.y, viewHints.frame.size.width, viewHints.frame.size.height);
    viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewExplanation.frame.origin.y, viewExplanation.frame.size.width, viewExplanation.frame.size.height);
    //    [scrollViewQuestionRhs setContentSize:CGSizeMake(scrollViewQuestionRhs.frame.size.width,scrollViewQuestionRhs.frame.size.height)];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    
    viewHints.frame = CGRectMake(viewHints.frame.origin.x, viewHints.frame.origin.y, viewHints.frame.size.width, yOrdinate);
    viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewHints.frame.origin.y + viewHints.frame.size.height + 10, viewExplanation.frame.size.width, viewExplanation.frame.size.height);
    
    
    
    
    [UIView commitAnimations];
    
    [scrollViewQuestionLhs setContentSize:CGSizeMake(scrollViewQuestionLhs.frame.size.width, (viewExplanation.frame.origin.y + viewExplanation.frame.size.height)+ 20)];
    
    
    
    
    [self autoScrollToEndForScrollView:scrollViewQuestionLhs];
    
    
    
    
    
    
    
}

- (void)expandExplanationViewTo:(int)yOrdinate{
    
    
    
    viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewExplanation.frame.origin.y, viewExplanation.frame.size.width, viewExplanation.frame.size.height);
    [scrollViewQuestionLhs setContentSize:CGSizeMake(scrollViewQuestionLhs.frame.size.width,scrollViewQuestionLhs.frame.size.height)];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    
    viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewExplanation.frame.origin.y, viewExplanation.frame.size.width, yOrdinate);
    [scrollViewQuestionLhs setContentSize:CGSizeMake(scrollViewQuestionLhs.frame.size.width, (viewExplanation.frame.origin.y + viewExplanation.frame.size.height) - scrollViewQuestionLhs.frame.origin.y +20 )];
    
    [UIView commitAnimations];
    
    
    [self autoScrollToEndForScrollView:scrollViewQuestionLhs];
    //    [self performSelector:@selector(autoScrollToEndForScrollView:) withObject:scrollViewQuestionRhs afterDelay:0.4];
    
    
}

-(void)autoScrollToEndForScrollView:(UIScrollView*)scrollView{
    
    NSLog(@"scrollView.contentSize.height : %f",scrollView.contentSize.height);
    NSLog(@"scrollView.frame.size.height : %f",scrollView.frame.size.height);
    NSLog(@"scrollView.contentOffset.y : %f",scrollView.contentOffset.y);
    NSLog(@"view_Question.frame.size.height : %f",view_Question.frame.size.height);
    NSLog(@"webView.frame.size.height : %f",[view_Question superview].frame.size.height);
    
    if (scrollView.contentSize.height > scrollView.frame.size.height) {
        
        
        
        //        float x= scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height;
        //        CGPoint bottomOffset = CGPointMake(0, scrollView.contentOffset.y + x);
        
        //        CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.frame.size.height);
        
        CGPoint bottomOffset = CGPointMake(0, scrollView.contentSize.height - scrollView.bounds.size.height);
        
        [scrollView setContentOffset:bottomOffset animated:YES];
        
        
    }
    
}



-(void)resetQuestionTemplate{
    
    for (int i = 1; i < 6; i++) {
        
        int tagBtn = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_OPTION_BTN;
        int tagValidatorView = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_VALIDATOR;
        int tagTxtViewAttrOption = i*ANSWER_OPTIONVIEW_TAG_START*MULTIPLIER_ANSWER_TEXT;
        
        UIView* optionView = (UIView*)[scrollViewQuestionRhs viewWithTag:ANSWER_OPTIONVIEW_TAG_START*i];
        UIButton* btnToSelectDeselect = (UIButton*)[optionView viewWithTag:tagBtn];
        UIImageView* validatorViewToHideUnhide = (UIImageView*)[optionView viewWithTag:tagValidatorView];
        
        DTAttributedTextView* txtViewAttrOption = (DTAttributedTextView*)[optionView viewWithTag:tagTxtViewAttrOption];
        [txtViewAttrOption setTextDelegate:nil];
        [txtViewAttrOption removeFromSuperview];
        
        validatorViewToHideUnhide.hidden = TRUE;
        [btnToSelectDeselect setSelected:FALSE];
        optionView.hidden = TRUE;
        
        UILabel* lblOption = (UILabel*)[optionView viewWithTag:111];
        
        [lblOption setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
        
        
        
    }
    [txtViewAttrQuestionText setTextDelegate:nil];
    [txtViewAttrQuestionText removeFromSuperview];
    
    for (int i=0; i<5; i++) {
        UIView* viewOptions = [scrollViewQuestionRhs viewWithTag:(i+1)*11];
        CGRect frameToSet = viewOptions.frame;
        
        frameToSet.size.height = 58;
        frameToSet.origin.y = 93+(73*i);
        
        viewOptions.frame = frameToSet;
    }
    
    //Reset Check Answer
    [btnCheckAnswer setEnabled:FALSE];
    [btnCheckAnswer setHidden:TRUE];
    
    [imgViewAnswerComment setHidden:TRUE];

    //Reset OE
    [viewOEQuestion setHidden:TRUE];
    [btnOESubmit setEnabled:TRUE];
    [self shouldHideView:lblCharLimit :TRUE];
    [self shouldHideView:lblEmptyText : TRUE];
    
    
    
    //Reset Hints
    btnHints.enabled = TRUE;
    [lblBtnHints setTextColor:[UIColor colorWithRed:16.0/225.0 green:118.0/225.0 blue:186.0/225.0 alpha:1.0]];
    viewHints.frame = CGRectMake(viewHints.frame.origin.x, viewHints.frame.origin.y, viewHints.frame.size.width, 40);
    
    for (UIView* aView in [viewHints subviews]) {
        if([aView isKindOfClass:[DTAttributedTextView class]]){
            DTAttributedTextView* viewHint = (DTAttributedTextView*)aView;
            
            [viewHint setTextDelegate:nil];
            [aView removeFromSuperview];
        }
        
    }
    
    //Reset Explanations
    btnExplanation.enabled = TRUE;
    viewExplanation.frame = CGRectMake(viewHints.frame.origin.x, viewHints.frame.origin.y, viewHints.frame.size.width, btnExplanation.frame.size.height);
    
    //Reset scrollViewQuestionRhs
    [scrollViewQuestionRhs setContentSize:CGSizeMake(scrollViewQuestionRhs.frame.size.width, scrollViewQuestionRhs.frame.size.height)];
}

#pragma mark - Rich Text Delegate -

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttributedString:(NSAttributedString *)string frame:(CGRect)frame{
	
	NSLog(@"viewForAttributedString delegate");
    
	NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:NULL];
	
	NSURL *URL = [attributes objectForKey:DTLinkAttribute];
	NSString *identifier = [attributes objectForKey:DTGUIDAttribute];
	
	
	DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:frame];
	button.URL = URL;
	button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
	button.GUID = identifier;
	
	// get image with normal link text
	UIImage *normalImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDefault];
	[button setImage:normalImage forState:UIControlStateNormal];
	
	// get image for highlighted link text
	UIImage *highlightImage = [attributedTextContentView contentImageWithBounds:frame options:DTCoreTextLayoutFrameDrawingDrawLinksHighlighted];
	[button setImage:highlightImage forState:UIControlStateHighlighted];
	
	// use normal push action for opening URL
	[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
	
	// demonstrate combination with long press
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
	[button addGestureRecognizer:longPress];
	
	return button;
}

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView viewForAttachment:(DTTextAttachment *)attachment frame:(CGRect)frame{
	
    NSLog(@"viewForAttachment delegate : %i",attributedTextContentView.tag);
	if ([attachment isKindOfClass:[DTImageTextAttachment class]])
	{
		// if the attachment has a hyperlinkURL then this is currently ignored
		DTLazyImageView *imageView = [[DTLazyImageView alloc] initWithFrame:frame];
		imageView.delegate = self;
        
		// sets the image if there is one
		imageView.image = [(DTImageTextAttachment *)attachment image];
		
		// url for deferred loading
		imageView.url = attachment.contentURL;
        
        //        [imageView setBackgroundColor:[UIColor redColor]];
		
		// if there is a hyperlink then add a link button on top of this image
		if (attachment.hyperLinkURL)
		{
			// NOTE: this is a hack, you probably want to use your own image view and touch handling
			// also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
			imageView.userInteractionEnabled = YES;
			
			DTLinkButton *button = [[DTLinkButton alloc] initWithFrame:imageView.bounds];
			button.URL = attachment.hyperLinkURL;
			button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
			button.GUID = attachment.hyperLinkGUID;
			
			// use normal push action for opening URL
			[button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
			
			// demonstrate combination with long press
			UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(linkLongPressed:)];
			[button addGestureRecognizer:longPress];
			
			[imageView addSubview:button];
		}
        
		return imageView;
	}
	else if ([attachment isKindOfClass:[DTIframeTextAttachment class]])
	{
		DTWebVideoView *videoView = [[DTWebVideoView alloc] initWithFrame:frame];
		videoView.attachment = attachment;
		
		return videoView;
	}
	else if ([attachment isKindOfClass:[DTObjectTextAttachment class]])
	{
		// somecolorparameter has a HTML color
		NSString *colorName = [attachment.attributes objectForKey:@"somecolorparameter"];
		UIColor *someColor = [UIColor colorWithHTMLName:colorName];
		
		UIView *someView = [[UIView alloc] initWithFrame:frame];
		someView.backgroundColor = someColor;
		someView.layer.borderWidth = 1;
		someView.layer.borderColor = [UIColor blackColor].CGColor;
		
		someView.accessibilityLabel = colorName;
		someView.isAccessibilityElement = YES;
		
		return someView;
	}
	
	return nil;
}

- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
{
    NSLog(@"shouldDrawBackgroundForTextBlock delegate");
	UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(frame,1,1) cornerRadius:10];
    
	CGColorRef color = [textBlock.backgroundColor CGColor];
	if (color)
	{
		CGContextSetFillColorWithColor(context, color);
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextFillPath(context);
		
		CGContextAddPath(context, [roundedRect CGPath]);
		CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
		CGContextStrokePath(context);
		return NO;
	}
	
	return YES; // draw standard background
}

#pragma mark DTLazyImageViewDelegate


- (void)lazyImageView:(DTLazyImageView *)lazyImageView didChangeImageSize:(CGSize)size {
    
    DTAttributedTextView* attributedTextView = (DTAttributedTextView*)[[lazyImageView superview] superview];
    
	NSURL *url = lazyImageView.url;
	CGSize imageSize = size;
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"contentURL == %@", url];
	
	BOOL didUpdate = NO;
	
	// update all attachments that matchin this URL (possibly multiple images with same size)
	for (DTTextAttachment *oneAttachment in [attributedTextView.attributedTextContentView.layoutFrame textAttachmentsWithPredicate:pred])
	{
		// update attachments that have no original size, that also sets the display size
		if (CGSizeEqualToSize(oneAttachment.originalSize, CGSizeZero))
		{
			oneAttachment.originalSize = imageSize;
			
			didUpdate = YES;
		}
	}
    
	if (didUpdate)
	{
        NSLog(@"relayout! : %i",attributedTextView.attributedTextContentView.tag);
        [attributedTextView relayoutText];
        NSLog(@"relayout!");
	}
}

#pragma mark Notification to layout Rich text view

-(void)relayoutRichTextViews:(NSNotification*)notification{
    
    NSLog(@"Notification Object : %@",notification.object);
    NSDictionary* dictReturn = notification.userInfo;
    
    DTAttributedTextView* attributedTextView = (DTAttributedTextView*)[notification.object superview];
    
    CGRect frame = attributedTextView.frame;
    frame.size.height = [[dictReturn valueForKey:@"OptimalFrame"] CGRectValue].size.height;
    attributedTextView.frame = frame;
    
    if (attributedTextView.attributedTextContentView.tag == TAG_QUESTION_TEXT) {
        
        //Question Image
        imgViewQuestionImage.frame = CGRectMake(imgViewQuestionImage.frame.origin.x, attributedTextView.frame.origin.y + attributedTextView.frame.size.height + 21, imgViewQuestionImage.frame.size.width, imgViewQuestionImage.frame.size.height);
        
        if (![imgViewQuestionImage isHidden]) {
            
            
            
            viewHints.frame  = CGRectMake(viewHints.frame.origin.x, imgViewQuestionImage.frame.origin.y + imgViewQuestionImage.frame.size.height + 20, viewHints.frame.size.width, viewHints.frame.size.height);
            
            viewExplanation.frame = CGRectMake(viewExplanation.frame.origin.x, viewHints.frame.origin.y + viewHints.frame.size.height + 25, viewExplanation.frame.size.width, viewExplanation.frame.size.height);
            
            
            [scrollViewQuestionLhs setContentSize:CGSizeMake(scrollViewQuestionLhs.frame.size.width, (viewExplanation.frame.origin.y + viewExplanation.frame.size.height)+ 20)];

            
        }
        
        
        
    }else if(fmodf(attributedTextView.attributedTextContentView.tag, MULTIPLIER_ANSWER_TEXT) == 0){
        
        UIView* viewOption = [attributedTextView superview];
        
        frame = viewOption.frame;
        int initialYHeight = frame.size.height;
        frame.size.height = attributedTextView.frame.size.height;
        
        int finalYHeight = 58;
        if (frame.size.height > 58) {
            viewOption.frame = frame;
            finalYHeight = frame.size.height;
        }
        
        for (int i=1; i<6; i++) {
            
            UIView* viewOptions = [scrollViewQuestionRhs viewWithTag:i*11];
            
            if (viewOptions.tag > viewOption.tag) {
                
                CGRect frameToSet = viewOptions.frame;
                
                frameToSet.origin.y = frameToSet.origin.y - (initialYHeight - finalYHeight);
                
                viewOptions.frame = frameToSet;
            }
            
        }
        
        
        
        CGRect frameToSet = viewHints.frame;
        frameToSet.origin.y = frameToSet.origin.y - (initialYHeight - finalYHeight);
        if (finalYHeight == 58) {
            frameToSet.origin.y = frameToSet.origin.y + 10;
        }
        viewHints.frame = frameToSet;
        
        frameToSet = viewExplanation.frame;
        frameToSet.origin.y = frameToSet.origin.y - (initialYHeight - finalYHeight);
        if (finalYHeight == 58) {
            frameToSet.origin.y = frameToSet.origin.y + 10;
        }
        viewExplanation.frame = frameToSet;
        
        [scrollViewQuestionRhs setContentSize:CGSizeMake(scrollViewQuestionRhs.contentSize.width, viewExplanation.frame.origin.y + viewExplanation.frame.size.height)];
        
    }
    
    [self setAllFramesAndAdjustFor:notification.object];
    
}

-(void)setAllFramesAndAdjustFor:(DTAttributedTextContentView*)attributedTextContentView{
    
    DTAttributedTextView* attributedTextView = (DTAttributedTextView*)[attributedTextContentView superview];
    
    if (attributedTextContentView.tag == TAG_QUESTION_TEXT) {
        
    }else if(fmodf(attributedTextContentView.tag, MULTIPLIER_ANSWER_TEXT) == 0){
        
        //Answer Options
        
        UIView* viewToAdjust = [scrollViewQuestionRhs viewWithTag:attributedTextView.tag/MULTIPLIER_ANSWER_TEXT];
        CGRect frameToSet = viewToAdjust.frame;
        
        UIView* viewToFollow = [[UIView alloc] init];
        if (attributedTextView.tag != 1100) {
            viewToFollow = [scrollViewQuestionRhs viewWithTag:(attributedTextView.tag/MULTIPLIER_ANSWER_TEXT)-11];
            
            frameToSet.origin.y = viewToFollow.frame.origin.y + viewToFollow.frame.size.height + 15;
            
            viewToAdjust.frame = frameToSet;
        }
        
        
    }else{
        
        NSLog(@"Hints/Explanation : %i",attributedTextContentView.tag);
        
    }
}


#pragma mark - Prep/Deprep for Summary Page
-(void)prepForSummaryPageAndRender:(BOOL)value{
    
    if (value) {
        
        [viewNarrationOverlay removeFromSuperview];
        
        NSLog(@"Rendering Summary!");
        [self pauseVideoPlayerForIndex:previousIndex];
        [self manageSelector];
        
        [activityIndicatorResourceLoading stopAnimating];
        
        [lblResourceTitle setText:@"Collection Summary"];
        CGRect frame;
        frame = [self getWLabelFrameForLabel:lblResourceTitle withString:lblResourceTitle.text];
        if (frame.size.width>764) {
            lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y, 764, lblResourceTitle.frame.size.height);
            
        }else{
            lblResourceTitle.frame=CGRectMake(lblResourceTitle.frame.origin.x, lblResourceTitle.frame.origin.y,frame.size.width, lblResourceTitle.frame.size.height);
        }
        
        [self animateView:viewBottomBar forFinalFrame:CGRectMake(viewBottomBar.frame.origin.x, self.view.frame.size.height, viewBottomBar.frame.size.width, viewBottomBar.frame.size.height) inDuration:0.2];
        
        [self animateView:viewWebControls forFinalFrame:CGRectMake(viewWebControls.frame.origin.x, self.view.frame.size.height, viewWebControls.frame.size.width, viewWebControls.frame.size.height) inDuration:0.2];
        
        [self animateView:btnNarration forFinalFrame:CGRectMake(btnNarration.frame.origin.x, -btnNarration.frame.size.height, btnNarration.frame.size.width, btnNarration.frame.size.height) inDuration:0.3];
        
        SummaryPageViewController* summaryPageViewController = [[SummaryPageViewController alloc] initWithCollectionDetails:dictCollection andResourceDetails:dictAllResources andCollectionPlayerObject:self];
        [self swapCurrentControllerWith:summaryPageViewController];

    }else{
        NSLog(@"self.view.frame.size.height - viewBottomBar.frame.size.height : %f",viewBottomBar.superview.frame.size.width - viewBottomBar.frame.size.height);
        
        
        
        [self animateView:viewBottomBar forFinalFrame:CGRectMake(viewBottomBar.frame.origin.x, viewBottomBar.superview.frame.size.width - viewBottomBar.frame.size.height, viewBottomBar.frame.size.width, viewBottomBar.frame.size.height) inDuration:0.2];
        
        [self animateView:viewWebControls forFinalFrame:CGRectMake(viewWebControls.frame.origin.x, self.view.frame.size.height - viewWebControls.frame.size.height, viewWebControls.frame.size.width, viewWebControls.frame.size.height) inDuration:1.0];
        
        [self animateView:btnNarration forFinalFrame:CGRectMake(btnNarration.frame.origin.x, 0, btnNarration.frame.size.width, btnNarration.frame.size.height) inDuration:0.2];
        
        //Removing Summary Page
        [[[carousel itemViewAtIndex:[dictAllResources count]] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
    }
}


#pragma mark - Webview Delegates -
-(void)webViewDidStartLoad:(UIWebView *)webView{

    if (carousel.currentItemIndex != [dictAllResources count]) {
        NSLog(@"webViewDidStartLoad");
        [activityIndicatorResourceLoading startAnimating];
    }
   
    
}



-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    if (carousel.currentItemIndex != [dictAllResources count]) {
        NSLog(@"webview did finish");
        [activityIndicatorResourceLoading stopAnimating];
        
        [self updateWebviewControlFor:webView];

    }

       
//    NSRange range_ForPdf = [webView.request.URL.absoluteString rangeOfString:@".pdf"];
//    if (range_ForPdf.location != NSNotFound) {
//        
//        
//        [self performSelector:@selector(scrollPdf:) withObject:(UIWebView*)webView afterDelay:2.0f];
//        
//    }



}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
   [activityIndicatorResourceLoading stopAnimating];
}


#pragma mark - Webview Control -
#pragma mark Update Webview Control
-(void)updateWebviewControlFor:(UIWebView*)webview{
    
    if (carousel.currentItemIndex != [dictAllResources count]) {
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        //Get key for the resource to be Loaded
        NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
        
        //Hitting Dictionary For the Resource Details
        NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
        
        
        if (![[dictResourceInfo valueForKey:RESOURCE_URL] rangeOfString:@"docs.google.com"].length == 0)  {
            
            //        viewWebControls.hidden = FALSE;
            [self hideWebviewControls:FALSE];
            
            
        }else {
            
            //        viewWebControls.hidden = TRUE;
            [self hideWebviewControls:FALSE];
            
            
        }
        
        
        if (webview.canGoBack) {
            btnWebControlBack.enabled = TRUE;
        }else {
            btnWebControlBack.enabled = FALSE;
        }
        
        if (webview.canGoForward) {
            btnWebControlForward.enabled = TRUE;
        }else {
            btnWebControlForward.enabled = FALSE;
        }

    }
        
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

#pragma mark - Scroll PDFs -

-(void)scrollPdf:(UIWebView*)webView{
    
    //Get all Keys and sort
//    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
//    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
//    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
    
//    NSLog(@"Incoming Page to scroll : %i",[[arr_resourceInfo objectAtIndex:6] intValue]);
    
//    if ([[arr_resourceInfo objectAtIndex:6] intValue] < [[arr_resourceInfo objectAtIndex:8] intValue]){
//        
//        if ([[arr_resourceInfo objectAtIndex:6] intValue] > 1 ){
//            
//            NSRange range = [[arr_resourceInfo objectAtIndex:2] rangeOfString:@".pdf"];
//            
//            
//            if (range.location != NSNotFound) {
//                
//                float pageCount = 0;
//                float scrollPos = 0;
//                
//                pageCount = [[arr_resourceInfo objectAtIndex:8] floatValue];
//                NSLog(@"webView.scrollView total height :%f",webView.scrollView.contentSize.height);
//                scrollPos = [self getScrollPositionForPage:[arr_resourceInfo objectAtIndex:6] whereTotalHeight:webView.scrollView.contentSize.height andPageCount:pageCount];
//                
//                [webView.scrollView setContentOffset:CGPointMake(0, scrollPos) animated:YES];
//                
//            }
//        }
//    }
    
//    [appDelegate removeLibProgressView:mainContentView];
    //    btn_closeCollectionsPlay.enabled = TRUE;
}

-(float)getScrollPositionForPage:(NSString*)page whereTotalHeight:(float)totalHeight andPageCount:(double)pageCount{
    
    double scrollPos = 0;
    double pageSize = totalHeight/pageCount;
    double tempPageSize = 0;
    double errorFactor = modf (pageSize , &tempPageSize);
    
    NSLog(@"Splitting PageSize For Error Factor : %f = %f + %f ",pageSize,tempPageSize,errorFactor);
    NSLog(@"Start value for textbooks:%f",[page floatValue]);
    
    
    pageSize = tempPageSize;
    float error = errorFactor*[page floatValue];
    
    if ([page floatValue] != 0) {
        
        scrollPos = ([page floatValue]-1)*pageSize;
        scrollPos = scrollPos + error;
        
    }
    
    NSLog(@"scrolling to %f",scrollPos);
    
    if (totalHeight < scrollPos) {
        
        scrollPos = totalHeight - pageSize;
    }
    return scrollPos;
}

    


#pragma mark - BA Webview controls -
- (IBAction)btnActionWebviewGoBack:(id)sender {
    
    NSLog(@"webControl_goBack");
    
    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
    
    UIWebView* webview;
    
    for (UIView *aView in [view subviews]){
        if([aView isKindOfClass:[UIWebView class]]){
            webview = (UIWebView*)aView;
        }
    }
    
    [webview goBack];
    
}

- (IBAction)btnActionWebviewGoForward:(id)sender {
    
    NSLog(@"webControl_goForward");
    
    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
    
    UIWebView* webview;
    
    for (UIView *aView in [view subviews]){
        if([aView isKindOfClass:[UIWebView class]]){
            webview = (UIWebView*)aView;
        }
    }
    
    [webview goForward];
}

- (IBAction)btnActionWebviewReload:(id)sender {
    
    NSLog(@"webControl_reload");
    
    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
    
    UIWebView* webview;
    
    for (UIView *aView in [view subviews]){
        if([aView isKindOfClass:[UIWebView class]]){
            webview = (UIWebView*)aView;
        }
    }
    
    [webview reload];
}

#pragma mark - Reactions -
#pragma mark BA Reactions

- (IBAction)btnActionReaction:(id)sender {
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];

    
    [dictAllResources setValue:dictResourceInfo forKey:requiredKey];
    
    //Setting the Reaction
    if ([sender isSelected]) {
        [dictResourceInfo setValue:@"NA" forKey:RESOURCE_REACTION];
        [sender setSelected:FALSE];
    }else{
        [dictResourceInfo setValue:[NSString stringWithFormat:@"%i",[sender tag]] forKey:RESOURCE_REACTION];
        [sender setSelected:TRUE];
    }
    
    //Set Selected
    for (int i=0; i<5; i++) {
        
        UIButton* btnReaction = (UIButton*)[viewBottomBar viewWithTag:(i+1)*111];
        
        if (btnReaction.tag != [sender tag]) {
            [btnReaction setSelected:FALSE];
        }

    }

    [self manageReactionToastForReaction:sender];

    
    if ([sender isSelected]) {
        
        NSString *tempReaction;
        switch ([sender tag]) {
            case 111:
                tempReaction = @"i-can-explain";
                break;
            case 222:
                tempReaction = @"i-can-understand";
                break;
            case 333:
                tempReaction = @"meh";
                break;
            case 444:
                tempReaction = @"i-donot-understand";
                break;
            case 555:
                tempReaction = @"i-need-help";
                break;
            default:
                break;
        }
        
        //Mixpanel logReactionsforResource dictionary
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID] forKey:@"Resource Id"];
        [dictionary setObject:[dictResourceInfo valueForKey:RESOURCE_TITLE] forKey:@"Resource Title"];
        [appDelegate logMixpanelforevent:@"Reactions" and:dictionary];
        
        
        [self logReactionsforResource:[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID] withReaction:tempReaction];
        
    }
    
    

}



#pragma mark Log Reaction for resource
-(void)logReactionsforResource:(NSString*)gooruOid withReaction:(NSString*)reaction{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"data", nil];
    
    
    NSString* strFields = [NSString stringWithFormat:@"{\"target\" : {\"value\":\"content\"}, \"type\" : {\"value\":\"%@\"}, \"assocGooruOid\":\"%@\", \"context\" : \"{\\\"parentGooruId\\\" : \\\"%@\\\",\\\"contentGooruId\\\" : \\\"%@\\\"}\"}",reaction,gooruOid,collectionGooruId,gooruOid];
    
    
    
    
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:strFields, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/reaction?sessionToken=%@",sessionToken] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"logReactionsforResource Response : %@",responseStr);
        NSArray *results = [responseStr JSONValue];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
     
}

- (void)deleteReactionforResource:(NSString*)resourceActualId{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", nil];
    NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient deletePath:[NSString stringWithFormat:@"/gooruapi/rest/v2/reaction/%@?sessionToken=%@",resourceActualId,sessionToken] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"Response delete reaction : %@",responseStr);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
    
    
    
    
    
}

- (void)manageReactionToastForReaction:(id)sender{
    
    UIImageView* imgViewReactionToast = [[UIImageView alloc] init];
    
    UIButton* btnReaction  = (UIButton*)sender;
    
//    [viewBottomBar makeToast:nil duration:3.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x, btnReaction.frame.origin.y)] title:nil image:[UIImage imageNamed:@"cancel_btn.png"]];
    
    if ([sender isSelected]) {
        switch ([sender tag]) {
            case 111:{
                
                imgViewReactionToast.frame = CGRectMake(0, 0, 93, 36);
                [imgViewReactionToast setImage:[UIImage imageNamed:@"React1Toast@2x.png"]];
                
                [viewBottomBar makeGooruToast:nil duration:2.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x + 31, -20)] image:imgViewReactionToast];
                
                break;
            }
            case 222:{
                
                imgViewReactionToast.frame = CGRectMake(0, 0, 93, 36);
                [imgViewReactionToast setImage:[UIImage imageNamed:@"React2Toast@2x.png"]];
                [viewBottomBar makeGooruToast:nil duration:2.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x + 15, -20)] image:imgViewReactionToast];
                
                break;
            }
            case 333:{
                
                
                imgViewReactionToast.frame = CGRectMake(0, 0, 62, 36);
                [imgViewReactionToast setImage:[UIImage imageNamed:@"React3Toast@2x.png"]];
                [viewBottomBar makeGooruToast:nil duration:2.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x + 15, -20)] image:imgViewReactionToast];
                
                break;
            }
            case 444:{
                
                
                imgViewReactionToast.frame = CGRectMake(0, 0, 104, 36);
                [imgViewReactionToast setImage:[UIImage imageNamed:@"React4Toast@2x.png"]];
                [viewBottomBar makeGooruToast:nil duration:2.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x + 13, -20)] image:imgViewReactionToast];
                
                break;
            }
            case 555:{
                
                
                imgViewReactionToast.frame = CGRectMake(0, 0, 93, 36);
                [imgViewReactionToast setImage:[UIImage imageNamed:@"React5Toast@2x.png"]];
                [viewBottomBar makeGooruToast:nil duration:2.0 position:[NSValue valueWithCGPoint:CGPointMake(btnReaction.frame.origin.x - 2, -20)] image:imgViewReactionToast];
                
                break;
            }
            default:
                break;
        }

    }
    
    
}

#pragma mark Manage Reaction Visibilty
-(void)shouldShowReactions:(BOOL)value{
    
    if (value) {
        
        [self animateView:viewReactionBtnsParent forFinalFrame:CGRectMake(0, 0, viewReactionBtnsParent.frame.size.width, viewReactionBtnsParent.frame.size.height) inDuration:0.3];
        
    }else{
        
        [self animateView:viewReactionBtnsParent forFinalFrame:CGRectMake(-viewReactionBtnsParent.frame.size.width, 0, viewReactionBtnsParent.frame.size.width, viewReactionBtnsParent.frame.size.height) inDuration:0.3];
        
    }
}

#pragma mark Manage Reactions for resource
-(void)manageReactionsOnLoad{

    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];

    //Set Selected
    for (int i=0; i<5; i++) {
        
        UIButton* btnReaction = (UIButton*)[viewBottomBar viewWithTag:(i+1)*111];
        [btnReaction setSelected:FALSE];
        
    }
    
    if (![[dictResourceInfo valueForKey:RESOURCE_REACTION] isEqualToString:@"NA"]) {
        UIButton* btnReaction = (UIButton*)[viewBottomBar viewWithTag:[[dictResourceInfo valueForKey:RESOURCE_REACTION] intValue]];
        [btnReaction setSelected:TRUE];
    }
    
//    [self getReactionsforResourceId:[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID] forKey:requiredKey];

}

-(void)getReactionsforResourceId:(NSString*)resourceActualId forKey:(NSString*)requiredKey{
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
    
    if(isAnonymous){
        
        if (![[dictResourceInfo valueForKey:RESOURCE_REACTION] isEqualToString:@"NA"]) {
            UIButton* btnReaction = (UIButton*)[viewBottomBar viewWithTag:[[dictResourceInfo valueForKey:RESOURCE_REACTION] intValue]];
            [btnReaction setSelected:TRUE];
        }

        
        
    }else{
        NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/v2/content/%@/reaction?sessionToken=%@",serverUrl,resourceActualId,sessionToken];
        
        NSLog(@"StrURL Get Reaction : %@",strURL);
        
        NSURL *url = [NSURL URLWithString:serverUrl];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        [httpClient getPath:[NSString stringWithFormat:@"%@/gooruapi/rest/v2/content/%@/reaction?sessionToken=%@",serverUrl,resourceActualId,sessionToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            
            NSLog(@"Response Get Reaction : %@",responseStr);
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        }];

    }

}




#pragma mark - Share -

#pragma mark BA Share Collection
- (IBAction)btnActionShare:(id)sender {
    
    UIButton* btnShare = (UIButton*)sender;
    
    
    CGPoint center;
    
    center.x = btnShare.center.x;
//    center.y = 663;
    center.y = viewBottomBar.frame.origin.y - (viewRCChooser.frame.size.height/2);
      
    switch ([sender tag]) {
        case 111:{
            strShareTo = SHARE_FACEBOOK;
            imageEmail.hidden = TRUE;
            imageFacebookTwitter.hidden = FALSE;
            break;
        }
            
        case 222:{
            strShareTo = SHARE_TWITTER;
            imageEmail.hidden = TRUE;
            imageFacebookTwitter.hidden = FALSE;
            break;
        }
            
        case 333:{
            strShareTo = SHARE_EMAIL;
            center.x = btnShare.center.x;
            
            imageEmail.hidden = TRUE;
            imageFacebookTwitter.hidden = FALSE;

            
            break;
        }
            
        case 444:{
            strShareTo = FLAG;
            center.x = btnShare.center.x - 40;
            
            imageEmail.hidden = FALSE;
            imageFacebookTwitter.hidden = TRUE;
            break;
        }
            
            
            
        default:
            break;
    }
    
    if([viewCoverPage isHidden]){
        viewRCChooser.center = center;
        
        NSMutableDictionary* params = [[NSMutableDictionary alloc] init];
        [params setValue:viewRCChooser forKey:@"View"];
        [params setValue:[NSNumber numberWithFloat:0.2] forKey:@"Duration"];
        
        [params setValue:[NSNumber numberWithBool:TRUE] forKey:@"Value"];
        [self shouldHideView:params];
        
        
        [params setValue:[NSNumber numberWithBool:FALSE] forKey:@"Value"];
        [self shouldHideView:params];
        
        
        [params setValue:[NSNumber numberWithBool:TRUE] forKey:@"Value"];
        [self performSelector:@selector(shouldHideView:) withObject:params afterDelay:5.0];

    }else{
        
        [self btnActionShareCollection:sender];
    }
    
    
}



#pragma mark Get Bitly URL
-(void)getBitlyUrlWithSender:(id)sender ifCollection:(BOOL)isCollection{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *realUrl;
    if (isCollection) {
        realUrl = [NSString stringWithFormat:@"%@/#!collection-play&id=%@",serverUrl,collectionGooruId];
    }else{
        
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        //Get key for the resource to be Loaded
        NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
        
        //Hitting Dictionary For the Resource Details
        NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
        
        realUrl = [NSString stringWithFormat:@"%@/#!resource-play&id=%@&pn=resource",serverUrl,[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID]];
    }
    
    NSLog(@"Real Url : %@",realUrl);
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"realUrl", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken,realUrl, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/url/shorten/%@",collectionGooruId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
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


#pragma mark BA Share Collection
- (IBAction)btnActionShareCollection:(id)sender {
    
    [self getBitlyUrlWithSender:sender ifCollection:TRUE];
    
}

#pragma mark Share Collection
-(void)shareCollection:(id)sender withUrl:(NSString*)urlToShare{
    
    //Mixpanel track dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictCollection valueForKey:COLLECTION_TITLE]] forKey:@"CollectionTitle"];
    [dictionary setObject:collectionGooruId forKey:@"gooruOid"];
    
    if ([strShareTo isEqualToString:SHARE_FACEBOOK]) {
        
        shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n",[dictCollection valueForKey:COLLECTION_TITLE]] contentType:SHKURLContentTypeImage];
        
        [shareItem setImage:imgViewCoverPage.image];
        
        [SHKiOSFacebook shareItem:shareItem];
        
        //Mixpanel track Facebook
//        [appDelegate logMixpanelforevent:@"Facebook Share - Collection" and:dictionary];
        
    }else if([strShareTo isEqualToString:SHARE_TWITTER]){
        
        shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n%@",[dictCollection valueForKey:COLLECTION_TITLE],urlToShare] contentType:SHKURLContentTypeWebpage];
        
        [shareItem setImage:imgViewCoverPage.image];
        
        [SHKiOSTwitter shareItem:shareItem];
        
        //Mixpanel track Twitter
//        [appDelegate logMixpanelforevent:@"Twitter Share - Collection" and:dictionary];
        
    }else if([strShareTo isEqualToString:SHARE_EMAIL]){
        
        NSString* strSubject = [NSString stringWithFormat:@"I've shared a Gooru Collection with you!"];
        
        NSString* strBody1 = [NSString stringWithFormat:@"Gooru Collection: %@ ",[NSString stringWithFormat:@"%@\n",[dictCollection valueForKey:COLLECTION_TITLE]]];
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
        
    }else{
        //Flag Collection
        
        [self displayFlaggingPopupForCollection:TRUE];
        
        
        
    }
    
    
}

#pragma mark BA Share Resource
- (IBAction)btnActionShareResource:(id)sender {
    
    [self getBitlyUrlWithSender:sender ifCollection:FALSE];
    
}

#pragma mark Share Resource
-(void)shareResource:(id)sender withUrl:(NSString*)urlToShare{
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];

    
    shareItem = [SHKItem URL:[NSURL URLWithString:urlToShare] title:[NSString stringWithFormat:@"%@\n%@",[dictResourceInfo valueForKey:RESOURCE_TITLE],urlToShare] contentType:SHKURLContentTypeWebpage];
    
    //Mixpanel track dictionary
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictResourceInfo valueForKey:RESOURCE_TITLE]] forKey:@"ResourceTitle"];
    [dictionary setObject:[NSString stringWithFormat:@"%@\n",[dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID]] forKey:@"gooruOid"];
    
    
    if ([strShareTo isEqualToString:SHARE_FACEBOOK]) {
        
        [SHKiOSFacebook shareItem:shareItem];
        
        //Mixpanel track Facebook
//        [appDelegate logMixpanelforevent:@"Facebook Share - Resource" and:dictionary];
        
        
    }else if([strShareTo isEqualToString:SHARE_TWITTER]){
        
        
        [SHKiOSTwitter shareItem:shareItem];
        
        //Mixpanel track Twitter
//        [appDelegate logMixpanelforevent:@"Twitter Share - Resource" and:dictionary];
        
    }else if([strShareTo isEqualToString:SHARE_EMAIL]){
        
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
        
        
    }else{
        //Flag Resource
        [self displayFlaggingPopupForCollection:FALSE];
        
    }
    
    
}

#pragma mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
    
}

#pragma mark - Flag -

#pragma mark Flag Resource/Collection Popup
- (void)displayFlaggingPopupForCollection:(BOOL)isCollection{
    
    FlaggingPopupViewController* flaggingPopupViewController = [[FlaggingPopupViewController alloc] initWithCollectionInfo:dictCollection andResourceInfo:dictCurrentResourceInfo forCollection:isCollection andParentViewController:self];
    
    [self presentDetailController:flaggingPopupViewController inMasterView:self.view];
    
}

#pragma mark Set Flag for Resource/Collection
- (void)setFlaggingForCollection:(BOOL)isCollection{
    
    if (isCollection) {
        [dictCollection setValue:@"Yes" forKey:COLLECTION_FLAG];
        [btnFlag setSelected:TRUE];
        
    }else{
        
        //Get all Keys and sort
        NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
        
        //Get key for the resource to be Loaded
        NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
        
        //Hitting Dictionary For the Resource Details
        NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
        
        
        //Setting the Reaction
        
        [dictResourceInfo setValue:@"Yes" forKey:RESOURCE_FLAG];
        
        [dictAllResources setValue:dictResourceInfo forKey:requiredKey];

        [btnFlag setSelected:TRUE];
        
    }
    
}

#pragma mark Manage Flag for resource
-(void)manageFlagOnLoad{
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [self sortedIntegerKeysForDictionary:dictAllResources];
    
    //Get key for the resource to be Loaded
    NSString* requiredKey = [keysDictAllResources objectAtIndex:carousel.currentItemIndex];
    
    //Hitting Dictionary For the Resource Details
    NSMutableDictionary* dictResourceInfo = [dictAllResources objectForKey:requiredKey];
    
    
    if ([[dictResourceInfo valueForKey:RESOURCE_FLAG] isEqualToString:@"Yes"]) {
        
        [btnFlag setSelected:TRUE];
    }else{
        
        [btnFlag setSelected:FALSE];
    }
    
}



#pragma mark - Did Recieve Memory Warning -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark Time Computer
-(NSString*)computeTimeInSecondsFor:(NSString*)time{
    
    int timeInSeconds;
    
    // Handling Start Time for Youtube Videos
    NSArray* arrComponentsForTime = [time componentsSeparatedByString:@":"];
    
    int lengthArrComponentsForTime = [arrComponentsForTime count];
//    NSLog(@"lengthArrComponentsForTime : %i",lengthArrComponentsForTime);
    
    if (lengthArrComponentsForTime > 1) {
        if (lengthArrComponentsForTime == 2) {
            
            timeInSeconds = [[arrComponentsForTime objectAtIndex:0]intValue]*60 + [[arrComponentsForTime objectAtIndex:1]intValue];
            
        }else{
            
            timeInSeconds = [[arrComponentsForTime objectAtIndex:0]intValue]*60*60 +[[arrComponentsForTime objectAtIndex:1]intValue]*60 + [[arrComponentsForTime objectAtIndex:2]intValue];
            
        }
        
    }else{
        timeInSeconds = [time intValue]*60;
    }
    
    return [NSString stringWithFormat:@"%i",timeInSeconds];
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


#pragma mark - UITextView delegates -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    [self shouldHideView:lblEmptyText : TRUE];
    int allowedLength;
    switch(textView.tag) {
        case 777:
            allowedLength = 1000;      // triggered for input fields with tag = 1
            break;
        default:
            allowedLength = 700;   // length default when no tag (=0) value =255
            break;
    }
    
    if (textView.text.length >= allowedLength && range.length == 0) {
        [self shouldHideView:lblCharLimit :FALSE];
        return NO; // Change not allowed
    } else {
        [self shouldHideView:lblCharLimit :TRUE];
        return YES; // Change allowed
    }
}



#pragma mark Create Sorted Array for Dictionary Integer Keys
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

#pragma mark - UI Helpers -

#pragma mark Hide/Unhide Animated!
-(void)shouldHideView:(UIView*)view :(BOOL)value{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

-(void)shouldHideView:(NSMutableDictionary*)params{
    
    BOOL value = [[params valueForKey:@"Value"] boolValue];
    UIView* view = (UIView*)[params valueForKey:@"View"];
    float duration = [[params valueForKey:@"Duration"] floatValue];
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = duration;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

#pragma mark Animate View!
-(void)animateView:(UIView*)view forFinalFrame:(CGRect)frame inDuration:(float)duration{
    
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark Get Required Min Label Height
-(CGRect)getHLabelFrameForLabel:(UILabel*)label withString:(NSString*)string{
    
    CGSize maximumLabelSize = CGSizeMake(label.frame.size.width,99999);
    
    CGSize expectedLabelSize = [string sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    
    //    NSLog(@"in meth : %f :: %f",expectedLabelSize.width,expectedLabelSize.height);
    
    
    return newFrame;
    
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

#pragma mark - View Controller Manipulators -
- (void)swapCurrentControllerWith:(UIViewController*)viewController{
    
    
    //    [self removeCurrentDetailViewController];
    
    //1. The current controller is going to be removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
    
    //2. The new controller is a new child of the container
    [self addChildViewController:viewController];
    
    //3. Setup the new controller's frame depending on the animation you want to obtain
    viewController.view.frame = CGRectMake(2000, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
    //3b. Attach the new view to the views hierarchy
    [[carousel itemViewAtIndex:carousel.currentItemIndex] addSubview:viewController.view];
    
    
    [UIView animateWithDuration:0.0
     
     //4. Animate the views to create a transition effect
                     animations:^{
                                                  
                         //The new controller's view is going to take the position of the current controller's view
                         viewController.view.frame = CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
                         
                         //The current controller's view will be moved outside the window
                         self.currentDetailViewController.view.frame = CGRectMake(-2000,0,viewController.view.frame.size.width, viewController.view.frame.size.height);
                         
                         
                     }
     
     
     //5. At the end of the animations we remove the previous view and update the hierarchy.
                     completion:^(BOOL finished) {
                         
                         //Remove the old Detail Controller view from superview
                         [self.currentDetailViewController.view removeFromSuperview];
                         //
                         //Remove the old Detail controller from the hierarchy
                         [self.currentDetailViewController removeFromParentViewController];
                         
                         //                         [self removeCurrentDetailViewController];
                         
                         //Set the new view controller as current
                         self.currentDetailViewController = viewController;
                         [self.currentDetailViewController didMoveToParentViewController:self];
                         
                     }];
    
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


- (void)removeCurrentDetailViewController{
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.currentDetailViewController.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self.currentDetailViewController removeFromParentViewController];
}



#pragma mark - General Button Actions -
#pragma mark BA Close Player
- (IBAction)btnActionClosePlayer:(id)sender {
    
    isViewInitialized = FALSE;
    [self pauseVideoPlayerForIndex:carousel.currentItemIndex];
    [self prepForSummaryPageAndRender:FALSE];
    if (![btnNavigation isSelected]) {
        viewNavigation.hidden = TRUE;
    }
    carousel.dataSource = nil;
    carousel.delegate = nil;
    
    UIView* view = [carousel itemViewAtIndex:carousel.currentItemIndex];
    
    UIWebView* webview;
    
    for (UIView *aView in [view subviews]){
        if([aView isKindOfClass:[UIWebView class]]){
            webview = (UIWebView*)aView;
        }
    }
    
    webview.delegate = nil;
    
    scrollNarrationOverlay.delegate = nil;
    lbYouTubePlayerViewController.delegate = nil;

    [appDelegate logMixpanelforevent:@"Exit Collection" and:nil];

    [self dismissViewControllerAnimated:YES completion:nil];
    
}




@end
