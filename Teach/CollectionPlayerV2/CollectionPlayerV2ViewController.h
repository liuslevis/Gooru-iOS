//
//  CollectionPlayerV2ViewController.h
// Gooru
//
//  Created by Gooru on 8/5/13.
//  Copyright (c) 2013 Gooru. All rights reserved.
//  http://www.goorulearning.org/
//
//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
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
#import "iCarousel.h"
#import "LBYouTubePlayerViewController.h"
#import "JSON/JSON.h"


#import <MessageUI/MessageUI.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "SHKiOSFacebook.h"
#import "SHKiOSTwitter.h"
#import "SHKConfiguration.h"
#import "DefaultSHKConfigurator.h"
#import "MySHKConfigurator.h"

#import "DTAttributedTextView.h"
#import "DTLazyImageView.h"


@interface CollectionPlayerV2ViewController : UIViewController<iCarouselDataSource, iCarouselDelegate, LBYouTubePlayerControllerDelegate, UIWebViewDelegate,UIAlertViewDelegate, UITextViewDelegate, LBYouTubeExtractorDelegate, MFMailComposeViewControllerDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UITextViewDelegate,UIScrollViewDelegate>{
    
    IBOutlet UIView *viewMain;
    IBOutlet UIView *viewCarouselParent;
    
    
    IBOutlet UIView *viewBottomBar;
    IBOutlet UIView *viewReactionBtnsParent;
    
    IBOutlet UILabel *lblResourceTitle;
    #pragma mark - Question Support Components -
    
    //Question View
    IBOutlet UIView *view_Question;
    
    //Scroll Views in Question View
    IBOutlet UIScrollView *scrollViewQuestionLhs;
    IBOutlet UIScrollView *scrollViewQuestionRhs;
        
    //Question Text Label
    IBOutlet UILabel *lblQuestionText;
    
    //Question Image Label
    IBOutlet UIImageView *imgViewQuestionImage;
    
    //Button Check Answer
    IBOutlet UIButton *btnCheckAnswer;
    
    //Image View Answer Comment
    IBOutlet UIImageView *imgViewAnswerComment;
    
    
    //OE View
    IBOutlet UIView *viewOEQuestion;

    //OE Answer
    IBOutlet UITextView *txtViewOEAnswer;
    IBOutlet UILabel *lblCharLimit;
    
    //OE Submit
    IBOutlet UIButton *btnOESubmit;
    
    
    //Hints
    IBOutlet UIButton *btnHints;
    IBOutlet UILabel *lblBtnHints;
    IBOutlet UIView *viewHints;
    
    //Explanation
    IBOutlet UIButton *btnExplanation;
    IBOutlet UIView *viewExplanation;
    
    
    #pragma mark - Narration Overlay -
    
    IBOutlet UIView *viewNarrationOverlay;
    IBOutlet UIScrollView *scrollNarrationOverlay;
    IBOutlet UIView *viewNarrationOverlayChild;
    
    IBOutlet UILabel *lblNarrationOverlay;
    
    
    #pragma mark - Button Narration/Navigation -
    IBOutlet UIButton *btnNarration;
    IBOutlet UIButton *btnNavigation;
    
    #pragma mark Navigation Bar
    IBOutlet UIView *viewNavigation;
    IBOutlet UIScrollView *scrollNavigation;
    IBOutlet UIView *viewSelector;
    
    #pragma mark Resource Loader Activity Indicator
    IBOutlet UIActivityIndicatorView *activityIndicatorResourceLoading;
    
    #pragma mark Webview controls 
    IBOutlet UIView *viewWebControls;
    
    IBOutlet UIButton *btnWebControlBack;
    IBOutlet UIButton *btnWebControlForward;
    IBOutlet UIButton *btnWebControlRefresh;
    
    #pragma mark RC Chooser Popup
    IBOutlet UIView *viewRCChooser;
    
    IBOutlet UIButton *btnShareCollection;
    IBOutlet UIButton *btnShareResource;
    IBOutlet UIImageView *imageFacebookTwitter;
    IBOutlet UIImageView *imageEmail;
    
    #pragma mark Btn Flag
    IBOutlet UIButton *btnFlag;
    
    
    
    #pragma mark Cover Page
    IBOutlet UIView *viewCoverPage;
    IBOutlet UIImageView *imgViewCoverPage;
    IBOutlet UILabel *lblCoverPageTitle;
    IBOutlet UITextView *txtViewDescription;
    IBOutlet UIButton *btnStartCollection;
    
    IBOutlet UIView *viewNavigationOverlayChild;
    IBOutlet UIActivityIndicatorView *activivtyIndicatorCollectionLoading;
    
}





#pragma mark - Init -
- (id)initWithAppDetails:(NSMutableDictionary*)dictIncomingAppDetails;


#pragma mark - BA Close Player -
- (IBAction)btnActionClosePlayer:(id)sender;

#pragma mark - BA Question Support -
#pragma mark BA Options
- (IBAction)btnAction_answerOptions:(id)sender;

#pragma mark BA Check Answer
- (IBAction)btnActionCheckAnswer:(id)sender;


#pragma mark BA OE Submit
- (IBAction)btnActionOESubmit:(id)sender;


#pragma mark BA Hints and Explanation
- (IBAction)btnAction_hints:(id)sender;
- (IBAction)btnAction_explanation:(id)sender;


#pragma mark - BA Navigation/Narration -
- (IBAction)btnActionNavigation:(id)sender;
- (IBAction)btnActionNarration:(id)sender;


#pragma mark - BA Webview controls -
- (IBAction)btnActionWebviewGoBack:(id)sender;
- (IBAction)btnActionWebviewGoForward:(id)sender;
- (IBAction)btnActionWebviewReload:(id)sender;

#pragma mark - BA Reaction -
- (IBAction)btnActionReaction:(id)sender;

#pragma mark - BA Share -
- (IBAction)btnActionShare:(id)sender;

- (IBAction)btnActionShareCollection:(id)sender;
- (IBAction)btnActionShareResource:(id)sender;

#pragma mark - BA Start Collection -
- (IBAction)btnActionStartCollection:(id)sender;


#pragma mark - Exposed Methods -
#pragma mark BA Navigate Resources
-(void)btnActionNavigateResources:(id)sender;

#pragma mark BA Replay Collection
-(void)btnActionReplayCollection:(id)sender;

#pragma mark - Carousel Enable/Disable -
- (void)enableCarousel:(BOOL)value;

#pragma mark Question Loader 
-(void)loadQuestionOn:(UIView*)view withQuestionData:(NSMutableDictionary*)dictQuestionData andKey:(NSString*)requiredKey forSummaryPage:(BOOL)forSummaryPage;

#pragma mark Hide/Unhide Animated!
-(void)shouldHideView:(UIView*)view :(BOOL)value;


#pragma mark Create Sorted Array for Dictionary Integer Keys
-(NSArray*)sortedIntegerKeysForDictionary:(NSMutableDictionary*)dict;

#pragma mark Get Required Min Label Height
-(CGRect)getHLabelFrameForLabel:(UILabel*)label withString:(NSString*)string;
    
#pragma mark Get Required Min Label Width
-(CGRect)getWLabelFrameForLabel:(UILabel*)label withString:(NSString*)string;


#pragma mark Set Flag
- (void)setFlaggingForCollection:(BOOL)isCollection;





@end
