//
//  FlaggingPopupViewController.m
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

#import "FlaggingPopupViewController.h"
#import "CollectionPlayerV2ViewController.h"
#import "ResourcePlayerViewController.h"
#import "AFHTTPClient.h"
#import "Toast+UIView.h"
#import "NSString_stripHtml.h"
#import "AppDelegate.h"
#import "LoginViewController.h"


#define COLLECTION_TITLE @"CollectionTitle"
#define COLLECTION_ID @"CollectionId"
#define COLLECTION_THUMBNAIL @"CollectionThumbnail"
#define COLLECTION_VIEWS @"CollectionViews"
#define COLLECTION_ASSETURI @"CollectionAssetURI"
#define COLLECTION_FOLDER @"CollectionFolder"
#define COLLECTION_NATIVEURL @"CollectionNativeURL"
#define COLLECTION_DESCRIPTION @"CollectionDescription"
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

#define QUESTION_TEXT @"QuestionText"
#define QUESTION_ANSWERS @"QuestionAnswers"
#define QUESTION_HINTS @"QuestionHints"
#define QUESTION_EXPLANATION @"QuestionExplanation"
#define QUESTION_CORRECTANSWER @"CorrectAnswer"
#define QUESTION_USERANSWER @"UserAnswer"
#define QUESTION_TYPE @"Type"

#define RESOURCE_REACTION @"ResourceReaction"


@interface FlaggingPopupViewController ()

@end

@implementation FlaggingPopupViewController

NSMutableDictionary* dictCollectionInfo;
NSMutableDictionary* dictResourceInfo;
BOOL isCollection = FALSE;

//Incoming Details
NSString* sessionToken;
NSString* serverUrl;
NSString* gooruOID;

NSUserDefaults* standardUserDefaults;
AppDelegate* appDelegate;
NSString* strSelection;

NSMutableArray* arrFlaggingSelection;

CollectionPlayerV2ViewController* collectionPlayerV2ViewController;
ResourcePlayerViewController* resourcePlayerViewController;
LoginViewController* loginViewController;

BOOL isParentCollectionPlayer = FALSE;
BOOL isLoggedIn = FALSE;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCollectionInfo:(NSMutableDictionary*)dictIncomingCollectionInfo andResourceInfo:(NSMutableDictionary*)dictIncomingResourceInfo forCollection:(BOOL)value andParentViewController:(UIViewController*)parentViewController{
    
    self = [super initWithNibName:@"FlaggingPopupViewController" bundle:nil];
    
    if ([parentViewController isKindOfClass:[CollectionPlayerV2ViewController class]]) {
        collectionPlayerV2ViewController = (CollectionPlayerV2ViewController*)parentViewController;
        isParentCollectionPlayer = TRUE;
        NSLog(@"parentViewController : CollectionPlayerV2ViewController");
    }else{
        resourcePlayerViewController = (ResourcePlayerViewController*)parentViewController;
        isParentCollectionPlayer = FALSE;
        NSLog(@"parentViewController : ResourcePlayerViewController");

    }
    
    
    isCollection = value;
    
    dictCollectionInfo = dictIncomingCollectionInfo;
    dictResourceInfo = dictIncomingResourceInfo;
    
    NSLog(@"dictCollectionInfo :%@",dictCollectionInfo);
    NSLog(@"dictResourceInfo :%@",dictResourceInfo);
    
    return self;
}

