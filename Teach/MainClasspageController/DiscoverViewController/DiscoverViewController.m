//
//  DiscoverViewController.m
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

#import "DiscoverViewController.h"
#import "AppDelegate.h"
#import "AFHTTPClient.h"
#import "GridElementViewController.h"
#import "ResourcePlayerViewController.h"
#import "ShareViewController.h"
#import "CHTCollectionViewSuggestLayout.h"
#import "CHTCollectionViewSearchLayout.h"
#import "MainClasspageViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

#define RESOURCE_TITLE @"ResourceTitle"
#define RESOURCE_CATEGORY @"ResourceCategory"
#define RESOURCE_THUMBNAIL @"ResourceThumbnail"
#define RESOURCE_URL @"ResourceUrl"
#define RESOURCE_ACTUAL_ID @"ResourceActualId"
#define RESOURCE_DESCRIPTION @"ResourceDescription"
#define RESOURCE_SOURCE @"ResourceSource"
#define RESOURCE_VIEWS @"ResourceViews"
#define RESOURCE_TAGS @"ResourceTags"


#define MULTIPLIER_SUGGEST 78
#define MULTIPLIER_SEARCH 81

#define MULTIPLIER_RESOURCE 10
#define MULTIPLIER_SHARE 100
#define MULTIPLIER_SCROLL 23

#define TAG_RESOURCE_PAGE1 600
#define TAG_RESOURCE_VIEWS 601


#define MULTIPLIER_SUGGEST_PAGEINDICATOR1 10001
#define MULTIPLIER_SUGGEST_PAGEINDICATOR2 10002

#define TAG_SUGGEST_COLLECTION_VIEW 999999
#define TAG_SEARCH_COLLECTION_VIEW 9999

#define TAG_INIT_FILTER_GRADE 11
#define TAG_INIT_FILTER_SUBJECT 211

#define TAG_FILTER_INCREMENT 11




@interface DiscoverViewController ()

@end

MainClasspageViewController* mainClasspageViewController;
ShareViewController* shareViewController;

AppDelegate *appDelegate;
NSUserDefaults* standardUserDefaults;
NSString* sessionToken;


int suggestPageNo;
int suggestTotalPages;
int suggestPageSize;
int suggestGridNo;


int searchPageNo;
int searchTotalPages;
int searchPageSize;
int searchGridNo;


NSMutableDictionary* dictSuggest;
NSArray* arrKeysForSuggest;

NSMutableDictionary* dictSearch;
NSArray* arrKeysForSearch;

NSString* strSearchTerm;

BOOL flagLoadMore = TRUE;

NSMutableArray* arrSearchGradeFilterParams;

NSMutableArray* arrSearchSubjectFilterParams;

NSMutableArray* arrSearchCategoryFilterParams;



@implementation DiscoverViewController

@synthesize collectionViewSuggestResults;
@synthesize collectionViewSearchResults;

#pragma mark - View Life Cycle -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithParentViewController:(MainClasspageViewController*)parentViewController{
    
    mainClasspageViewController = parentViewController;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    sessionToken  = [standardUserDefaults stringForKey:@"token"];
    
    if ([sessionToken isEqualToString:@"NA"]) {
        NSLog(@"User Auth Status : User Logged Out!");
        sessionToken = [standardUserDefaults objectForKey:@"defaultGooruSessionToken"];
    }else{
        NSLog(@"User Auth Status : User Logged In!");
    }
    
    
    [viewFUEDiscoverChild.layer setCornerRadius:8.0];
    [self.view addSubview:viewFUEDiscoverParent];
    

    [viewFilterParent.layer setCornerRadius:6.0];
    
    [self addLeftGestureOnView:viewFUEPageParent];
    [self addRightGestureOnView:viewFUEPageParent];
    
    arrSearchGradeFilterParams = [[NSMutableArray alloc] init];
    arrSearchSubjectFilterParams = [[NSMutableArray alloc] init];
    arrSearchCategoryFilterParams = [[NSMutableArray alloc] init];

    
    suggestPageNo = -1;
    suggestPageSize = 20;
    suggestGridNo = 1;
    
    searchPageNo = -1;
    searchPageSize = 20;
    searchGridNo = 1;
    
    strSearchTerm = @"";

    dictSuggest = [[NSMutableDictionary alloc] init];
    
    self.collectionViewSuggestResults.delegate = self;
    self.collectionViewSuggestResults.dataSource = self;
    [self.collectionViewSuggestResults setTag:TAG_SUGGEST_COLLECTION_VIEW];
    [self.collectionViewSuggestResults registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    
    CHTCollectionViewSuggestLayout* chtCollectionViewSuggestLayout = [[CHTCollectionViewSuggestLayout alloc] init];
    [chtCollectionViewSuggestLayout setSectionInset:UIEdgeInsetsMake(2, 2, 2, 2)];
    [chtCollectionViewSuggestLayout setDelegate:self];
    [collectionViewSuggestResults setCollectionViewLayout:chtCollectionViewSuggestLayout];
    
    
    self.collectionViewSearchResults.delegate = self;
    self.collectionViewSearchResults.dataSource = self;
    [self.collectionViewSearchResults setTag:TAG_SEARCH_COLLECTION_VIEW];
    [self.collectionViewSearchResults registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"FlickrCell"];
    
    CHTCollectionViewSearchLayout* chtCollectionViewSearchLayout = [[CHTCollectionViewSearchLayout alloc] init];
    [chtCollectionViewSearchLayout setSectionInset:UIEdgeInsetsMake(2, 2, 2, 2)];
    [chtCollectionViewSearchLayout setDelegate:self];
    [collectionViewSearchResults setCollectionViewLayout:chtCollectionViewSearchLayout];
    
    [txtFieldSearch addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
    
    dictSearch = [[NSMutableDictionary alloc] init];
    
    if (![[standardUserDefaults stringForKey:@"FUEFlagShouldShowDiscoverFUE"] isEqualToString:@"No"]) {
        
        [btnDiscoverHelp sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }

    

}

- (void)viewWillAppear:(BOOL)animated{
    
    NSLog(@"viewWillAppear DiscoverViewController");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Gooru Suggest -
#pragma mark Get Suggested Resources
- (void)getSuggestedResources{
    
    if (suggestPageNo == -1) {
        [activityIndicatorInitialSuggestLoading startAnimating];
        suggestPageNo = 1;
    }else{
        [self shouldShowScrollLoader:TRUE];
    }

     NSLog(@"suggestPageNo : %i",suggestPageNo);
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/suggest/resource?sessionToken=%@&context=search&pageSize=20&pageNum=%i&flt.mediaType=iPad_friendly",[appDelegate getValueByKey:@"ServerURL"],sessionToken,suggestPageNo];
    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
//    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"context", @"pageSize", @"pageNum", @"flt.mediaType", nil];
//	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, @"search", [NSString stringWithFormat:@"%i",suggestPageSize], [NSString stringWithFormat:@"%i",suggestPageNo], @"iPad_friendly", nil];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"context", @"pageSize", @"pageNum", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, @"search", [NSString stringWithFormat:@"%i",suggestPageSize], [NSString stringWithFormat:@"%i",suggestPageNo], nil];

	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"gooruapi/rest/suggest/resource?"] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
//        NSLog(@"getAssignment Response : %@",responseStr);
        [activityIndicatorInitialSuggestLoading stopAnimating];
        [self shouldShowScrollLoader:FALSE];
        [self parseSuggestedResources:responseStr];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [activityIndicatorInitialSuggestLoading stopAnimating];
        [self shouldShowScrollLoader:FALSE];

    }];

}

