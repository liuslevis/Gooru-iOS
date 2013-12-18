//
//  MainClasspageViewController.h
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

@interface MainClasspageViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate>{
    
    
    //Top Bar Button Views
    IBOutlet UIView *viewTopBarLoggedIn;
    IBOutlet UIView *viewTopBarLoggedOut;
    
    //TextField to enter Classcode
    IBOutlet UITextField *txtFieldClasscode;
    
    //Btn Teach
    IBOutlet UIButton *btnTeach;
    
    //Btn Study
    IBOutlet UIButton *btnStudy;
    
    //Btn Discover
    IBOutlet UIButton *btnDiscover;
    
    //Btn Gooru Suggest/Search
    IBOutlet UIButton *btnGooruSuggest;
    IBOutlet UIButton *btnGooruSearch;
    
    IBOutlet UIImageView *imgViewArrowTeach;
    IBOutlet UIImageView *imgViewArrowStudy;
    IBOutlet UIImageView *imgViewArrowDiscover;
    
    
    //Side Bar Classpages
    IBOutlet UIScrollView *scrollClasspageTabBar;
    IBOutlet UIView *viewTeachClasspages;
    IBOutlet UIView *viewStudyClasspages;
    IBOutlet UIView *viewDiscover;
    
    
    UIButton *btnClasspageTitle;

    
    //Side bar User Settings
    IBOutlet UIView *viewUserSettings;
    IBOutlet UIView *viewSideBar;
    
    //Assignment Master
    IBOutlet UIView *viewMasterAssignment;
    
    IBOutlet UIImageView *testingImage;
    //User details area
    IBOutlet UILabel *lblUsername;
    IBOutlet UIButton *btnUserSettings;
    IBOutlet UIImageView *imgViewSettingsGear;
        
    IBOutlet UIButton *btnNarrationSettings;
    IBOutlet UIView *viewLogoutBtn;
    
    IBOutlet UIButton *btnHelp;
    
// View/Btn Support logged IN
    IBOutlet UIView *viewBtnSupport;
    IBOutlet UIButton *btnSupportLoggedIn;
// View/Btn Support logged Out
    IBOutlet UIView *viewBtnSupportLoggedOut;
    IBOutlet UIButton *btnSupportLoggedOut;
    // btn StudyNow
    IBOutlet UIButton *btnStudyNow;
    
    IBOutlet UIButton *btnLogin;
    BOOL isYourFirstClassPageInMC;
    IBOutlet UIActivityIndicatorView *activityIndicatorPrimary;
}

//Btn Gooru Suggest/Search

@property (strong, nonatomic) IBOutlet UIButton *btnGooruSuggest;
@property (strong, nonatomic) IBOutlet UIButton *btnGooruSearch;

//Btn Teach
@property (strong, nonatomic) IBOutlet UIButton *btnTeach;

//BA Sign Up!
- (IBAction)btnActionSignUp:(id)sender;

// BA Help
- (IBAction)btnActionhelp:(id)sender;

//BA Log In
- (IBAction)btnActionLogIn:(id)sender;

//BA Log Out
- (IBAction)btnActionLogout:(id)sender;

//BA Teach
- (IBAction)btnActionTeach:(id)sender;

//BA Study
- (IBAction)btnActionStudy:(id)sender;

//BA Discover
- (IBAction)btnActionDiscover:(id)sender;

//BA Gooru Suggest/Search
- (IBAction)btnActionGooruSuggest:(id)sender;
- (IBAction)btnActionGooruSearch:(id)sender;



//BA Study Now
- (IBAction)btnActionStudyNow:(id)sender;


- (IBAction)btnActionUserSettings:(id)sender;

- (IBAction)btnActionNarrationSettings:(id)sender;

- (void)btnActionStarterClasspageFUE:(id)sender;

- (void)onLogin;

- (void)starterClasspageIntiatior:(int)tag;

- (void)setUpStarterClasspageDictionaryAndShouldAutoPopulate:(BOOL)value;

- (void)verifyClasscode:(NSString*)classcode;

//Exit Study Classpage
- (void)exitStudyClasspage;

// BA Support
- (IBAction)btnActionSupport:(id)sender;

- (IBAction)btnActionCollectionAnalytics:(id)sender;

@end
