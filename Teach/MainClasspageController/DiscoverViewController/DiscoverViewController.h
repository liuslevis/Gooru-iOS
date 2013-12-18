//
//  DiscoverViewController.h
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

#import <UIKit/UIKit.h>
#import "CHTCollectionViewSuggestLayout.h"
#import "CHTCollectionViewSearchLayout.h"
#import "MainClasspageViewController.h"

@interface DiscoverViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UICollectionViewDelegate, UITextFieldDelegate, CHTCollectionViewSuggestDelegateWaterfallLayout, CHTCollectionViewSearchDelegateWaterfallLayout>{
    
    
    //Initial Loading Indicator
    IBOutlet UIActivityIndicatorView *activityIndicatorInitialSuggestLoading;
    IBOutlet UIActivityIndicatorView *activityIndicatorInitialSearchLoading;
    
    //Scroll Loading
    IBOutlet UIView *viewScrollLoader;
    IBOutlet UIActivityIndicatorView *activityIndicatorScrollLoading;
    
    
    
    //View Gooru Suggest
    IBOutlet UIView *viewParentGooruSuggest;
    IBOutlet UIView *viewSuggestResultsParent;
    
    //View Gooru Suggest
    
    IBOutlet UIView *viewParentGooruSearch;
    IBOutlet UIView *viewFilterParent;

    IBOutlet UIButton *btnSearch;
    
    IBOutlet UITextField *txtFieldSearch;
    IBOutlet UIButton *btnToggleFilter;
    
    IBOutlet UILabel *lblToggleFilter;
    
    IBOutlet UIView *viewSearchResultsParent;
    
    IBOutlet UIView *viewNoResults;
    
    IBOutlet UILabel *lblNoResults;
    
    
    //Resource Grid Template gET(gridElementTemplate)
    IBOutlet UIView *gETParent;
    IBOutlet UIScrollView *gETScrollParent;
    
    IBOutlet UIView *gETView1;
    IBOutlet UIImageView *gETImgViewThumbnail;
    IBOutlet UILabel *gETLblResourceTitle;
    IBOutlet UILabel *gETLblResourceSource;
    IBOutlet UILabel *gETLblResourceViews;
    IBOutlet UIImageView *gETImgViewViewsHelper;
    IBOutlet UIButton *gETBtnResource;
    
    IBOutlet UIView *gETView2;
    IBOutlet UILabel *gETLblResourceDescription;
    
    IBOutlet UIButton *gETBtnPageIndicator1;
    IBOutlet UIButton *gETBtnPageIndicator2;
    
    IBOutlet UIButton *gETBtnResourceShare;
    
    //FUE Discover
    
    IBOutlet UIButton *btnDiscoverHelp;
    
    IBOutlet UIView *viewFUEDiscoverParent;
    IBOutlet UIView *viewFUEDiscoverChild;
    IBOutlet UIView *viewPopupShade;
    
    IBOutlet UIView *viewFUEPageParent;
    
    IBOutlet UIView *viewFUEDiscover1;
    IBOutlet UIView *viewFUEDiscover2;
    IBOutlet UIView *viewFUEDiscover3;
    
    IBOutlet UIButton *btnFUEPageIndicator1;
    IBOutlet UIButton *btnFUEPageIndicator2;
    IBOutlet UIButton *btnFUEPageIndicator3;
    
    IBOutlet UIButton *btnFUESkipTutorial;
    IBOutlet UIButton *btnFUEPrevious;
    IBOutlet UIButton *btnFUENext;
    IBOutlet UIButton *btnFueDoneTutorial;
    IBOutlet UIButton *btnDoNotShow;
    
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewSuggestResults;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewSearchResults;



//BA Suggest/Search
- (IBAction)btnActionGooruSuggest:(id)sender;
- (IBAction)btnActionGooruSearch:(id)sender;


//BA Toggle Filter Panel
- (IBAction)btnActionFiltersToggle:(id)sender;

//BA Grade Filter
- (IBAction)btnActionGradeFilter:(id)sender;

//BA Subject Filter
- (IBAction)btnActionSubjectFilter:(id)sender;

- (IBAction)btnActionSearchActual:(id)sender;

//BA Discover Help
- (IBAction)btnActionDiscoverHelp:(id)sender;

//BA FUE
- (IBAction)btnActionFUESkipTutorial:(id)sender;
- (IBAction)btnActionFUEPrevious:(id)sender;
- (IBAction)btnActionFUENext:(id)sender;
- (IBAction)btnActionFueDoneTutorial:(id)sender;
- (IBAction)btnActionDoNotShow:(id)sender;


//Exposed methods
- (void)loadGooruSuggest;
- (void)loadGooruSearch;

- (id)initWithParentViewController:(MainClasspageViewController*)parentViewController;






@end
