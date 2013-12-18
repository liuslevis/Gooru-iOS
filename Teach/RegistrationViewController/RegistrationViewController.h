//
//  RegistrationViewController.h
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
#import "FlatDatePicker.h"
#import "Toast+UIView.h"
#import "GTMRegex.h"



@interface RegistrationViewController : UIViewController<FlatDatePickerDelegate>{
    
    BOOL isViewHelp;
    int checkingFlag;
    NSMutableArray *arrayGrade;

    
    FlatDatePicker *flatDatePicker;
    IBOutlet UITextField *textFieldBirthday;
 
    IBOutlet UIButton *btnCalendar;
    
    IBOutlet UIButton *btnSelectGrade;
    
    IBOutlet UIButton *btnSelectCourse;
    BOOL isBtnGradeSelected;
}

@property (nonatomic, strong) FlatDatePicker *flatDatePicker;


// textField for teacher/student/other role
@property (strong, nonatomic) IBOutlet UITextField *textFieldFirstName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUserName;
@property (strong, nonatomic) IBOutlet UITextField *textFieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldConfirmPassword;
@property (strong, nonatomic) IBOutlet UITextField *textFieldEmailID;
@property (strong, nonatomic) IBOutlet UITextField *textFieldBirthday;
@property (strong, nonatomic) IBOutlet UITextField *textFieldLastName;

// labl top bar title
@property (strong, nonatomic) IBOutlet UILabel *lablTitleTopBar;

// btn topbar cross button
@property (strong, nonatomic) IBOutlet UIButton *btnCloseSignUpPopUp;

@property (strong, nonatomic) IBOutlet UIView *viewIndividualRole;
@property (strong, nonatomic) IBOutlet UIView *viewRolePicking;

@property (strong, nonatomic) IBOutlet UIView *viewAdditionalInfoGrade;
@property (strong, nonatomic) IBOutlet UIView *viewAdditionalInfoCourse;

@property (strong, nonatomic) IBOutlet UIView *viewCongratulation;
@property (strong, nonatomic) IBOutlet UIView *viewUnder13;
@property (strong, nonatomic) IBOutlet UIView *viewSignUp;
@property (strong, nonatomic) IBOutlet UIView *viewDatePickerparent;
@property (strong, nonatomic) IBOutlet UIView *viewHelp;

@property (strong, nonatomic) IBOutlet UIView *viewPopUpShade;
@property (strong, nonatomic) IBOutlet UIView *viewHelpSubview;
@property (strong, nonatomic) IBOutlet UIView *viewExitWarning;
// View For Grade and Grade Selection

@property (strong, nonatomic) IBOutlet UIView *viewGrade;
@property (strong, nonatomic) IBOutlet UIView *viewGradeContents;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewGrade;
@property (strong, nonatomic) IBOutlet UIView *viewForScrollviewGrade;


- (IBAction)btnActionCloseSignUpPopUp:(id)sender;

//role picking view BtnAction
- (IBAction)btnActionTeacher:(id)sender;
- (IBAction)btnActionStudent:(id)sender;
- (IBAction)btnActionOther:(id)sender;
- (IBAction)btnActionSignin:(id)sender;

// Teacher/Student/Other view BtnAction
- (IBAction)btnActionSignUp:(id)sender;
- (IBAction)btnActionHelp:(id)sender;

// Additional Info view BtnAction
- (IBAction)btnActionThanxYouAreAwesomeGrade:(id)sender;
- (IBAction)btnActionSkip:(id)sender;
- (IBAction)btnActionThanxYouAreAwesomeCourse:(id)sender;

//Date Picker Action
- (IBAction)btnActionDatePicker:(id)sender;

// hyperLink sign in text
- (IBAction)btnActionTermsofUse:(id)sender;
- (IBAction)btnActionprivacyPolicy:(id)sender;
- (IBAction)btnActionCopyrightPolicy:(id)sender;


// Congratulation View BtnAction
- (IBAction)btnActionExitAndGetstarted:(id)sender;

// ViewExitWarning BtnAction
- (IBAction)btnActionNoIwouldContinue:(id)sender;

// ViewGrade BtnAction
- (IBAction)btnActionPopulateGradeData:(id)sender;

@end