#pragma mark Parse Suggested Resources
- (void)parseSuggestedResources:(NSString*)responseString{
    
    NSArray *results = [responseString JSONValue];
    
    
    NSString* strTotalHitCount = [results valueForKey:@"totalHitCount"];
    NSLog(@"totalHitCount : %@",strTotalHitCount);
    
    if([strTotalHitCount intValue] == 0){
        
        NSLog(@"Suggest no results");

    }else{

        NSLog(@"Suggest results present");
        
        float suggestTotalPagesFloat = [strTotalHitCount intValue]/suggestPageSize;
        NSLog(@"suggestTotalPagesFloat : %f",suggestTotalPagesFloat);
        
        suggestTotalPages = ceilf(suggestTotalPagesFloat);
        NSLog(@"suggestTotalPages : %i",suggestTotalPages);
        
        NSMutableArray* arrSearchResults = [results valueForKey:@"searchResults"];
        
        int countArrSearchResults = [arrSearchResults count];
    
        int countForKey = 0;
        
        int countResources = 0;
        
        while (countResources < countArrSearchResults) {
            
            NSMutableDictionary* dictResourceInstance = [[NSMutableDictionary alloc] init];
            
            int key = suggestGridNo*MULTIPLIER_SUGGEST;
            
            BOOL isHashtag = [self isHashtagForTag:suggestGridNo isSuggest:TRUE];
            

            if(!isHashtag){
                
                NSString* strResourceInstance = [arrSearchResults objectAtIndex:countResources];
                
                
                NSString* strResourceTitle = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"title"] With:@"NA"];
                //            NSLog(@"strResourceTitle : %@",strResourceTitle);
                
                NSString* strResourceCategory = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"category"] With:@"NA"];
                //            NSLog(@"strResourceCategory : %@",strResourceCategory);
                
                NSString* strResourceThumbnail = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"thumbnails"] valueForKey:@"url"] With:@"NA"];
                //            NSLog(@"strResourceThumbnail : %@",strResourceThumbnail);
                
                NSString* strResourceUrl = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"url"] With:@"NA"];
                //            NSLog(@"strResourceUrl : %@",strResourceUrl);
                
                NSString* strResourceId = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"gooruOid"] With:@"NA"];
                //            NSLog(@"strResourceId : %@",strResourceId);
                
                NSString* strResourceDescription = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"description"] With:@""];
                //            NSLog(@"strResourceDescription : %@",strResourceDescription);
                
                NSString* strResourceSource = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"resourceSource"] valueForKey:@"domainName"] With:@""];
                //            NSLog(@"strResourceSource : %@",strResourceSource);
                
                NSString* strResourceViews = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"viewCount"] stringValue] With:@"NA"];
                //            NSLog(@"strResourceViews : %@",strResourceViews);
                
                NSString* strResourceTags = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"tags"] With:@"NA"];
//                NSLog(@"strResourceTags : %@",strResourceTags);
                
                //            NSLog(@"====================================");
                
                
                if ([strResourceUrl rangeOfString:@"youtube.com/"].location != NSNotFound) {
                    
                    NSString* youtubeId = [self extractYoutubeID:strResourceUrl];
//                    NSLog(@"youtubeID : %@",youtubeId);
                    
                    strResourceThumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg",youtubeId];
                }
                
                
                
                
                [dictResourceInstance setValue:strResourceTitle forKey:RESOURCE_TITLE];
                [dictResourceInstance setValue:strResourceCategory forKey:RESOURCE_CATEGORY];
                [dictResourceInstance setValue:strResourceThumbnail forKey:RESOURCE_THUMBNAIL];
                [dictResourceInstance setValue:strResourceUrl forKey:RESOURCE_URL];
                [dictResourceInstance setValue:strResourceId forKey:RESOURCE_ACTUAL_ID];
                [dictResourceInstance setValue:strResourceDescription forKey:RESOURCE_DESCRIPTION];
                [dictResourceInstance setValue:strResourceSource forKey:RESOURCE_SOURCE];
                [dictResourceInstance setValue:strResourceViews forKey:RESOURCE_VIEWS];
                [dictResourceInstance setValue:strResourceTags forKey:RESOURCE_TAGS];
                
                countResources++;
                
            }else{
                
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_TITLE];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_CATEGORY];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_THUMBNAIL];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_URL];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_ACTUAL_ID];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_DESCRIPTION];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_SOURCE];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_VIEWS];
                
                 if ((suggestGridNo-1) != 0) {
                     
                     NSMutableDictionary* dictPreviousResource = [dictSuggest valueForKey:[NSString stringWithFormat:@"%i",(suggestGridNo-1)*MULTIPLIER_SUGGEST]];
                     
                     [dictResourceInstance setValue:[dictPreviousResource valueForKey:RESOURCE_TAGS] forKey:RESOURCE_TAGS];
                     [dictResourceInstance setValue:[self getCategoryForHashtag] forKey:RESOURCE_CATEGORY];
                     
                 }
                
                
                
            
            }
            
            
            
            [dictSuggest setObject:dictResourceInstance forKey:[NSString stringWithFormat:@"%i",key]];
            
            suggestGridNo++;
            countForKey ++;

        }
        
        suggestPageNo++;
        
        [self populateSuggestedResources];
    }

}

#pragma mark Populate Suggested Resources



- (void)populateSuggestedResources{
    

    [self.collectionViewSuggestResults reloadData];
    
}

#pragma mark - Gooru Search -
#pragma mark Get Search Results

- (void)getSearchResults{
    
    if (searchPageNo == -1) {
        [activityIndicatorInitialSearchLoading startAnimating];
        searchPageNo = 1;
    }else{
        [self shouldShowScrollLoader:TRUE];
    }
    
    NSLog(@"searchPageNo : %i",searchPageNo);
    
    strSearchTerm = txtFieldSearch.text;
    
    if (strSearchTerm == nil) {
        strSearchTerm = @"";
    }
    
    //Compute Required Params
    
    NSString* strGradeParams = [arrSearchGradeFilterParams componentsJoinedByString:@","];
    NSString* strSubjectParams = [arrSearchSubjectFilterParams componentsJoinedByString:@"~~"];
    NSString* strCategoryParams = [arrSearchCategoryFilterParams componentsJoinedByString:@","];
    
    
    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/search/resource?sessionToken=%@&query=%@&pageSize=20&pageNum=%i&flt.mediaType=iPad_friendly",[appDelegate getValueByKey:@"ServerURL"],sessionToken,txtFieldSearch.text, searchPageNo];
    
    strURL = [NSString stringWithFormat:@"%@&category=%@",strURL,strCategoryParams];
    
    if ([arrSearchGradeFilterParams count] != 0) {
        strURL = [NSString stringWithFormat:@"%@&flt.grade=%@",strURL,strGradeParams];
    }
    
    if ([arrSearchSubjectFilterParams count] != 0) {
        strURL = [NSString stringWithFormat:@"%@&flt.subjectName=%@",strURL,strSubjectParams];
    }
    
    
    
    NSLog(@"StrURL : %@",strURL);
    
    NSLog(@"StrURL encoded : %s",[strURL UTF8String]);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];

//    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"query", @"pageSize", @"pageNum",@"flt.mediaType", nil];
//	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, strSearchTerm, [NSString stringWithFormat:@"%i",searchPageSize], [NSString stringWithFormat:@"%i",searchPageNo],@"iPad_friendly" , nil];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"sessionToken", @"query", @"pageSize", @"pageNum", nil];
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:sessionToken, strSearchTerm, [NSString stringWithFormat:@"%i",searchPageSize], [NSString stringWithFormat:@"%i",searchPageNo] , nil];
    
    [parameterKeys addObject:@"category"];
    [parameterValues addObject:strCategoryParams];
    
    if ([arrSearchGradeFilterParams count] != 0) {
        [parameterKeys addObject:@"flt.grade"];
        [parameterValues addObject:strGradeParams];
        
    }
    
    if ([arrSearchSubjectFilterParams count] != 0) {
        [parameterKeys addObject:@"flt.subjectName"];
        [parameterValues addObject:strSubjectParams];
    }
    
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    [httpClient getPath:[NSString stringWithFormat:@"gooruapi/rest/search/resource?"] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

//        NSLog(@"getSearchResults Response : %@",responseStr);
        [activityIndicatorInitialSearchLoading stopAnimating];
        [self shouldShowScrollLoader:FALSE];
        [self parseSearchedResources:responseStr];
//
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [activityIndicatorInitialSearchLoading stopAnimating];
        [self shouldShowScrollLoader:FALSE];
//
    }];
    
}

