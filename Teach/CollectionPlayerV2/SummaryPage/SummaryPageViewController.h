//
//  SummaryPageViewController.h
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

#import <UIKit/UIKit.h>
#import "CollectionPlayerV2ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>
#import <MessageUI/MessageUI.h>

@interface SummaryPageViewController : UIViewController<MFMailComposeViewControllerDelegate>{
    
    IBOutlet UILabel *lblCollectionTitle;
    
    IBOutlet UIView *viewTopBarBtns;
    IBOutlet UIView *viewTabParent;
    IBOutlet UIView *viewTabsParent;
    
    IBOutlet UIView *viewReviewAnswer;
    
    IBOutlet UIView *viewReviewAnswerChild;
    IBOutlet UIView *viewRefSummaryItem;
    
    
    IBOutlet UILabel *lblRefSerialNumber;
    IBOutlet UIImageView *imgViewRefThumbnail;
    IBOutlet UIImageView *imgViewRefValidator;
    IBOutlet UIImageView *imgViewRefDescriptionHint;
    
    IBOutlet UILabel *lblRefResourceTitle;
    IBOutlet UILabel *lblRefResourceDescription;
    IBOutlet UIImageView *imgViewRefReaction;
    IBOutlet UIButton *btnRefReviewAnswer;
    IBOutlet UIView *viewRefSeparator;
    
    
    IBOutlet UIScrollView *scrollOverview;
    IBOutlet UIScrollView *scrollCorrect;
    IBOutlet UIScrollView *scrollIncorrect;
    IBOutlet UIScrollView *scrollSkipped;
    IBOutlet UIScrollView *scrollResponses;
    
    IBOutlet UIButton *btnBackFromReview;
    
    
    IBOutlet UIActivityIndicatorView *activityIndicatorMail;
    
    
}
@property (strong, nonatomic) IBOutlet UIView *viewOverview;
@property (strong, nonatomic) IBOutlet UIView *viewCorrect;
@property (strong, nonatomic) IBOutlet UIView *viewIncorrect;
@property (strong, nonatomic) IBOutlet UIView *viewSkipped;
@property (strong, nonatomic) IBOutlet UIView *viewResponses;

@property (strong, nonatomic) IBOutlet UIView *viewMainSubview;
@property (strong, nonatomic) IBOutlet UIButton *btnOverview;
@property (strong, nonatomic) IBOutlet UIButton *btnCorrect;
@property (strong, nonatomic) IBOutlet UIButton *btnIncorrect;
@property (strong, nonatomic) IBOutlet UIButton *btnSkipped;
@property (strong, nonatomic) IBOutlet UIButton *btnResponses;

- (IBAction)btnActionShowSubview:(id)sender;
- (IBAction)btnEmailAction:(id)sender;
- (IBAction)btnPrintAction:(id)sender;

- (IBAction)btnActionReplay:(id)sender;

- (IBAction)btnActionBackFromReview:(id)sender;

- (id)initWithCollectionDetails:(NSMutableDictionary*)dictIncomingCollections andResourceDetails:(NSMutableDictionary*)dictIncomingResourceDetails andCollectionPlayerObject:(CollectionPlayerV2ViewController*)incomingCollectionPlayerV2ViewController;

@end
