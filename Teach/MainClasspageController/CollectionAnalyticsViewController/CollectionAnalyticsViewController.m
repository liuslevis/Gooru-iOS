//
//  CollectionAnalyticsViewController.m
//  Gooru
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

#import "CollectionAnalyticsViewController.h"
#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import "JSON.h"

@interface CollectionAnalyticsViewController ()

@end

@implementation CollectionAnalyticsViewController

@synthesize collectionId;
@synthesize lablAvgStudentGrade,lablAvgStudentReaction,lablAvgTimeSpent,lablTotalStudentViews;
@synthesize viewCollectionAnalytics;
@synthesize viewMainView;
@synthesize viewForShowingEmptyContent;
@synthesize viewHelp;
@synthesize viewHelpCollectionAnalytics;
AppDelegate *appDelegate;

#define COLLECTION_ANALYTICS_REACTION @"CollectionReaction"
#define COLLECTION_ANALYTICS_AVGTIMESPENT @"CollectionAvgTimeSpent"
#define COLLECTION_ANALYTICS_VIEWS @"CollectionViews"
#define COLLECTION_ANALYTICS_TOTALTIMESPENT @"CollectionTotalTimeSpent"

#define COLLECTION_BREAKDOWN_REACTION @"Resourcereaction"
#define COLLECTION_BREAKDOWN_AVGTIMESPENT @"ResourceAvgTimeSpent"
#define COLLECTION_BREAKDOWN_VIEWS @"ResourceViews"
#define COLLECTION_BREAKDOWN_TOTALTIMESPENT @"ResourceTotalTimeSpent"
#define COLLECTION_BREAKDOWN_TITLE @"ResourceTitle"
#define COLLECTION_BREAKDOWN_CATEGORY @"ResourceCategory"
#define COLLECTION_BREAKDOWN_SEQUENCENO @"ResourceSequenceNo"
#define COLLECTION_BREAKDOWN_DESCRIPTION @"ResourceDescription"

#define TAG_COLLECTIONBREAKDOWN_ADDITIVE 21
#define TAG_COLLECTIONBREAKDOWN_MULTIPLIER 31

NSMutableDictionary *dictCollectionAnalyticsDetails;
NSMutableDictionary *dictCollectionBreakDownDetails;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithCollectionId:(NSString *)incomingCollectionId{
    collectionId=incomingCollectionId;
    return self;
    
}

- (void)viewDidLoad
{  appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    viewCollectionAnalytics.frame=CGRectMake(0, 108, viewCollectionAnalytics.frame.size.width, viewCollectionAnalytics.frame.size.height);
    
    viewHelp.frame=CGRectMake(0, 60, viewHelp.frame.size.width, viewHelp.frame.size.height);
    
    [viewMainView addSubview:viewCollectionAnalytics];
    
    [viewMainView addSubview:viewHelp];
   [self getCollectionAnalyticsDetails];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark Get Collection Analytics Details

-(void)getCollectionAnalyticsDetails{
    
    
    
    NSString* strParams = @"{\"fields\":\"timeSpent,views,averageTimeSpent,reaction,reactionTimeSpent,gooruOId,date\",\"filters\":{\"filterAggregate\":\"All\"},\"groupBy\":\"gooruOId,date\",\"paginate\":{\"offSet\":0,\"limit\":30,\"sortBy\":\"date\",\"sortOrder\":\"ASC\"}}";
    
    
    
    NSString *strURL = [NSString stringWithFormat:@"%@/v1/collections/%@.json?data=%@",[appDelegate getValueByKey:@"InsightsURL"],collectionId,strParams];
    
    NSLog(@"StrURL : %@",strURL);
    
    
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"InsightsURL"]];
    
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    
    
    
    
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"data", nil];
    
    NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:strParams, nil];
    
    NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    
    
    [httpClient getPath:[NSString stringWithFormat:@"v1/collections/%@.json",collectionId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        
        
        NSLog(@"getCollectionAnalyticsDetails response : %@",responseStr);
        [self parseCollectionAnalyticsDetails:responseStr];
        [self getCollectionBreakDownDetails];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
    }];
    
    
    
    
    
    
    
}

 #pragma mark ParseCollectionAnalyticsDetails

