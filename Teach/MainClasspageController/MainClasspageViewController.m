
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
#import "SVWebViewController.h"
#import "Reachability.h"
#import "CollectionPlayerV2ViewController.h"

#define MULTIPLIER_CLASSPAGETABS 666
#define MULTIPLIER_CLASSPAGETABSTEACH 777
#define MAX_LENGTH 10

#define TAG_REACHABILITY_ALERT 9890

@interface MainClasspageViewController ()
@property UIViewController  *currentDetailViewController;
@end

@implementation MainClasspageViewController

AppDelegate *appDelegate;
NSUserDefaults* standardUserDefaults;
NSString* sessionTokenMainClassPageView;

AssignmentViewController * assignmentDetailViewController;
LoginViewController* loginViewController;
NarrationSettingsViewController* narrationSettingsViewController;

NSMutableDictionary* dictStarterClasspages;
NSMutableDictionary *dictUserClasspages;
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
        
        //When Not Logged In
        [viewUserClasspages setHidden:TRUE];
        viewStarterClasspages.frame = CGRectMake(0, 0, viewStarterClasspages.frame.size.width, viewStarterClasspages.frame.size.height);
        [btnUserSettings setEnabled:FALSE];
        imgViewSettingsGear.hidden=TRUE;
        
        narrationSettingsViewController = [[NarrationSettingsViewController alloc] initWithNibName:@"NarrationSettingsViewController" bundle:nil];
        [narrationSettingsViewController setNarrationDefaultSettings];
        

        if ([standardUserDefaults objectForKey:@"classpageCodeNotLoggedIn"] != nil) {
            [self getClasspageIdforClasspageCode:[standardUserDefaults objectForKey:@"classpageCodeNotLoggedIn"]];
        }else{
            [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
        }
        
        viewBtnSupportLoggedOut.hidden=FALSE;
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
     [self populateUserClasspageTabsWithData:dictUserClasspages];
    
   
}



