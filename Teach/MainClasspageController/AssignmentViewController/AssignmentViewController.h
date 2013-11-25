//
//  AssignmentViewController.h
// Gooru
//
//  Created by Gooru on 8/12/13.
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
#import <MessageUI/MFMailComposeViewController.h>
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "FlatDatePicker.h"

@interface AssignmentViewController : UIViewController<UIScrollViewDelegate,MFMailComposeViewControllerDelegate,FlatDatePickerDelegate>{
    
    //Label Classpage Title
    IBOutlet UILabel *lblClasspageTitle;
      //Image Classpage 
    IBOutlet UIImageView *imgClasspageThumbnail;
    //Scroll view for Assignments
    IBOutlet UIScrollView *scrollAssignments;
    
    //Parent View for Assignments
    IBOutlet UIView *viewAssignments;
    
    //Parent View for share
    IBOutlet UIView *viewShare;
    
    //Activity Indicatior for Assignments
    IBOutlet UIActivityIndicatorView *activityIndicatorLoadAssignments;
    
    //View for No Assignments
    IBOutlet UIView *viewNoAssignments;
    
    //View to show Classcode / Exit classpage
    
    IBOutlet UIView *viewExitClasspage;
    IBOutlet UIView *viewClasscodeEmail;
    
    //Buttons Assignment and Share Tabs
    IBOutlet UIButton *btnAssignmentTab;
    IBOutlet UIButton *btnShareTab;
    
    IBOutlet UITextView *txtViewShareClasscode;
    
    //Pull Down to Refresh
    IBOutlet UIProgressView *progressViewRefresh;
    
       
}
@property (strong, nonatomic) IBOutlet UIButton *btnExitClasspage;
@property BOOL isLoggedOut;
@property BOOL isYourFirstClasspageAss;
//BA Assignment Tab
- (IBAction)btnActionAssignmentTab:(id)sender;

//BA Share Tab
- (IBAction)btnActionShareTab:(id)sender;
- (IBAction)btnActionSendShareEmail:(id)sender;

- (IBAction)btnActionExitClasspage:(id)sender;

//Init
- (id)initWithClasspageDetails:(NSMutableDictionary*)dictIncomingClasspage forTeach:(BOOL)value;


@end
