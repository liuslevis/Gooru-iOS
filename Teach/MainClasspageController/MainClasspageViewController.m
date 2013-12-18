
//
//  MainClasspageViewController.m
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

#import "MainClasspageViewController.h"
#import "AssignmentViewController.h"
#import "AppDelegate.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NarrationSettingsViewController.h"
#import "FirstUserExperienceViewController.h"
#import "RegistrationViewController.h"
#import "SVWebViewController.h"
#import "Reachability.h"
#import "CollectionPlayerV2ViewController.h"
#import "DiscoverViewController.h"
#import "FUEViewController.h"
#import "CollectionAnalyticsViewController.h"
#define MULTIPLIER_CLASSPAGETABS 666
#define MULTIPLIER_CLASSPAGETABSTEACH 777
#define MAX_LENGTH 10

#define TAG_REACHABILITY_ALERT 9890

#define FUE_TEACH @"Teach"
#define FUE_STUDY @"Study"
#define FUE_OTHER @"Other"
#define FUE_NO_CLASSPAGES @"TeachNoClasspages"

#define TAG_BTN_TEACH 100010
#define TAG_BTN_STUDY 100020
#define TAG_BTN_DISCOVER 100030

/////


@interface MainClasspageViewController ()
@property UIViewController  *currentDetailViewController;
@end

@implementation MainClasspageViewController
@synthesize btnGooruSuggest;
@synthesize btnGooruSearch;
@synthesize btnTeach;

AppDelegate *appDelegate;
NSUserDefaults* standardUserDefaults;
NSString* sessionTokenMainClassPageView;

AssignmentViewController * assignmentDetailViewController;
LoginViewController* loginViewController;
NarrationSettingsViewController* narrationSettingsViewController;
RegistrationViewController *registrationViewController;
DiscoverViewController* discoverViewController;


NSMutableDictionary* dictStarterClasspages;
//NSMutableDictionary* dictStarterClasspagesTeach;
NSMutableDictionary *dictUserClasspages;
NSMutableDictionary *dictStudyClasspages;

NSMutableDictionary *dictCourseDetails;

BOOL isTeachFlag;

Reachability *internetReachableFoo;
UIAlertView *alertViewForReachability;





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecycle -
- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    
    if ([[standardUserDefaults stringForKey:@"defaultGooruSessionToken"] isEqualToString:@"NA"]) {
        //Stop Execution
        [self alertShow:@"Something went wrong. Please restart the application!" withTag:56];
        
    }else{
        // Do any additional setup after loading the view from its nib.
        
        appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];

        //When Not Logged In
        [btnUserSettings setEnabled:FALSE];
        imgViewSettingsGear.hidden=TRUE;
        
        narrationSettingsViewController = [[NarrationSettingsViewController alloc] initWithNibName:@"NarrationSettingsViewController" bundle:nil];
        [narrationSettingsViewController setNarrationDefaultSettings];
        [btnDiscover sendActionsForControlEvents:UIControlEventTouchUpInside];
//        [self displayFUEFor:FUE_TEACH];
        [standardUserDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"isLoggedIn"];
        
        viewBtnSupportLoggedOut.hidden=FALSE;
        
        //Setup Arrows
        [self shouldHideView:imgViewArrowTeach :YES];
        [self shouldHideView:imgViewArrowStudy :YES];
        [self shouldHideView:imgViewArrowDiscover :NO];
        
        //Adding Observer to Refresh Views
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin) name:@"onLogin" object:nil];
        
    }
    
    if (![[standardUserDefaults stringForKey:@"FUEFlagShouldShowMainFUE"] isEqualToString:@"No"]) {
        
        FUEViewController* fueViewController=[[FUEViewController alloc]init];
        [self presentDetailController:fueViewController inMasterView:self.view];

    }
    
    
    
}

- (void)viewWillAppear:(BOOL)animated{
    if ([[standardUserDefaults stringForKey:@"defaultGooruSessionToken"] isEqualToString:@"NA"]) {
        //Stop Execution
        [self alertShow:@"Oh No! Something went wrong. Please restart the application!" withTag:56];
        
    }
    
    [self testInternetConnection];
    alertViewForReachability = [[UIAlertView alloc] initWithTitle:[appDelegate getValueByKey:@"NoConnection"] message:[appDelegate getValueByKey:@"No Connection"] delegate:self cancelButtonTitle:@"Retry" otherButtonTitles:@"Quit",nil];
    [alertViewForReachability setTag:TAG_REACHABILITY_ALERT];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)userVoiceWasDismissed {
    NSLog(@"UserVoice dismissed");
}

#pragma mark - User Classpages -

#pragma mark Get all User Classpages
- (void)getMyClasspages{
    [activityIndicatorPrimary startAnimating];
    
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    sessionTokenMainClassPageView  = [standardUserDefaults stringForKey:@"token"];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/v2/classpage/my?sessionToken=%@&data={\"skipPagination\":\"true\"}",[appDelegate getValueByKey:@"ServerURL"],sessionTokenMainClassPageView];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"data", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionTokenMainClassPageView, @"{\"skipPagination\":\"true\"}", nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:@"/gooruapi/rest/v2/classpage/my?" parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"getClasspages Response : %@",responseStr);
        [activityIndicatorPrimary stopAnimating];
        [self parseClasspages:responseStr];
        [viewTopBarLoggedIn setUserInteractionEnabled:TRUE];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityIndicatorPrimary stopAnimating];
        [viewTopBarLoggedIn setUserInteractionEnabled:TRUE];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];
    
}



- (void)parseClasspages:(NSString*)responseString{
    
    NSArray *results = [responseString JSONValue];
    
    NSLog(@"results : %@",[results description]);
    
    BOOL isClasspagesEmpty;
    
    
    NSArray* arrSearchResults = results;
    NSString* strTotalHitCount = [NSString stringWithFormat:@"%i",[arrSearchResults count]];
    
    
    
    NSLog(@"strTotalHitCount : %@",strTotalHitCount);
    NSLog(@"arrSearchResults : %@",[arrSearchResults description]);
    
    if([strTotalHitCount intValue] == 0){
         dictUserClasspages = [[NSMutableDictionary alloc]init];
        //Populate no results screen
        NSLog(@"CONNECTION_IDENTIFIER_ASSIGNMENTS no results");
        isClasspagesEmpty = TRUE;
        
      
    }else{
        isClasspagesEmpty = FALSE;
        
        //Setup dictionary for Classpages only
        dictUserClasspages = [[NSMutableDictionary alloc]init];
        
        int countArrSearchResults = [arrSearchResults count];
        
        for (int i = 0; i<countArrSearchResults; i++) {
            
            NSMutableDictionary* dictStaticClasspageAttr = [[NSMutableDictionary alloc]init];
            
            
            
            [dictStaticClasspageAttr setValue:[[arrSearchResults objectAtIndex:i] valueForKey:@"title"] forKey:@"classpageTitle"];
            [dictStaticClasspageAttr setValue:[[arrSearchResults objectAtIndex:i] valueForKey:@"gooruOid"] forKey:@"classpageId"];
            [dictStaticClasspageAttr setValue:[[arrSearchResults objectAtIndex:i] valueForKey:@"classpageCode"] forKey:@"classpageCode"];
            
            [dictStaticClasspageAttr setValue:[[[arrSearchResults objectAtIndex:i] valueForKey:@"thumbnails"] valueForKey:@"url"] forKey:@"thumbnailUrl"];

   
            NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABS];
            [dictUserClasspages setValue:dictStaticClasspageAttr forKey:keyForDictStaticClasspageAttr];
        }
        
        
        
    }
     [self populateUserTeachClasspagesUsingData:dictUserClasspages];
    
   
}



