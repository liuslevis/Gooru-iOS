//
//  AssignmentViewController.m
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

#import "AssignmentViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FlatDatePicker.h"
#import "Toast+UIView.h"
#import "AFHTTPClient.h"
#import "Reachability.h"
#import "SVWebViewController.h"
#import "AppDelegate.h"
#import "EditAssignmentPopupViewController.h"
#import "NSString_stripHtml.h"
#import "CollectionPlayerV2ViewController.h"


#define MULTIPLIER_ASSIGNMENTS 777
#define MULTIPLIER_ASSIGNMENT_VIEW 100
#define MULTIPLIER_ASSIGNMENT_ITEMS 888
#define TAG_ASSIGNMENT_ITEM_VIEWS 52


#define TAG_VIEW_NO_ASSIGNMENT 69

#define TAG_ASSIGNMENT_TITLE 13
#define TAG_ASSIGNMENT_DIRECTION 26
#define TAG_ASSIGNMENT_DUEDATE 39
#define TAG_ASSIGNMENT_ACTIVITYINDICATOR 52
#define TAG_ASSIGNMENT_DIRECTION_HELPER 65



@interface AssignmentViewController ()
@property UIViewController  *currentDetailViewController;

@end

@implementation AssignmentViewController
@synthesize btnExitClasspage,btnExitClasspageNoAssignment;
@synthesize isLoggedOut;
@synthesize isYourFirstClasspageAss;



AppDelegate *appDelegate;
NSUserDefaults* standardUserDefaults;
NSString* sessionToken;


EditAssignmentPopupViewController* editAssignmentPopupViewController;


//Pull to refresh items
BOOL flagIsDragging = TRUE;

//Mode Flag
BOOL isTeach = TRUE;



//Global Classpage Dictionary
NSMutableDictionary* dictClasspage;

//Global Assignment Dictionary
NSMutableDictionary* dictAssignments;

//Global Assignment Item Dictionary
NSMutableDictionary* dictAssignmentsItems;

//Assignment to be populated
UIView* viewAssignmentToBePopulated;
UILabel* lblCollectionViewsToBeRefreshed;

//Activity Indicator in Use
UIActivityIndicatorView *activityIndicatorAssignmentItemsInUse;

//Font for Classcode
UIFont* tahoma;

float originalAssignmentScrollContentSizeHeight;

#pragma mark - Init and View Lifecycle -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithClasspageDetails:(NSMutableDictionary*)dictIncomingClasspage forTeach:(BOOL)value{
    
    dictClasspage = dictIncomingClasspage;
    isTeach = value;
    
    return self;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self didMoveToParentViewController:self];
    
//    sessionToken  = [standardUserDefaults stringForKey:@"token"];
//    
//    if ([sessionToken isEqualToString:@"NA"]) {
//        NSLog(@"User Auth Status : User Logged Out!");
//        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
//    }else{
//        NSLog(@"User Auth Status : User Logged In!");
//    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    tahoma        = [UIFont fontWithName:@"Tahoma" size:15.0];

    if ([sessionToken isEqualToString:@"NA"]) {
        NSLog(@"User Auth Status : User Logged Out!");
        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
    }else{
        NSLog(@"User Auth Status : User Logged In!");
    }
    
//    if (isLoggedOut) {
//        [btnExitClasspage setHidden:FALSE];
//        [viewExitClasspage setHidden:FALSE];
//        isLoggedOut=FALSE;
//        // isLoggedOut=FALSE;
//    }else{
//        [btnExitClasspage setHidden:TRUE];
//        [viewClasscodeEmail setHidden:FALSE];
//        // isLoggedOut=FALSE;
//        
//    }
    if (isTeach) {
        [viewClasscodeEmail setHidden:FALSE];
        [viewExitClasspage setHidden:TRUE];
    }else{
        [viewClasscodeEmail setHidden:TRUE];
        [viewExitClasspage setHidden:FALSE];

    }
    
   
    //Add No Assignment View to Assignments
    [viewAssignments addSubview:viewNoAssignments];
    [viewNoAssignments setTag:TAG_VIEW_NO_ASSIGNMENT];
    [viewNoAssignments setHidden:TRUE];

    //Set Classpage Title
    [lblClasspageTitle setText:[dictClasspage valueForKey:@"classpageTitle"]];
    [imgClasspageThumbnail setImageWithURL:[dictClasspage valueForKey:@"thumbnailUrl"] placeholderImage:[UIImage imageNamed:@"default-classpage.png"]];
    
    [self setImageIfStarterClasspageForClasspageId:[dictClasspage valueForKey:@"classpageId"]];
    

    txtViewShareClasscode.font = tahoma;
    
    NSLog(@"dictClasspage share : %@ ",[[dictClasspage valueForKey:@"classpageCode"] uppercaseString]);
    txtViewShareClasscode.text = [[dictClasspage valueForKey:@"classpageCode"] uppercaseString];
    
    [self getAllAssignmentsForClasspageId:[dictClasspage valueForKey:@"classpageId"]];
    
    //Adding Observer to Refresh Views
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAssignmentItemViews) name:@"refreshAssignmentItemViews" object:nil];

}

#pragma mark Set Image for starter classpages
- (void)setImageIfStarterClasspageForClasspageId:(NSString*)classpageId{
    
    if ([classpageId isEqualToString:@"272e9c46-c0a9-427a-9a0d-f31eb051ce3a"]) {
        [imgClasspageThumbnail setImage:[UIImage imageNamed:@"1_Page.png"]];
        
    }else if ([classpageId isEqualToString:@"087ddf35-6b2b-4411-9832-d8e789a25888"]) {
        
        [imgClasspageThumbnail setImage:[UIImage imageNamed:@"2_Page.png"]];
        
    }else if ([classpageId isEqualToString:@"6b2fbea8-b3e9-4b74-937b-28e209049eec"]) {
        
        [imgClasspageThumbnail setImage:[UIImage imageNamed:@"3_Page.png"]];
        
    }else if ([classpageId isEqualToString:@"18c2e8db-ffcc-471e-960b-78b5ae30b98d"]) {
        
        [imgClasspageThumbnail setImage:[UIImage imageNamed:@"4_Page.png"]];
        
    }
    
    
    
}

#pragma mark - Assignments -
#pragma mark Get all Assignments for a Classpage
- (void)getAllAssignmentsForClasspageId:(NSString*)gooruOid{
    
    [activityIndicatorLoadAssignments startAnimating];
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/v2/classpage/%@/item?sessionToken=%@&data={\"skipPagination\":\"true\"}",[appDelegate getValueByKey:@"ServerURL"],gooruOid,sessionToken];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"data", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, @"{\"skipPagination\":\"true\"}", nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/classpage/%@/item?",gooruOid] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //        NSLog(@"getAssignment Response : %@",responseStr);
        [self parseAssignments:responseStr];
        [activityIndicatorLoadAssignments stopAnimating];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [activityIndicatorLoadAssignments stopAnimating];
    }];
    
}