#pragma mark Parse Searched Resources
- (void)parseSearchedResources:(NSString*)responseString{
    
    NSArray *results = [responseString JSONValue];
    
    
    NSString* strTotalHitCount = [results valueForKey:@"totalHitCount"];
    NSLog(@"totalHitCount : %@",strTotalHitCount);
    
    if([strTotalHitCount intValue] == 0){
        
        NSLog(@"Search no results");
        
        [self shouldHideView:viewNoResults :FALSE];
        [lblNoResults setText:[NSString stringWithFormat:@"We didn’t find any results for \"%@\"",strSearchTerm]];
        
        [self shouldHideView:collectionViewSearchResults :TRUE];
        
        
    }else{
        
        
        NSLog(@"Search results present");
        
        [self shouldHideView:viewNoResults :TRUE];
        [self shouldHideView:collectionViewSearchResults :FALSE];
        
        float searchTotalPagesFloat = [strTotalHitCount intValue]/searchPageSize;
        NSLog(@"searchTotalPagesFloat : %f",searchTotalPagesFloat);
        
        searchTotalPages = ceilf(searchTotalPagesFloat);
        NSLog(@"searchTotalPages : %i",searchTotalPages);
        
        NSMutableArray* arrSearchResults = [results valueForKey:@"searchResults"];
        
        int countArrSearchResults = [arrSearchResults count];
        
        int countForKey = 0;
        
        int countResources = 0;
        
        while (countResources < countArrSearchResults) {
            
            NSMutableDictionary* dictResourceInstance = [[NSMutableDictionary alloc] init];
            
            int key = searchGridNo*MULTIPLIER_SEARCH;
            
            BOOL isHashtag = [self isHashtagForTag:searchGridNo isSuggest:FALSE];
            
            if(!isHashtag){
                
                NSString* strResourceInstance = [arrSearchResults objectAtIndex:countResources];
                
                
                NSString* strResourceTitle = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"title"] With:@"NA"];
                //            NSLog(@"strResourceTitle : %@",strResourceTitle);
                
                NSString* strResourceCategory = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"category"] With:@"NA"];
                //            NSLog(@"strResourceCategory : %@",strResourceCategory);
                
                NSString* strResourceThumbnail = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"thumbnails"] valueForKey:@"url"] With:@"NA"];
                //            NSLog(@"strResourceThumbnail : %@",strResourceThumbnail);
                
                NSString* strResourceUrl = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"url"] With:@"NA"];
                //            NSLog(@"strResourceUrl : %@",strResourceUrl);
                
                NSString* strResourceId = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"gooruOid"] With:@"NA"];
                //            NSLog(@"strResourceId : %@",strResourceId);
                
                NSString* strResourceDescription = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"description"] With:@"NA"];
                //            NSLog(@"strResourceDescription : %@",strResourceDescription);
                
                NSString* strResourceSource = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"resourceSource"] valueForKey:@"domainName"] With:@""];
                //            NSLog(@"strResourceSource : %@",strResourceSource);
                
                NSString* strResourceViews = [appDelegate ifNullStrReplace:[[strResourceInstance valueForKey:@"viewCount"] stringValue] With:@"NA"];
                //            NSLog(@"strResourceViews : %@",strResourceViews);
                
                NSString* strResourceTags = [appDelegate ifNullStrReplace:[strResourceInstance valueForKey:@"tags"] With:@"NA"];
                //                NSLog(@"strResourceTags : %@",strResourceTags);
                
                //            NSLog(@"====================================");
                
                
                if ([strResourceUrl rangeOfString:@"youtube.com/"].location != NSNotFound) {
                    
                    NSString* youtubeId = [self extractYoutubeID:strResourceUrl];
                    NSLog(@"youtubeID : %@",youtubeId);
                    
                    strResourceThumbnail = [NSString stringWithFormat:@"http://img.youtube.com/vi/%@/1.jpg",youtubeId];
                }
                
                [dictResourceInstance setValue:strResourceTitle forKey:RESOURCE_TITLE];
                [dictResourceInstance setValue:strResourceCategory forKey:RESOURCE_CATEGORY];
                [dictResourceInstance setValue:strResourceThumbnail forKey:RESOURCE_THUMBNAIL];
                [dictResourceInstance setValue:strResourceUrl forKey:RESOURCE_URL];
                [dictResourceInstance setValue:strResourceId forKey:RESOURCE_ACTUAL_ID];
                [dictResourceInstance setValue:strResourceDescription forKey:RESOURCE_DESCRIPTION];
                [dictResourceInstance setValue:strResourceSource forKey:RESOURCE_SOURCE];
                [dictResourceInstance setValue:strResourceViews forKey:RESOURCE_VIEWS];
                [dictResourceInstance setValue:strResourceTags forKey:RESOURCE_TAGS];
                
                countResources++;

            }else{
                
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_TITLE];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_CATEGORY];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_THUMBNAIL];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_URL];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_ACTUAL_ID];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_DESCRIPTION];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_SOURCE];
                [dictResourceInstance setValue:@"Hashtag!" forKey:RESOURCE_VIEWS];
                
                if ((searchGridNo-1) > 0) {
                    
                    NSMutableDictionary* dictPreviousResource = [dictSearch valueForKey:[NSString stringWithFormat:@"%i",(searchGridNo-1)*MULTIPLIER_SEARCH]];
                    
                    [dictResourceInstance setValue:[dictPreviousResource valueForKey:RESOURCE_TAGS] forKey:RESOURCE_TAGS];
                    [dictResourceInstance setValue:[self getCategoryForHashtag] forKey:RESOURCE_CATEGORY];
                    

                }
                
                
            }
            
            [dictSearch setObject:dictResourceInstance forKey:[NSString stringWithFormat:@"%i",key]];
            
            searchGridNo++;
            countForKey ++;
            
        }
        
        searchPageNo++;
        
        [self populateSearchedResources];
    }
    
}

#pragma mark Populate Searched  Resources
- (void)populateSearchedResources{
    
    [self.collectionViewSearchResults reloadData];
    
}

#pragma mark - Randomize Category -
- (NSString*)getCategoryForHashtag{
    
    int random = arc4random() % (9 - 1) + 1;
    
    NSString* strCategory;
    
    switch (random) {
        case 1:{
            strCategory = @"Video";
            break;
        }
            
        case 2:{
            strCategory = @"Website";
            break;
        }
            
        case 3:{
            strCategory = @"Interactive";
            break;
        }
            
        case 4:{
            strCategory = @"Slide";
            break;
        }
            
        case 5:{
            strCategory = @"Textbook";
            break;
        }
            
        case 6:{
            strCategory = @"Handout";
            break;
        }
            
        case 7:{
            strCategory = @"Lesson";
            break;
        }
            
        case 8:{
            strCategory = @"Exam";
            break;
        }
            
        default:
            break;
    }
    
    return strCategory;
}