#pragma mark Populate User Classpages
- (void)populateUserTeachClasspagesUsingData:(NSMutableDictionary*)dictClasspages{
    //Clean Classpage View
    
    [viewTeachClasspages setHidden:FALSE];
    
    for (UIView *aView in [viewTeachClasspages subviews]){
        if (aView.frame.origin.y != 0) {
            [aView removeFromSuperview];
        }
        
        
    }
    
    NSArray* sortedKeysDictClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
    int countClasspages = [sortedKeysDictClasspages count];
    NSLog(@"countClasspages : %i",countClasspages);
    
    
    if (countClasspages != 0) {
        
        int lastYordinate = 50;
        
        
        for (int i=0; i<countClasspages; i++) {
            
            NSString* keyInUse = [sortedKeysDictClasspages objectAtIndex:i];
            NSMutableDictionary* dictInUse = [dictClasspages valueForKey:keyInUse];
            
            btnClasspageTitle = [[UIButton alloc]init];
            btnClasspageTitle.frame = CGRectMake(0,0,scrollClasspageTabBar.frame.size.width,50);
            
            [btnClasspageTitle setTitle:[dictInUse valueForKey:@"classpageTitle"] forState:UIControlStateNormal];
            [btnClasspageTitle setBackgroundImage:[UIImage imageNamed:@"classpageButtonSelected.png"] forState:UIControlStateSelected];
            [btnClasspageTitle setBackgroundImage:[UIImage imageNamed:@"classpagebuttondefault.png"] forState:UIControlStateNormal];
            [btnClasspageTitle.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [btnClasspageTitle.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [btnClasspageTitle  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btnClasspageTitle.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            [btnClasspageTitle addTarget:self action:@selector(btnActionUserClasspage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            //Delete Button
            UIButton *btnClasspageDelete = [[UIButton alloc] init];
            btnClasspageDelete.frame = CGRectMake(0,0,btnClasspageTitle.frame.size.width,btnClasspageTitle.frame.size.height);
            [btnClasspageDelete setBackgroundImage:[UIImage imageNamed:@"btnClasspageDeleteOverlay@2x.png"] forState:UIControlStateNormal];
            [btnClasspageDelete setHidden:TRUE];
            
            //Swipe gesture for button
            UISwipeGestureRecognizer* swipeUpGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            //            [btnClasspageTitle addGestureRecognizer:swipeUpGestureRecognizerLeft];
            
            
            UISwipeGestureRecognizer* swipeUpGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
            
            //Setting Tag
            int classpageTag = [keyInUse intValue];
            [btnClasspageTitle setTag:classpageTag];            
            if (i == 0) {
                
                [viewTeachClasspages insertSubview:btnClasspageTitle belowSubview:btnTeach];
                [btnClasspageTitle sendActionsForControlEvents:UIControlEventTouchUpInside];
                
            }else{
                
                [viewTeachClasspages insertSubview:btnClasspageTitle belowSubview:[viewTeachClasspages viewWithTag:[[sortedKeysDictClasspages objectAtIndex:i-1] intValue]]];
                
            }

            lastYordinate = lastYordinate+btnClasspageTitle.frame.size.height+2;
        }
        
        
        
        [self manageDOTSforBtn:btnTeach.tag forData:dictClasspages];
        

       
    }else{
        
        [self displayFUEFor:FUE_NO_CLASSPAGES];
         [self manageDOTSforBtn:btnTeach.tag forData:dictClasspages];
        
    }
    
    
    
}




- (void)animateClasspageItemsToOpen:(BOOL)value forData:(NSMutableDictionary*)dictClasspages{
    
    NSArray* sortedKeysDictClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
    int countClasspages = [sortedKeysDictClasspages count];
    
    if (value) {
        
        CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50+(52*countClasspages));
        [self animateView:viewTeachClasspages forFinalFrame:frame];
        
        [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, viewStudyClasspages.frame.size.height)];
        
        [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, viewDiscover.frame.size.height)];
        
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToAnimate = (UIButton*)[viewTeachClasspages viewWithTag:[[sortedKeysDictClasspages objectAtIndex:i] intValue]];
            
            [UIView animateWithDuration:.4f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 btnToAnimate.frame = CGRectMake( btnToAnimate.frame.origin.x,  btnToAnimate.frame.origin.y + 52*(i+1),  btnToAnimate.frame.size.width,  btnToAnimate.frame.size.height);;
                                 
                             } completion:^(BOOL finished){
                                 
                                 
                             }];
            
            
            
        }

    }else{
        
        [self animateView:viewTeachClasspages forFinalFrame:CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50)];
        
        [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, 50, viewStudyClasspages.frame.size.width, viewStudyClasspages.frame.size.height)];
        
        [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, viewDiscover.frame.size.height)];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToAnimate = (UIButton*)[viewTeachClasspages viewWithTag:[[sortedKeysDictClasspages objectAtIndex:i] intValue]];
            
            [UIView animateWithDuration:.4f
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 
                                 btnToAnimate.frame = CGRectMake( btnToAnimate.frame.origin.x,  btnToAnimate.frame.origin.y - 52*(i+1),  btnToAnimate.frame.size.width,  btnToAnimate.frame.size.height);;
                                 
                             } completion:^(BOOL finished){
                                 
                                 
                             }];
            
        }
  
    }
    
    [scrollClasspageTabBar setContentSize:CGSizeMake(scrollClasspageTabBar.frame.size.width,viewTeachClasspages.frame.size.height + viewStudyClasspages.frame.size.height + viewDiscover.frame.size.height)];
    
    
}

#pragma mark BA User Classpages
- (void)btnActionUserClasspage:(id)sender{
    
    [btnSupportLoggedOut setSelected:FALSE];
    
    UIButton* tempBtn =  (UIButton*)sender;
    if (![tempBtn isSelected]) {
        
        NSMutableDictionary* dictUserClasspageInUse = [dictUserClasspages valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]];
        NSLog(@"dictInUse : %@",[dictUserClasspageInUse description]);
        
        
        
        //Unselect all buttons
        
        NSArray* sortedKeysDictUserClasspages = [appDelegate sortedIntegerKeysForDictionary:dictUserClasspages];
        int countClasspages = [sortedKeysDictUserClasspages count];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToDeselect = (UIButton*)[viewTeachClasspages viewWithTag:[[sortedKeysDictUserClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        
        if ([btnTeach isSelected]||[btnStudy isSelected]) {
            assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictUserClasspageInUse forTeach:isTeachFlag];
            [self swapCurrentControllerWith:assignmentDetailViewController];
        }else{
        
            assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictUserClasspageInUse forTeach:isTeachFlag];
                assignmentDetailViewController.isLoggedOut=TRUE;
            [self swapCurrentControllerWith:assignmentDetailViewController];
        }
    }
    
    
    
}

#pragma mark - Starter Classpages -