- (void)parseAssignments:(NSString*)responseString{
    
    NSArray *results = [responseString JSONValue];
    
    NSLog(@"results : %@",[results description]);
    
    BOOL isAssignmemtsEmpty;
    
    NSArray* arrSearchResults = results;
    NSString* strTotalHitCount = [NSString stringWithFormat:@"%i",[arrSearchResults count]];
    
    
    
    NSLog(@"strTotalHitCount : %@",strTotalHitCount);
    NSLog(@"arrSearchResults : %@",[arrSearchResults description]);
    
    if([strTotalHitCount intValue] == 0){
        
        //Populate no results screen
        NSLog(@"CONNECTION_IDENTIFIER_ASSIGNMENTS no results");
        isAssignmemtsEmpty = TRUE;
    }else{
        
        isAssignmemtsEmpty = FALSE;
        
        //            NSLog(@"arrSearchResults : %@",[arrSearchResults description]);
        
        int countArrSearchResults = [arrSearchResults count];
        
        dictAssignments = [[NSMutableDictionary alloc] init];
        
        for (int i=0; i<countArrSearchResults; i++) {
            
            
            //Parse resource
            NSString* strTask = [appDelegate ifNullStrReplace:[[arrSearchResults objectAtIndex:i] valueForKey:@"task"] With:@"NA"];
            //                NSLog(@"strAssignmentResource : %@",strAssignmentResource);
            
            
            //===
            //Parse gooruOid - 1
            NSString* strAssignmentGooruOid = [appDelegate ifNullStrReplace:[strTask valueForKey:@"gooruOid"] With:@"NA"];
            NSLog(@"strAssignmentGooruOid : %@",[strAssignmentGooruOid description]);
            
            //Parse title - 2
            NSString* strAssignmentTitle = [appDelegate ifNullStrReplace:[strTask valueForKey:@"title"] With:@""];
            NSLog(@"strAssignmentTitle : %@",[strAssignmentTitle description]);
            
            //Parse description - 3
            NSString* strAssignmentDescription = [appDelegate ifNullStrReplace:[strTask valueForKey:@"description"] With:@"NA"];
            NSLog(@"strAssignmentDescription : %@",[strAssignmentDescription description]);
            
            //Parse Due Date here when it arrives
            NSString* strPlannedEndDate = [appDelegate ifNullStrReplace:[strTask valueForKey:@"plannedEndDate"] With:@"NA"];
            NSLog(@"strPlannedEndDate : %@",[strPlannedEndDate description]);
                    
            //Add all to static dictionary
            NSMutableDictionary* dictStaticAssignmentAttr = [[NSMutableDictionary alloc] init];
            
            [dictStaticAssignmentAttr setValue:strAssignmentGooruOid forKey:@"assignmentId"];
            [dictStaticAssignmentAttr setValue:strAssignmentTitle forKey:@"assignmentTitle"];
            [dictStaticAssignmentAttr setValue:strAssignmentDescription forKey:@"assignmentDescription"];
            [dictStaticAssignmentAttr setValue:strPlannedEndDate forKey:@"plannedEndDate"];
            
            //Add static dictionary to assignment dictionary
            NSString* keyForDictStaticAssignmentAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_ASSIGNMENTS];
            [dictAssignments setValue:dictStaticAssignmentAttr forKey:keyForDictStaticAssignmentAttr];
            
        }
        
    }
    
    NSLog(@"dictAssignments : %@",dictAssignments);
    
    [self populateAssignmentsIsEmpty:isAssignmemtsEmpty];

}

#pragma mark Populate Assignments

