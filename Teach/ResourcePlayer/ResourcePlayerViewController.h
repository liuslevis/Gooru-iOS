//
//  ResourcePlayerViewController.h
//  Gooru
//
//  Created by Prasad Ram on 11/6/13.
//  Copyright (c) 2013 Gooru Admin. All rights reserved.
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


@interface ResourcePlayerViewController : UIViewController<LBYouTubePlayerControllerDelegate, UIWebViewDelegate,UIAlertViewDelegate, UITextViewDelegate, LBYouTubeExtractorDelegate, MFMailComposeViewControllerDelegate, DTAttributedTextContentViewDelegate, DTLazyImageViewDelegate, UITextViewDelegate,UIScrollViewDelegate>{

    
    IBOutlet UILabel *lblResourceTitle;
    
    IBOutlet UIActivityIndicatorView *activityIndicatorResourceLoading;
    
    IBOutlet UIWebView *webViewResource;
    
    IBOutlet UIView *viewWebControls;
  
    IBOutlet UIView *viewMainParent;
    
    IBOutlet UIButton *btnFlag;
    
    
}

#pragma mark - Init -
- (id)initWithAppDetails:(NSMutableDictionary*)dictIncomingAppDetails;

- (IBAction)btnActionShareResource:(id)sender;
- (IBAction)btnActionFlagging:(id)sender;


- (IBAction)btnActionWebBack:(id)sender;
- (IBAction)btnActionWebForward:(id)sender;
- (IBAction)btnActionWebRefresh:(id)sender;
- (IBAction)btnActionClosePlayer:(id)sender;

- (void)setFlagging;

@end