#pragma mark FUE Classpages
- (void)displayFUEFor:(NSString*)value{
    
    if ([value isEqualToString:FUE_TEACH]) {
        FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Teach"];
        [self swapCurrentControllerWith:firstUserExperienceViewController];
    }else if([value isEqualToString:FUE_STUDY]){
        FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Study"];
        [self swapCurrentControllerWith:firstUserExperienceViewController];
    }else if([value isEqualToString:FUE_OTHER]){
        FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Other"];
        [self swapCurrentControllerWith:firstUserExperienceViewController];
    }else{
        
        NSArray* arrSuggestedClasspageTitles = [[NSArray alloc] initWithObjects:@"Your First Classpage", nil];
        
        NSArray* arrSuggestedClasspageIds = [[NSArray alloc] initWithObjects:@"5b4a7103-7e16-41cb-b3bb-4dee1c3548a8", nil];
        
        
        NSArray* arrSuggestedClasspageCodes = [[NSArray alloc] initWithObjects:@"IATBGII", nil];
        
        NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
        
        [dictClasspageInstance setValue:[arrSuggestedClasspageTitles objectAtIndex:0] forKey:@"classpageTitle"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageIds objectAtIndex:0] forKey:@"classpageId"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageCodes objectAtIndex:0] forKey:@"classpageCode"];
        
        assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictClasspageInstance forTeach:isTeachFlag];
        [self swapCurrentControllerWith:assignmentDetailViewController];
//        FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"TeachNoClasspages"];
//        [self swapCurrentControllerWith:firstUserExperienceViewController];
    }
    
    
    
}

#pragma mark Setup Starter Classpages
- (void)setUpStarterClasspageDictionaryAndShouldAutoPopulate:(BOOL)value{
    
    NSArray* arrSuggestedClasspageTitles;
    if ([btnStudy isSelected]) {
          arrSuggestedClasspageTitles = [[NSArray alloc] initWithObjects:@"Get Started",@"Algebra 1",@"Ancient Civilizations",@"Physics",@"English Language Arts 8", nil];
    }else{
     arrSuggestedClasspageTitles = [[NSArray alloc] initWithObjects:@"Welcome to Gooru!",@"Algebra 1",@"Ancient Civilizations",@"Physics",@"English Language Arts 8", nil];
    }
    NSArray* arrSuggestedClasspageIds = [[NSArray alloc] initWithObjects:@"0305adfe-2edc-4054-a29e-616f11f06181",@"272e9c46-c0a9-427a-9a0d-f31eb051ce3a",@"087ddf35-6b2b-4411-9832-d8e789a25888",@"6b2fbea8-b3e9-4b74-937b-28e209049eec",@"18c2e8db-ffcc-471e-960b-78b5ae30b98d", nil];

    
    NSArray* arrSuggestedClasspageCodes = [[NSArray alloc] initWithObjects:@"I6WAII1",@"I4VFPII",@"I4VDCII",@"I6RQYII",@"I8RCRII", nil];
    
    dictStarterClasspages = [[NSMutableDictionary alloc] init];
    for (int i=0; i<5; i++) {
        
        NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
        
        [dictClasspageInstance setValue:[arrSuggestedClasspageTitles objectAtIndex:i] forKey:@"classpageTitle"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageIds objectAtIndex:i] forKey:@"classpageId"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageCodes objectAtIndex:i] forKey:@"classpageCode"];
        
        
        
        NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABS];
        [dictStarterClasspages setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
        
    }
    
    
//    [self populateStarterClasspageTabsWithData:dictStarterClasspages shouldAutoPopulate:value];
    
}

- (void)setUpStarterClasspageDictionaryAndShouldAutoPopulateForTeach:(BOOL)value{
    
    isYourFirstClassPageInMC=TRUE;
    NSArray* arrSuggestedClasspageTitles = [[NSArray alloc] initWithObjects:@"Teach Something",@"Your First Classpage", nil];
    
    NSArray* arrSuggestedClasspageIds = [[NSArray alloc] initWithObjects:@"0305adfe-2edc-4054-a29e-616f11f06181",@"5b4a7103-7e16-41cb-b3bb-4dee1c3548a8", nil];
    
    
    NSArray* arrSuggestedClasspageCodes = [[NSArray alloc] initWithObjects:@"I6WAII1",@"IATBGII", nil];
    
    dictStarterClasspages = [[NSMutableDictionary alloc] init];
    for (int i=0; i<2; i++) {
        
        NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
        
        [dictClasspageInstance setValue:[arrSuggestedClasspageTitles objectAtIndex:i] forKey:@"classpageTitle"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageIds objectAtIndex:i] forKey:@"classpageId"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageCodes objectAtIndex:i] forKey:@"classpageCode"];
        
        NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABSTEACH];
        [dictStarterClasspages setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
        
    }
    NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    
    [self populateStarterClasspageTabsWithData:dictStarterClasspages shouldAutoPopulate:value];
    
}