#pragma mark Populate User Classpages
- (void)populateUserClasspageTabsWithData:(NSMutableDictionary*)dictClasspages{
    //Clean Classpage View
    
    [viewUserClasspages setHidden:FALSE];
    
    for (UIView *aView in [viewUserClasspages subviews]){
        if (aView.frame.origin.y != 0) {
            [aView removeFromSuperview];
        }
        
        
    }
    
    NSArray* sortedKeysDictClasspages = [appDelegate sortedIntegerKeysForDictionary:dictClasspages];
    int countClasspages = [sortedKeysDictClasspages count];
    NSLog(@"countClasspages : %i",countClasspages);
    
    
    if (countClasspages != 0) {
        
        int lastYordinate = 20;
        
        
        CGRect frame = CGRectMake(viewUserClasspages.frame.origin.x, viewUserClasspages.frame.origin.y, viewUserClasspages.frame.size.width, 20+(52*countClasspages));
        [self animateView:viewUserClasspages forFinalFrame:frame];
        
        for (int i=0; i<countClasspages; i++) {
            
            NSString* keyInUse = [sortedKeysDictClasspages objectAtIndex:i];
            NSMutableDictionary* dictInUse = [dictClasspages valueForKey:keyInUse];
            
            btn_classpageTitle = [[UIButton alloc]init];
            btn_classpageTitle.frame = CGRectMake(0,lastYordinate,scrollClasspageTabBar.frame.size.width,50);
            
            [btn_classpageTitle setTitle:[dictInUse valueForKey:@"classpageTitle"] forState:UIControlStateNormal];
            [btn_classpageTitle setBackgroundImage:[UIImage imageNamed:@"classpageButtonSelected.png"] forState:UIControlStateSelected];
            [btn_classpageTitle setBackgroundImage:[UIImage imageNamed:@"classpagebuttondefault.png"] forState:UIControlStateNormal];
            [btn_classpageTitle.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [btn_classpageTitle.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [btn_classpageTitle  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btn_classpageTitle.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [btn_classpageTitle addTarget:self action:@selector(btnActionUserClasspage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            
            //Delete Button
            UIButton *btnClasspageDelete = [[UIButton alloc] init];
            btnClasspageDelete.frame = CGRectMake(0,0,btn_classpageTitle.frame.size.width,btn_classpageTitle.frame.size.height);
            [btnClasspageDelete setBackgroundImage:[UIImage imageNamed:@"btnClasspageDeleteOverlay@2x.png"] forState:UIControlStateNormal];
            [btnClasspageDelete setHidden:TRUE];
            
            //Swipe gesture for button
            UISwipeGestureRecognizer* swipeUpGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            
            UISwipeGestureRecognizer* swipeUpGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
            
            //Setting Tag
            int classpageTag = [keyInUse intValue];
            [btn_classpageTitle setTag:classpageTag];            
            if (i == 0) {
                [btn_classpageTitle sendActionsForControlEvents:UIControlEventTouchUpInside];
            }

            [viewUserClasspages addSubview:btn_classpageTitle];
            
            
            //Set
            btn_classpageTitle.frame = CGRectMake( btn_classpageTitle.frame.origin.x - btn_classpageTitle.frame.size.width,  btn_classpageTitle.frame.origin.y ,  btn_classpageTitle.frame.size.width,  btn_classpageTitle.frame.size.height);
            
            [UIView animateWithDuration:0.2f
                                  delay:.2*i
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 btn_classpageTitle.frame = CGRectMake( btn_classpageTitle.frame.origin.x + btn_classpageTitle.frame.size.width,  btn_classpageTitle.frame.origin.y,  btn_classpageTitle.frame.size.width,  btn_classpageTitle.frame.size.height);;
                                 
                             } completion:^(BOOL finished){
                             }];
            lastYordinate = lastYordinate+btn_classpageTitle.frame.size.height+2;
        }
        [scrollClasspageTabBar setContentSize:CGSizeMake(scrollClasspageTabBar.frame.size.width,lastYordinate)];
        if ([btnStudy isSelected]) {
            [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:NO];
        }else if([btnTeach isSelected]){
             [self setUpStarterClasspageDictionaryAndShouldAutoPopulateForTeach:NO];
        }else{
             [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:NO];
        }
       
    }else{
        
        if ([btnStudy isSelected]) {
            [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
        }else if([btnTeach isSelected]){
            
            [self setUpStarterClasspageDictionaryAndShouldAutoPopulateForTeach:YES];
        }else{
            [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
        }
    }
    
    
    
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
            
            UIButton* btnToDeselect = (UIButton*)[viewUserClasspages viewWithTag:[[sortedKeysDictUserClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        //Unselect All Buttons in Starter Classpages
        for (UIButton *aView in [viewStarterClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                if ([aView isSelected]) {
                    [aView setSelected:FALSE];

                }
            }
        }
        
        
        
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
#pragma mark Setup Starter Classpages
- (void)setUpStarterClasspageDictionaryAndShouldAutoPopulate:(BOOL)value{
    
    NSArray* arrSuggestedClasspageTitles;
    if ([btnStudy isSelected]) {
        arrSuggestedClasspageTitles = [appDelegate getArrayValueByKey:@"StarterClasspages"];
    }else{
     arrSuggestedClasspageTitles = [appDelegate getArrayValueByKey:@"StarterClasspages1"];
    }
    NSArray* arrSuggestedClasspageIds = [appDelegate getArrayValueByKey:@"StarerClasspagesGooruId"];
 
    
    NSArray* arrSuggestedClasspageCodes =[appDelegate getArrayValueByKey:@"StarterClasspageClasscodes"] ;
    
    dictStarterClasspages = [[NSMutableDictionary alloc] init];
    for (int i=0; i<5; i++) {
        
        NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
        
        [dictClasspageInstance setValue:[arrSuggestedClasspageTitles objectAtIndex:i] forKey:@"classpageTitle"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageIds objectAtIndex:i] forKey:@"classpageId"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageCodes objectAtIndex:i] forKey:@"classpageCode"];
        
        
        
        NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABS];
        [dictStarterClasspages setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
        
    }
    
    
    [self populateStarterClasspageTabsWithData:dictStarterClasspages shouldAutoPopulate:value];
    
}

- (void)setUpStarterClasspageDictionaryAndShouldAutoPopulateForTeach:(BOOL)value{
    
    isYourFirstClassPageInMC=TRUE;
    NSArray* arrSuggestedClasspageTitles = [appDelegate getArrayValueByKey:@"StarerClasspageTeach"];
    
    NSArray* arrSuggestedClasspageIds = [appDelegate getArrayValueByKey:@"StarerClasspagesGooruIdTeach"];
    
    
    NSArray* arrSuggestedClasspageCodes = [appDelegate getArrayValueByKey:@"StarterClasspageClasscodesTeach"];
    
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
    for (UIView *aView in [viewStarterClasspages subviews]){
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
        if ([viewUserClasspages isHidden]) {
            frame = CGRectMake(viewStarterClasspages.frame.origin.x, viewStarterClasspages.frame.origin.y, viewStarterClasspages.frame.size.width, 20+(52*countClasspages));
        }else{
            if (value) {
                NSLog(@"viewStarterClasspages.frame.origin.y=%f",viewStarterClasspages.frame.origin.y);
                 frame = CGRectMake(viewStarterClasspages.frame.origin.x, 0, viewStarterClasspages.frame.size.width, 20+(52*countClasspages));
            }else{
            frame = CGRectMake(viewUserClasspages.frame.origin.x, viewUserClasspages.frame.size.height, viewUserClasspages.frame.size.width, 20+(52*countClasspages));
            }
        }
        
        [self animateView:viewStarterClasspages forFinalFrame:frame];
        
        for (int i=0; i<countClasspages; i++) {
            
            NSString* keyInUse = [sortedKeysDictClasspages objectAtIndex:i];
            NSLog(@"keyInUse=%@",[keyInUse description]);
            NSMutableDictionary* dictInUse = [dictClasspages valueForKey:keyInUse];
             NSLog(@"dictInUse=%@",[dictInUse description]);
            btn_classpageTitle = [[UIButton alloc]init];
            btn_classpageTitle.frame = CGRectMake(0,lastYordinate,scrollClasspageTabBar.frame.size.width,50);
            
            [btn_classpageTitle setTitle:[dictInUse valueForKey:@"classpageTitle"] forState:UIControlStateNormal];
            [btn_classpageTitle setBackgroundImage:[UIImage imageNamed:@"classpageButtonSelected.png"] forState:UIControlStateSelected];
            [btn_classpageTitle setBackgroundImage:[UIImage imageNamed:@"classpagebuttondefault.png"] forState:UIControlStateNormal];
            [btn_classpageTitle.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
            [btn_classpageTitle.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [btn_classpageTitle  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btn_classpageTitle.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            
            if (i==0) {
                  NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
                [btn_classpageTitle addTarget:self action:@selector(btnActionStarterClasspageFirstUserExp:) forControlEvents:UIControlEventTouchUpInside];
               
            }else{
                 NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
            [btn_classpageTitle addTarget:self action:@selector(btnActionStarterClasspage:) forControlEvents:UIControlEventTouchUpInside];
            
            }
            
            //Delete Button
            UIButton *btnClasspageDelete = [[UIButton alloc] init];
            btnClasspageDelete.frame = CGRectMake(0,0,btn_classpageTitle.frame.size.width,btn_classpageTitle.frame.size.height);
            [btnClasspageDelete setBackgroundImage:[UIImage imageNamed:@"btnClasspageDeleteOverlay@2x.png"] forState:UIControlStateNormal];
            [btnClasspageDelete setHidden:TRUE];
            
            //Swipe gesture for button
            UISwipeGestureRecognizer* swipeUpGestureRecognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            //            [btn_classpageTitle addGestureRecognizer:swipeUpGestureRecognizerLeft];
            
            
            UISwipeGestureRecognizer* swipeUpGestureRecognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeForClasspageDeleteFrom:)];
            swipeUpGestureRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
            
            //Setting Tag
            int classpageTag = [keyInUse intValue];
            [btn_classpageTitle setTag:classpageTag];
            
            if (i == 0) {
                if (value) {
                    [btn_classpageTitle sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
                
            }
            
            [viewStarterClasspages addSubview:btn_classpageTitle];
            
            lastYordinate = lastYordinate+btn_classpageTitle.frame.size.height+2;
        }
        [scrollClasspageTabBar setContentSize:CGSizeMake(scrollClasspageTabBar.frame.size.width,viewStarterClasspages.frame.origin.y + viewStarterClasspages.frame.size.height)];
        
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
        
    
        //Unselect all buttons
        
        NSArray* sortedKeysdictStarterClasspages = [appDelegate sortedIntegerKeysForDictionary:dictStarterClasspages];
        int countClasspages = [sortedKeysdictStarterClasspages count];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToDeselect = (UIButton*)[viewStarterClasspages viewWithTag:[[sortedKeysdictStarterClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        //Unselect All Buttons in User Classpages
        for (UIButton *aView in [viewUserClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                [aView setSelected:FALSE];
            }
        }
        assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictStarterClasspageInUse forTeach:NO];
        if (isYourFirstClassPageInMC) {

            assignmentDetailViewController.isYourFirstClasspageAss=isYourFirstClassPageInMC;
        }else{
            
        }
           
       [self presentDetailController:assignmentDetailViewController];

    }
    
        
}

#pragma mark BA Starter Classpages for FUE

- (void)btnActionStarterClasspageFUE:(id)sender{
    if ([sender tag]==1554) {
        isYourFirstClassPageInMC=TRUE;
    }
    NSLog(@"sender : %@",sender);
    [btnSupportLoggedOut setSelected:FALSE];
    
    UIButton *tempBtn = (UIButton *)[viewStarterClasspages viewWithTag:[sender tag]];    
    
    if (![tempBtn isSelected]) {
        NSMutableDictionary* dictStarterClasspageInUse = [dictStarterClasspages valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]];
        NSLog(@"dictInUse : %@",[dictStarterClasspageInUse description]);
        
        
        
        //Unselect all buttons
        
        NSArray* sortedKeysdictStarterClasspages = [appDelegate sortedIntegerKeysForDictionary:dictStarterClasspages];
        int countClasspages = [sortedKeysdictStarterClasspages count];
        
        for (int i=0; i<countClasspages; i++) {
            
            UIButton* btnToDeselect = (UIButton*)[viewStarterClasspages viewWithTag:[[sortedKeysdictStarterClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        

        //Unselect All Buttons in User Classpages
        for (UIButton *aView in [viewUserClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                [aView setSelected:FALSE];
            }
        }
        
        
        [tempBtn setSelected:TRUE];
        
        assignmentDetailViewController = [[AssignmentViewController alloc] initWithClasspageDetails:dictStarterClasspageInUse forTeach:NO];
        if (isYourFirstClassPageInMC) {
            
            assignmentDetailViewController.isYourFirstClasspageAss=isYourFirstClassPageInMC;
        }else{
            
        }
        [self swapCurrentControllerWith:assignmentDetailViewController];
        
    }
    
    
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
            
            UIButton* btnToDeselect = (UIButton*)[viewStarterClasspages viewWithTag:[[sortedKeysdictStarterClasspages objectAtIndex:i] intValue]];
            [btnToDeselect setSelected:FALSE];
        }
        
        
        [tempBtn setSelected:TRUE];
        
        //Unselect All Buttons in User Classpages
        for (UIButton *aView in [viewUserClasspages subviews]){
            if (aView.frame.origin.y != 0) {
                [aView setSelected:FALSE];
            }
        }
        
        [btnSupportLoggedOut setSelected:FALSE];
        
        if([viewUserClasspages isHidden] ){
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
    [self classcodeVerify];
}

#pragma mark Classcode Validation
- (void)classcodeVerify{
    
    NSString* classpageCode = txtFieldClasscode.text;
    
    NSString *trimmedString = [classpageCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
#pragma mark CallingGetClassPage Method

- (void)callGetClassPageIdFromFUE:(NSString *)classPageCode{
     isTeachFlag = FALSE;
     [self getClasspageIdforClasspageCode:classPageCode];
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
       
        [self parseClasspageId:responseStr forClasspageCode:classpageCode];
       
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [activityIndicatorPrimary stopAnimating];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        
    }];
    
}

- (void)parseClasspageId:(NSString*)responseString forClasspageCode:(NSString*)strClasspageCode{
    
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
          NSString* sessionTokenToUse = [standardUserDefaults stringForKey:@"token"];
        if ([sessionTokenToUse isEqualToString:@"NA"]) {
            
            NSLog(@"User Auth Status : User Logged Out!");
          
            [standardUserDefaults setObject:strClasspageCode forKey:@"classpageCodeNotLoggedIn"];
        }else{
            if (![viewTopBarLoggedIn isHidden]) {
                [btnStudy setSelected:TRUE];
                [btnTeach setSelected:FALSE];
                isYourFirstClassPageInMC=FALSE;
            }
            [standardUserDefaults setObject:strClasspageCode forKey:@"classpageCode"];
            NSLog(@"User Auth Status : User Logged In!");
        }
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:[results valueForKey:@"title"] forKey:@"classpageTitle"];
        [standardUserDefaults setObject:[results valueForKey:@"gooruOid"] forKey:@"gooruOid"];
        [standardUserDefaults setObject:[[results valueForKey:@"thumbnails"] valueForKey:@"url"] forKey:@"thumbnailUrl"];

        dictUserClasspages = [[NSMutableDictionary alloc] init];
        for (int i=0; i<1; i++) {
            
            NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
            
            [dictClasspageInstance setValue:[results valueForKey:@"title"] forKey:@"classpageTitle"];
            [dictClasspageInstance setValue:[results valueForKey:@"gooruOid"] forKey:@"classpageId"];
            [dictClasspageInstance setValue:[[results valueForKey:@"thumbnails"] valueForKey:@"url"] forKey:@"thumbnailUrl"];
            [dictClasspageInstance setValue:strClasspageCode forKey:@"classpageCode"];
            
            NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABS];
            [dictUserClasspages setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
            
        }
        
        
        [self populateUserClasspageTabsWithData:dictUserClasspages];
        
    
    }
    
    
    
    
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
          
            NSArray *arrayNodes=[[results objectAtIndex:i]objectForKey:@"node"];
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
    if (![btnTeach isSelected]) {
        
        [viewTopBarLoggedIn setUserInteractionEnabled:FALSE];
        isTeachFlag = TRUE;
        
        [btnTeach setSelected:TRUE];
        [btnStudy setSelected:FALSE];
        [self getMyClasspages];
        
        if (viewUserSettings.frame.origin.y == 50) {
            [self manageSettingsPanel];
        }
    }
    
    
    
}

- (IBAction)btnActionStudy:(id)sender {
    
    if (![btnStudy isSelected]) {
        
        
        isTeachFlag = FALSE;
        isYourFirstClassPageInMC=FALSE;
        
        [btnStudy setSelected:TRUE];
        [btnTeach setSelected:FALSE];
        [txtFieldClasscode setText:@""];
        
        
        
        [self shouldHideView:viewUserClasspages :TRUE];
         NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if ([standardUserDefaults objectForKey:@"classpageCode"] != nil) {
            isTeachFlag=FALSE;
            [self getClasspageIdforClasspageCode:[standardUserDefaults objectForKey:@"classpageCode"]];
        }else{
           [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES]; 
        }
        
        [self animateView:viewStarterClasspages forFinalFrame:CGRectMake(viewStarterClasspages.frame.origin.x, 0, viewStarterClasspages.frame.size.width, viewStarterClasspages.frame.size.height)];
        
        [self removeCurrentDetailViewController];
        
        if (viewUserSettings.frame.origin.y == 50) {
            [self manageSettingsPanel];
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
       [activityIndicatorPrimary stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
       [activityIndicatorPrimary stopAnimating];
       
    }];

}

#pragma mark - Login -
#pragma mark BA Login
- (IBAction)btnActionLogIn:(id)sender {
    [txtFieldClasscode resignFirstResponder];
    txtFieldClasscode.text=@"";
    
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    if ([standardUserDefaults objectForKey:@"classpageCode"] != nil) {
        [standardUserDefaults setObject:nil forKey:@"classpageCode"];
        //isTeachFlag=FALSE;
        
    }else{
        
    }

    
    loginViewController=[[LoginViewController alloc]init];
    [self presentDetailController:loginViewController inMasterView:self.view];
}

#pragma mark onLogin Return From LoginViewController
- (void)onLogin{
    
    //Unhide User Classpage Parent
    [self shouldHideView:viewUserClasspages :FALSE];
    
    //Switch Top bar
    [self shouldHideView:viewTopBarLoggedOut :TRUE];
    [self shouldHideView:viewTopBarLoggedIn :FALSE];
    [self shouldHideView:viewBtnSupportLoggedOut :TRUE];
    [btnUserSettings setEnabled:TRUE];
    imgViewSettingsGear.hidden=FALSE;
    
    //Clean up the Assignment Detail View
    [self removeCurrentDetailViewController];
    
    
    [btnTeach sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //Set Username
    [lblUsername setText:[standardUserDefaults stringForKey:@"username"]];
    
    
}

#pragma mark - Logout -
#pragma mark BA Logout

- (IBAction)btnActionLogout:(id)sender {
    isYourFirstClassPageInMC=FALSE;
    isTeachFlag=FALSE;
    
 //   [appDelegate logMixpanelforevent:@"Log-out - Teach tab" and:NULL];
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
    [self shouldHideView:viewTopBarLoggedOut :FALSE];
    [self shouldHideView:viewTopBarLoggedIn :TRUE];
    [self shouldHideView:viewBtnSupportLoggedOut :FALSE];
    [btnSupportLoggedOut setSelected:FALSE];
    if ([standardUserDefaults objectForKey:@"classpageCodeNotLoggedIn"] != nil) {
     
        [self getClasspageIdforClasspageCode:[standardUserDefaults objectForKey:@"classpageCodeNotLoggedIn"]];
    }else{
        [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
    }
    
    if ([standardUserDefaults objectForKey:@"classpageCode"] != nil) {
        [standardUserDefaults setObject:nil forKey:@"classpageCode"];
        
        
    }else{
        
    }
    
    
    [self animateView:viewStarterClasspages forFinalFrame:CGRectMake(viewStarterClasspages.frame.origin.x, 0, viewStarterClasspages.frame.size.width, viewStarterClasspages.frame.size.height)];

    
    
}

- (IBAction)btnActionSupport:(id)sender {

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
        
        [self runSpinAnimationOnView:imgViewSettingsGear duration:.5 rotations:1 repeat:1];
        
        [self manageNarrationSettingsVisibility];
        

        
    }else{
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x, viewUserSettings.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationDelegate:self];
        
        viewUserSettings.frame = CGRectMake(viewUserSettings.frame.origin.x, -viewUserSettings.frame.size.height-viewSideBar.frame.origin.y, viewUserSettings.frame.size.width, viewUserSettings.frame.size.height);
        
        //save teacher Narration settings
        [UIView commitAnimations];
        
        [self runSpinAnimationOnView:imgViewSettingsGear duration:.5 rotations:.5 repeat:1];
        
        if ([btnNarrationSettings isSelected]) {
            
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
    for(UIView *subview in [viewUserClasspages subviews]) {
        
        if (subview.frame.origin.y != 0) {
            [subview removeFromSuperview];
        }
    
    }

}


- (void)manageNarrationSettingsVisibility{
  
    [self animateView:viewBtnSupport forFinalFrame:CGRectMake(viewBtnSupport.frame.origin.x, 657, viewBtnSupport.frame.size.width, viewBtnSupport.frame.size.height)];
}

- (IBAction)btnActionNarrationSettings:(id)sender {
    
    if (![btnNarrationSettings isSelected]) {
        [btnNarrationSettings setSelected:TRUE];
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
    
    
    [UIView animateWithDuration:duration delay:0.0 options:0
                     animations:^{
                         view.transform = CGAffineTransformRotate(view.transform, M_PI);
                     }
                     completion:nil];
    
}

#pragma mark - View Controller Manipulators -
- (void)swapCurrentControllerWith:(UIViewController*)viewController{
    
     NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    
    //1. The current controller is going to be removed
    [self.currentDetailViewController willMoveToParentViewController:nil];
       NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    //2. The new controller is a new child of the container
    [self addChildViewController:viewController];
       NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    //3. Setup the new controller's frame depending on the animation you want to obtain
    viewController.view.frame = CGRectMake(2000, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
       NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    //3b. Attach the new view to the views hierarchy
    [viewMasterAssignment addSubview:viewController.view];
    
    
       NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
    
    
    [UIView animateWithDuration:0.0
     
     //4. Animate the views to create a transition effect
                     animations:^{
                         
                          NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
                         
                         //The new controller's view is going to take the position of the current controller's view
                         viewController.view.frame = CGRectMake(0, 0, 769, 700);
                         
                         //The current controller's view will be moved outside the window
                         self.currentDetailViewController.view.frame = CGRectMake(-2000,0,769,700);
                    
                         
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
                          NSLog(@"dictStarterClasspages=%@",[dictStarterClasspages description]);
                         
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


#pragma mark Delete classcode from FUEOther
- (void)deleteClassCodeOnExitClassPageBtnClick{
    if ([standardUserDefaults objectForKey:@"classpageCodeNotLoggedIn"] != nil) {
        [standardUserDefaults setObject:nil forKey:@"classpageCodeNotLoggedIn"];
        //isTeachFlag=FALSE;
        
    }else{
        
    }
    [self setUpStarterClasspageDictionaryAndShouldAutoPopulate:YES];
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