- (void)populateAssignmentsIsEmpty:(BOOL)isEmpty{
    
    //Clean Assignments View
    for (UIView *aView in [viewAssignments subviews]){
        if (aView.tag != TAG_VIEW_NO_ASSIGNMENT) {
            [aView removeFromSuperview];
        }
        
    }
    
    [self shouldHideView:viewNoAssignments :TRUE];
    
    if (!isEmpty) {
        NSLog(@"populateAssignments");
        
        [viewNoAssignments setHidden:TRUE];
        
        NSArray* keysDictAssignments = [appDelegate sortedIntegerKeysForDictionary:dictAssignments];
        
        int countAssignments = [keysDictAssignments count];
        
        NSMutableArray* arrViewAssignment = [[NSMutableArray alloc] initWithCapacity:countAssignments];
        
        int lastYordinate = 10;
        for (int i=0; i<countAssignments; i++) {
            
            NSMutableDictionary* dictAssignmentPopulate = [dictAssignments valueForKey:[keysDictAssignments objectAtIndex:i]];
            
            //Parent view
            UIView* viewAssignment = [[UIView alloc] init];
            
            [viewAssignment setBackgroundColor:[UIColor whiteColor]];
            viewAssignment.frame = CGRectMake(0, lastYordinate, viewAssignments.frame.size.width, 44);
            
            viewAssignment.layer.cornerRadius = 4.0;
            
//            viewAssignment.layer.shadowColor = [[UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] CGColor];
//            viewAssignment.layer.shadowOffset = CGSizeMake(0.0f,0.0f);
//            viewAssignment.layer.shadowOpacity = .25f;
            
            [viewAssignment setTag:[[keysDictAssignments objectAtIndex:i] intValue]*MULTIPLIER_ASSIGNMENT_VIEW];
            
            [viewAssignment setClipsToBounds:YES];
           
            viewAssignment.alpha = 0.0;
            [viewAssignments addSubview:viewAssignment];
            
            
            [arrViewAssignment addObject:viewAssignment];
            
            
            //Assignment Title
            UILabel* lblAssignmentTitle = [[UILabel alloc] initWithFrame:CGRectMake(42, 11, 554, 21)];
            
            [lblAssignmentTitle setBackgroundColor:[UIColor clearColor]];
            [lblAssignmentTitle setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [lblAssignmentTitle setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            
            [lblAssignmentTitle setText:[dictAssignmentPopulate valueForKey:@"assignmentTitle"]];
            
            lblAssignmentTitle.frame = [appDelegate getWLabelFrameForLabel:lblAssignmentTitle withString:lblAssignmentTitle.text];
            
            [lblAssignmentTitle setTag:TAG_ASSIGNMENT_TITLE];
            [viewAssignment addSubview:lblAssignmentTitle];
            
            //Assignment Title Helper Icon
            UIImageView* imgViewHelperAssignmentTitle = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 14, 14)];
            [imgViewHelperAssignmentTitle setImage:[UIImage imageNamed:@"AssignmentTitle@2x.png"]];
            [imgViewHelperAssignmentTitle setTag:TAG_ASSIGNMENT_TITLE];
            [viewAssignment addSubview:imgViewHelperAssignmentTitle];
            
            //Assignment Activity Indicator
            UIActivityIndicatorView* activityIndicatorLoadAssignmentItems = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            activityIndicatorLoadAssignmentItems.frame = CGRectMake(lblAssignmentTitle.frame.origin.x + lblAssignmentTitle.frame.size.width + 10, 12, 20, 20);
            [activityIndicatorLoadAssignmentItems setHidesWhenStopped:TRUE];
            [activityIndicatorLoadAssignmentItems setTag:TAG_ASSIGNMENT_ACTIVITYINDICATOR];
            [viewAssignment addSubview:activityIndicatorLoadAssignmentItems];
            
            
            //Assignment Due Date
            UILabel* lblAssignmentDuedate = [[UILabel alloc] init];
            lblAssignmentDuedate.frame = CGRectMake(604, 11, 120, 21);
            [lblAssignmentDuedate setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
            [lblAssignmentDuedate setTextColor:[UIColor colorWithRed:78.0/255.0 green:151.0/255.0 blue:70.0/255.0 alpha:1.0]];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];

            NSDate *plannedEndDate = [NSDate dateWithTimeIntervalSince1970:([[dictAssignmentPopulate valueForKey:@"plannedEndDate"] doubleValue] / 1000)];
            
            NSDate *comparatorDate = [NSDate dateWithTimeIntervalSince1970:(0)];
            
            NSComparisonResult result = [plannedEndDate compare:comparatorDate];
                       NSString* strPlannedEndDate = [dateFormatter stringFromDate:plannedEndDate];
            [lblAssignmentDuedate setTag:TAG_ASSIGNMENT_DUEDATE];
            
            [lblAssignmentDuedate setText:[NSString stringWithFormat:@"Due Date: %@",strPlannedEndDate]];
            [viewAssignment addSubview:lblAssignmentDuedate];
             NSLog(@"comparatorDate : %@",comparatorDate);
            NSLog(@"strPlannedEndDate : %@",strPlannedEndDate);
            //Assignment DueDate Helper Icon
            UIImageView* imgViewHelperAssignmentDuedate = [[UIImageView alloc] initWithFrame:CGRectMake(lblAssignmentDuedate.frame.origin.x - 22, 14, 16, 15)];
            [imgViewHelperAssignmentDuedate setImage:[UIImage imageNamed:@"DueDate@2x.png"]];
            [imgViewHelperAssignmentDuedate setTag:TAG_ASSIGNMENT_DUEDATE];
            [viewAssignment addSubview:imgViewHelperAssignmentDuedate];

            if (result!=NSOrderedSame)
            {
                imgViewHelperAssignmentDuedate.hidden =FALSE;
                lblAssignmentDuedate.hidden = FALSE;
            }else{
                imgViewHelperAssignmentDuedate.hidden =TRUE;
                lblAssignmentDuedate.hidden =TRUE;
            }

            
            //Assignment Direction
            UILabel* lblAssignmentDirection = [[UILabel alloc] init];
            lblAssignmentDirection.frame = CGRectMake(42, 42, 680, 30);
            [lblAssignmentDirection setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            
            [lblAssignmentDirection setBackgroundColor:[UIColor clearColor]];
            [lblAssignmentDirection setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
            [lblAssignmentDirection setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            [lblAssignmentDirection setLineBreakMode:NSLineBreakByWordWrapping];
            lblAssignmentDirection.numberOfLines = 10;
       
            NSString *decodedString = [[dictAssignmentPopulate valueForKey:@"assignmentDescription"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            [lblAssignmentDirection setText:decodedString];
            
            lblAssignmentDirection.frame = [appDelegate getHLabelFrameForLabel:lblAssignmentDirection withString:lblAssignmentDirection.text];
            
            [lblAssignmentDirection setTag:TAG_ASSIGNMENT_DIRECTION];
            [viewAssignment addSubview:lblAssignmentDirection];
            
            //Assignment Direction Helper Icon
            UIImageView* imgViewHelperAssignmentDirection = [[UIImageView alloc] initWithFrame:CGRectMake(20, 44, 15, 13)];
            [imgViewHelperAssignmentDirection setImage:[UIImage imageNamed:@"AssignmentDirections@2x.png"]];
            [imgViewHelperAssignmentDirection setTag:TAG_ASSIGNMENT_DIRECTION];
            [viewAssignment addSubview:imgViewHelperAssignmentDirection];
    
            if ([[dictAssignmentPopulate valueForKey:@"assignmentDescription"] isEqualToString:@"NA"]) {
                imgViewHelperAssignmentDirection.hidden = TRUE;
                lblAssignmentDirection.hidden = TRUE;
            }
            
            
            //Invisible Btn to expand Assignments
            UIButton* btnAssignment = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnAssignment setBackgroundColor:[UIColor clearColor]];
            btnAssignment.frame = CGRectMake(0, 0, viewAssignment.frame.size.width, 44);
            // [btnAssignment.titleLabel setTextColor:[UIColor redColor]];
            
            [btnAssignment setTag:[[keysDictAssignments objectAtIndex:i] intValue]];
            [btnAssignment addTarget:self action:@selector(btnActionAssignment:) forControlEvents:UIControlEventTouchUpInside];
            
            UILongPressGestureRecognizer *gestureLongPressToEditAssignment = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(btnActionLPAssignmentItems:)];
            
            if (isTeach) {
                [viewAssignment addGestureRecognizer:gestureLongPressToEditAssignment];
            }else{
                if (isYourFirstClasspageAss) {
                    
                    [viewAssignment addGestureRecognizer:gestureLongPressToEditAssignment];
                }
            }
            
            [viewAssignment addSubview:btnAssignment];
            
            //Autopopulate first Assignment
            if (i == 0) {
                [btnAssignment sendActionsForControlEvents:UIControlEventTouchUpInside];
            }

            lastYordinate = lastYordinate + 53;
            
            [scrollAssignments setContentSize:CGSizeMake(scrollAssignments.frame.size.width, viewAssignments.frame.origin.y + lastYordinate + 30)];
            
            originalAssignmentScrollContentSizeHeight = scrollAssignments.contentSize.height;
        
            
        }
        
        //Unhide With animation
        for (int i=0 ; i<countAssignments; i++) {
            
            UIView* viewAssignment = [arrViewAssignment objectAtIndex:i];
            
            [self performSelector:@selector(addView:) withObject:viewAssignment afterDelay:.1*(i+1)];
            
            
            
        }
        
    }else{
        
        [self shouldHideView:viewNoAssignments :FALSE];
  
    }

}

- (void)addView:(UIView*)view{
    
    
    view.alpha = 0.0;
    [UIView beginAnimations:nil context:nil];
    
    [UIView setAnimationDuration:0.5];
    
    [UIView setAnimationDelegate:self];
    
    //set transformation
    view.alpha = 1.0;
    
    [UIView commitAnimations];
    
    
    
}

#pragma mark BA Assignment
- (void)btnActionAssignment:(id)sender {
    
    
    UIButton* btnClicked = (UIButton*)sender;
    
    UIView* viewClicked = [btnClicked superview];
    
    viewAssignmentToBePopulated = viewClicked;
    
    
    
    if (viewClicked.frame.size.height != 44) {
        [btnClicked setSelected:FALSE];
        [self manageAssignmentsWithOpenHeight:viewAssignmentToBePopulated.frame.size.height];
        
        [self setScrollLength:originalAssignmentScrollContentSizeHeight];
        
        
    }else{
        
        UIActivityIndicatorView* activityIndicatorForAssignmentItems = (UIActivityIndicatorView*)[viewClicked viewWithTag:TAG_ASSIGNMENT_ACTIVITYINDICATOR];
        if (activityIndicatorAssignmentItemsInUse != nil) {
            [activityIndicatorAssignmentItemsInUse stopAnimating];
        }
        
        activityIndicatorAssignmentItemsInUse = activityIndicatorForAssignmentItems;
        [activityIndicatorForAssignmentItems startAnimating];
        
        [btnClicked setSelected:TRUE];
        
        NSLog(@"btnAction_assignment : %i",[sender tag]);
        NSLog(@"AssignmentId : %@",[[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]] valueForKey:@"assignmentId"]);
        
        [self.view setUserInteractionEnabled:FALSE];
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]] valueForKey:@"assignmentTitle"] forKey:@"AssignmentTitle"];
                [dictionary setObject:[[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]] valueForKey:@"assignmentId"] forKey:@"AssignmentId"];
       
        [appDelegate logMixpanelforevent:@"Tap on an assignment" and:dictionary];
        //API Call for collections inside a classpage
        [self getAllAssignmentItemsForAssignmentId:[[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",[sender tag]]] valueForKey:@"assignmentId"]];
    }
    
}



#pragma mark - Assignment Items -
#pragma mark Get all Collections for an Assignment
- (void)getAllAssignmentItemsForAssignmentId:(NSString*)gooruOid{
    
//    [appDelegate showLibProgressOnView:self.view andMessage:@""];
    
    NSLog(@"Assignment Id : %@",gooruOid);
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/v2/assignment/%@/item?sessionToken=%@&data={\"skipPagination\":\"true\"}",[appDelegate getValueByKey:@"ServerURL"],gooruOid,sessionToken];
    
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"data", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, @"{\"skipPagination\":\"true\"}", nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/assignment/%@/item?",gooruOid] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //        NSLog(@"getAssignment Response : %@",responseStr);
        [self parseAssignmentItems:responseStr];
        
        [self performSelector:@selector(enableUserInteraction) withObject:nil afterDelay:1.0];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        UIActivityIndicatorView* activityIndicatorForAssignmentItems = (UIActivityIndicatorView*)[viewAssignmentToBePopulated viewWithTag:TAG_ASSIGNMENT_ACTIVITYINDICATOR];
        [activityIndicatorForAssignmentItems stopAnimating];
        [self enableUserInteraction];
    }];
    
    
}