#pragma mark Populate Starter Classpages
- (void)populateStarterClasspageTabsWithData:(NSMutableDictionary*)dictClasspages shouldAutoPopulate:(BOOL)value{
    //Clean Classpage View
    NSLog(@"dictStarterClasspages=%@",[dictClasspages description]);
    for (UIView *aView in [viewStudyClasspages subviews]){
        if (aView.frame.origin.y != 0) {
            [aView removeFromSuperview];
        }
        
        
    }
    
    NSArray* sortedKeysDictClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
    NSLog(@"sortedKeysDictClasspages=%@",[sortedKeysDictClasspages description]);
    int countClasspages = [sortedKeysDictClasspages count];
    NSLog(@"countClasspages : %i",countClasspages);
    
     NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    
    if (countClasspages != 0) {
        
        int lastYordinate = 20;
        CGRect frame;
        if ([viewTeachClasspages isHidden]) {
            frame = CGRectMake(viewStudyClasspages.frame.origin.x, viewStudyClasspages.frame.origin.y, viewStudyClasspages.frame.size.width, 20+(52*countClasspages));
        }else{
            if (value) {
                NSLog(@"viewStudyClasspages.frame.origin.y=%f",viewStudyClasspages.frame.origin.y);
                 frame = CGRectMake(viewStudyClasspages.frame.origin.x, 0, viewStudyClasspages.frame.size.width, 20+(52*countClasspages));
            }else{
            frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewTeachClasspages.frame.size.width, 20+(52*countClasspages));
            }
        }
        
        [self animateView:viewStudyClasspages forFinalFrame:frame];
        
        for (int i=0; i<countClasspages; i++) {
            
            NSString* keyInUse = [sortedKeysDictClasspages objectAtIndex:i];
            NSLog(@"keyInUse=%@",[keyInUse description]);
            NSMutableDictionary* dictInUse = [dictClasspages valueForKey:keyInUse];
             NSLog(@"dictInUse=%@",[dictInUse description]);
            btnClasspageTitle = [[UIButton alloc]init];
            btnClasspageTitle.frame = CGRectMake(0,lastYordinate,scrollClasspageTabBar.frame.size.width,50);
            
            [btnClasspageTitle setTitle:[dictInUse valueForKey:@"classpageTitle"] forState:UIControlStateNormal];
            [btnClasspageTitle setBackgroundImage:[UIImage imageNamed:@"classpageButtonSelected.png"] forState:UIControlStateSelected];
            [btnClasspageTitle setBackgroundImage:[UIImage imageNamed:@"classpagebuttondefault.png"] forState:UIControlStateNormal];
            [btnClasspageTitle.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [btnClasspageTitle.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [btnClasspageTitle  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btnClasspageTitle.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            
            if (i==0) {
                  NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
                [btnClasspageTitle addTarget:self action:@selector(btnActionStarterClasspageFirstUserExp:) forControlEvents:UIControlEventTouchUpInside];
               
            }else{
                 NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
            [btnClasspageTitle addTarget:self action:@selector(btnActionStarterClasspage:) forControlEvents:UIControlEventTouchUpInside];
            
            }
            
            //Delete Button
            UIButton *btnClasspageDelete = [[UIButton alloc] init];
            btnClasspageDelete.frame = CGRectMake(0,0,btnClasspageTitle.frame.size.width,btnClasspageTitle.frame.size.height);
            [btnClasspageDelete setBackgroundImage:[UIImage imageNamed:@"btnClasspageDeleteOverlay@2x.png"] forState:UIControlStateNormal];
            [btnClasspageDelete setHidden:TRUE];
            
            //Swipe gesture for button
            UISwipeGestureRecognizer* swipeUpGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            //            [btnClasspageTitle addGestureRecognizer:swipeUpGestureRecognizerLeft];
            
            
            UISwipeGestureRecognizer* swipeUpGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
            //            [btnClasspageTitle addGestureRecognizer:swipeUpGestureRecognizerRight];
            
            //            [btnClasspageTitle addSubview:btnClasspageDelete];
            
            
            
            //            UILabel* tempLabel = [[UILabel alloc] initWithFrame:btnClasspageTitle.frame];
            //            [tempLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            //            [tempLabel setText:[[dict_classpages valueForKey:[sortedKeysDict_classpages objectAtIndex:i]] valueForKey:@"classpageTitle"]];
            
            //            btnClasspageTitle.frame = [appDelegate getWLabelFrameForLabel:tempLabel withString:tempLabel.text];
            //
            //            btnClasspageTitle.frame = CGRectMake(btnClasspageTitle.frame.origin.x, btnClasspageTitle.frame.origin.y, btnClasspageTitle.frame.size.width, btnClasspageTitle.frame.size.height+5);
            
            //Setting Tag
            int classpageTag = [keyInUse intValue];
            [btnClasspageTitle setTag:classpageTag];
            //            [btnClasspageDelete setTag:classpageTag * MULTIPLIER_CLASSPAGE_DELETE];
            
            if (i == 0) {
                if (value) {
                    [btnClasspageTitle sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                
            }
            
            
            //Adding Grey Seperator after every Button
            
            //            UIView* tempwhiteSeperatorView = [[UIView alloc]initWithFrame:CGRectMake(0,lastYordinate+btnClasspageTitle.frame.size.height,scrollClasspageTabBar.frame.size.width,1)];
            //            [tempwhiteSeperatorView setBackgroundColor:[UIColor grayColor]];
            //            [scrollClasspageTabBar addSubview:tempwhiteSeperatorView];
            
            [viewStudyClasspages addSubview:btnClasspageTitle];
            
            
            //Set
//            btnClasspageTitle.frame = CGRectMake( btnClasspageTitle.frame.origin.x - btnClasspageTitle.frame.size.width,  btnClasspageTitle.frame.origin.y ,  btnClasspageTitle.frame.size.width,  btnClasspageTitle.frame.size.height);
//            
//            [UIView animateWithDuration:0.2f
//                                  delay:.2*i
//                                options:UIViewAnimationOptionCurveEaseInOut
//                             animations:^{
//                                 btnClasspageTitle.frame = CGRectMake( btnClasspageTitle.frame.origin.x + btnClasspageTitle.frame.size.width,  btnClasspageTitle.frame.origin.y,  btnClasspageTitle.frame.size.width,  btnClasspageTitle.frame.size.height);;
//                                 
//                             } completion:^(BOOL finished){
//                             }];
            
            
            lastYordinate = lastYordinate+btnClasspageTitle.frame.size.height+2;
        }
        [scrollClasspageTabBar setContentSize:CGSizeMake(scrollClasspageTabBar.frame.size.width,viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height)];
        
    }
    
}

#pragma mark BA Starter Classpages
- (void)btnActionStarterClasspage:(id)sender{
    
        
    NSLog(@"sender : %@",sender);

    UIButton* tempBtn =  (UIButton*)sender;
    NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    if (![tempBtn isSelected]) {
        NSMutableDictionary* dictStarterClasspageInUse = [dictStarterClasspages valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]];
        NSLog(@"dictInUse : %@",[dictStarterClasspageInUse description]);
        
        
        //Mixpanel starter Classpages
        [appDelegate logMixpanelforevent:@"Starter Classpages" and:dictStarterClasspageInUse];
        

        //Unselect all buttons
        
        NSArray* sortedKeysdictStarterClasspages = [appDelegate sortedIntegerKeysForDictionary:dictStarterClasspages];
        int countClasspages = [sortedKeysdictStarterClasspages count];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToDeselect = (UIButton*)[viewStudyClasspages viewWithTag:[[sortedKeysdictStarterClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        //Unselect All Buttons in User Classpages
        for (UIButton *aView in [viewTeachClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                [aView setSelected:FALSE];
            }
        }
        assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictStarterClasspageInUse forTeach:NO];
        if (isYourFirstClassPageInMC) {

            assignmentDetailViewController.isYourFirstClasspageAss=isYourFirstClassPageInMC;
           // isYourFirstClassPageInMC=FALSE;
        }else{
            
        }
           
       [self presentDetailController:assignmentDetailViewController];

    }
    
        
}

#pragma mark BA Starter Classpages for FUE

- (void)btnActionStarterClasspageFUE:(id)sender{
   
    NSLog(@"sender : %@",sender);
    [btnSupportLoggedOut setSelected:FALSE];
   
        NSMutableDictionary* dictStarterClasspageInUse = [dictStarterClasspages valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]];
        NSLog(@"dictInUse : %@",[dictStarterClasspageInUse description]);
        
    [self verifyClasscode:[dictStarterClasspageInUse valueForKey:@"classpageCode"]];
    
    
}


- (void)btnActionStarterClasspageFirstUserExp:(id)sender{
    
    UIButton* tempBtn =  (UIButton*)sender;
    if (![tempBtn isSelected]) {
        NSMutableDictionary* dictStarterClasspageInUse = [dictStarterClasspages valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]];
        NSLog(@"dictInUse : %@",[dictStarterClasspageInUse description]);
        
        
        
        //Unselect all buttons
        
        NSArray* sortedKeysdictStarterClasspages = [appDelegate sortedIntegerKeysForDictionary:dictStarterClasspages];
        int countClasspages = [sortedKeysdictStarterClasspages count];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToDeselect = (UIButton*)[viewStudyClasspages viewWithTag:[[sortedKeysdictStarterClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        //Unselect All Buttons in User Classpages
        for (UIButton *aView in [viewTeachClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                [aView setSelected:FALSE];
            }
        }

        
        [btnSupportLoggedOut setSelected:FALSE];
        
        if([viewTeachClasspages isHidden] ){
            if ([btnStudy isSelected]) {
                FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Study"];
                [self swapCurrentControllerWith:firstUserExperienceViewController];
            }else{
            FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Other"];
            [self swapCurrentControllerWith:firstUserExperienceViewController];
            }
        }else{
            if ([btnTeach isSelected]) {
                FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Teach"];
                [self swapCurrentControllerWith:firstUserExperienceViewController];
            }else if([btnStudy isSelected]){
                FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Study"];
                [self swapCurrentControllerWith:firstUserExperienceViewController];
            }else{
                FirstUserExperienceViewController *firstUserExperienceViewController=[[FirstUserExperienceViewController alloc]initWithCheckingStringForFUE:@"Other"];
                [self swapCurrentControllerWith:firstUserExperienceViewController];
            }
        }
       
       
        
        //    [self presentDetailController:assignmentDetailViewController];
        
    }
  
}

#pragma mark - Study Classpage -

#pragma mark BA Study Now
- (IBAction)btnActionStudyNow:(id)sender {
    
    if ([btnNarrationSettings isSelected]) {
        
        
        [btnNarrationSettings setSelected:FALSE];
        [narrationSettingsViewController closeNarrationSettings];
        [self manageSettingsPanel];
    }
    
    isTeachFlag = FALSE;
    [self verifyClasscode:txtFieldClasscode.text];
}

#pragma mark Classcode Validation
- (void)verifyClasscode:(NSString*)classcode{

    
    NSString *trimmedString = [classcode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whiteSpaceRange.location != NSNotFound) {
        NSLog(@"Found whitespace");
        [self alertShow:@"Oops! We don’t recognize that code. \n Try again and double check with your teacher for the correct code." withTag:25];
        [txtFieldClasscode resignFirstResponder];
        txtFieldClasscode.text=@"";
    }else{
        [self getClasspageIdforClasspageCode:trimmedString];
        [txtFieldClasscode resignFirstResponder];
        txtFieldClasscode.text=@"";
        
    }
    
}


#pragma mark Get Classpage Id based on Classcode
- (void)getClasspageIdforClasspageCode:(NSString*)classpageCode{
    
     
    [activityIndicatorPrimary startAnimating];
    
    
    
    NSString* sessionTokenToUse = [standardUserDefaults stringForKey:@"token"];
    
    if ([sessionTokenToUse isEqualToString:@"NA"]) {
        
        NSLog(@"User Auth Status : User Logged Out!");
        sessionTokenToUse = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
       
    }
        
    NSArray* parameterKeys = [NSArray arrayWithObjects:@"sessionToken", nil];
    NSArray* parameterValues = [NSArray arrayWithObjects:sessionTokenToUse, nil];
    
    NSDictionary* dictPostParams = [NSDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/classpage/code/%@?",classpageCode] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"getClasspageId Response : %@",responseStr);
        [activityIndicatorPrimary stopAnimating];
       
        [self parseClasspage:responseStr forClasspageCode:classpageCode];
       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [activityIndicatorPrimary stopAnimating];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        
    }];
    
}

- (void)parseClasspage:(NSString*)responseString forClasspageCode:(NSString*)strClasspageCode{
    
    NSArray *results = [responseString JSONValue];
    NSLog(@"CONNECTION_IDENTIFIER_CLASSPAGECODE");
    
    NSRange range = [responseString rangeOfString:@"gooruOid"];
    
    if(range.location == NSNotFound)
    {
        //then check for nil
        //Populate no results screen
        NSString* sessionTokenToUse = [standardUserDefaults stringForKey:@"token"];
        if ([sessionTokenToUse isEqualToString:@"NA"]) {
            
            NSLog(@"User Auth Status : User Logged Out!");
            
            
        }else{
            if ([btnStudy isSelected]) {
                btnStudy.selected=TRUE;
                btnTeach.selected=FALSE;
            }else{
            btnTeach.selected=TRUE;
            btnStudy.selected=FALSE;
            isYourFirstClassPageInMC=TRUE;
            }
            NSLog(@"User Auth Status : User Logged In!");
        }
        
        NSLog(@"CONNECTION_IDENTIFIER_CLASS CODE no results");
        [self alertShow:@"Please enter a valid Class Code" withTag:26];
        
        
    }else{

        
        [standardUserDefaults setObject:strClasspageCode forKey:@"ClasspageCode"];
        
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:[results valueForKey:@"title"] forKey:@"classpageTitle"];
        [standardUserDefaults setObject:[results valueForKey:@"gooruOid"] forKey:@"gooruOid"];
        [standardUserDefaults setObject:[[results valueForKey:@"thumbnails"] valueForKey:@"url"] forKey:@"thumbnailUrl"];

        dictStudyClasspages = [[NSMutableDictionary alloc] init];
//        for (int i=0; i<1; i++) {
        
            NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
            
            [dictClasspageInstance setValue:[results valueForKey:@"title"] forKey:@"classpageTitle"];
            [dictClasspageInstance setValue:[results valueForKey:@"gooruOid"] forKey:@"classpageId"];
            [dictClasspageInstance setValue:[[results valueForKey:@"thumbnails"] valueForKey:@"url"] forKey:@"thumbnailUrl"];
        
            NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",MULTIPLIER_CLASSPAGETABS];
            [dictStudyClasspages setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
            
//        }
        
        [self populateAssignmentForStudy:dictStudyClasspages];
        
        
        
        //Mixpanel track Classcode Log-in
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[results valueForKey:@"title"] forKey:@"classpageTitle"];
        [dictionary setObject:[results valueForKey:@"gooruOid"] forKey:@"gooruOid"];
        
        [appDelegate logMixpanelforevent:@"Log-in Classcode" and:dictionary];
        
    }
 
}


- (void)populateAssignmentForStudy:(NSMutableDictionary*)dictClasspages{
    
    isTeachFlag = FALSE;
    NSArray* sortedKeysDictUserClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
    
    NSMutableDictionary* dictStudyClasspageInUse = [dictClasspages valueForKey:[sortedKeysDictUserClasspages objectAtIndex:0]];
    
    assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictStudyClasspageInUse forTeach:isTeachFlag];
    
    [self swapCurrentControllerWith:assignmentDetailViewController];
    
}

#pragma mark Exit Study Classpage
- (void)exitStudyClasspage{
    [standardUserDefaults setObject:@"NA" forKey:@"ClasspageCode"];
    [self displayFUEFor:FUE_STUDY];
    
}

#pragma mark Get Course to be selected according to Default Session Token

- (void)parseSignupCourseDetails:(NSString *)responseString{
    if ([responseString hasPrefix:@"error:"]){
        
        responseString = [responseString stringByReplacingOccurrencesOfString:@"error:" withString:@""];
       [self alertShow:@"Something went wrong during Sign Up!" withTag:54];
    }else if ([responseString isEqualToString:@""] || [responseString isEqualToString:@"(null)"] || [responseString isEqualToString:@"nil"]){
         [self alertShow:@"Something went wrong during Sign Up!" withTag:54];
        return;
    }else{
          dictCourseDetails=[[NSMutableDictionary alloc]init];
         NSArray *results = [responseString JSONValue];
        for (int i = 0; i<[results count]; i++) {
           
            NSMutableDictionary *dictSubjectsInCoursesByCodeId=[[NSMutableDictionary alloc]init];
          
        //    NSString *title=[[results objectAtIndex:i]objectForKey:@"label"];
            NSArray *arrayNodes=[[results objectAtIndex:i]objectForKey:@"node"];
          //  NSLog(@"arrayNodes=%@",[arrayNodes description]);
            for (int j=0; j<[arrayNodes count]; j++) {
                
                NSMutableDictionary *dictSubjectsInCourse=[[NSMutableDictionary alloc]init];
                [dictSubjectsInCourse setValue:[[arrayNodes objectAtIndex:j] valueForKey:@"label"] forKey:@"SubjectTitle"];
                [dictSubjectsInCourse setValue:[[arrayNodes objectAtIndex:j] valueForKey:@"codeId"] forKey:@"SubjectCodeId"];
                [dictSubjectsInCourse setValue:[[arrayNodes objectAtIndex:j] valueForKey:@"codeId"] forKey:@"SubjectFirstUnitId"];
                [dictSubjectsInCoursesByCodeId setObject:dictSubjectsInCourse forKey:[[arrayNodes objectAtIndex:j]objectForKey:@"codeId"] ];
            }
          
           
        [dictCourseDetails setObject:dictSubjectsInCoursesByCodeId forKey:[[results objectAtIndex:i]objectForKey:@"label"]];
        NSLog(@"dictCourseDetails=%@",[dictCourseDetails description]);
        }
    
    }
}




#pragma mark - Button Action Top Bar -

#pragma mark BA Teach/Study
- (IBAction)btnActionTeach:(id)sender {
    
    if (viewTeachClasspages.frame.size.height == 50) {
        
        [self manageDotsBtnSelection:sender];
        
        if ([[standardUserDefaults objectForKey:@"isLoggedIn"] boolValue]) {
            
            NSLog(@"Teach - Logged In");
            
            isTeachFlag = TRUE;
            
            [self getMyClasspages];
            
            if (viewUserSettings.frame.origin.y == 50) {
                [self manageSettingsPanel];
            }
        }else{
            
            NSLog(@"Teach - Logged Out");
            [self manageDOTSforBtn:TAG_BTN_TEACH forData:nil];
            [self displayFUEFor:FUE_TEACH];
            
        }
        
        [appDelegate logMixpanelforevent:@"Tap Teach" and:nil];

    }

    
}

- (IBAction)btnActionStudy:(id)sender {
    
    [self manageDotsBtnSelection:sender];
    

    [txtFieldClasscode setText:@""];
    
    isTeachFlag=FALSE;

    [self manageDOTSforBtn:[sender tag] forData:nil];
    
    
    
    if ([standardUserDefaults objectForKey:@"ClasspageCode"] == nil || [[standardUserDefaults objectForKey:@"ClasspageCode"] isEqualToString:@"NA"]) {
        
        [self displayFUEFor:FUE_STUDY];
        
    }else{
        
        [self verifyClasscode:[standardUserDefaults objectForKey:@"ClasspageCode"]];
        
    }



    

    if (viewUserSettings.frame.origin.y == 50) {
        [self manageSettingsPanel];
    }


        
    [appDelegate logMixpanelforevent:@"Tap Study" and:nil];

    
}

- (IBAction)btnActionDiscover:(id)sender {
    
    if(![sender isSelected]){
        
        [self manageDotsBtnSelection:sender];
        
        [self manageDOTSforBtn:[sender tag] forData:nil];
        
        discoverViewController = [[DiscoverViewController alloc] initWithParentViewController:self];
        
        [self swapCurrentControllerWith:discoverViewController];
        
        [btnGooruSearch sendActionsForControlEvents:UIControlEventTouchUpInside];

    }

}

- (IBAction)btnActionGooruSuggest:(id)sender {
    
    [discoverViewController loadGooruSuggest];
    [btnGooruSuggest setSelected:TRUE];
    [btnGooruSearch setSelected:FALSE];
    
}

- (IBAction)btnActionGooruSearch:(id)sender {
    
    [discoverViewController loadGooruSearch];
    [btnGooruSuggest setSelected:FALSE];
    [btnGooruSearch setSelected:TRUE];
    
}

#pragma mark - Manage DOTS Left Bar -
- (void)manageDOTSforBtn:(int)btnToOpen forData:(NSMutableDictionary*)dictClasspages{
    
    
    UIView* viewToOpenClose = (UIView*)[scrollClasspageTabBar viewWithTag:btnToOpen/10];
    
    switch (btnToOpen) {
        case TAG_BTN_TEACH:
        {
            
            
            if (viewToOpenClose.frame.size.height == 50) {
                
                NSArray* sortedKeysDictClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
                int countClasspages = [sortedKeysDictClasspages count];
                
                CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50+(52*countClasspages));
                [self animateView:viewTeachClasspages forFinalFrame:frame];
                
                [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, 50)];
                
                [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, 50)];
 
                [self manageArrowsToOpen:FALSE forArrow:imgViewArrowDiscover];
                [self manageArrowsToOpen:TRUE forArrow:imgViewArrowTeach];
                [self manageArrowsToOpen:FALSE forArrow:imgViewArrowStudy];
                
                
                for (int i=0; i<countClasspages; i++) {
                    
                    UIButton* btnToAnimate = (UIButton*)[viewTeachClasspages viewWithTag:[[sortedKeysDictClasspages objectAtIndex:i] intValue]];
                    
                    [UIView animateWithDuration:.4f
                                          delay:0
                                        options:UIViewAnimationOptionCurveEaseInOut
                                     animations:^{
                                         
                                         btnToAnimate.frame = CGRectMake( btnToAnimate.frame.origin.x,  btnToAnimate.frame.origin.y + 52*(i+1),  btnToAnimate.frame.size.width,  btnToAnimate.frame.size.height);;
                                         
                                     } completion:^(BOOL finished){
                                         
                                         
                                     }];
                    
                    
                    
                }
                
            }else{
                
//                CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50);
//                [self animateView:viewTeachClasspages forFinalFrame:frame];
//                
//                [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, 50)];
//                
//                [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, 50)];
                
            }
            
            
            break;
        }
            
        case TAG_BTN_STUDY:
        {
            CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50);
            [self animateView:viewTeachClasspages forFinalFrame:frame];
            
            [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, 50)];
            
            [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, 50)];
            
            [self manageArrowsToOpen:FALSE forArrow:imgViewArrowDiscover];
            [self manageArrowsToOpen:FALSE forArrow:imgViewArrowTeach];
            [self manageArrowsToOpen:TRUE forArrow:imgViewArrowStudy];
            
            break;
        }
            
        case TAG_BTN_DISCOVER:
        {
            if (viewToOpenClose.frame.size.height == 50) {
                
                CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50);
                [self animateView:viewTeachClasspages forFinalFrame:frame];
                
                [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, 50)];
                
                [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, 50*2)];
                
                [self manageArrowsToOpen:TRUE forArrow:imgViewArrowDiscover];
                [self manageArrowsToOpen:FALSE forArrow:imgViewArrowTeach];
                [self manageArrowsToOpen:FALSE forArrow:imgViewArrowStudy];

            }else{
                
                CGRect frame = CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50);
                [self animateView:viewTeachClasspages forFinalFrame:frame];
                
                [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, viewTeachClasspages.frame.size.height, viewStudyClasspages.frame.size.width, 50)];
                
                [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, viewStudyClasspages.frame.origin.y + viewStudyClasspages.frame.size.height, viewDiscover.frame.size.width, 50)];
                
            }
            
            break;
        }
            
            
        default:
            break;
    }
    
    [scrollClasspageTabBar setContentSize:CGSizeMake(scrollClasspageTabBar.frame.size.width,viewTeachClasspages.frame.size.height + viewStudyClasspages.frame.size.height + viewDiscover.frame.size.height)];
    
    
    
}

