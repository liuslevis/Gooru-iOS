//
//  SummaryPageViewController.m
// Gooru
//
//  Created by Gooru on 17/09/13.
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

#import "SummaryPageViewController.h"
#import "CollectionPlayerV2ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "AFHTTPClient.h"
#import "DTCoreText.h"
#import "Toast+UIView.h"
#import "DTAttributedLabel.h"
#import "DTAttributedTextView.h"
#import "AppDelegate.h"
#import "NSString_stripHtml.h"

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


//Resource Navigation
#define MULTIPLIER_RESOURCE_NAVIGATION 789


#define TAG_RESOURCE_ADDITIVE 21
#define TAG_RESOURCE_MULTIPLIER 31


@interface SummaryPageViewController ()

@end

NSMutableDictionary* dictCollection;
NSMutableDictionary* dictAllResources;

NSMutableDictionary* dictCorrect;
NSMutableDictionary* dictIncorrect;
NSMutableDictionary* dictSkipped;
NSMutableDictionary* dictResponses;

NSMutableDictionary* dictMCQ;
NSMutableDictionary* dictOE;
NSMutableDictionary* dictSimpleResources;

BOOL flagShouldAllowSummary;
NSUserDefaults *standardUserDefaults;


NSString* sessionToken,*serverUrl;
CollectionPlayerV2ViewController* collectionPlayerV2ViewController;
AppDelegate* appDelegate;
@implementation SummaryPageViewController
@synthesize viewOverview,viewCorrect,viewIncorrect,viewSkipped,viewResponses;
@synthesize btnCorrect,btnOverview,btnIncorrect,btnSkipped,btnResponses;
@synthesize viewMainSubview;

#pragma mark - Inits -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCollectionDetails:(NSMutableDictionary*)dictIncomingCollections andResourceDetails:(NSMutableDictionary*)dictIncomingResourceDetails andCollectionPlayerObject:(CollectionPlayerV2ViewController*)incomingCollectionPlayerV2ViewController{
    
    collectionPlayerV2ViewController = incomingCollectionPlayerV2ViewController;
    
    dictCollection = dictIncomingCollections;
    dictAllResources = dictIncomingResourceDetails;
    
    flagShouldAllowSummary = FALSE;

    
    
    return self;
}

#pragma mark - View Lifecycle -
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    btnOverview.selected=TRUE;
    
    //Adding Tabs
    viewMainSubview.frame=CGRectMake(0, 0, viewMainSubview.frame.size.width, viewMainSubview.frame.size.height);
    [viewTabsParent addSubview:viewMainSubview];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];

    //Adding Answer Review View
    [viewReviewAnswer setFrame:CGRectMake(1024, 0, viewReviewAnswer.frame.size.width, viewReviewAnswer.frame.size.height)];
    [viewTabParent addSubview:viewReviewAnswer];
     appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    sessionToken = [dictCollection valueForKey:SESSION_TOKEN];
    serverUrl = [dictCollection valueForKey:SERVER_URL];
    // Do any additional setup after loading the view from its nib.
    [self populateCollectionDetails];
    [self prepDictionaries];
        
}


#pragma mark - Populate Collection Details -
- (void)populateCollectionDetails{
    
    [lblCollectionTitle setText:[dictCollection valueForKey:COLLECTION_TITLE]];
    
    
    
}

#pragma mark - Prep and Populate Tabs -