- (void)enableUserInteraction{
    
    [self.view setUserInteractionEnabled:TRUE];
}

- (void)parseAssignmentItems:(NSString*)responseString{
    
    NSArray *results = [responseString JSONValue];
    
    NSLog(@"results : %@",[results description]);
    
    BOOL isAssignmemtItemsEmpty;
    
    NSArray* arrSearchResults = results;
    NSString* strTotalHitCount = [NSString stringWithFormat:@"%i",[arrSearchResults count]];
    
    
    
    
    NSLog(@"strTotalHitCount : %@",strTotalHitCount);
    NSLog(@"arrSearchResults : %@",[arrSearchResults description]);
    
    if([strTotalHitCount intValue] == 0){
        
        //Populate no results screen
        NSLog(@"CONNECTION_IDENTIFIER_ASSIGNMENTS no results");
        isAssignmemtItemsEmpty = TRUE;
        
//        float finalScrollHeight = originalAssignmentScrollContentSizeHeight;
//        [self setScrollLength:finalScrollHeight];
        
    }else{
        
        
        
        dictAssignmentsItems = [[NSMutableDictionary alloc] init];
        
        
        
        
        for (int i=0; i<[strTotalHitCount intValue]; i++) {
            
            
            NSMutableDictionary* dictStaticAssignmentItemsAttr = [[NSMutableDictionary alloc] init];
            
            [dictStaticAssignmentItemsAttr setValue:[appDelegate ifNullStrReplace:[[arrSearchResults objectAtIndex:i] valueForKey:@"title"] With:@""] forKey:@"assignmentItemTitle"];
            [dictStaticAssignmentItemsAttr setValue:[appDelegate ifNullStrReplace:[[arrSearchResults objectAtIndex:i] valueForKey:@"goals"] With:@""] forKey:@"assignmentItemDescription"];
            NSString* strThumbnailUrl = [[[arrSearchResults objectAtIndex:i] valueForKey:@"thumbnails"] valueForKey:@"url"];
            [dictStaticAssignmentItemsAttr setValue:[self resizeThumbnail:[appDelegate ifNullStrReplace:strThumbnailUrl With:@"NA"] To:@"160x120"] forKey:@"assignmentItemThumbnail"];
            [dictStaticAssignmentItemsAttr setValue:[appDelegate ifNullStrReplace:[[arrSearchResults objectAtIndex:i] valueForKey:@"gooruOid"] With:@"NA"] forKey:@"assignmentItemId"];
            [dictStaticAssignmentItemsAttr setValue:[appDelegate ifNullStrReplace:[[arrSearchResults objectAtIndex:i] valueForKey:@"views"] With:@"NA"] forKey:@"assignmentItemViews"];
            
            NSLog(@"views : %@",[[arrSearchResults objectAtIndex:i] valueForKey:@"views"]);
            
            NSString* keyForDictStaticAssignmentItemsAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_ASSIGNMENT_ITEMS];
            [dictAssignmentsItems setValue:dictStaticAssignmentItemsAttr forKey:keyForDictStaticAssignmentItemsAttr];
            
        }
        
        isAssignmemtItemsEmpty = FALSE;
        
        
    }
    
    [self populateAssignmentItemsIsEmpty:isAssignmemtItemsEmpty];
    
    
}