- (void)manageDotsBtnSelection:(id)sender{
    
    
    switch ([sender tag]) {
        case TAG_BTN_TEACH:
        {
            [btnTeach setSelected:TRUE];
            [btnStudy setSelected:FALSE];
            [btnDiscover setSelected:FALSE];
            break;
        }
            
        case TAG_BTN_STUDY:
        {
            [btnTeach setSelected:FALSE];
            [btnStudy setSelected:TRUE];
            [btnDiscover setSelected:FALSE];

            break;
        }
            
        case TAG_BTN_DISCOVER:
        {
            [btnTeach setSelected:FALSE];
            [btnStudy setSelected:FALSE];
            [btnDiscover setSelected:TRUE];

            break;
        }
            
            
        default:
            break;
    }
    
}

- (void)manageArrowsToOpen:(BOOL)isOpening forArrow:(UIImageView*)imgViewArrow{
    
    CGFloat radians = atan2f(imgViewArrow.transform.b, imgViewArrow.transform.a);
    NSString* strRadians = [NSString stringWithFormat:@"%.2f",radians];
    NSLog(@"radians : %f",radians);
    NSLog(@"strRadians : %@",strRadians);

    if (isOpening) {
        
        if ([strRadians isEqualToString:[NSString stringWithFormat:@"0.00"]] || [strRadians isEqualToString:[NSString stringWithFormat:@"-0.00"]]) {
            [self runSpinAnimationOnView:imgViewArrow duration:.3 rotations:.5 repeat:1];
        }

        
    }else{
        
        if ([strRadians isEqualToString:[NSString stringWithFormat:@"3.14"]]) {
            [self runSpinAnimationOnView:imgViewArrow duration:.3 rotations:-.5 repeat:1];
        }
        
    }
    
}


