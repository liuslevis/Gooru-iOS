//
//  FlaggingPopupViewController.h
// Gooru
//
//  Created by Gooru on 10/18/13.
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

@interface FlaggingPopupViewController : UIViewController{
    
    IBOutlet UIView *viewPopupshade;
    
    
    //Popup View
    IBOutlet UIView *viewFlaggingPopup;
    
    //Popup Heading
    IBOutlet UILabel *lblFlagPopupTitle;
    
    //Flagging Question
    IBOutlet UILabel *lblFlagPrompt;
    
    
    //View with Resource Flagging Options
    IBOutlet UIView *viewResourceFlagging;
    
    //View with Collection Flagging Options
    IBOutlet UIView *viewCollectionFlagging;
    
    //Text View for Other Details
    IBOutlet UITextView *txtViewOtherDetails;
    
    //Button to submit flags
    IBOutlet UIButton *btnSubmitFlags;
    
    //View Flagging Confirmation
    IBOutlet UIView *viewFlaggingConfirmedPopup;
    
    IBOutlet UILabel *lblFlaggedTitle;
    IBOutlet UIView *viewTandC;

    IBOutlet UIButton *btnCopyright;
    IBOutlet UILabel *lblCopyright;
    
    IBOutlet UIWebView *webviewTerms;
    
}

- (IBAction)btnActionCloseFlagPopup:(id)sender;

- (IBAction)btnActionFlagOptions:(id)sender;

- (IBAction)btnActionSubmitFlags:(id)sender;

- (IBAction)btnActionTermsAndConditions:(id)sender;

//Exposed Methods
- (id)initWithCollectionInfo:(NSMutableDictionary*)dictIncomingCollectionInfo andResourceInfo:(NSMutableDictionary*)dictIncomingResourceInfo forCollection:(BOOL)value andParentViewController:(UIViewController*)parentViewController;



@end