#pragma mark Populate AssignmentItems
- (void)populateAssignmentItemsIsEmpty:(BOOL)isEmpty{
    
    //Clean up Assignment Items
    
    for (UIView *aView in [viewAssignmentToBePopulated subviews]){
        
        
        if (aView.tag != TAG_ASSIGNMENT_TITLE && aView.tag != TAG_ASSIGNMENT_DIRECTION && aView.tag != TAG_ASSIGNMENT_DUEDATE && aView.tag != TAG_ASSIGNMENT_ACTIVITYINDICATOR) {
            
            if ([aView isKindOfClass:[UIButton class]]) {
                
                UIButton* buttonToCheck = (UIButton*)aView;
                if (buttonToCheck.frame.origin.x != 0) {
                    [aView removeFromSuperview];
                }
            }else{
                [aView removeFromSuperview];
            }
            
            
            
            
        }
        
    }
    
    UILabel* lblDirection = (UILabel*)[viewAssignmentToBePopulated viewWithTag:TAG_ASSIGNMENT_DIRECTION];
    
    float finalScrollHeight = originalAssignmentScrollContentSizeHeight;
    
    if (!isEmpty) {
        //Call method to manage opening and closing
        
        int countAssignmentItems = [dictAssignmentsItems count];
        
        NSArray* keysDict_assignmentsItems = [appDelegate sortedIntegerKeysForDictionary:dictAssignmentsItems];
        
        int lastYordinate = lblDirection.frame.origin.y + lblDirection.frame.size.height+15;
        
        for (int i=0; i<countAssignmentItems; i++) {
            
            NSMutableDictionary* dictAssignmentItemsPopulate = [dictAssignmentsItems valueForKey:[keysDict_assignmentsItems objectAtIndex:i]];
            
            //Collection Thumbnail
            UIButton* btnCollection = [UIButton buttonWithType:UIButtonTypeCustom];
            btnCollection.frame = CGRectMake(20, lastYordinate, 120, 90);
            
            [btnCollection setTag:[[keysDict_assignmentsItems objectAtIndex:i] intValue]];
            [btnCollection addTarget:self action:@selector(btnActionAssignmentItems:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewAssignmentToBePopulated addSubview:btnCollection];
            
            //Imageview for thumbnail
            UIImageView* imgViewCollection = [[UIImageView alloc] init];
            imgViewCollection.frame = CGRectMake(0, 0, btnCollection.frame.size.width, btnCollection.frame.size.height);
            [imgViewCollection setImageWithURL:[dictAssignmentItemsPopulate valueForKey:@"assignmentItemThumbnail"] placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
            
            [btnCollection addSubview:imgViewCollection];
            
            //Imageview for Colletion accent
            UIImageView* imgViewCollectionAccent = [[UIImageView alloc] init];
            imgViewCollectionAccent.frame = CGRectMake(0, 0, 7, btnCollection.frame.size.height);
            
            [imgViewCollectionAccent setImage:[UIImage imageNamed:@"btnaccentcollection.png"]];
            [btnCollection addSubview:imgViewCollectionAccent];
            
            
            //Collection Title
            UILabel* lblCollectionTitle = [[UILabel alloc] init];
            lblCollectionTitle.frame = CGRectMake(148, lastYordinate, 586, 21);
            [lblCollectionTitle setNumberOfLines:1];
            [lblCollectionTitle setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [lblCollectionTitle setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            
            [lblCollectionTitle setText:[dictAssignmentItemsPopulate valueForKey:@"assignmentItemTitle"]];
            
            [viewAssignmentToBePopulated addSubview:lblCollectionTitle];
            
            //Collection Views
            UILabel* lblCollectionViews = [[UILabel alloc] init];
            lblCollectionViews.frame = CGRectMake(148, lblCollectionTitle.frame.origin.y, 586, 21);
            [lblCollectionViews setNumberOfLines:0];
            [lblCollectionViews setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [lblCollectionViews setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            
            [lblCollectionViews setText:[NSString stringWithFormat:@"%@ views",[dictAssignmentItemsPopulate valueForKey:@"assignmentItemViews"]]];
            
            [lblCollectionViews setFrame:[appDelegate getWLabelFrameForLabel:lblCollectionViews withString:lblCollectionViews.text]];
            [lblCollectionViews setFrame:CGRectMake(viewAssignmentToBePopulated.frame.size.width - lblCollectionViews.frame.size.width - 10, lblCollectionViews.frame.origin.y, lblCollectionViews.frame.size.width, lblCollectionViews.frame.size.height)];
            
            [lblCollectionViews setTag:[[keysDict_assignmentsItems objectAtIndex:i] intValue] * TAG_ASSIGNMENT_ITEM_VIEWS];
            
            [viewAssignmentToBePopulated addSubview:lblCollectionViews];
            
            //Collection Views Helper
            UIImageView* imgViewHelperCollectionViews = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"views@2x.png"]];
            [imgViewHelperCollectionViews setFrame:CGRectMake(lblCollectionViews.frame.origin.x - 20, lblCollectionViews.frame.origin.y + 4, 16, 13)];
            [viewAssignmentToBePopulated addSubview:imgViewHelperCollectionViews];
            
            
            //Collection Description
            UILabel* lblCollectionDescription = [[UILabel alloc] init];
            lblCollectionDescription.frame = CGRectMake(148, lblCollectionTitle.frame.origin.y + lblCollectionTitle.frame.size.height + 5, 550, 65);
            [lblCollectionDescription setNumberOfLines:0];
            [lblCollectionDescription setFont:[UIFont fontWithName:@"Arial" size:12.0f]];
            [lblCollectionDescription setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:81.0/255.0 alpha:1.0]];
            [lblCollectionDescription setLineBreakMode:NSLineBreakByWordWrapping];
            
            //            [lblCollectionDescription setBackgroundColor:[UIColor redColor]];
            
            [lblCollectionDescription setText:[[dictAssignmentItemsPopulate valueForKey:@"assignmentItemDescription"] stripHtml]];
            
            lblCollectionDescription.frame = [appDelegate getHLabelFrameForLabel:lblCollectionDescription withString:lblCollectionDescription.text];
            
            
            [viewAssignmentToBePopulated addSubview:lblCollectionDescription];
            
            float endHeight;
            if ((lblCollectionDescription.frame.origin.y + lblCollectionDescription.frame.size.height) > (btnCollection.frame.origin.y + btnCollection.frame.size.height)) {
                endHeight = lblCollectionDescription.frame.origin.y + lblCollectionDescription.frame.size.height;
            }else{
                endHeight = btnCollection.frame.origin.y + btnCollection.frame.size.height;
            }
            
            lastYordinate = lastYordinate + 100 + 20;
            
        }
        
        [self manageAssignmentsWithOpenHeight:lastYordinate];
        
        finalScrollHeight = finalScrollHeight + lastYordinate - 44;
        
    }else{
        if (![lblDirection.text isEqualToString:@""]) {
            [self manageAssignmentsWithOpenHeight:lblDirection.frame.origin.y + lblDirection.frame.size.height + 10];
            finalScrollHeight = finalScrollHeight + lblDirection.frame.origin.y + lblDirection.frame.size.height + 10;
        }else{
            [self manageAssignmentsWithOpenHeight:44];
            finalScrollHeight = originalAssignmentScrollContentSizeHeight;
        }
        
    }
    
    UIActivityIndicatorView* activityIndicatorForAssignmentItems = (UIActivityIndicatorView*)[viewAssignmentToBePopulated viewWithTag:TAG_ASSIGNMENT_ACTIVITYINDICATOR];
    [activityIndicatorForAssignmentItems stopAnimating];
    
    [self setScrollLength:finalScrollHeight];
    
}

#pragma mark Assignment Items Button Action
- (void)btnActionAssignmentItems:(id)sender{
    
    NSLog(@"tag : %i",[sender tag]);
    
    UIButton *btnCollection = (UIButton*)sender;
    
    NSLog(@"Gooru Id : %@",[[dictAssignmentsItems valueForKey:[NSString stringWithFormat:@"%i",[sender tag] ]] valueForKey:@"assignmentItemId"]);
    
    lblCollectionViewsToBeRefreshed = (UILabel*)[[btnCollection superview] viewWithTag:[sender tag]*TAG_ASSIGNMENT_ITEM_VIEWS];
    
    NSLog(@"Views : %@",lblCollectionViewsToBeRefreshed.text);
    

    NSMutableDictionary* dictAppDetails = [[NSMutableDictionary alloc] init];
    [dictAppDetails setValue:[appDelegate getValueByKey:@"ServerURL"] forKey:@"ServerUrl"];
    
    
    
    [dictAppDetails setValue:[[dictAssignmentsItems valueForKey:[NSString stringWithFormat:@"%i",[sender tag] ]] valueForKey:@"assignmentItemId"] forKey:@"CollectionGooruId"];
    
    [dictAppDetails setValue:@"NA" forKey:@"ResourceInstanceId"];
    
    [dictAppDetails setValue:sessionToken forKey:@"SessionToken"];
    
    
    
    if ([[standardUserDefaults stringForKey:@"token"] isEqualToString:@"NA"]) {
        NSLog(@"User Auth Status : User Logged Out!");
        [dictAppDetails setValue:[NSNumber numberWithBool:TRUE] forKey:@"isAnonymous"];
        [dictAppDetails setValue:[NSNumber numberWithBool:FALSE] forKey:@"isTeacher"];
    }else{
        NSLog(@"User Auth Status : User Logged In!");
        [dictAppDetails setValue:[NSNumber numberWithBool:FALSE] forKey:@"isAnonymous"];
        
        if (isTeach) {
            NSLog(@"User Role Status : Teacher");
            [dictAppDetails setValue:[NSNumber numberWithBool:TRUE] forKey:@"isTeacher"];
        }else{
            NSLog(@"User Role Status : Student");
            [dictAppDetails setValue:[NSNumber numberWithBool:FALSE] forKey:@"isTeacher"];
        }
        
        
    }
    
    [dictAppDetails setValue:[NSNumber numberWithBool:TRUE] forKey:@"shouldAutoloadNarration"];
    
         [appDelegate logMixpanelforevent:@"Share Email Summary" and:dictAppDetails];
    CollectionPlayerV2ViewController* collectionPlayerV2ViewController = [[CollectionPlayerV2ViewController alloc] initWithAppDetails:dictAppDetails];
    
    [self presentViewController:collectionPlayerV2ViewController animated:YES completion:nil];
    
}

#pragma mark Assignment Items Button Long Press
- (void)btnActionLPAssignmentItems:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan ) {
        
        NSLog(@"Edit Assignment Popup Emminent!");
        
        NSArray* sortedKeysForDict_assignments = [appDelegate sortedIntegerKeysForDictionary:dictAssignments];
        NSLog(@"sortedKeysForDict_assignments : %@",[sortedKeysForDict_assignments description]);
        
        NSLog(@"Gesture view tag : %@",[[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",gesture.view.tag/MULTIPLIER_ASSIGNMENT_VIEW]] valueForKey:@"assignmentId"]);
        
        NSString* currentAssignmentIdBeingEdited = [[dictAssignments valueForKey:[NSString stringWithFormat:@"%i",gesture.view.tag/MULTIPLIER_ASSIGNMENT_VIEW]] valueForKey:@"assignmentId"];
        UIView* currentAssignmentViewBeingEdited = gesture.view;
        
        
        
        
        
        //        self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:viewEditAssignmentDatePickerParent];
//        [self.flatDatePicker setTag:TAG_POPUP_EDITASSIGNMENT];
        
        //        self.flatDatePicker.delegate = self;
        //        self.flatDatePicker.title = @"Select your Due Date";
//        [self managePopup:TAG_POPUP_EDITASSIGNMENT];
        
        //Pre Populate fields
        UILabel* lblAssignmentTitle = (UILabel*)[gesture.view viewWithTag:TAG_ASSIGNMENT_TITLE];
        //        [txtFieldEditAssignmentTitle setText:lblAssignmentTitle.text];
        
        UILabel* lblAssignmentDueDate = (UILabel*)[gesture.view viewWithTag:TAG_ASSIGNMENT_DUEDATE];
        NSString* strDueDate = [lblAssignmentDueDate.text stringByReplacingOccurrencesOfString:@"Due Date: " withString:@""];
        //        [lblEditAssignmentDueDate setText:strDueDate];
        
        UILabel* lblAssignmentDirection = (UILabel*)[gesture.view viewWithTag:TAG_ASSIGNMENT_DIRECTION];
        //        [txtViewEditAssignmentDirection setText:lblAssignmentDirection.text];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
//        [self.flatDatePicker setDate:[dateFormatter dateFromString:strDueDate] animated:NO];
        
        UIButton* btnAssignmentBeingEdited = (UIButton*)[currentAssignmentViewBeingEdited viewWithTag:currentAssignmentViewBeingEdited.tag/MULTIPLIER_ASSIGNMENT_VIEW];
        
        
        NSMutableDictionary* dictEditAssignment = [[NSMutableDictionary alloc] init];
        
        [dictEditAssignment setValue:currentAssignmentIdBeingEdited forKey:@"AssignmentId"];
        [dictEditAssignment setValue:currentAssignmentViewBeingEdited forKey:@"AssignmentView"];
//        [dictToPopulateEditAssignment setValue:viewPopupEditAssignment forKey:@"AssignmentPopupParent"];
        [dictEditAssignment setValue:lblAssignmentTitle.text forKey:@"AssignmentTitle"];
        [dictEditAssignment setValue:strDueDate forKey:@"AssignmentDueDate"];
        [dictEditAssignment setValue:lblAssignmentDirection.text forKey:@"AssignmentDirection"];
        
        [dictEditAssignment setValue:btnAssignmentBeingEdited forKey:@"btnAssignment"];
        
        
        NSLog(@"dictEditAssignment=%@",[dictEditAssignment description]);
        
        //Mixpanel track Successful Login
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setValue:lblAssignmentTitle.text forKey:@"AssignmentTitle"];
        [dictionary setValue:strDueDate forKey:@"AssignmentDueDate"];
        [dictionary setValue:currentAssignmentIdBeingEdited forKey:@"AssignmentId"];
        [dictionary setValue:lblAssignmentDirection.text forKey:@"AssignmentDirection"];
        NSLog(@"dictionary=%@",[dictionary description]);
        [appDelegate logMixpanelforevent:@"Assignment Edit Pop Opened" and:dictionary];
        
        
        editAssignmentPopupViewController = [[EditAssignmentPopupViewController alloc] initWithAssignmentDetails:dictEditAssignment];
        if (isYourFirstClasspageAss) {
           // isYourFirstClasspageAss=FALSE;
            editAssignmentPopupViewController.isYourFirstClasspageEAP=TRUE;
        }else{
            
        }
        [self presentDetailController:editAssignmentPopupViewController inMasterView:self.parentViewController.view];
        
    }
}

#pragma mark Refresh AssignmentItem Views
- (void)refreshAssignmentItemViews{
    
    
    NSString* strViews = lblCollectionViewsToBeRefreshed.text;
    NSArray* arrViewsComponents = [strViews componentsSeparatedByString:@" "];
    [lblCollectionViewsToBeRefreshed setText:[NSString stringWithFormat:@"%i views",[[arrViewsComponents objectAtIndex:0] intValue] + 1]];
    
}


#pragma mark - BA Assignment/Share Tabs -

- (IBAction)btnActionAssignmentTab:(id)sender {
    
    
    
    if (![btnAssignmentTab isSelected]) {
        
        [btnAssignmentTab setSelected:TRUE];
        [btnShareTab setSelected:FALSE];
        [self animateView:viewAssignments forFinalFrame:CGRectMake(20, viewAssignments.frame.origin.y, viewAssignments.frame.size.width, viewAssignments.frame.size.height)];
        
        [self animateView:viewShare forFinalFrame:CGRectMake(self.view.frame.size.width + 20, viewShare.frame.origin.y, viewShare.frame.size.width, viewShare.frame.size.height)];
        
    }
    
    
}
- (IBAction)btnActionShareTab:(id)sender {
    
    if (![btnShareTab isSelected]) {
        
        [btnShareTab setSelected:TRUE];
        [btnAssignmentTab setSelected:FALSE];
        
        [self animateView:viewShare forFinalFrame:CGRectMake(20, viewShare.frame.origin.y, viewShare.frame.size.width, viewShare.frame.size.height)];
        
        [self animateView:viewAssignments forFinalFrame:CGRectMake(self.view.frame.origin.x - 20 - viewAssignments.frame.size.width, viewAssignments.frame.origin.y, viewAssignments.frame.size.width, viewAssignments.frame.size.height)];
        
        //Mixpanel track Share Classpage
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[dictClasspage valueForKey:@"classpageCode"] forKey:@"ClassPageCode"];
        [appDelegate logMixpanelforevent:@"Share Classpage - Teach Tab" and:dictionary];
        
        txtViewShareClasscode.font = tahoma;
        
        NSLog(@"dictClasspage share : %@ ",[[dictClasspage valueForKey:@"classpageCode"] uppercaseString]);
        txtViewShareClasscode.text = [[dictClasspage valueForKey:@"classpageCode"] uppercaseString];

    }
    
    
}

- (IBAction)btnActionSendShareEmail:(id)sender {
    
    //Mixpanel track Share Email
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[dictClasspage valueForKey:@"classpageCode"] forKey:@"ClassPageCode"];
    
    [appDelegate logMixpanelforevent:@"Share Classpage Email - Teach Tab" and:dictionary];
    
    NSString* urlToShare = [NSString stringWithFormat:@"http://www.goorulearning.org/#students-view&id=%@&pageSize=10&pageNum=0&pos=1",[dictClasspage valueForKey:@"classpageId"]];
    
    NSString* strSubject = [NSString stringWithFormat:@"Classpage : %@ ",[dictClasspage valueForKey:@"classpageTitle"]];
    
    NSString* strBody1 = [NSString stringWithFormat:@" %@ ",[dictClasspage valueForKey:@"classpageTitle"]];
    NSString* strBody2  = [NSString stringWithFormat:@"%@",urlToShare];
    NSString* strBody3  = [NSString stringWithFormat:@"Class Code : %@  ",[[dictClasspage valueForKey:@"classpageCode"]uppercaseString]];
    
    
    NSLog(@"Email");
    if ([MFMailComposeViewController canSendMail]) {
        // Show the composer
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:strSubject];
        
        
        // Fill out the email body text
        NSString *emailBody = [NSString stringWithFormat:@"<br>%@</br> <br><a href = '%@'>%@</a></br>  <br>%@</br>  <br/> <br />Sent using <a href = 'http://www.goorulearning.org'>Gooru</a>. Visit <a href = 'http://www.goorulearning.org'>goorulearning.org</a> for more great resources and collections. It's free!</p>", strBody1,strBody2,strBody2,strBody3];
        
        [controller setMessageBody:emailBody isHTML:YES];
        
        if (controller) [self presentModalViewController:controller animated:YES];
        
        //if you want to change its size but the view will remain centerd on the screen in both portrait and landscape then:
        controller.view.superview.bounds = CGRectMake(0, 0, 320, 480);
        
        //or if you want to change it's position also, then:
        controller.view.superview.frame = CGRectMake(236, 146, 540, 540);
    } else {
        // Handle the error
        
        [self.view makeToast:@"No e-mail client configured on the device."
                    duration:2.0
                    position:@"center"];
    }
    
}