#pragma mark BA Register 
- (IBAction)btnActionSignUp:(id)sender {
    [txtFieldClasscode resignFirstResponder];
    txtFieldClasscode.text=@"";
     NSString* sessionTokenToUse = [standardUserDefaults stringForKey:@"defaultGooruSessionToken"];
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/taxonomy/course.json?sessionToken=%@",[appDelegate getValueByKey:@"ServerURL"],sessionTokenToUse];
    
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionTokenToUse, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/taxonomy/course.json?"] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        [self parseSignupCourseDetails:responseStr];
        //        NSLog(@"getAssignment Response : %@",responseStr);
       [activityIndicatorPrimary stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
       [activityIndicatorPrimary stopAnimating];
       
    }];
    
//    registrationViewController=[[RegistrationViewController alloc]init];
//    [self presentDetailController:registrationViewController inMasterView:self.view];
}

- (IBAction)btnActionhelp:(id)sender {
    
    FUEViewController* fueViewController=[[FUEViewController alloc]init];
    [self presentDetailController:fueViewController inMasterView:self.view];
    
    
}

#pragma mark - Login -
#pragma mark BA Login
- (IBAction)btnActionLogIn:(id)sender {
    [txtFieldClasscode resignFirstResponder];
    txtFieldClasscode.text=@"";
    
    //Mixpanel track dictionary
    [appDelegate logMixpanelforevent:@"Log In Tab" and:nil];
    
    loginViewController=[[LoginViewController alloc]initWithParentViewController:self];
    [self presentDetailController:loginViewController inMasterView:self.view];
}