-(void)parseCollectionAnalyticsDetails:(NSString *)responseString{
    if ([responseString hasPrefix:@"error:"]){
        
        responseString = [responseString stringByReplacingOccurrencesOfString:@"error:" withString:@""];
       // [self login_AlertShow:responseString];
    }else if ([responseString isEqualToString:@""] || [responseString isEqualToString:@"(null)"] || [responseString isEqualToString:@"nil"]){
        
        //[self login_AlertShow:@"Unable to connect to Gooru."];
        return;
    }else{
        
        NSDictionary *results=[responseString JSONValue];
        NSArray *contents=[results objectForKey:@"content"];
       // NSLog(@"content=%@",[contents description]);
        dictCollectionAnalyticsDetails=[[NSMutableDictionary alloc]init];
        if ([contents count]==0) {
            [viewForShowingEmptyContent setHidden:TRUE];
        }else{
            [viewForShowingEmptyContent setHidden:TRUE];
        }
        
        for (int i=0; i<[contents count]; i++) {
            NSString *strCollectionReaction=[[contents objectAtIndex:i]objectForKey:@"reaction"];
            NSLog(@"strCollectionReaction=%@",strCollectionReaction);
            
            NSString *strCollectionAvgTimeSpent=[[contents objectAtIndex:i]objectForKey:@"averageTimeSpent"];
            strCollectionAvgTimeSpent=[self getTimeFromString:strCollectionAvgTimeSpent];
            
            NSString *strCollectionViews=[[contents objectAtIndex:i]objectForKey:@"views"];
            
            NSString *strCollectionTotalTimeSpent=[[contents objectAtIndex:i]objectForKey:@"timeSpent"];
            
            [dictCollectionAnalyticsDetails setValue:strCollectionReaction forKey:COLLECTION_ANALYTICS_REACTION];
            [dictCollectionAnalyticsDetails setValue:strCollectionAvgTimeSpent forKey:COLLECTION_ANALYTICS_AVGTIMESPENT];
            [dictCollectionAnalyticsDetails setValue:strCollectionViews forKey:COLLECTION_ANALYTICS_VIEWS];
            [dictCollectionAnalyticsDetails setValue:strCollectionTotalTimeSpent forKey:COLLECTION_ANALYTICS_TOTALTIMESPENT];
        }
         NSLog(@"dictCollectionAnalyticsDetails checking=%@",[dictCollectionAnalyticsDetails description]);
    }

}

#pragma Get Collection BreakDown Details



-(void)getCollectionBreakDownDetails{
    
    
    
    NSString* strParams = @"{\"fields\":\"timeSpent,views,averageTimeSpent,title,thumbnail,gooruOId,itemSequence,collectionGooruOId,resourceGooruOId,description,category,status,reaction\",\"filters\":{\"filterAggregate\":\"All\"},\"paginate\":{\"limit\":10,\"sortBy\":\"itemSequence\",\"sortOrder\":\"DESC\"}}";
    
    
    
    NSString *strURL = [NSString stringWithFormat:@"%@/v1/collections/%@/resources.json?data=%@",[appDelegate getValueByKey:@"InsightsURL"],collectionId,strParams];
    
    NSLog(@"StrURL : %@",strURL);
    
    
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"InsightsURL"]];
    
    
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    
    
    
    
    
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"data", nil];
    
    NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:strParams, nil];
    
    NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    
    
    [httpClient getPath:[NSString stringWithFormat:@"v1/collections/%@/resources.json",collectionId] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        
        
        NSLog(@"getCollectionBreakDownDetails response : %@",responseStr);
        
        [self parseCollectionBreakDownDetails:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
    }];
    
    
    
}

#pragma mark Parse CollectionBreakDownDetails