#pragma mark - Mail Delegate -
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent) {
        NSLog(@"Mail Sent");
        //Mixpanel track Email Sent to share classpage with Classcode
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[dictClasspage valueForKey:@"classpageCode"] forKey:@"ClassPageCode"];
        
        [appDelegate logMixpanelforevent:@"Classpage Share Email sent" and:dictionary];
        
    }
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Manage Assignment View Expansion/Contraction -
- (void)manageAssignmentsWithOpenHeight:(int)height{
    
    BOOL isOpening;
    
    if (viewAssignmentToBePopulated.frame.size.height == 44) {
        
        isOpening = TRUE;
        [self animateAssignmentView:viewAssignmentToBePopulated forFinalFrame:CGRectMake(viewAssignmentToBePopulated.frame.origin.x, viewAssignmentToBePopulated.frame.origin.y, viewAssignmentToBePopulated.frame.size.width, height)];
        
        
    }else{
        isOpening = FALSE;
        [self animateAssignmentView:viewAssignmentToBePopulated forFinalFrame:CGRectMake(viewAssignmentToBePopulated.frame.origin.x, viewAssignmentToBePopulated.frame.origin.y, viewAssignmentToBePopulated.frame.size.width, 44)];
        
        
    }
    
    [self adjustViewsAfterView:viewAssignmentToBePopulated whenOpening:isOpening withHeightDiff:height - 44];
    
    //    [self manageScrollLengthWhenOpening:isOpening withLengthDifference:height];
    
    
    
    //    NSArray* sortedKeysForDict_assignments = [appDelegate sortedIntegerKeysForDictionary:dict_assignments];
    //    for (int i=0; i<[dict_assignments count]; i++) {
    //
    //        if ([[sortedKeysForDict_assignments objectAtIndex:i] intValue]*MULTIPLIER_ASSIGNMENT_VIEW > viewAssignmentToBePopulated.tag) {
    //
    //            UIView* viewsToBeAdjusted = (UIView*)[viewAssignments viewWithTag:[[sortedKeysForDict_assignments objectAtIndex:i] intValue]*MULTIPLIER_ASSIGNMENT_VIEW];
    //
    //            if (isOpening) {
    //                [self animateView:viewsToBeAdjusted forFinalFrame:CGRectMake(viewsToBeAdjusted.frame.origin.x, viewsToBeAdjusted.frame.origin.y+100, viewsToBeAdjusted.frame.size.width, viewsToBeAdjusted.frame.size.height)];
    //            }else{
    //                [self animateView:viewsToBeAdjusted forFinalFrame:CGRectMake(viewsToBeAdjusted.frame.origin.x, viewsToBeAdjusted.frame.origin.y-100, viewsToBeAdjusted.frame.size.width, viewsToBeAdjusted.frame.size.height)];
    //            }
    //
    //        }
    //
    //    }
    
}