#pragma mark - Enforce Hashtag Protocol -
- (BOOL)isHashtagForTag:(int)tag isSuggest:(BOOL)isSuggest{
    
    BOOL isHashtag = FALSE;
    
    
    int random = arc4random() % (3 - 0) + 0;
    
    if (random == 1) {
        
        NSMutableDictionary* dictToCheck;
        int multiplierToUse;
        if (isSuggest) {
            dictToCheck = dictSuggest;
            multiplierToUse = MULTIPLIER_SUGGEST;
        }else{
            dictToCheck = dictSearch;
            multiplierToUse = MULTIPLIER_SEARCH;
        }

        BOOL goNorth = FALSE;
        BOOL goWest = FALSE;
        
        int tagNorth = (tag - 4>0)?tag - 4:0;
        int tagWest = (tag - 1>0)?tag - 1:0;
        
        NSMutableDictionary* dictResourceInstance;
        
        if (tagNorth != 0) {
            
            dictResourceInstance = [dictToCheck valueForKey:[NSString stringWithFormat:@"%i",tagNorth*multiplierToUse]];
            if (![[dictResourceInstance valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"]) {
                goNorth = TRUE;
            }
            
        }

        if (tagWest != 0) {
            
            dictResourceInstance = [dictToCheck valueForKey:[NSString stringWithFormat:@"%i",tagWest*multiplierToUse]];
            if (![[dictResourceInstance valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"] && ![[dictResourceInstance valueForKey:RESOURCE_TAGS] isEqualToString:@""]) {
                goWest = TRUE;
                
            }
            
        }
        
        /// Modified for more suggests
//        dictResourceInstance = [dictToCheck valueForKey:[NSString stringWithFormat:@"%i",tagWest*multiplierToUse]];
//        if (tagWest != 0 && ![[dictResourceInstance valueForKey:RESOURCE_TAGS] isEqualToString:@""]) {
//            
//            goWest = TRUE;
//            goNorth = TRUE;
//            
//        }
//        

        
        if (goNorth && goWest) {
            
            
            isHashtag = TRUE;
        }else{
            isHashtag = FALSE;
        }

    }else{
        
        isHashtag = FALSE;
        
    }
    
    return FALSE;
}


#pragma Load Gooru Search
- (void)loadGooruSuggest{
    
    if (![viewFUEDiscoverParent isHidden]) {
        [btnDiscoverHelp sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    
    [shareViewController closeSharePopup];
    
    NSLog(@"mainClasspageViewController : %@",[mainClasspageViewController description]);
    [mainClasspageViewController.btnGooruSuggest setSelected:TRUE];
    [mainClasspageViewController.btnGooruSearch setSelected:FALSE];
    

    
    [self animateView:viewParentGooruSuggest forFinalFrame:CGRectMake(0, viewParentGooruSuggest.frame.origin.y, viewParentGooruSuggest.frame.size.width, viewParentGooruSuggest.frame.size.height)];
    [self animateView:viewParentGooruSearch forFinalFrame:CGRectMake(viewParentGooruSearch.frame.size.width, viewParentGooruSearch.frame.origin.y, viewParentGooruSearch.frame.size.width, viewParentGooruSearch.frame.size.height)];
    
    if (suggestPageNo == -1) {
        [self getSuggestedResources];
    }

}

#pragma Load Gooru Suggest

- (void)loadGooruSearch{
    
    NSLog(@"mainClasspageViewController : %@",[mainClasspageViewController description]);
    [mainClasspageViewController.btnGooruSuggest setSelected:FALSE];
    [mainClasspageViewController.btnGooruSearch setSelected:TRUE];
    
    [shareViewController closeSharePopup];
    
    
//    [self animateView:viewParentGooruSuggest forFinalFrame:CGRectMake(-viewParentGooruSuggest.frame.size.width, viewParentGooruSuggest.frame.origin.y, viewParentGooruSuggest.frame.size.width, viewParentGooruSuggest.frame.size.height)];
//    [self animateView:viewParentGooruSearch forFinalFrame:CGRectMake(0, viewParentGooruSearch.frame.origin.y, viewParentGooruSearch.frame.size.width, viewParentGooruSearch.frame.size.height)];

    
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
    
    
    [self performSelector:@selector(removeCurrentDetailViewControllerFromDiscover) withObject:nil afterDelay:0.4];
    
}

#pragma mark - Remove ViewController -

- (void)removeCurrentDetailViewControllerFromDiscover{
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}




#pragma mark - BA Filters -

#pragma mark BA Filter View Toggle

- (IBAction)btnActionFiltersToggle:(id)sender {
    
    if (viewFilterParent.frame.size.height == 64) {
        //Open Filter
        
        [self animateView:viewFilterParent forFinalFrame:CGRectMake(viewFilterParent.frame.origin.x, viewFilterParent.frame.origin.y, viewFilterParent.frame.size.width, 194) inTime:0.4 withDelay:0.0];
        
        [self animateView:viewSearchResultsParent forFinalFrame:CGRectMake(viewSearchResultsParent.frame.origin.x, viewSearchResultsParent.frame.origin.y + 130, viewSearchResultsParent.frame.size.width, viewSearchResultsParent.frame.size.height - 130) inTime:0.4 withDelay:0.0];
        
        [lblToggleFilter setText:@"Close Filters"];
        
    }else{
        
        //Close Filter
        [self animateView:viewFilterParent forFinalFrame:CGRectMake(viewFilterParent.frame.origin.x, viewFilterParent.frame.origin.y, viewFilterParent.frame.size.width, 64) inTime:0.4 withDelay:0.0];
        
        [self animateView:viewSearchResultsParent forFinalFrame:CGRectMake(viewSearchResultsParent.frame.origin.x, viewSearchResultsParent.frame.origin.y - 130, viewSearchResultsParent.frame.size.width, viewSearchResultsParent.frame.size.height + 130) inTime:0.4 withDelay:0.0];
                
        [lblToggleFilter setText:@"Show Me Filters"];
        
    }
    
}

#pragma mark BA Grade Filter
- (IBAction)btnActionGradeFilter:(id)sender {
    
    UIButton* btnFilterToSelectDeselect = (UIButton*)sender;
    
    if ([btnFilterToSelectDeselect isSelected]) {
        [btnFilterToSelectDeselect setSelected:FALSE];
    }else{
        [btnFilterToSelectDeselect setSelected:TRUE];
    }
    
    
    NSString* strParams;
    
    switch ([sender tag]) {
        case 11:
        {
            strParams = [NSString stringWithFormat:@"K-4"];
            

            break;
        }
            
        case 22:
        {
            strParams = [NSString stringWithFormat:@"5-8"];
            break;
        }
            

        case 33:
        {
            strParams = [NSString stringWithFormat:@"9-12"];
            break;
        }
            
        case 44:
        {
            strParams = [NSString stringWithFormat:@"H"];
            break;
        }
        default:
            break;
    }
    
    if ([btnFilterToSelectDeselect isSelected]) {
        
        [arrSearchGradeFilterParams addObject:strParams];
        
        
    }else{
        
        for (int i = 0; i < [arrSearchGradeFilterParams count]; i++) {
            
            if ([[arrSearchGradeFilterParams objectAtIndex:i] isEqualToString:strParams]) {
                
                [arrSearchGradeFilterParams removeObjectAtIndex:i];
            }
            
        }
        
    }
    
    
    NSLog(@"arrSearchGradeFilterParams : %@",[arrSearchGradeFilterParams componentsJoinedByString:@","]);

}

#pragma mark BA Subject Filter
- (IBAction)btnActionSubjectFilter:(id)sender {
    
    UIButton* btnFilterToSelectDeselect = (UIButton*)sender;
    
    if ([btnFilterToSelectDeselect isSelected]) {
        [btnFilterToSelectDeselect setSelected:FALSE];
    }else{
        [btnFilterToSelectDeselect setSelected:TRUE];
    }
    
    
    NSString* strParams;
    
    switch ([sender tag]) {
        case 211:
        {
            strParams = [NSString stringWithFormat:@"Math"];
            break;
        }
            
        case 222:
        {
            strParams = [NSString stringWithFormat:@"Science"];
            break;
        }
            
            
        case 233:
        {
            strParams = [NSString stringWithFormat:@"Language Arts"];
            break;
        }
            
        case 244:
        {
            strParams = [NSString stringWithFormat:@"Social Sciences"];
            break;
        }
            
        case 255:
        {
            strParams = [NSString stringWithFormat:@"Technology & Engineering"];
            break;
        }
        default:
            break;
    }
    
    if ([btnFilterToSelectDeselect isSelected]) {
        
        [arrSearchSubjectFilterParams addObject:strParams];
        
        
    }else{
        
        for (int i = 0; i < [arrSearchSubjectFilterParams count]; i++) {
            
            if ([[arrSearchSubjectFilterParams objectAtIndex:i] isEqualToString:strParams]) {
                
                [arrSearchSubjectFilterParams removeObjectAtIndex:i];
            }
            
        }
        
    }
    
    
    NSLog(@"arrSearchSubjectFilterParams : %@",[arrSearchSubjectFilterParams componentsJoinedByString:@"~~"]);
}

#pragma mark - BA Search Actual -
- (IBAction)btnActionSearchActual:(id)sender {
    
    searchPageNo = -1;
    searchGridNo = 1;
    [txtFieldSearch resignFirstResponder];
    [collectionViewSearchResults scrollRectToVisible:CGRectMake(0, 0, collectionViewSearchResults.frame.size.width, collectionViewSearchResults.frame.size.height) animated:TRUE];
    dictSearch = [[NSMutableDictionary alloc] init];
    arrSearchCategoryFilterParams = [NSMutableArray arrayWithObjects:@"Video",@"Website",@"Interactive",@"Slide",@"Textbook",@"Handout",@"Lesson",@"Exam", nil];

    [self getSearchResults];
}


#pragma mark - UIScrollView Delegate -

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (fmodf(scrollView.tag,MULTIPLIER_SCROLL) == 0) {
        
        UIButton* btnIndicator1 = (UIButton*)[[scrollView superview] viewWithTag:(scrollView.tag/MULTIPLIER_SCROLL)*MULTIPLIER_SUGGEST_PAGEINDICATOR1];
        UIButton* btnIndicator2 = (UIButton*)[[scrollView superview] viewWithTag:(scrollView.tag/MULTIPLIER_SCROLL)*MULTIPLIER_SUGGEST_PAGEINDICATOR2];
        if (scrollView.contentOffset.x == 0) {
            
            [btnIndicator1 setSelected:TRUE];
            [btnIndicator2 setSelected:FALSE];
        
        }else{
            
            [btnIndicator1 setSelected:FALSE];
            [btnIndicator2 setSelected:TRUE];
            
        }
        
    }
    
}


#pragma mark - Collection View Datasource -
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    
//    NSLog(@"numberOfItemsInSection : %i",[dictSuggest count]);
    
    int numberOfItems;
    if (view.tag == TAG_SUGGEST_COLLECTION_VIEW) {
        
        arrKeysForSuggest = [appDelegate sortedIntegerKeysForDictionary:dictSuggest];
        numberOfItems = [dictSuggest count];
        
    }else{

        arrKeysForSearch = [appDelegate sortedIntegerKeysForDictionary:dictSearch];
        numberOfItems = [dictSearch count];
        
    }
   
    
    return numberOfItems;
    
}

// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
//    NSLog(@"numberOfSectionsInCollectionView");
    return 1;
}

// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForItemAtIndexPath %i",indexPath.row);
   
    
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"FlickrCell" forIndexPath:indexPath];
    
    NSString* requiredKey;
    int arrKeysCount;
    
    if (cv.tag == TAG_SUGGEST_COLLECTION_VIEW) {
        requiredKey = [arrKeysForSuggest objectAtIndex:indexPath.row];
        
        arrKeysCount = [arrKeysForSuggest count] - 1;

        if (indexPath.row == arrKeysCount && suggestPageNo < suggestTotalPages) {
            [self getSuggestedResources];
        }
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if ([[[dictSuggest valueForKey:requiredKey] valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"]) {
            
            [cell.contentView addSubview:[self createHashtagGridElementViewForSuggest:TRUE UsingDetails:[dictSuggest valueForKey:requiredKey] ForTag:[requiredKey intValue]]];
            
        }else{
            
            [cell.contentView addSubview:[self createGridElementViewForSuggest:TRUE UsingDetails:[dictSuggest valueForKey:requiredKey] ForTag:[requiredKey intValue]]];
        }
        
        
    }else{
        
        requiredKey = [arrKeysForSearch objectAtIndex:indexPath.row];
        
        arrKeysCount = [arrKeysForSearch count] - 1;
        
        if (indexPath.row == arrKeysCount && searchPageNo < searchTotalPages) {
            [self getSearchResults];
        }
        
        [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        if ([[[dictSearch valueForKey:requiredKey] valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"]) {
            
            [cell.contentView addSubview:[self createHashtagGridElementViewForSuggest:FALSE UsingDetails:[dictSearch valueForKey:requiredKey] ForTag:[requiredKey intValue]]];
            
        }else{
            
            [cell.contentView addSubview:[self createGridElementViewForSuggest:FALSE UsingDetails:[dictSearch valueForKey:requiredKey] ForTag:[requiredKey intValue]]];
        }
        
        
    }

    return cell;
    
}




#pragma mark - CHT Collection View Delegate -

- (CGFloat)collectionViewSuggest:(UICollectionView *)collectionView layout:(CHTCollectionViewSuggestLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"heightForItemAtIndexPath Suggest %i",indexPath.row);
    
    float height = 0.0;
    NSString* requiredKey = [arrKeysForSuggest objectAtIndex:indexPath.row];
    
    if ([[[dictSuggest valueForKey:requiredKey] valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"]) {
        
        height = 120.0;
        
    }else{
        
        height = 252.0;
        
    }

    return height;
    
}

- (CGFloat)collectionViewSearch:(UICollectionView *)collectionView layout:(CHTCollectionViewSearchLayout *)collectionViewLayout heightForItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    NSLog(@"heightForItemAtIndexPath Search %i",indexPath.row);
    
    float height = 0.0;
    NSString* requiredKey = [arrKeysForSearch objectAtIndex:indexPath.row];
    
    if ([[[dictSearch valueForKey:requiredKey] valueForKey:RESOURCE_TITLE] isEqualToString:@"Hashtag!"]) {
        
        height = 120.0;
        
    }else{
        
        height = 252.0;
        
    }
    
    return height;
    
}

//// 1
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    CGSize retval;
//
//    retval = CGSizeMake(162, 252);
//    return retval;
//    
//}
//
//// 2
//- (UIEdgeInsets)collectionView:
//(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    
//    return UIEdgeInsetsMake(2, 2, 2, 2);
//}


#pragma mark - Make Grid Element for Hashtags -
- (UIView*)createHashtagGridElementViewForSuggest:(BOOL)isSuggest UsingDetails:(NSMutableArray*)dictResource ForTag:(int)tag{
    
    NSLog(@"dictResource : %@",[dictResource description]);
    
    //Main Parent View
    UIView* viewGridParent = [[UIView alloc] init];
    CGRect frame = CGRectMake(0, 0, gETParent.frame.size.width, gETParent.frame.size.height);
    [viewGridParent setBackgroundColor:[UIColor clearColor]];
    [viewGridParent setFrame:frame];
    
    
    
    
    //Main Parent View Background
    UIImageView* imgViewGridBackground = [[UIImageView alloc] init];
    [imgViewGridBackground setImage:[UIImage imageNamed:@"ResourceGridElementBackground.png"]];
    [imgViewGridBackground setFrame:frame];
    
    [viewGridParent addSubview:imgViewGridBackground];
    
    //Central View
    UIView* viewHashtag = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 160, 120)];
    [viewHashtag setBackgroundColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:0.23]];
    
    //Resource Type Icons
//    UIImageView* imgViewResourceTypeIcon = [[UIImageView alloc] init];
//    imgViewResourceTypeIcon.frame = CGRectMake(61, 28, 38, 29);
//    
//    imgViewResourceTypeIcon.image = [appDelegate imageForResourceType:[dictResource valueForKey:RESOURCE_CATEGORY]];
//    
//    [viewHashtag addSubview:imgViewResourceTypeIcon];
    

    UILabel* lblHashtag = [[UILabel alloc] init];
//    [lblHashtag setFrame:CGRectMake(5, imgViewResourceTypeIcon.frame.origin.y + imgViewResourceTypeIcon.frame.size.height + 5, viewHashtag.frame.size.width - 10, 50)];
    [lblHashtag setFrame:CGRectMake(0, 0, viewHashtag.frame.size.width - 10, 50)];
    [lblHashtag setCenter:viewHashtag.center];
    [lblHashtag setTextColor:gETLblResourceTitle.textColor];
    [lblHashtag setTextAlignment:NSTextAlignmentCenter];
    [lblHashtag setLineBreakMode:NSLineBreakByTruncatingTail];
    [lblHashtag setFont:[UIFont systemFontOfSize:14.0]];
    [lblHashtag setBackgroundColor:[UIColor clearColor]];
    [lblHashtag setNumberOfLines:3];
    [viewHashtag addSubview:lblHashtag];
    
    NSArray* arrAllTags = [[dictResource valueForKey:RESOURCE_TAGS] componentsSeparatedByString:@","];
    NSString* strHashtagText = [NSString stringWithFormat:@"Resources on %@",[arrAllTags objectAtIndex:0]];
    [lblHashtag setText:strHashtagText];

    //Resource Button
    UIButton* btnHashtag = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnHashtag setFrame:CGRectMake(0, 0, viewHashtag.frame.size.width, viewHashtag.frame.size.height)];
    [btnHashtag setBackgroundColor:[UIColor clearColor]];
    [btnHashtag setTag:tag*MULTIPLIER_RESOURCE];

    if (isSuggest) {
        [btnHashtag addTarget:self action:@selector(btnActionSuggestHashtag:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btnHashtag addTarget:self action:@selector(btnActionSearchHashtag:) forControlEvents:UIControlEventTouchUpInside];
    }
    
//    UILabel* lblCounter = [[UILabel alloc] initWithFrame:viewHashtag.frame];
//    if (isSuggest) {
//        [lblCounter setText:[NSString stringWithFormat:@"%i",tag/MULTIPLIER_SUGGEST]];
//    }else{
//        [lblCounter setText:[NSString stringWithFormat:@"%i",tag/MULTIPLIER_SEARCH]];
//    }
//    [lblCounter setTextColor:[UIColor blackColor]];
//    [lblCounter setFont:[UIFont systemFontOfSize:15.0]];
//    [lblCounter setBackgroundColor:[UIColor clearColor]];
//    [lblCounter setNumberOfLines:2];
//    
//    [viewHashtag addSubview:lblCounter];
    
    [viewHashtag addSubview:btnHashtag];
    
    
    return viewHashtag;
    
    
}


#pragma mark - Make Grid Element for Suggest/Search Results -
- (UIView*)createGridElementViewForSuggest:(BOOL)isSuggest UsingDetails:(NSMutableDictionary*)dictResource ForTag:(int)tag{
    
    //Main Parent View
    UIView* viewGridParent = [[UIView alloc] init];
    CGRect frame = CGRectMake(0, 0, gETParent.frame.size.width, gETParent.frame.size.height);
    [viewGridParent setBackgroundColor:[UIColor clearColor]];
    [viewGridParent setFrame:frame];
    
    
    //Main Parent View Background
    UIImageView* imgViewGridBackground = [[UIImageView alloc] init];
    [imgViewGridBackground setImage:[UIImage imageNamed:@"ResourceGridElementBackground.png"]];
    [imgViewGridBackground setFrame:frame];
    
    [viewGridParent addSubview:imgViewGridBackground];
    
    //ScrollView
    UIScrollView* scrollviewGridPages = [[UIScrollView alloc] init];
    [scrollviewGridPages setFrame:gETScrollParent.frame];
    [scrollviewGridPages setPagingEnabled:TRUE];
    [scrollviewGridPages setContentSize:CGSizeMake(gETScrollParent.frame.size.width*2, gETScrollParent.frame.size.height)];
    [scrollviewGridPages setBackgroundColor:[UIColor clearColor]];
    [scrollviewGridPages setShowsHorizontalScrollIndicator:FALSE];
    [scrollviewGridPages setShowsVerticalScrollIndicator:FALSE];
    [scrollviewGridPages setDelegate:self];
    [scrollviewGridPages setTag:tag*MULTIPLIER_SCROLL];

    [viewGridParent addSubview:scrollviewGridPages];

    //////
    //Details Page 1
    
    //Resource Details Page1
    UIView* viewDetailPage1 = [[UIView alloc] initWithFrame:gETView1.frame];
    [viewDetailPage1 setBackgroundColor:[UIColor clearColor]];

    //Resource Thumbnail
    UIImageView* imgViewThumbnail = [[UIImageView alloc]initWithFrame:gETImgViewThumbnail.frame];
    [imgViewThumbnail setImageWithURL:[NSURL URLWithString:[dictResource valueForKey:RESOURCE_THUMBNAIL]] placeholderImage:[UIImage imageNamed:@"defaultCollection@2x.png"]];
    [viewDetailPage1 addSubview:imgViewThumbnail];
    
    //Resource Type Icons
    UIImageView* imgViewResourceTypeIcon = [[UIImageView alloc] init];
    imgViewResourceTypeIcon.frame = CGRectMake(0, 91, 38, 29);
    
    imgViewResourceTypeIcon.image = [appDelegate imageForResourceType:[dictResource valueForKey:RESOURCE_CATEGORY]];
    
    [imgViewThumbnail addSubview:imgViewResourceTypeIcon];
    
    //Resource Button
    UIButton* btnResource = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnResource setFrame:imgViewThumbnail.frame];
    [btnResource setBackgroundColor:[UIColor clearColor]];
    
    if (isSuggest) {
        [btnResource addTarget:self action:@selector(btnActionSuggestResource:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btnResource addTarget:self action:@selector(btnActionSearchResource:) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnResource setTag:tag*MULTIPLIER_RESOURCE];
    
    [viewDetailPage1 addSubview:btnResource];
    
    //Resource Title
    UILabel* lblResourceTitle = [[UILabel alloc] initWithFrame:gETLblResourceTitle.frame];
    [lblResourceTitle setFont:gETLblResourceTitle.font];
    [lblResourceTitle setTextColor:gETLblResourceTitle.textColor];
    [lblResourceTitle setNumberOfLines:gETLblResourceTitle.numberOfLines];
    [lblResourceTitle setText:[dictResource valueForKey:RESOURCE_TITLE]];
    [lblResourceTitle setBackgroundColor:[UIColor clearColor]];
    
    [viewDetailPage1 addSubview:lblResourceTitle];
    
    // Resourse Title Button
    UIButton* btnResourceTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnResourceTitle setFrame:lblResourceTitle.frame];
    [btnResourceTitle setBackgroundColor:[UIColor clearColor]];
    
    if (isSuggest) {
        [btnResourceTitle addTarget:self action:@selector(btnActionSuggestResource:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btnResourceTitle addTarget:self action:@selector(btnActionSearchResource:) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnResourceTitle setTag:tag*MULTIPLIER_RESOURCE];
    
    [viewDetailPage1 addSubview:btnResourceTitle];

    
    
    //Resource Source
    UILabel* lblResourceSource = [[UILabel alloc] initWithFrame:gETLblResourceSource.frame];
    [lblResourceSource setFont:gETLblResourceSource.font];
    [lblResourceSource setTextColor:gETLblResourceSource.textColor];
    [lblResourceSource setNumberOfLines:gETLblResourceSource.numberOfLines];
    [lblResourceSource setText:[dictResource valueForKey:RESOURCE_SOURCE]];
    [lblResourceSource setBackgroundColor:[UIColor clearColor]];
    
    [viewDetailPage1 addSubview:lblResourceSource];
    
    //Views Helper Icon
    UIImageView* imgViewViewsHelper = [[UIImageView alloc]initWithFrame:gETImgViewViewsHelper.frame];
    [imgViewViewsHelper setImage:gETImgViewViewsHelper.image];
    [viewDetailPage1 addSubview:imgViewViewsHelper];
    
    
    
    //Resource Views
    UILabel* lblResourceViews = [[UILabel alloc] initWithFrame:gETLblResourceViews.frame];
    [lblResourceViews setFont:gETLblResourceViews.font];
    [lblResourceViews setTextColor:gETLblResourceViews.textColor];
    [lblResourceViews setNumberOfLines:1];
    [lblResourceViews setBackgroundColor:[UIColor clearColor]];
    [lblResourceViews setText:[dictResource valueForKey:RESOURCE_VIEWS]];
    [lblResourceViews setTag:TAG_RESOURCE_VIEWS];
    
    [viewDetailPage1 addSubview:lblResourceViews];
    
    [scrollviewGridPages addSubview:viewDetailPage1];
    
    //////
    //Details Page 2
    
    //Resource Details Page1
    UIView* viewDetailPage2 = [[UIView alloc] initWithFrame:gETView2.frame];
    [viewDetailPage2 setBackgroundColor:[UIColor clearColor]];
    
    
    //Resource Description
    UILabel* lblResourceDescription = [[UILabel alloc] initWithFrame:gETLblResourceDescription.frame];
    [lblResourceDescription setFont:gETLblResourceDescription.font];
    [lblResourceDescription setTextColor:gETLblResourceDescription.textColor];
    [lblResourceDescription setNumberOfLines:gETLblResourceDescription.numberOfLines];
    [lblResourceDescription setText:[dictResource valueForKey:RESOURCE_DESCRIPTION]];
    [lblResourceDescription setBackgroundColor:[UIColor clearColor]];
    
    [viewDetailPage2 addSubview:lblResourceDescription];
    
    [scrollviewGridPages addSubview:viewDetailPage2];
    
    //Page Indicator Buttons
    //Page Indicator 1
    UIButton* btnPageIndicator1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPageIndicator1 setFrame:gETBtnPageIndicator1.frame];
    [btnPageIndicator1 setSelected:TRUE];
    [btnPageIndicator1 setImage:[UIImage imageNamed:@"PaginationIndicatorNormal.png"] forState:UIControlStateNormal];
    [btnPageIndicator1 setImage:[UIImage imageNamed:@"PaginationIndicatorSelected.png"] forState:UIControlStateSelected];
    [btnPageIndicator1 setTag:tag*MULTIPLIER_SUGGEST_PAGEINDICATOR1];
    [viewGridParent addSubview:btnPageIndicator1];
    
    //Page Indicator 2
    UIButton* btnPageIndicator2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnPageIndicator2 setFrame:gETBtnPageIndicator2.frame];
    [btnPageIndicator2 setSelected:FALSE];
    [btnPageIndicator2 setImage:[UIImage imageNamed:@"PaginationIndicatorNormal.png"] forState:UIControlStateNormal];
    [btnPageIndicator2 setImage:[UIImage imageNamed:@"PaginationIndicatorSelected.png"] forState:UIControlStateSelected];
    [btnPageIndicator2 setTag:tag*MULTIPLIER_SUGGEST_PAGEINDICATOR2];
    [viewGridParent addSubview:btnPageIndicator2];
    
    //Share Button
    UIButton* btnShareResource = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShareResource setFrame:gETBtnResourceShare.frame];
    [btnShareResource setImage:[UIImage imageNamed:@"btnDiscoverShareResource.png"] forState:UIControlStateNormal];
    [btnShareResource setTag:tag*MULTIPLIER_SHARE];
    
    if (isSuggest) {
        [btnShareResource addTarget:self action:@selector(btnActionSuggestResourceShare:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [btnShareResource addTarget:self action:@selector(btnActionSearchResourceShare:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
//    UILabel* lblCounter = [[UILabel alloc] initWithFrame:viewGridParent.frame];
//    if (isSuggest) {
//        [lblCounter setText:[NSString stringWithFormat:@"%i",tag/MULTIPLIER_SUGGEST]];
//    }else{
//        [lblCounter setText:[NSString stringWithFormat:@"%i",tag/MULTIPLIER_SEARCH]];
//    }
//
//    [lblCounter setTextColor:[UIColor blackColor]];
//    [lblCounter setFont:[UIFont systemFontOfSize:15.0]];
//    [lblCounter setBackgroundColor:[UIColor clearColor]];
//    [lblCounter setNumberOfLines:2];
//    
//    [viewGridParent addSubview:lblCounter];
    
    [viewGridParent addSubview:btnShareResource];
    
    
    return viewGridParent;
    
}

#pragma mark - BA Resource/Resource Share -
#pragma mark BA Suggest Resource
- (void)btnActionSuggestResource:(id)sender{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_RESOURCE];
    NSLog(@"Launch Player (Suggest) for %@",[[dictSuggest valueForKey:requiredKey] valueForKey:RESOURCE_TITLE]);
    
    [self updateViewsFor:sender forSuggest:TRUE];
    
    
    ResourcePlayerViewController* resourcePlayerV2ViewController = [[ResourcePlayerViewController alloc] initWithAppDetails:[dictSuggest valueForKey:requiredKey]];
    
    [self presentViewController:resourcePlayerV2ViewController animated:YES completion:nil];
    
}


#pragma mark BA Suggest Resource Share
- (void)btnActionSuggestResourceShare:(id)sender{
 
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_SHARE];
    NSLog(@"Share (Suggest) %@",[[dictSuggest valueForKey:requiredKey] valueForKey:RESOURCE_TITLE]);
    
    shareViewController = [[ShareViewController alloc] initToShareCollection:NO withDetails:[dictSuggest valueForKey:requiredKey] shouldOccupyFullScreen:NO];
    
    [self presentDetailController:shareViewController inMasterView:self.view];
    
    
    
}

#pragma mark BA Search Resource
- (void)btnActionSearchResource:(id)sender{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_RESOURCE];
    NSLog(@"Launch Player (Search) for %@",[[dictSearch valueForKey:requiredKey] valueForKey:RESOURCE_TITLE]);
    
    [self updateViewsFor:sender forSuggest:FALSE];
    
    ResourcePlayerViewController* resourcePlayerV2ViewController = [[ResourcePlayerViewController alloc] initWithAppDetails:[dictSearch valueForKey:requiredKey]];
    
    [self presentViewController:resourcePlayerV2ViewController animated:YES completion:nil];
    
}


#pragma mark BA Search Resource Share
- (void)btnActionSearchResourceShare:(id)sender{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_SHARE];
    NSLog(@"Share (Search) %@",[[dictSearch valueForKey:requiredKey] valueForKey:RESOURCE_TITLE]);
    
    shareViewController = [[ShareViewController alloc] initToShareCollection:NO withDetails:[dictSearch valueForKey:requiredKey] shouldOccupyFullScreen:NO];
    
    [self presentDetailController:shareViewController inMasterView:self.view];
    
}

#pragma mark Update Views
- (void)updateViewsFor:(id)sender forSuggest:(BOOL)value{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_RESOURCE];
    
    NSMutableDictionary* dictToUse;
    if (value) {
        
        dictToUse = dictSuggest;
        
    }else{
        dictToUse = dictSearch;
    }
    
    NSMutableDictionary* dictResource = [dictToUse valueForKey:requiredKey];
    
    int resourceViews = [[dictResource valueForKey:RESOURCE_VIEWS] intValue];
    resourceViews = resourceViews + 1;
    
    UIButton* btnResource = (UIButton*)sender;
    
    UIView* viewPage1 = [btnResource superview];
    UILabel* lblResourceViews = (UILabel*)[viewPage1 viewWithTag:TAG_RESOURCE_VIEWS];
    [lblResourceViews setText:[NSString stringWithFormat:@"%i",resourceViews]];
    
    [dictResource setValue:[NSString stringWithFormat:@"%i",resourceViews] forKey:RESOURCE_VIEWS];
    
    [dictToUse setValue:dictResource forKey:requiredKey];
    
}

#pragma mark BA Suggest Hashtag
- (void)btnActionSuggestHashtag:(id)sender{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_RESOURCE];
    NSLog(@"Hashtag! (Suggest)");
    
    NSMutableDictionary* dictResource = [dictSuggest valueForKey:requiredKey];
    
    NSString* strResourceCategory = [dictResource valueForKey:RESOURCE_CATEGORY];
    
    NSArray* arrAllTags = [[dictResource valueForKey:RESOURCE_TAGS] componentsSeparatedByString:@","];
    NSString* strHashtagText = [arrAllTags objectAtIndex:0];
    
    NSLog(@"Hastag to search : %@",strHashtagText);
    NSLog(@"Hashtag Category : %@",strResourceCategory);

    [self initiateHashtagSearchFor:strHashtagText inCategory:strResourceCategory];
    

    
}

#pragma mark BA Search Hashtag
- (void)btnActionSearchHashtag:(id)sender{
    
    NSString* requiredKey = [NSString stringWithFormat:@"%i",[sender tag]/MULTIPLIER_RESOURCE];
    NSLog(@"Hashtag! (Search)");
    
    NSMutableDictionary* dictResource = [dictSearch valueForKey:requiredKey];
    
    NSString* strResourceCategory = [dictResource valueForKey:RESOURCE_CATEGORY];
    
    NSArray* arrAllTags = [[dictResource valueForKey:RESOURCE_TAGS] componentsSeparatedByString:@","];
    NSString* strHashtagText = [arrAllTags objectAtIndex:0];
    
    NSLog(@"Hastag to search : %@",strHashtagText);
    NSLog(@"Hashtag Category : %@",strResourceCategory);
    
    [self initiateHashtagSearchFor:strHashtagText inCategory:strResourceCategory];


    
}

- (void)initiateHashtagSearchFor:(NSString*)strHashtag inCategory:(NSString*)strCategory{
    
    
    arrSearchGradeFilterParams = [[NSMutableArray alloc] init];
    arrSearchSubjectFilterParams = [[NSMutableArray alloc] init];
    
    //Unselecting all filters
    for (UIView* subview in [viewFilterParent subviews]){
        
        if ([subview isKindOfClass:[UIButton class]]) {
            if (subview.frame.size.width != 125) {
                
                UIButton* btnFilter = (UIButton*)subview;
                [btnFilter setSelected:FALSE];
                
            }
        }
    }
    
    [self loadGooruSearch];
    
    searchPageNo = -1;
    searchGridNo = 1;
    [txtFieldSearch resignFirstResponder];
    
    dictSearch = [[NSMutableDictionary alloc] init];
    [collectionViewSearchResults reloadData];
    
//    [collectionViewSearchResults scrollRectToVisible:CGRectMake(0, 0, collectionViewSearchResults.frame.size.width, collectionViewSearchResults.frame.size.height) animated:TRUE];
    

//    arrSearchCategoryFilterParams = [[NSMutableArray alloc]init];
//    [arrSearchCategoryFilterParams addObject:strCategory];
    
    strSearchTerm = strHashtag;
    
    [txtFieldSearch setText:strHashtag];
    
    [self getSearchResults];
    
}

#pragma mark - Scroll Loading - 
- (void)shouldShowScrollLoader:(BOOL)value{
    
    if (value) {
        
        [self animateView:viewScrollLoader forFinalFrame:CGRectMake(viewScrollLoader.frame.origin.x, 670, viewScrollLoader.frame.size.width, viewScrollLoader.frame.size.height) inTime:0.3 withDelay:0.0];
        [activityIndicatorScrollLoading startAnimating];
        
    }else{
        [self animateView:viewScrollLoader forFinalFrame:CGRectMake(viewScrollLoader.frame.origin.x, 700, viewScrollLoader.frame.size.width, viewScrollLoader.frame.size.height) inTime:0.3 withDelay:0.0];
        [activityIndicatorScrollLoading stopAnimating];
    }
}



#pragma mark - BA Discover FUE -

#pragma mark BA Discover Help
- (IBAction)btnActionDiscoverHelp:(id)sender {
    
    if ([viewFUEDiscoverParent isHidden]) {
        
        [viewFUEPageParent setFrame:CGRectMake(0, 0, viewFUEPageParent.frame.size.width, viewFUEPageParent.frame.size.height)];
        [self shouldHideView:viewFUEDiscoverParent :FALSE];
        
        [self manageBtnVisibiltyForFUE:0];
    }else{
        
        [self shouldHideView:viewFUEDiscoverParent :TRUE];
        
    }
    
}

#pragma mark BA Discover FUE Skip Tutorial
- (IBAction)btnActionFUESkipTutorial:(id)sender{
    
    [self shouldHideView:viewFUEDiscoverParent :TRUE];
    
}
- (IBAction)btnActionFUEPrevious:(id)sender{
    
    [self manageBtnVisibiltyForFUE:viewFUEPageParent.frame.origin.x + 591];
    [self animateView:viewFUEPageParent forFinalFrame:CGRectMake(viewFUEPageParent.frame.origin.x + 591, viewFUEPageParent.frame.origin.y, viewFUEPageParent.frame.size.width, viewFUEPageParent.frame.size.height)];
    
    
    
}

- (void)handleSwipeRight{
    
    if(![btnFUEPageIndicator1 isSelected]){

        [self manageBtnVisibiltyForFUE:viewFUEPageParent.frame.origin.x + 591];
        [self animateView:viewFUEPageParent forFinalFrame:CGRectMake(viewFUEPageParent.frame.origin.x + 591, viewFUEPageParent.frame.origin.y, viewFUEPageParent.frame.size.width, viewFUEPageParent.frame.size.height)];
    }
    
}



- (IBAction)btnActionFUENext:(id)sender{
    
    [self manageBtnVisibiltyForFUE:viewFUEPageParent.frame.origin.x - 591 ];
    [self animateView:viewFUEPageParent forFinalFrame:CGRectMake(viewFUEPageParent.frame.origin.x - 591, viewFUEPageParent.frame.origin.y, viewFUEPageParent.frame.size.width, viewFUEPageParent.frame.size.height)];
    
    
}

- (void)handleSwipeLeft{
    
    if(![btnFUEPageIndicator2 isSelected]){
        
        [self manageBtnVisibiltyForFUE:viewFUEPageParent.frame.origin.x - 591 ];
        [self animateView:viewFUEPageParent forFinalFrame:CGRectMake(viewFUEPageParent.frame.origin.x - 591, viewFUEPageParent.frame.origin.y, viewFUEPageParent.frame.size.width, viewFUEPageParent.frame.size.height)];
        
    }
    
    
    
}

- (IBAction)btnActionFueDoneTutorial:(id)sender{
    
    [self shouldHideView:viewFUEDiscoverParent :TRUE];
    
}

- (IBAction)btnActionDoNotShow:(id)sender {
    
    if(![btnDoNotShow isSelected]){
        [btnDoNotShow setSelected:TRUE];
        [standardUserDefaults setObject:@"No" forKey:@"FUEFlagShouldShowDiscoverFUE"];
        
    }else{
        
        [btnDoNotShow setSelected:FALSE];
        [standardUserDefaults setObject:@"Yes" forKey:@"FUEFlagShouldShowDiscoverFUE"];
        
    }

}

- (void)manageBtnVisibiltyForFUE:(int)pageOffset{
    
    NSLog(@"pageOffset : %i",pageOffset);
    switch (pageOffset) {
        case 0:{
            [self shouldHideView:btnFUESkipTutorial :FALSE];
            [self shouldHideView:btnFUENext :FALSE];
            [self shouldHideView:btnFUEPrevious :TRUE];
            [self shouldHideView:btnFueDoneTutorial :TRUE];
            [self shouldHideView:btnDoNotShow :TRUE];
            
            [btnFUEPageIndicator1 setSelected:TRUE];
            [btnFUEPageIndicator2 setSelected:FALSE];
            [btnFUEPageIndicator3 setSelected:FALSE];
            break;
        }
            
        case -591:{
            [self shouldHideView:btnFUESkipTutorial :TRUE];
            [self shouldHideView:btnFUENext :TRUE];
            [self shouldHideView:btnFUEPrevious :FALSE];
            [self shouldHideView:btnFueDoneTutorial :FALSE];
            [self shouldHideView:btnDoNotShow :FALSE];
            
            [btnFUEPageIndicator1 setSelected:FALSE];
            [btnFUEPageIndicator2 setSelected:TRUE];
            [btnFUEPageIndicator3 setSelected:FALSE];
            break;
        }
            
        case -1182:{
            [self shouldHideView:btnFUESkipTutorial :TRUE];
            [self shouldHideView:btnFUENext :TRUE];
            [self shouldHideView:btnFUEPrevious :FALSE];
            [self shouldHideView:btnFueDoneTutorial :FALSE];
            [self shouldHideView:btnDoNotShow :FALSE];
            
            [btnFUEPageIndicator1 setSelected:FALSE];
            [btnFUEPageIndicator2 setSelected:FALSE];
            [btnFUEPageIndicator3 setSelected:TRUE];
            break;
        }
        default:
            break;
    }
    
}


#pragma mark - Text Did Change -

- (void)textFieldDidChange{
    
    if (txtFieldSearch.text.length == 0) {
        [txtFieldSearch setFont:[UIFont italicSystemFontOfSize:14.0]];
    }else{
        [txtFieldSearch setFont:[UIFont systemFontOfSize:14.0]];
    }
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{

    [btnSearch sendActionsForControlEvents:UIControlEventTouchUpInside];
    [textField resignFirstResponder];
    return YES;

}

#pragma mark Add Gesture to particular View

- (void)addLeftGestureOnView:(UIView *)view{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft)];
    
    swipe.numberOfTouchesRequired = 1;
    
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    swipe.delaysTouchesBegan = YES;
    [view addGestureRecognizer:swipe];
}
- (void)addRightGestureOnView:(UIView *)view{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight)];
    
    swipe.numberOfTouchesRequired = 1;
    
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    swipe.delaysTouchesBegan = YES;
    [view addGestureRecognizer:swipe];
}




#pragma mark - Animation Helpers
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

#pragma mark Animate View to Final Frame with duration and delay!
- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame inTime:(float)duration withDelay:(float)delay{
    
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark Hide/Unhide Animated!
-(void)shouldHideView:(UIView*)view :(BOOL)value{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

#pragma mark -

#pragma mark - Parse Helper
#pragma mark Extract youtube Id
- (NSString *)extractYoutubeID:(NSString *)youtubeURL{
    
    
//    NSLog(@"youtubeURL : %@",youtubeURL);
    
    
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




#pragma mark - View Contoller Handlers -
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

@end