#pragma mark onLogin Return From LoginViewController
- (void)onLogin{

    
    //Switch Top bar
    [self shouldHideView:btnLogin :TRUE];
    [self animateView:btnHelp forFinalFrame:CGRectMake(464 , btnHelp.frame.origin.y, btnHelp.frame.size.width, btnHelp.frame.size.height)];

    [self shouldHideView:viewBtnSupportLoggedOut :TRUE];
    [btnUserSettings setEnabled:TRUE];
    imgViewSettingsGear.hidden=FALSE;
    
    //Clean up the Assignment Detail View
//    [self removeCurrentDetailViewController];
    
    [self shouldHideView:imgViewArrowTeach :NO];

//    [btnTeach sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Set Username
    [lblUsername setText:[standardUserDefaults stringForKey:@"username"]];
    
    [standardUserDefaults setObject:[NSNumber numberWithBool:TRUE] forKey:@"isLoggedIn"];
    
    
}

#pragma mark onLogin Return From FUEViewController
-(void)starterClasspageIntiatior:(int)tag{
    
    switch (tag) {
        case 10:{
            [btnTeach sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 20:{
            [btnStudy sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 30:{
            [btnDiscover sendActionsForControlEvents:UIControlEventTouchUpInside];
            break;
        }
        default:
            break;
    }
    
    
}


#pragma mark - Logout -
#pragma mark BA Logout

- (IBAction)btnActionLogout:(id)sender {
    isYourFirstClassPageInMC=FALSE;
    isTeachFlag=FALSE;
    
    [appDelegate logMixpanelforevent:@"Log-out - Teach tab" and:NULL];
    [standardUserDefaults setObject:@"NA" forKey:@"token"];
    [standardUserDefaults setObject:[NSNumber numberWithBool:FALSE] forKey:@"isLoggedIn"];
    
    [lblUsername setText:@"Guest"];
    [btnTeach setSelected:FALSE];
    [btnStudy setSelected:FALSE];
    [btnUserSettings setEnabled:FALSE];
     imgViewSettingsGear.hidden=TRUE;
    [self removeUserclassPageViewContentsOnLogout];
    [self manageSettingsPanel];
    
    //Switch Top bar
    [self shouldHideView:btnLogin :FALSE];
    [self animateView:btnHelp forFinalFrame:CGRectMake(391 , btnHelp.frame.origin.y, btnHelp.frame.size.width, btnHelp.frame.size.height)];
    [self shouldHideView:viewBtnSupportLoggedOut :FALSE];
    [btnSupportLoggedOut setSelected:FALSE];

    
    [self shouldHideView:imgViewArrowTeach :YES];
    
    //[self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
    
    [self animateView:viewTeachClasspages forFinalFrame:CGRectMake(viewTeachClasspages.frame.origin.x, viewTeachClasspages.frame.origin.y, viewTeachClasspages.frame.size.width, 50)];
    
    [self animateView:viewStudyClasspages forFinalFrame:CGRectMake(viewStudyClasspages.frame.origin.x, 50, viewStudyClasspages.frame.size.width, viewStudyClasspages.frame.size.height)];

    [self animateView:viewDiscover forFinalFrame:CGRectMake(viewDiscover.frame.origin.x, 100, viewDiscover.frame.size.width, viewDiscover.frame.size.height)];
    
    [btnTeach sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
}

- (IBAction)btnActionSupport:(id)sender {

    //Mixpanel track dictionary
    if ([[standardUserDefaults stringForKey:@"defaultGooruSessionToken"] isEqualToString:@"NA"]) {
        
        NSLog(@"User Auth Status : User Logged Out!");
        [appDelegate logMixpanelforevent:@"Support - Logged out" and:nil];
    }else{
        
        [appDelegate logMixpanelforevent:@"Support - Logged in" and:nil];

    }
}

- (IBAction)btnActionCollectionAnalytics:(id)sender {
    
    CollectionAnalyticsViewController *collectionAnalyticsViewController=[[CollectionAnalyticsViewController alloc]initWithCollectionId:@"670abd63-d49d-41c5-a320-e81878db6651"];
    
     [self presentDetailController:collectionAnalyticsViewController inMasterView:self.view];
}




#pragma mark - User Settings -

#pragma mark BA User Settings
- (IBAction)btnActionUserSettings:(id)sender {
    
    [self manageSettingsPanel];
}



#pragma mark Manage Settings Panel
- (void) manageSettingsPanel{
    
    if (viewUserSettings.frame.origin.y != viewSideBar.frame.origin.y) {
        
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x, viewUserSettings.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x,viewSideBar.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        [UIView commitAnimations];
        
        [self runSpinAnimationOnView:imgViewSettingsGear duration:.5 rotations:-1.5 repeat:1];
        
        [self manageNarrationSettingsVisibility];
        

        
    }else{
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x, viewUserSettings.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x, -viewUserSettings.frame.size.height-viewSideBar.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        //save teacher Narration settings
        //         [viewNarrationSettings removeFromSuperview];
        [UIView commitAnimations];
        
        [self runSpinAnimationOnView:imgViewSettingsGear duration:.5 rotations:1.5 repeat:1];
        
        if ([btnNarrationSettings isSelected]) {
            
             [appDelegate logMixpanelforevent:@"Narration Setting Closed" and:NULL];
            [btnNarrationSettings setSelected:FALSE];
            [narrationSettingsViewController closeNarrationSettings];
        }
        
        if ([btnSupportLoggedIn isSelected]) {
            
            
            [btnSupportLoggedIn setSelected:FALSE];
            
        }
        
        
    }
}
#pragma mark Remove User classpage view on Logout

- (void)removeUserclassPageViewContentsOnLogout{
    for(UIView *subview in [viewTeachClasspages subviews]) {
        
        if (subview.frame.origin.y != 0) {
            [subview removeFromSuperview];
        }
    
    }

}


- (void)manageNarrationSettingsVisibility{
    
    [self animateView:viewLogoutBtn forFinalFrame:CGRectMake(viewLogoutBtn.frame.origin.x, 41, viewLogoutBtn.frame.size.width, viewLogoutBtn.frame.size.height)];
    
    [self animateView:viewBtnSupport forFinalFrame:CGRectMake(viewBtnSupport.frame.origin.x, 657, viewBtnSupport.frame.size.width, viewBtnSupport.frame.size.height)];
}

- (IBAction)btnActionNarrationSettings:(id)sender {
    
    if (![btnNarrationSettings isSelected]) {
        [btnNarrationSettings setSelected:TRUE];
         [appDelegate logMixpanelforevent:@"Narration Settings Opened" and:NULL];
        [self presentDetailController:narrationSettingsViewController inMasterView:viewMasterAssignment];
    }

}


#pragma mark - Textfield delegates -

- (BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField == txtFieldClasscode){
        [btnStudyNow sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return TRUE;
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == txtFieldClasscode){
        if (textField.text.length >= MAX_LENGTH && range.length == 0)
        {
            return NO; // return NO to not change text
        }
        else
        {
            return YES;
        }
        
    }
    return TRUE;
}




#pragma mark - Alertview delegates -
- (void)alertShow:(NSString *)strMessage withTag:(int)tag{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gooru" message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:tag];
    
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 56) {
        exit(0);
    }
    
    
}

#pragma mark - UI Enhancers -
#pragma mark Hide/Unhide Animated!
- (void)shouldHideView:(UIView*)view :(BOOL)value{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

#pragma mark Animate View to Final Frame!
- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark Rotation Animation!
- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat{
    
    //    CABasicAnimation* rotationAnimation;
    //    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    //
    ////    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI];
    //
    //    rotationAnimation.duration = duration;
    //    rotationAnimation.cumulative = YES;
    //    rotationAnimation.repeatCount = repeat;
    //
    //    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    rotations = rotations*2;
    
    
    [UIView animateWithDuration:duration delay:0.0 options:0
                     animations:^{
//                         view.transform = CGAffineTransformRotate(view.transform, M_PI);
                         view.transform = CGAffineTransformRotate(view.transform, M_PI*rotations);
                         CGFloat radians = atan2f(view.transform.b, view.transform.a);
                         NSLog(@"M_PI*rotations : %f",M_PI*rotations);
//                         NSLog(@"radians : %f",radians);
                     }
                     completion:nil];
    
}

#pragma mark - View Controller Manipulators -
- (void)swapCurrentControllerWith:(UIViewController*)viewController{
    
    
//    [self removeCurrentDetailViewController];
    
    //1. The current controller is going to be removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
    
    //2. The new controller is a new child of the container
    [self addChildViewController:viewController];
    
    //3. Setup the new controller's frame depending on the animation you want to obtain
//    viewController.view.frame = CGRectMake(2000, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
    [viewController.view setHidden:TRUE];
    
    //3b. Attach the new view to the views hierarchy
    [viewMasterAssignment addSubview:viewController.view];
    
    
    
    
    [UIView animateWithDuration:0.5
     
     //4. Animate the views to create a transition effect
                     animations:^{
                         
                         
                         //The new controller's view is going to take the position of the current controller's view
//                         viewController.view.frame = CGRectMake(0, 0, 769, 700);
                         [self shouldHideView:viewController.view :FALSE];
                         
                         //The current controller's view will be moved outside the window
//                         self.currentDetailViewController.view.frame = CGRectMake(-2000,0,769,700);
                         [self shouldHideView:self.currentDetailViewController.view :TRUE];
                    
                         
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

- (void)presentDetailController:(UIViewController*)detailVC{
    
    //0. Remove the current Detail View Controller showed
    if(self.currentDetailViewController){
        [self removeCurrentDetailViewController];
    }
    
    //1. Add the detail controller as child of the container
    [self addChildViewController:detailVC];
    
    //2. Define the detail controller's view size
//    detailVC.view.frame = [self frameForDetailController];
    
    //3. Add the Detail controller's view to the Container's detail view and save a reference to the detail View Controller
    [viewMasterAssignment addSubview:detailVC.view];
    self.currentDetailViewController = detailVC;
    
    //4. Complete the add flow calling the function didMoveToParentViewController
    [detailVC didMoveToParentViewController:self];
    
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
                         detailVC.view.alpha = 1;
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




- (IBAction)btnActionLaunchPlayer:(id)sender{
    
    NSMutableDictionary* dictAppDetails = [[NSMutableDictionary alloc] init];
    [dictAppDetails setValue:[appDelegate getValueByKey:@"ServerURL"] forKey:@"ServerUrl"];

    //Mix with intermittent narration
    [dictAppDetails setValue:@"12f16eb2-fc89-4990-ae15-bcd30bb869cb" forKey:@"CollectionGooruId"];
    
    //NO QUESTIONS
//    [dictAppDetails setValue:@"19222d32-ef58-4945-aa75-f72ed1d42aa4" forKey:@"CollectionGooruId"];
    
    //ALL QUESTIONS WITH RICH TEXT
//    [dictAppDetails setValue:@"8cadbf10-6973-4b3c-8fc4-f19c57cf21d7" forKey:@"CollectionGooruId"];
    
    //ALL QUESTIONS
//    [dictAppDetails setValue:@"751d48a8-0859-451e-af85-cafebc63acd7" forKey:@"CollectionGooruId"];
    
    [dictAppDetails setValue:@"NA" forKey:@"ResourceInstanceId"];
    
    [dictAppDetails setValue:@"96d11705-f986-4533-8387-2e7a0c97f0be" forKey:@"SessionToken"];
    [dictAppDetails setValue:@"True" forKey:@"isTeacher"];
    [dictAppDetails setValue:@"True" forKey:@"shouldAutoloadNarration"];
    [dictAppDetails setValue:@"True" forKey:@"isAnonymous"];
    
    CollectionPlayerV2ViewController* collectionPlayerV2ViewController = [[CollectionPlayerV2ViewController alloc] initWithAppDetails:dictAppDetails];
    
    [self presentViewController:collectionPlayerV2ViewController animated:YES completion:nil];
    
}

#pragma - Alert Delegate -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    if (alertView.tag == TAG_REACHABILITY_ALERT) {
        if (buttonIndex == 0)
        {
            NSLog(@"Retry Tapped : %@",internetReachableFoo.currentReachabilityString);
            if ([internetReachableFoo.currentReachabilityString isEqualToString:@"No Connection"]) {
                [alertViewForReachability show];
            }
            
            
        }
        else if (buttonIndex == 1)
        {
            NSLog(@"OK Tapped. Hello World!");
            exit (0);
        }
    }
    
}

#pragma mark - Internet Connection Checks -

- (void)testInternetConnection
{
    internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [alertViewForReachability show];
            [appDelegate removeLibProgressView:self.view];
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [internetReachableFoo startNotifier];
}

@end