- (id)initWithResourceInfo:(NSMutableDictionary*)dictIncomingResourceInfo andParentViewController:(UIViewController*)parentViewController{
    
    if ([parentViewController isKindOfClass:[CollectionPlayerV2ViewController class]]) {
        collectionPlayerV2ViewController = (CollectionPlayerV2ViewController*)parentViewController;
        isParentCollectionPlayer = TRUE;
        NSLog(@"parentViewController : CollectionPlayerV2ViewController");
    }else{
        resourcePlayerViewController = (ResourcePlayerViewController*)parentViewController;
        isParentCollectionPlayer = FALSE;
        NSLog(@"parentViewController : ResourcePlayerViewController");
    }
    
    isCollection = FALSE;
   dictResourceInfo = dictIncomingResourceInfo;
    
    NSLog(@"dictCollectionInfo :%@",dictCollectionInfo);
    NSLog(@"dictResourceInfo :%@",dictResourceInfo);
    
    return self;

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    if (isCollection) {
        [lblFlagPopupTitle setText:[NSString stringWithFormat:@"Flag this Collection"]];
        [viewCollectionFlagging setHidden:FALSE];
        [viewResourceFlagging setHidden:TRUE];
        [lblCopyright setHidden:TRUE];
        [btnCopyright setHidden:TRUE];
        
        [lblFlagPrompt setText:[NSString stringWithFormat:@"Why would you like to flag \"%@\"?",[dictCollectionInfo valueForKey:COLLECTION_TITLE]]];
        
        strSelection = [NSString stringWithFormat:@"Collection"];
        
        [lblFlaggedTitle setText:[dictCollectionInfo valueForKey:COLLECTION_TITLE]];
        
    }else{
        [lblFlagPopupTitle setText:[NSString stringWithFormat:@"Flag this Resource"]];
        [viewCollectionFlagging setHidden:TRUE];
        [viewResourceFlagging setHidden:FALSE];
        [lblCopyright setHidden:FALSE];
        [btnCopyright setHidden:FALSE];
        
        [lblFlagPrompt setText:[NSString stringWithFormat:@"Why would you like to flag \"%@\"?",[dictResourceInfo valueForKey:RESOURCE_TITLE]]];
        
        strSelection = [NSString stringWithFormat:@"Resource"];
        
        [lblFlaggedTitle setText:[dictResourceInfo valueForKey:RESOURCE_TITLE]];
    }
    
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    //Incoming Details
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    isLoggedIn = [[standardUserDefaults stringForKey:@"isLoggedIn"] boolValue];
    
    arrFlaggingSelection = [[NSMutableArray alloc] init];
    
    if (isLoggedIn) {
        NSLog(@"User Auth Status : User Logged In!");
    }else{
        NSLog(@"User Auth Status : User Logged Out!");
        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
    }
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    serverUrl = [appDelegate getValueByKey:@"ServerURL"];
 
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BA Close

- (IBAction)btnActionCloseFlagPopup:(id)sender {
    
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeCurrentDetailViewController) withObject:nil afterDelay:0.3];
    
//    [self removeCurrentDetailViewController];
    
}


#pragma mark BA Flag Options
- (IBAction)btnActionFlagOptions:(id)sender {
    
    
    [self manageOptionSelection:sender];
    
}

#pragma mark Manage Option Selection
- (void)manageOptionSelection:(id)sender{
    
    
    UIButton* btnOptionToSelectDeselect = (UIButton*)sender;
    
    if ([btnOptionToSelectDeselect isSelected]) {
        [btnOptionToSelectDeselect setSelected:FALSE];
    }else{
        [btnOptionToSelectDeselect setSelected:TRUE];
    }
    
    NSString* strParams;

    switch ([sender tag]) {
        case 11:
        {
            strParams = [NSString stringWithFormat:@"missing-concept"];
            
            
            break;
        }
            
        case 22:
        {
            strParams = [NSString stringWithFormat:@"not-loading"];
            break;
        }
            
            
        case 33:
        {
            strParams = [NSString stringWithFormat:@"inappropriate"];
            break;
        }
            
        case 44:
        {
            strParams = [NSString stringWithFormat:@"other"];
            break;
        }
        default:
            break;
    }


    
    
    if ([btnOptionToSelectDeselect isSelected]) {
        
        [arrFlaggingSelection addObject:strParams];
        
        
    }else{
        
        for (int i = 0; i < [arrFlaggingSelection count]; i++) {
            
            if ([[arrFlaggingSelection objectAtIndex:i] isEqualToString:strParams]) {
                
                [arrFlaggingSelection removeObjectAtIndex:i];
            }
            
        }
        
    }
    
    //Flagging Validation
    if ([arrFlaggingSelection count] != 0) {
        [btnSubmitFlags setEnabled:TRUE];
    }else{
        [btnSubmitFlags setEnabled:FALSE];
    }
    
    NSLog(@"arrFlaggingSelection : %@",[arrFlaggingSelection description]);
    
}

#pragma mark BA Submit Flags
- (IBAction)btnActionSubmitFlags:(id)sender {
    
    if(isLoggedIn){
        
        [self flagContent];
        
    }else{
        
        loginViewController=[[LoginViewController alloc]initWithParentViewController:self];
        [self presentDetailController:loginViewController inMasterView:self.view];
        
    }
    
}