-(void)parseCollectionBreakDownDetails:(NSString *)responseString{
    if ([responseString hasPrefix:@"error:"]){
        
        responseString = [responseString stringByReplacingOccurrencesOfString:@"error:" withString:@""];
        // [self login_AlertShow:responseString];
    }else if ([responseString isEqualToString:@""] || [responseString isEqualToString:@"(null)"] || [responseString isEqualToString:@"nil"]){
        
        //[self login_AlertShow:@"Unable to connect to Gooru."];
        return;
    }else{
        NSDictionary *results=[responseString JSONValue];
        NSArray *contents=[results objectForKey:@"content"];
         NSLog(@"content=%@",[contents description]);
        dictCollectionBreakDownDetails=[[NSMutableDictionary alloc]init];
        for (int i=0; i<[contents count]; i++) {
             int tag = TAG_COLLECTIONBREAKDOWN_ADDITIVE+(i*TAG_COLLECTIONBREAKDOWN_MULTIPLIER);
            
            NSMutableDictionary *dictResourceInstance=[[NSMutableDictionary alloc]init];
            
            NSString *strResourceReaction=[[contents objectAtIndex:i]objectForKey:@"reaction"];
            
            NSString *strResourceAvgTimeSpent=[[contents objectAtIndex:i]objectForKey:@"averageTimeSpent"];
            
            NSString *strResourceViews=[[contents objectAtIndex:i]objectForKey:@"views"];
            
            NSString *strResourceTotalTimeSpent=[[contents objectAtIndex:i]objectForKey:@"timeSpent"];
            
            NSString *strResourceTitle=[[contents objectAtIndex:i]objectForKey:@"title"];
            
            NSString *strResourceCategory=[[contents objectAtIndex:i]objectForKey:@"thumbnail"];
            
            NSString *strResourceDescription=[[contents objectAtIndex:i]objectForKey:@"description"];
            
            NSString *strResourceSequenceNo=[[contents objectAtIndex:i]objectForKey:@"itemSequence"];
            
            [dictResourceInstance setValue:strResourceReaction forKey:COLLECTION_BREAKDOWN_REACTION];
            [dictResourceInstance setValue:strResourceAvgTimeSpent forKey:COLLECTION_BREAKDOWN_AVGTIMESPENT];
            [dictResourceInstance setValue:strResourceViews forKey:COLLECTION_BREAKDOWN_VIEWS];
             [dictResourceInstance setValue:strResourceTotalTimeSpent forKey:COLLECTION_BREAKDOWN_TOTALTIMESPENT];
            [dictResourceInstance setValue:strResourceTitle forKey:COLLECTION_BREAKDOWN_TITLE];
            [dictResourceInstance setValue:strResourceCategory forKey:COLLECTION_BREAKDOWN_CATEGORY];
            [dictResourceInstance setValue:strResourceDescription forKey:COLLECTION_BREAKDOWN_DESCRIPTION];
            [dictResourceInstance setValue:strResourceSequenceNo forKey:COLLECTION_BREAKDOWN_SEQUENCENO];
            
            [dictCollectionBreakDownDetails setValue:dictResourceInstance forKey:[NSString stringWithFormat:@"%i",tag]];
        }
        
        NSLog(@"dictCollectionBreakDownDetails checking=%@",[dictCollectionBreakDownDetails description]);
        
    }
}

#pragma mark Upadate Data for Collection Analytics
-(void)updateDataForCollectionAnalytics{
    lablAvgTimeSpent.text=[dictCollectionAnalyticsDetails valueForKey:COLLECTION_ANALYTICS_AVGTIMESPENT];
    lablTotalStudentViews.text=[dictCollectionAnalyticsDetails valueForKey:COLLECTION_ANALYTICS_VIEWS];
}


- (IBAction)btnActionCloseCollectionAnalytics:(id)sender {
    
   [ self performSelector:@selector(removeLoginViewController) withObject:nil afterDelay:0];
}

- (IBAction)btnActionCloseHelpPage:(id)sender {
    [self shouldHideView:viewHelp :TRUE];
    
}

- (IBAction)btnActionShowHelpPage:(id)sender {
    
    [self shouldHideView:viewHelp :FALSE];
    
}


# pragma mark Get Time From String

- (NSString *)getTimeFromString: (NSString*) interval{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
   unsigned long milliseconds= [[formatter numberFromString:interval] unsignedLongValue];
   // unsigned long milliseconds = interval;
    unsigned long seconds = milliseconds / 1000;
    milliseconds %= 1000;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;
    
    NSMutableString * result = [NSMutableString new];
    
    if(hours)
    [result appendFormat: @"%ldhr ", hours];
    if (minutes)
    [result appendFormat: @"%2ldmin ", minutes];
    
    [result appendFormat: @"%2ldsec", seconds];
   // [result appendFormat: @"%2ld",milliseconds];
    
    return result;
}


#pragma mark  Remove Child View controller

- (void)removeLoginViewController{
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}

#pragma mark Hide/Unhide Animated!
-(void)shouldHideView:(UIView*)view :(BOOL)value{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
}

#pragma mark - Alerts -
    
//    - (void)login_AlertShow:(NSString *)strMessage {
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gooru" message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//    }
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