#pragma mark Prepare Dictionaries for Tabs
- (void)prepDictionaries{
    
    dictCorrect = [[NSMutableDictionary alloc] init];
    dictIncorrect = [[NSMutableDictionary alloc] init];
    dictSkipped = [[NSMutableDictionary alloc] init];
    dictResponses = [[NSMutableDictionary alloc] init];
    
    //Prep dictionaries for report
    dictMCQ = [[NSMutableDictionary alloc] init];
    dictOE = [[NSMutableDictionary alloc] init];
    dictSimpleResources = [[NSMutableDictionary alloc] init];
    
    //Get all Keys and sort
    NSArray* keysDictAllResources =  [collectionPlayerV2ViewController sortedIntegerKeysForDictionary:dictAllResources];
    
    int totalResource = [dictAllResources count];
    
    for (int i = 0; i<totalResource; i++) {
        
        NSMutableDictionary* dictResourceInfo = [dictAllResources valueForKey:[keysDictAllResources objectAtIndex:i]];
        
        //Prep dictionary for summary page
        if ([[dictResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Question"]) {
            
            if ([[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:@"NA"]) {
                
                NSLog(@"Skipped!");
                
                [dictSkipped setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
                
            }else{
                 if (![[dictResourceInfo valueForKey:QUESTION_TYPE] isEqualToString:@"6"]) {
                     
                     if ([[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:[dictResourceInfo valueForKey:QUESTION_CORRECTANSWER]]) {
                         
                         NSLog(@"Correct Answer!");
                         [dictCorrect setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
                         
                     }else{
                         
                         NSLog(@"Incorrect Answer!");
                         [dictIncorrect setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
                         
                     }

                 }
                
                                
            }
            
        }
        
        if ([[dictResourceInfo valueForKey:QUESTION_TYPE] isEqualToString:@"6"]) {
            if (![[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:@"NA"]) {
                [dictResponses setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
            }
            
            
        }
        
        
        
        if ([[dictResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Question"]) {
            
            //Load OE Questions that are not skipped
            if ([[dictResourceInfo valueForKey:QUESTION_TYPE] isEqualToString:@"6"]) {
                if (![[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:@"NA"]) {
                    [dictOE setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
                }
                
            }else{
                //Load MCQ
                if (![[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:@"NA"]) {
                    [dictMCQ setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
                }
                
            }

        }else{
            //Simple Resources with Reactions
            
            if (![[dictResourceInfo valueForKey:RESOURCE_REACTION] isEqualToString:@"NA"]) {
                [dictSimpleResources setValue:dictResourceInfo forKey:[keysDictAllResources objectAtIndex:i]];
            }
            
            
            
        }
        
        
    }

    [btnOverview setTitle:[NSString stringWithFormat:@"%@(%i)",btnOverview.titleLabel.text,[dictAllResources count]] forState:UIControlStateNormal];
    [btnCorrect setTitle:[NSString stringWithFormat:@"%@(%i)",btnCorrect.titleLabel.text,[dictCorrect count]] forState:UIControlStateNormal];
    [btnIncorrect setTitle:[NSString stringWithFormat:@"%@(%i)",btnIncorrect.titleLabel.text,[dictIncorrect count]] forState:UIControlStateNormal];
    [btnSkipped setTitle:[NSString stringWithFormat:@"%@(%i)",btnSkipped.titleLabel.text,[dictSkipped count]] forState:UIControlStateNormal];
    [btnResponses setTitle:[NSString stringWithFormat:@"%@(%i)",btnResponses.titleLabel.text,[dictResponses count]] forState:UIControlStateNormal];
    
    [self populateTab:scrollOverview usingDictionary:dictAllResources];
    [self populateTab:scrollCorrect usingDictionary:dictCorrect];
    [self populateTab:scrollIncorrect usingDictionary:dictIncorrect];
    [self populateTab:scrollSkipped usingDictionary:dictSkipped];
    [self populateTab:scrollResponses usingDictionary:dictResponses];
    
    [self relayoutTabButtons];
    
    
}

#pragma relayout tab buttons
-(void)relayoutTabButtons{

    int lastXordinate = btnOverview.frame.origin.x + btnOverview.frame.size.width;
    for (int i=1; i<5; i++) {
        
        UIButton* btnTab = (UIButton*)[viewTopBarBtns viewWithTag:i*1024];
        
        if ([btnTab.titleLabel.text rangeOfString:@"(0)"].length > 0) {
            
            [btnTab setHidden:TRUE];
            [collectionPlayerV2ViewController shouldHideView:btnTab :TRUE];
            
        }else{
            
            [self animateView:btnTab forFinalFrame:CGRectMake(lastXordinate, btnTab.frame.origin.y, btnTab.frame.size.width, btnTab.frame.size.height) withDuration:0.4];
            lastXordinate = lastXordinate + btnOverview.frame.size.width;
        }
        
    }
    
}

#pragma mark Populate Tabs

- (void)populateTab:(UIScrollView*)scrollViewTab usingDictionary:(NSMutableDictionary*)dictResources{
    
    int sizeDictResources = [dictResources count];
    
    //Get all Keys and sort
    NSArray* keysDictResources =  [collectionPlayerV2ViewController sortedIntegerKeysForDictionary:dictResources];
    int lastYordinate = 0;
    
    for (int i=0; i<sizeDictResources; i++) {
        
        NSMutableDictionary* dictResourceInfo = [dictResources valueForKey:[keysDictResources objectAtIndex:i]];
        
         //Summary Item Parent
        UIView* viewSummaryItem = [[UIView alloc] init];
        
        //Serial Number
        UILabel* lblSerialNumber = [[UILabel alloc] initWithFrame:lblRefSerialNumber.frame];
        [lblSerialNumber setFont:lblRefSerialNumber.font];
        [lblSerialNumber setTextColor:lblRefSerialNumber.textColor];
        
        int serialNumber = [[keysDictResources objectAtIndex:i] intValue];
        serialNumber = serialNumber - TAG_RESOURCE_ADDITIVE;
        serialNumber = serialNumber/TAG_RESOURCE_MULTIPLIER;
        
        [lblSerialNumber setText:[NSString stringWithFormat:@"%i",serialNumber+1]];
        [viewSummaryItem addSubview:lblSerialNumber];
        
        //Thumbnail
        UIImageView* imgViewThumbnail = [[UIImageView alloc] initWithFrame:imgViewRefThumbnail.frame];
        [imgViewThumbnail setImageWithURL:[NSURL URLWithString:[dictResourceInfo valueForKey:RESOURCE_THUMBNAIL]] placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
        [viewSummaryItem addSubview:imgViewThumbnail];
        
        //Button for retrying
        UIButton* btnResource = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnResource setFrame:imgViewThumbnail.frame];
        [btnResource setBackgroundColor:[UIColor clearColor]];
        
        [btnResource setTag:[[keysDictResources objectAtIndex:i] intValue] * MULTIPLIER_RESOURCE_NAVIGATION];
        [btnResource addTarget:self action:@selector(btnActionNavigateResourcesSummary:) forControlEvents:UIControlEventTouchUpInside];
        
        [viewSummaryItem addSubview:btnResource];
    
        
        
        //Validator
        UIImageView* imgViewValidator = [[UIImageView alloc] initWithFrame:imgViewRefValidator.frame];
        [viewSummaryItem addSubview:imgViewValidator];

        
        //Resource Title
        UILabel* lblResourceTitle = [[UILabel alloc] initWithFrame:lblRefResourceTitle.frame];
        [lblResourceTitle setFont:lblRefResourceTitle.font];
        [lblResourceTitle setTextColor:lblRefResourceTitle.textColor];
        
        [lblResourceTitle setText:[[dictResourceInfo valueForKey:RESOURCE_TITLE] stripHtml]];
    
        
        
        lblResourceTitle.numberOfLines = 10;
        
        lblResourceTitle.frame = [collectionPlayerV2ViewController getHLabelFrameForLabel:lblResourceTitle withString:lblResourceTitle.text];
        
        [viewSummaryItem addSubview:lblResourceTitle];
        
        
        //Validation
        if ([[dictResourceInfo valueForKey:RESOURCE_CATEGORY] isEqualToString:@"Question"]) {
            
            flagShouldAllowSummary = TRUE;
            
            //Review Answer
            UIButton* btnReviewAnswer = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnReviewAnswer setFrame:btnRefReviewAnswer.frame];
            [btnReviewAnswer setBackgroundColor:[UIColor clearColor]];
            [btnReviewAnswer setImage:btnRefReviewAnswer.imageView.image forState:UIControlStateNormal];
            
            [btnReviewAnswer setTag:[[keysDictResources objectAtIndex:i] intValue] * MULTIPLIER_RESOURCE_NAVIGATION];
            [btnReviewAnswer addTarget:self action:@selector(btnActionReviewAnswer:) forControlEvents:UIControlEventTouchUpInside];
            
            [viewSummaryItem addSubview:btnReviewAnswer];
            
            //Adding Q: to Resource Title
            [lblResourceTitle setText:[NSString stringWithFormat:@"Q: %@",[dictResourceInfo valueForKey:RESOURCE_TITLE]]];
            
            if ([[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:@"NA"]) {
                
                NSLog(@"Skipped!");
                [btnResource setImage:[UIImage imageNamed:@"summaryGoBackAnswer.png"] forState:UIControlStateNormal];
                
                
            }else{
                if(![[dictResourceInfo valueForKey:QUESTION_TYPE] isEqualToString:@"6"]){
                    
                    if ([[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:[dictResourceInfo valueForKey:QUESTION_CORRECTANSWER]]) {
                        
                        NSLog(@"Correct Answer!");
                        [imgViewValidator setImage:[UIImage imageNamed:@"correct@2x.png"]];
                        
                    }else{
                        
                        NSLog(@"Incorrect Answer!");
                        [imgViewValidator setImage:[UIImage imageNamed:@"incorrect@2x.png"]];
                        [btnResource setImage:[UIImage imageNamed:@"summaryRetry.png"] forState:UIControlStateNormal];
                        
                    }

                }else{
                    
                    [imgViewValidator setImage:[UIImage imageNamed:nil]];
                    
                }
                
                                
            }
            
        }

        
        //Description
        UILabel* lblResourceNarration = [[UILabel alloc] initWithFrame:lblRefResourceDescription.frame];
        [lblResourceNarration setFont:lblRefResourceDescription.font];
        [lblResourceNarration setTextColor:lblRefResourceDescription.textColor];
        lblResourceNarration.numberOfLines = 10;
        
        [lblResourceNarration setText:[[dictResourceInfo valueForKey:RESOURCE_NARRATION] stripHtml]];
        
        lblResourceNarration.frame = [collectionPlayerV2ViewController getHLabelFrameForLabel:lblResourceNarration withString:lblResourceNarration.text];
        
        [lblResourceNarration setFrame:CGRectMake(lblResourceNarration.frame.origin.x, lblResourceTitle.frame.origin.y + lblResourceTitle.frame.size.height + 10, lblResourceNarration.frame.size.width, lblResourceNarration.frame.size.height)];
        
        if (![[dictResourceInfo valueForKey:RESOURCE_NARRATION] isEqualToString:@""] && ![[dictResourceInfo valueForKey:RESOURCE_NARRATION] isEqualToString:@"NA"]) {
            [viewSummaryItem addSubview:lblResourceNarration];
        }
        
        
        //Description Hint
        UIImageView* imgViewDescriptionHint = [[UIImageView alloc] initWithFrame:imgViewRefDescriptionHint.frame];
        [imgViewDescriptionHint setFrame:CGRectMake(imgViewDescriptionHint.frame.origin.x, lblResourceTitle.frame.origin.y + lblResourceTitle.frame.size.height + 10, imgViewDescriptionHint.frame.size.width, imgViewDescriptionHint.frame.size.height)];

        
        [imgViewDescriptionHint setImage:imgViewRefDescriptionHint.image];
        if (![[dictResourceInfo valueForKey:RESOURCE_NARRATION] isEqualToString:@""] && ![[dictResourceInfo valueForKey:RESOURCE_NARRATION] isEqualToString:@"NA"]) {
            [viewSummaryItem addSubview:imgViewDescriptionHint];
        }
        
        
        //Reaction
        UIImageView* imgViewReaction = [[UIImageView alloc] initWithFrame:imgViewRefReaction.frame];
        [imgViewReaction setBackgroundColor:[UIColor clearColor]];
        [self setReactFaceOnImageView:imgViewReaction forReaction:[[dictResourceInfo valueForKey:RESOURCE_REACTION] intValue]];
        
        [viewSummaryItem addSubview:imgViewReaction];
        

        //Separator
        UIView* viewSeparator = [[UIView alloc] initWithFrame:viewRefSeparator.frame];
        [viewSeparator setBackgroundColor:viewRefSeparator.backgroundColor];
        
        CGRect frameForSeparator;
        frameForSeparator.size.width = viewRefSeparator.frame.size.width;
        frameForSeparator.size.height = viewRefSeparator.frame.size.height;
        frameForSeparator.origin.x = 0;
        
        float yOrdinateForSeparator = MAX(lblResourceNarration.frame.origin.y + lblResourceNarration.frame.size.height, imgViewThumbnail.frame.origin.y + imgViewThumbnail.frame.size.height);
        
        frameForSeparator.origin.y = yOrdinateForSeparator + 24;
        
        
        
        viewSeparator.frame = frameForSeparator;
        
        [viewSummaryItem addSubview:viewSeparator];
        
        
        //Setting Summary Item frame
        CGRect frameForSummaryItem;
        frameForSummaryItem.size.width = viewRefSummaryItem.frame.size.width;
        frameForSummaryItem.size.height = viewSeparator.frame.origin.y + viewSeparator.frame.size.height;
        frameForSummaryItem.origin.x = 0;
        frameForSummaryItem.origin.y = lastYordinate;
        
        viewSummaryItem.frame = frameForSummaryItem;
    
        
        //Adding Summary Item to Parent view
        [scrollViewTab addSubview:viewSummaryItem];
        
        lastYordinate = lastYordinate + viewSummaryItem.frame.size.height;
        
        
    }
    
    [scrollViewTab setContentSize:CGSizeMake(scrollViewTab.frame.size.width, lastYordinate)];
        
    


    
    
}

#pragma mark Set Reaction Image

-(void)setReactFaceOnImageView:(UIImageView*)imgView forReaction:(int)reaction{
    
    switch (reaction) {
        case 111:{
            flagShouldAllowSummary = TRUE;
            [imgView setImage:[UIImage imageNamed:@"reactFace1.png"]];
            break;
        }
            
        case 222:{
            flagShouldAllowSummary = TRUE;
            [imgView setImage:[UIImage imageNamed:@"reactFace2.png"]];
            break;
        }
            
        case 333:{
            flagShouldAllowSummary = TRUE;
            [imgView setImage:[UIImage imageNamed:@"reactFace3.png"]];
            break;
        }
            
        case 444:{
            flagShouldAllowSummary = TRUE;
            [imgView setImage:[UIImage imageNamed:@"reactFace4.png"]];
            break;
        }
            
        case 555:{
            flagShouldAllowSummary = TRUE;
            [imgView setImage:[UIImage imageNamed:@"reactFace5.png"]];
            break;
        }
             
        default:
            break;
    }
    
}

#pragma mark BA Review Answer/Back From Review
-(void)btnActionReviewAnswer:(id)sender{
    
    [self animateView:viewTabParent forFinalFrame:CGRectMake(-1024, viewTabParent.frame.origin.y, viewTabParent.frame.size.width, viewTabParent.frame.size.height) withDuration:0.4f];
    
    int tag = [sender tag];
    
    tag = tag/MULTIPLIER_RESOURCE_NAVIGATION;
    
    NSMutableDictionary* dictResourceInfo = [dictAllResources valueForKey:[NSString stringWithFormat:@"%i",tag]];
    
    [collectionPlayerV2ViewController loadQuestionOn:viewReviewAnswerChild withQuestionData:dictResourceInfo andKey:[NSString stringWithFormat:@"%i",tag] forSummaryPage:TRUE];
    [collectionPlayerV2ViewController enableCarousel:FALSE];
    
    [collectionPlayerV2ViewController shouldHideView:btnBackFromReview :FALSE];
    

    
}

- (IBAction)btnActionBackFromReview:(id)sender {
    
    [self animateView:viewTabParent forFinalFrame:CGRectMake(0, viewTabParent.frame.origin.y, viewTabParent.frame.size.width, viewTabParent.frame.size.height) withDuration:0.4f];
    [collectionPlayerV2ViewController shouldHideView:btnBackFromReview :TRUE];
    
    for (UIView* aView in [viewReviewAnswerChild subviews]) {
        [aView removeFromSuperview];
        
    }
    
    [collectionPlayerV2ViewController enableCarousel:TRUE];
}

#pragma mark BA Navigate from Summary

-(void)btnActionNavigateResourcesSummary:(id)sender{
    
    [collectionPlayerV2ViewController btnActionNavigateResources:sender];
    
}

#pragma mark Manage View Animation
-(void)animateView:(UIView*)view forFinalFrame:(CGRect)frame withDuration:(float)duration{
    
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark   BtnAction for Overview/Correct/Incorrect/Skipped
-(IBAction)btnActionShowSubview:(id)sender{
    
    int tag = [sender tag];
    
    tag = tag - (tag*2);

    
    if ([sender tag]==0) {
        btnOverview.selected=TRUE;
        btnCorrect.selected=FALSE;
        btnIncorrect.selected=FALSE;
        btnSkipped.selected=FALSE;
        btnResponses.selected=FALSE;
    }else if([sender tag]==1024){
        btnOverview.selected=FALSE;
        btnCorrect.selected=TRUE;
        btnIncorrect.selected=FALSE;
        btnSkipped.selected=FALSE;
        btnResponses.selected=FALSE;
    }else if ([sender tag]==2048){
        btnOverview.selected=FALSE;
        btnCorrect.selected=FALSE;
        btnIncorrect.selected=TRUE;
        btnSkipped.selected=FALSE;
        btnResponses.selected=FALSE;
    }else if ([sender tag]==3072){
        btnOverview.selected=FALSE;
        btnCorrect.selected=FALSE;
        btnIncorrect.selected=FALSE;
        btnSkipped.selected=TRUE;
        btnResponses.selected=FALSE;
    }else if([sender tag]==4096){
        btnOverview.selected=FALSE;
        btnCorrect.selected=FALSE;
        btnIncorrect.selected=FALSE;
        btnSkipped.selected=FALSE;
        btnResponses.selected=TRUE;
    }
    
    [self animateView:viewMainSubview forFinalFrame:CGRectMake(tag, 0, viewMainSubview.frame.size.width, viewMainSubview.frame.size.height) withDuration:0.4f];
    
    
}

#pragma mark - BA Email/Print -
- (IBAction)btnEmailAction:(id)sender {
    
    
    if (!flagShouldAllowSummary) {
        [self alertWithMessage:@"You may only save your summary if you've reacted to a resource or if the collection has questions."];
    }else{
        
        [activityIndicatorMail startAnimating];
        
        //Mixpanel track dictionary
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[dictCollection valueForKey:COLLECTION_TITLE] forKey:@"CollectionTitle"];
        
        NSString *username;
        
        if ([[standardUserDefaults valueForKey:@"isLoggedIn"] boolValue]) {
            username = [standardUserDefaults valueForKey:@"username"];
        }else{
            username = @"Anonymous";
        }
        [dictionary setObject:username forKey:@"Username"];
     //   [appDelegate logMixpanelforevent:@"Email Summary" and:dictionary];
        
        [self createHtmlSummary];
    }
    
    
   
}

- (IBAction)btnPrintAction:(id)sender {
//     [self createPDF:temp];
}


#pragma mark - BA Replay Collection -
- (IBAction)btnActionReplay:(id)sender {
    
    [collectionPlayerV2ViewController btnActionReplayCollection:sender];
}


#pragma mark - Summary Page HTML methods -



#pragma mark generatePDFfromHTML for resource
-(void)generatePDFfromHTML:(NSString*)strHtml{
    
    NSURL *url = [NSURL URLWithString:serverUrl];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    NSMutableArray* parameterKeys = [NSArray arrayWithObjects:@"data", nil];
    
    
    // This is the final html to which u have to add everything as a huge string 
    
    NSString* html = strHtml;
    

    NSString* strFields = [NSString stringWithFormat:@"{\"html\" : \"%@\",\"fileName\" : \"iPadSummary\"}}",html];
    NSMutableArray* parameterValues =  [NSArray arrayWithObjects:strFields, nil];
    NSMutableDictionary* dictPostParams = [NSDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/media/htmltopdf?sessionToken=%@",sessionToken] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"generatePDFfromHTML Response : %@",responseStr);
        
        
        NSString* strSubject = [NSString stringWithFormat:@"I've shared my Gooru collection summary with you!"];
      
        NSString* emailBody = [NSString stringWithFormat:@"Hello [Enter your teacher or tutor's name].\n I am sharing my collection summary with you. \n [PDF attached below] \n "];
        
        NSLog(@"Email");
        if ([MFMailComposeViewController canSendMail]) {
            // Show the composer
            MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
            emailController.mailComposeDelegate = self;
            [emailController setSubject:strSubject];
            
            NSURL *pdfURL = [NSURL URLWithString:responseStr];
            NSData *pdfData = [NSData dataWithContentsOfURL:pdfURL];
            [emailController addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"summary.pdf"];
        
            if (emailController) [self presentModalViewController:emailController animated:YES];
            
            //if you want to change its size but the view will remain centerd on the screen in both portrait and landscape then:
            emailController.view.superview.bounds = CGRectMake(0, 0, 320, 480);
            
            //or if you want to change it's position also, then:
            emailController.view.superview.frame = CGRectMake(236, 146, 540, 540);
            
             [emailController setMessageBody:emailBody isHTML:NO];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:[dictCollection valueForKey:COLLECTION_TITLE] forKey:@"CollectionTitle"];
            
            NSString *username;
            
            if ([[standardUserDefaults valueForKey:@"isLoggedIn"] boolValue]) {
                username = [standardUserDefaults valueForKey:@"username"];
            }else{
                username = @"Anonymous";
            }
            
            [dictionary setObject:username forKey:@"Username"];
        } else {
            // Handle the error
     
            [self.view makeToast:@"No e-mail client configured on the device."
                        duration:2.0
                        position:@"center"];
        }
        
        [activityIndicatorMail stopAnimating];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [activityIndicatorMail stopAnimating];
        NSLog(@"[HTTPClient Error]: %@", [error description]);
    }];
    
}

#pragma mark Create HTML Summary
-(void)createHtmlSummary{
    
    NSString* strHtmlSummary = [NSString stringWithFormat:@"%@%@",[self createHtmlHeader],[self createHtmlBody]];
    
    //Adding OE Questions
    if ([dictOE count] != 0) {
        strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary,[self createSectionDividerWithHeading:@"Open Ended Questions"]];
        
        //Get all Keys and sort
        NSArray* keysDictResources =  [collectionPlayerV2ViewController sortedIntegerKeysForDictionary:dictOE];
        
       
        
        for (int i=0; i < [dictOE count]; i++) {
            
             NSMutableDictionary* dictResourceInfo = [dictOE valueForKey:[keysDictResources objectAtIndex:i]];
            
            int serialNumber = [[keysDictResources objectAtIndex:i] intValue];
            serialNumber = serialNumber - TAG_RESOURCE_ADDITIVE;
            serialNumber = serialNumber/TAG_RESOURCE_MULTIPLIER;
            serialNumber = serialNumber + 1;
            
            strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary, [self createopenEndedDiv:[dictResourceInfo valueForKey:QUESTION_USERANSWER] andResourceNumber:[NSString stringWithFormat:@"%i",serialNumber] withQuestionText:[dictResourceInfo valueForKey:QUESTION_TEXT]]];
            
        }
    }
    
    //Adding Multiple Choice Questions
    if ([dictMCQ count] != 0) {
        strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary,[self createSectionDividerWithHeading:@"Multiple Choice Questions"]];
        
        //Get all Keys and sort
        NSArray* keysDictResources =  [collectionPlayerV2ViewController sortedIntegerKeysForDictionary:dictMCQ];
        
        for (int i=0; i < [dictMCQ count]; i++) {
            
             NSMutableDictionary* dictResourceInfo = [dictMCQ valueForKey:[keysDictResources objectAtIndex:i]];
            
            int serialNumber = [[keysDictResources objectAtIndex:i] intValue];
            serialNumber = serialNumber - TAG_RESOURCE_ADDITIVE;
            serialNumber = serialNumber/TAG_RESOURCE_MULTIPLIER;
            serialNumber = serialNumber + 1;
            
            BOOL isCorrect = FALSE;
            
            
            if ([[dictResourceInfo valueForKey:QUESTION_USERANSWER] isEqualToString:[dictResourceInfo valueForKey:QUESTION_CORRECTANSWER]]) {
                
                NSLog(@"Correct Answer!");
                isCorrect = TRUE;
                
            }else{
                
                NSLog(@"Incorrect Answer!");
                isCorrect = FALSE;
                
            }


            strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary, [self createQuestionDiv:isCorrect andQuestionNumber:[NSString stringWithFormat:@"%i",serialNumber] withQuestionText:[dictResourceInfo valueForKey:QUESTION_TEXT]]];

        }
    }
    
    //Adding Simple Resources
    if ([dictSimpleResources count] != 0) {
        strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary,[self createSectionDividerWithHeading:@"Reactions"]];
        
        //Get all Keys and sort
        NSArray* keysDictResources =  [collectionPlayerV2ViewController sortedIntegerKeysForDictionary:dictSimpleResources];
        
        for (int i=0; i < [dictSimpleResources count]; i++) {
            
             NSMutableDictionary* dictResourceInfo = [dictSimpleResources valueForKey:[keysDictResources objectAtIndex:i]];
            
            int serialNumber = [[keysDictResources objectAtIndex:i] intValue];
            serialNumber = serialNumber - TAG_RESOURCE_ADDITIVE;
            serialNumber = serialNumber/TAG_RESOURCE_MULTIPLIER;
            serialNumber = serialNumber + 1;
        
            
            
            strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary, [self createReactionDiv:[[dictResourceInfo valueForKey:RESOURCE_REACTION] intValue] andResourceNumber:[NSString stringWithFormat:@"%i",serialNumber] withQuestionText:[dictResourceInfo valueForKey:RESOURCE_TITLE]]];
            
        }
    }


    strHtmlSummary = [NSString stringWithFormat:@"%@%@",strHtmlSummary, [self createHtmlEnd]];
    
   
    
    strHtmlSummary = [[strHtmlSummary componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
    
    [self generatePDFfromHTML:strHtmlSummary];
    
}


#pragma mark createHtmlHeader

//Creates the HTML header no values to be passed to this. Incase in future if we have to add fill in the blanks etc we can update classes here.

-(NSString*)createHtmlHeader{
    NSString* htmlHeader = @"<!DOCTYPE html PUBLIC \\\"-//W3C//DTD XHTML 1.0 Transitional//EN\\\" \\\"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\\\">    <html xmlns=\\\"http://www.w3.org/1999/xhtml\\\">    <head>    <meta http-equiv=\\\"Content-Type\\\" content=\\\"text/html; charset=utf-8\\\" />    <title>Untitled Document</title>    <style type=\\\"text/css\\\">    body {	color:#515151;        font-family:Arial, Helvetica, sans-serif;        font-size:12px;} p {margin:0px;}   .container {	width:568px;        min-height:500px;	height:auto;        margin:0 auto;    }    .gooru-logo {	background:url(\\\"http://www.goorulearning.org/images/print/gooru-small-logo.png\\\");	width:51px;	height:16px;margin:0 auto 15px auto;}.fill-in-student-data.name {        float:left;        clear:both;        line-height:20px;}.fill-in-student-data.class {float:right;line-height:20px;}    .fill-in-student-data .label {        float:left;        margin-right:10px;        font-weight:bold}  .fill-in-student-data.name {float:left;clear:both;line-height:20px;}.fill-in-student-data.class 	float:right;	line-height:20px;}.fill-in-student-data .label 	float:left;	margin-right:10px;	font-weight:bold}.fill-in-student-data .blank {width:215px;height:20px;float:left;	border-bottom:1px solid #b3b3b3;}.content-container {border: 1px solid #dddddd;	margin-top:10px;	float:left;}.collection-metadata-left {width: 300px;	float:left;margin:10px;}.collection-metadata-right {	float:right;margin:10px;}.label {	font-weight:bold;}.section-divider {	font-weight:bold;clear:both;background:#f0f0f0;padding: 7px 10px;margin:10px 0px;	border-bottom:1px solid #ddd;}.oe-question {width:532px;	min-height:20px;height:auto;	margin-bottom: 17px;	border-bottom:1px solid #dddddd;margin:15px;overflow:hidden;}.oe-question.last, .mc-question.last, .non-question-resource.last {	border-bottom:none;	margin-bottom:0px;}.question-number, .resource-number {	float:left;	font-weight:bold;margin:0px 14px 0px 14px;}.question-title {	float:left;	font-weight:bold;margin:0px 0px 0px 0px;width:475px;}.oe-question-answer {	float:left;margin:10px 15px 15px 37px;}.mc-question, .non-question-resource {	margin-bottom: 17px;	border-bottom:1px solid #dddddd;width:532px;	min-height:20px;height:auto;	margin-left:15px;overflow:hidden;}.non-question-resource {	margin-bottom:10px;min-height:30px;}.resource-number, .resource-title {	margin-top:3px !important;}.collection-link {	float:left;clear:both;	line-height:20px;}.page-number {	float:right;	line-height:20px;}.scoring-mark, .reaction {	float:left;margin:0px 15px;}     .correct {background:url(\\\"http://www.goorulearning.org/images/print/right-image.png\\\");width:15px;height:13px;}.incorrect {	background: url(\\\"http://www.goorulearning.org/images/print/wrong-image.png\\\");width:12px;height:13px;}.mc-question-answer, .resource-title {        float:left;        font-weight:bold;width:440px; margin:0px 0px 10px 0px;}.reaction {width:20px;height:20px;}.i-can-explain {background:url(\\\"http://www.goorulearning.org/images/print/reactFace1.png\\\");width: 22px;height: 22px;float: left;}.i-understand {background:url(\\\"http://www.goorulearning.org/images/print/reactFace2.png\\\");width: 22px;height: 22px;float: left;}.meh {background:url(\\\"http://www.goorulearning.org/images/print/reactFace3.png\\\");width: 22px;height: 22px;float: left;}.i-dont-understand {background:url(\\\"http://www.goorulearning.org/images/print/reactFace4.png\\\");width: 22px;height: 22px;float: left;}    .i-need-help {background:url(\\\"http://www.goorulearning.org/images/print/reactFace5.png\\\");width: 22px;height: 22px;float: left;}</style></head>";
      return htmlHeader;
}

#pragma mark createHtmlbody

// Create Html Body by taking username coll id and current date and time from dictCollection

-(NSString*)createHtmlBody{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //            [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    NSString *value = [dateFormatter stringFromDate:today];
    
    NSString *username;
    
    if ([[standardUserDefaults valueForKey:@"isLoggedIn"] boolValue]) {
        username = [standardUserDefaults valueForKey:@"username"];
    }else{
        username = @"Anonymous";
    }
    NSString* htmlbody = [NSString stringWithFormat:@"<body><div class=\\\"container\\\"><div class=\\\"gooru-logo\\\"></div><div class=\\\"fill-in-student-data name\\\"><div class=\\\"label\\\">Name:</div><div class=\\\"blank\\\"></div></div><div class=\\\"fill-in-student-data class\\\"><div class=\\\"label\\\">Class:</div><div class=\\\"blank\\\"></div></div><div class=\\\"content-container\\\"><div class=\\\"collection-metadata-left\\\"><div class=\\\"collection-title\\\"><span class=\\\"label\\\">Colllection Title:</span> %@ </div><div class=\\\"username\\\"><span class=\\\"label\\\">Username:</span> %@ </div></div><div class=\\\"collection-metadata-right\\\"><div class=\\\"completed\\\"><span class=\\\"label\\\">Completed:</span> %@</div></div>",[dictCollection valueForKey:COLLECTION_TITLE],username,value];
    return htmlbody;
}

-(NSString*)createHtmlEnd{
    
    NSString* htmlbody = [NSString stringWithFormat:@"</div></div></body></html>"];
    return htmlbody;
}


#pragma mark sectiopnDividersforHeadingswithHeading
// All headings like Open Ended or MCQ or reactions use this


-(NSString*)createSectionDividerWithHeading:(NSString*)header{
    
    NSString* questionDiv = [NSString stringWithFormat:@"<div class=\\\"section-divider\\\">%@</div>",header];
    
    return questionDiv;
}


#pragma mark CreateQuestionDiv
//Call this div inside a loop passing question data for MCQ only


-(NSString*)createQuestionDiv:(BOOL)isright andQuestionNumber:(NSString*)number withQuestionText:(NSString*)questiontext{

    NSString* questionDiv;
    
    if (isright) {
        
        questionDiv = [NSString stringWithFormat:@"<div class=\\\"mc-question\\\"><div class=\\\"scoring-mark correct\\\"></div><div class=\\\"question-number\\\">%@</div> <div class=\\\"mc-question-answer\\\">%@</div></div>",number,[questiontext stripHtml]];
                     
       
    }else{
        questionDiv = [NSString stringWithFormat:@"<div class=\\\"mc-question\\\"><div class=\\\"scoring-mark incorrect\\\"></div><div class=\\\"question-number\\\">%@</div> <div class=\\\"mc-question-answer\\\">%@</div></div>",number,[questiontext stripHtml]];
    }

    return questionDiv;
}

#pragma mark createReactionDiv


//Call this div inside a loop passing reaction data for non question resources  only also no answer options will be shoed just if the answer is right or wrong. also pass reaction btn tag!!!

-(NSString*)createReactionDiv:(int)reactionTag andResourceNumber:(NSString*)number withQuestionText:(NSString*)resourcetext{
    
    NSString* reactionDiv,*reactionTypeDiv;
    
    
    switch (reactionTag) {
        case 111:{
            reactionTypeDiv = @"i-can-explain";
            break;
        }
        case 222:{
            reactionTypeDiv = @"i-understand";
            break;

        }
        case 333:{
            reactionTypeDiv = @"meh";
            break;

        }
        case 444:{
            reactionTypeDiv = @"i-dont-understand";
            break;

        }
        case 555:{
            reactionTypeDiv = @"i-need-help";
            break;

        }
        default:
            break;
    }
   
    reactionDiv = [NSString stringWithFormat:@"<div class=\\\"non-question-resource\\\"><div class=\\\"%@\\\"></div> <div class=\\\"resource-number\\\">%@</div> <div class=\\\"resource-title\\\">%@</div> </div>",reactionTypeDiv,number,resourcetext];
    
    return reactionDiv;
}

#pragma mark createopenEndedDiv
//Call this div inside a loop passing question data for open ended  only

-(NSString*)createopenEndedDiv:(NSString*)answer andResourceNumber:(NSString*)number withQuestionText:(NSString*)questionText{
    
    
    NSString* reactionDiv = [NSString stringWithFormat:@"<div class=\\\"oe-question\\\"><div class=\\\"question-number\\\">%@</div><div class=\\\"question-title\\\">%@</div><div class=\\\"oe-question-answer\\\">%@</div></div>",number,[questionText stripHtml],[answer stripHtml]];
    
    return reactionDiv;
}

#pragma mark Alert View
-(void)alertWithMessage:(NSString *)strMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate getValueByKey:@"MessageTitle"] message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

#pragma mark Mail Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
    
    if(error) NSLog(@"ERROR - mailComposeController: %@", [error localizedDescription]);
    [self dismissModalViewControllerAnimated:YES];
    return;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