- (IBAction)btnActionTermsAndConditions:(id)sender {
    
    if (viewTandC.frame.origin.y == 42) {
        [self animateView:viewTandC forFinalFrame:CGRectMake(0, 605, viewTandC.frame.size.width, viewTandC.frame.size.height)];
    }else{
        [self animateView:viewTandC forFinalFrame:CGRectMake(0, 42, viewTandC.frame.size.width, viewTandC.frame.size.height)];
    }
    
//    [scrollTandC setContentSize:CGSizeMake(scrollTandC.frame.size.width, 1372)];
    
    [webviewTerms loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"]isDirectory:NO]]];

    
    [self performSelector:@selector(renderText) withObject:nil afterDelay:0.6];
    
//    txtViewTandC.hidden = FALSE;
    [scrollTandC setContentOffset:CGPointMake(0, 0) animated:YES];

}

- (void)renderText{
    
    [webviewTerms.scrollView setContentOffset:CGPointMake(0, webviewTerms.frame.size.height + 65) animated:YES];
    
}

-(void)flaggingComplete{
    if (!isParentCollectionPlayer) {
        
        
        NSLog(@"parentViewController : ResourcePlayerViewController Submit");
        [resourcePlayerViewController setFlagging];
        
    }else{
        
        NSLog(@"parentViewController : CollectionPlayerV2ViewController Submit");
        [collectionPlayerV2ViewController setFlaggingForCollection:isCollection];
        
    }
    
    
    [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(-797, viewFlaggingPopup.frame.origin.y, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];
    
    [self animateView:viewFlaggingConfirmedPopup forFinalFrame:CGRectMake(287, viewFlaggingConfirmedPopup.frame.origin.y, viewFlaggingConfirmedPopup.frame.size.width, viewFlaggingConfirmedPopup.frame.size.height)];
}

#pragma mark - API Connections -

#pragma mark - flagContent -

-(void)flagOnLogin{
    
    [self flagContent];
    
}

-(void)flagContent{
    
    if (isCollection) {
        gooruOID = [dictCollectionInfo valueForKey:COLLECTION_ID];
    }else{
        gooruOID = [dictResourceInfo valueForKey:RESOURCE_ACTUAL_ID];
    }
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    
    
  
    NSURL *url = [NSURL URLWithString:serverUrl];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"data", nil];
    
    NSString* strFields;
//    
//    if ([arrFlaggingSelection count] == 1) {
//        
//        strFields = [NSString stringWithFormat:@"{\"target\" : {\"value\":\"content\"}, \"type\" : {\"value\":\"%@\"}, \"assocGooruOid\":\"%@\"}",[arrFlaggingSelection objectAtIndex:0],gooruOID];
//        
//    }else{
//        
//        NSMutableArray* arrValue = [[NSMutableArray alloc] init];
//        
//        for (int i = 0 ; i < [arrFlaggingSelection count]; i++) {
//            
//            [arrValue addObject:[NSString stringWithFormat:@"{\"value\":\"%@\"}",[arrFlaggingSelection objectAtIndex:i]]];
//            
//        }
//
//        strFields = [NSString stringWithFormat:@"{\"target\" : {\"value\":\"content\"}, \"types\" : [%@], \"assocGooruOid\":\"%@\"}",[arrValue componentsJoinedByString:@","],gooruOID];
//        
//    }
strFields = [NSString stringWithFormat:@"{\"target\" : {\"value\":\"content\"}, \"type\" : {\"value\":\"other\"}, \"assocGooruOid\":\"%@\"}",gooruOID];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:strFields, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/flag?sessionToken=%@",sessionToken] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"flagContent Response : %@",responseStr);
        NSArray *results = [responseStr JSONValue];
        [self flaggingComplete];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
    
}



#pragma mark - KeyBoard delegates -

- (void) keyboardDidShow: (NSNotification *)notif {
    NSLog(@"keyboardDidShow : %f",viewFlaggingPopup.frame.origin.y);
    
    if (viewFlaggingPopup.frame.origin.y == 82) {
        
        [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(viewFlaggingPopup.frame.origin.x, viewFlaggingPopup.frame.origin.y - 180, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];
        
    }
    
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    NSLog(@"keyboardDidHide : %f",viewFlaggingPopup.frame.origin.y);
    if (viewFlaggingPopup.frame.origin.y != 82) {
        
        [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(viewFlaggingPopup.frame.origin.x, viewFlaggingPopup.frame.origin.y + 180, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];

    }
    
}


#pragma mark - Animate Views -
- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}



#pragma mark - Remove ViewController -

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
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}
@end