- (void)animateAssignmentView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    __block float heightDiff = 0;
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         NSArray* sortedKeysForDict_assignments = [appDelegate sortedIntegerKeysForDictionary:dictAssignments];
                         
                         int countDictAssignments = [sortedKeysForDict_assignments count];
                         for (int i=0; i<countDictAssignments; i++) {
                             
                             if ([[sortedKeysForDict_assignments objectAtIndex:i] intValue]*100 != view.tag) {
                                 
                                 UIView* viewToClose = (UIView*)[viewAssignments viewWithTag:[[sortedKeysForDict_assignments objectAtIndex:i] intValue]*100];
                                 
                                 if (viewToClose.frame.size.height != 44) {
                                     heightDiff = viewToClose.frame.size.height;
                                     
                                     [self adjustViewsAfterView:viewToClose whenOpening:FALSE withHeightDiff:viewToClose.frame.size.height - 44];
                                     
                                     [self animateView:viewToClose forFinalFrame:CGRectMake(viewToClose.frame.origin.x, viewToClose.frame.origin.y, viewToClose.frame.size.width,44)];
                                     
                                     
                                 }
                                 
                             }
                             
                         }
                         
                     }];
}


- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

- (void)shouldHideView:(UIView*)view :(BOOL)value{
    
    
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

- (void)adjustViewsAfterView:(UIView*)view whenOpening:(BOOL)isOpening withHeightDiff:(int)heightDiff{
    
    NSArray* sortedKeysForDict_assignments = [appDelegate sortedIntegerKeysForDictionary:dictAssignments];
    int countDictAssignments = [dictAssignments count];
    for (int i=0; i<countDictAssignments; i++) {
        
        if ([[sortedKeysForDict_assignments objectAtIndex:i] intValue]*MULTIPLIER_ASSIGNMENT_VIEW > view.tag) {
            
            UIView* viewsToBeAdjusted = (UIView*)[viewAssignments viewWithTag:[[sortedKeysForDict_assignments objectAtIndex:i] intValue]*MULTIPLIER_ASSIGNMENT_VIEW];
            
            if (isOpening) {
                [self animateView:viewsToBeAdjusted forFinalFrame:CGRectMake(viewsToBeAdjusted.frame.origin.x, viewsToBeAdjusted.frame.origin.y+heightDiff, viewsToBeAdjusted.frame.size.width, viewsToBeAdjusted.frame.size.height)];
                
            }else{
                
                [self animateView:viewsToBeAdjusted forFinalFrame:CGRectMake(viewsToBeAdjusted.frame.origin.x, viewsToBeAdjusted.frame.origin.y-heightDiff, viewsToBeAdjusted.frame.size.width, viewsToBeAdjusted.frame.size.height)];
                
            }
            
        }
        
    }
    
}

- (void)setScrollLength:(float)length{
    
    
    
    [scrollAssignments setContentSize:CGSizeMake(scrollAssignments.contentSize.width, length)];
    [viewAssignments setFrame:CGRectMake(viewAssignments.frame.origin.x, viewAssignments.frame.origin.y, viewAssignments.frame.size.width, scrollAssignments.contentSize.height)];
    
    
    if (scrollAssignments.contentOffset.y + scrollAssignments.frame.size.height == scrollAssignments.contentSize.height) {
        
        [scrollAssignments setContentOffset:CGPointMake(scrollAssignments.contentOffset.x, length - scrollAssignments.frame.size.height) animated:YES];
        
    }
    
}

- (void)presentDetailController:(UIViewController*)detailVC inMasterView:(UIView*)viewMaster{

    
    //1. Add the detail controller as child of the container
    [self.parentViewController addChildViewController:detailVC];
    
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
    self.currentDetailViewController = detailVC;
    
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

#pragma mark - Scroll View Delegates - 
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
     NSLog(@"Scroll offset DidEndDecelerating : %f",scrollAssignments.contentOffset.y);
    flagIsDragging = TRUE;
    [progressViewRefresh setHidden:TRUE];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    NSLog(@"Scroll offset DidEndDragging : %f",scrollAssignments.contentOffset.y);
    flagIsDragging = FALSE;
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"Scroll offset DidEndScrollingAnimation : %f",scrollAssignments.contentOffset.y);
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
    if (scrollAssignments.contentOffset.y < 0 && flagIsDragging) {
        
        NSLog(@"Scroll offset Did Scroll : %f",scrollAssignments.contentOffset.y);
        
        float scrollPercentage = (scrollAssignments.contentOffset.y/-125);
        
        NSLog(@"scrollPercentage : %f",scrollPercentage);
        [progressViewRefresh setHidden:FALSE];
        
        [progressViewRefresh setProgress:scrollPercentage];
        
        
    }
    

}


#pragma mark - Parse Helpers -
- (NSString*)resizeThumbnail:(NSString*)thumbnailUrl To:(NSString*)thumbnailDimensions{
    
    if ([thumbnailUrl rangeOfString:@".png"].length > 0) {
        thumbnailUrl = [thumbnailUrl stringByReplacingOccurrencesOfString:@".png" withString:[NSString stringWithFormat:@"-%@.png",thumbnailDimensions]];
    }else if([thumbnailUrl rangeOfString:@".jpg"].length > 0){
        
        thumbnailUrl = [thumbnailUrl stringByReplacingOccurrencesOfString:@".jpg" withString:[NSString stringWithFormat:@"-%@.jpg",thumbnailDimensions]];
        
    }
    
    return thumbnailUrl;
    
}
#pragma mark Delete Classcode Classpage from FUEOther
- (IBAction)btnActionExitClasspage:(id)sender {
    
    MainClasspageViewController* mainClasspageViewController = (MainClasspageViewController*)self.parentViewController;
    
    [mainClasspageViewController exitStudyClasspage];
    
}


#pragma mark Memory Warning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
