//
//  RegistrationViewController.m
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

#import "RegistrationViewController.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SVWebViewController.h"

#define MULTIPLIER_GRADE 333

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize textFieldBirthday,textFieldConfirmPassword,textFieldEmailID,textFieldFirstName,textFieldLastName,textFieldPassword,textFieldUserName;
@synthesize viewSignUp,viewRolePicking,viewIndividualRole,viewAdditionalInfoGrade,viewCongratulation,viewUnder13,viewDatePickerparent,viewAdditionalInfoCourse;
@synthesize lablTitleTopBar;
@synthesize flatDatePicker;
@synthesize viewHelp;
@synthesize viewPopUpShade;
@synthesize viewHelpSubview;
@synthesize viewExitWarning;
@synthesize viewGrade,viewGradeContents;
@synthesize scrollViewGrade;
@synthesize viewForScrollviewGrade;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - View Lifecycle -
- (void)viewDidLoad
{
    checkingFlag=1;
    viewHelp.layer.cornerRadius=6.0f;
    viewHelpSubview.layer.cornerRadius=6.0f;
    viewHelp.hidden=TRUE;
    viewExitWarning.hidden=TRUE;
    viewGradeContents.hidden=TRUE;
    [super viewDidLoad];
    [viewUnder13 setHidden:TRUE];
   // viewGradeContents.backgroundColor=[UIColor yellowColor];
    lablTitleTopBar.text=@"Sign Up!";
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:viewDatePickerparent];
    
    [self animateView:viewDatePickerparent forFinalFrame:CGRectMake(viewDatePickerparent.frame.origin.x, viewDatePickerparent.frame.origin.y, viewDatePickerparent.frame.size.width, btnCalendar.frame.size.height)];
    [textFieldBirthday setText:@""];
       self.flatDatePicker.delegate = self;
    self.flatDatePicker.title = @"Select your Birthday";
    arrayGrade=[[NSMutableArray alloc]initWithObjects:@"Kindergarten",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"Higher Education", nil];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector (keyboardDidShow:)
     name: UIKeyboardDidShowNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector (keyboardDidHide:)
     name: UIKeyboardDidHideNotification
     object:nil];
}


#pragma mark - KeyBoard delegates -

- (void) keyboardDidShow: (NSNotification *)notif {
    if (viewSignUp.frame.origin.y==27) {
        
    }else{
    
    [self animateView:viewSignUp forFinalFrame:CGRectMake(viewSignUp.frame.origin.x, viewSignUp.frame.origin.y - 160, viewSignUp.frame.size.width, viewSignUp.frame.size.height)];
    
    [self animateView:viewHelp forFinalFrame:CGRectMake(viewHelp.frame.origin.x, viewHelp.frame.origin.y - 160, viewHelp.frame.size.width, viewHelp.frame.size.height)];
    }
}

- (void) keyboardDidHide: (NSNotification *)notif {
    if (viewSignUp.frame.origin.y==187) {
        
    }else{
    [self animateView:viewSignUp forFinalFrame:CGRectMake(viewSignUp.frame.origin.x, viewSignUp.frame.origin.y + 160, viewSignUp.frame.size.width, viewSignUp.frame.size.height)];
    
     [self animateView:viewHelp forFinalFrame:CGRectMake(viewHelp.frame.origin.x, viewHelp.frame.origin.y + 160, viewHelp.frame.size.width, viewHelp.frame.size.height)];
    }
}
#pragma mark Manage SignUp View Animation

- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}
#pragma mark - Button Actions -
- (IBAction)btnActionCloseSignUpPopUp:(id)sender{
    
    
    viewExitWarning.hidden=FALSE;
     viewSignUp.hidden=TRUE;
    if (checkingFlag==1) {
       
        viewRolePicking.hidden=TRUE;
        
    }else if (checkingFlag==2){
        viewIndividualRole.hidden=TRUE;
        
    }else if (checkingFlag==3){
        viewAdditionalInfoGrade.hidden=TRUE;
    }else if (checkingFlag==4){
        self.view.alpha=1;
        [UIView animateWithDuration:0.3
                         animations:^{
                             // theView.center = newCenter;
                             self.view.alpha = 0;
                         }
                         completion:^(BOOL finished){
                             // Do other things
                         }];
        
        [self performSelector:@selector(removeRegistrationViewController) withObject:nil afterDelay:0.3];
    }
    
}
#pragma mark  Remove Child View controller

- (void)removeRegistrationViewController{
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}
#pragma mark Role Picking View BtnAction

- (IBAction)btnActionTeacher:(id)sender{
    
    [self animateView:viewRolePicking forFinalFrame:CGRectMake(-471, 0, viewRolePicking.frame.size.width, viewRolePicking.frame.size.height)];
    [self animateView:viewIndividualRole forFinalFrame:CGRectMake(0, 0, viewIndividualRole.frame.size.width, viewIndividualRole.frame.size.height)];
    checkingFlag=2;
}
- (IBAction)btnActionStudent:(id)sender{
  
    [self animateView:viewRolePicking forFinalFrame:CGRectMake(-471, 0, viewRolePicking.frame.size.width, viewRolePicking.frame.size.height)];
    [self animateView:viewIndividualRole forFinalFrame:CGRectMake(0, 0, viewIndividualRole.frame.size.width, viewIndividualRole.frame.size.height)];
    checkingFlag=2;
}
- (IBAction)btnActionOther:(id)sender{
   
    [self animateView:viewRolePicking forFinalFrame:CGRectMake(-471, 0, viewRolePicking.frame.size.width, viewRolePicking.frame.size.height)];
    [self animateView:viewIndividualRole forFinalFrame:CGRectMake(0, 0, viewIndividualRole.frame.size.width, viewIndividualRole.frame.size.height)];
    checkingFlag=2;
}

- (IBAction)btnActionSignin:(id)sender{
  
    LoginViewController *loginViewController=[[LoginViewController alloc]init];
    [self presentDetailController:loginViewController inMasterView:self.parentViewController.view];
      [self removeRegistrationViewController];
}

#pragma mark Teacher/Student/Other Role BtnAction
- (IBAction)btnActionSignUp:(id)sender{
    
    
    
    if([textFieldFirstName.text isEqualToString:@""] || textFieldFirstName.text == nil ||[textFieldLastName.text isEqualToString:@""] || textFieldLastName.text == nil||[textFieldUserName.text isEqualToString:@""] || textFieldUserName.text == nil||[textFieldBirthday.text isEqualToString:@""] || textFieldBirthday.text == nil||[textFieldEmailID.text isEqualToString:@""] || textFieldEmailID.text == nil||[textFieldPassword.text isEqualToString:@""] || textFieldPassword.text == nil||[textFieldConfirmPassword.text isEqualToString:@""] || textFieldConfirmPassword.text == nil)
    {
        [self error_AlertShow:@"Please fill in all the fields!!!!"];
    }else
        if(![self isEmailValid:textFieldEmailID.text]){
        
        [self error_AlertShow:@"Please enter a Valid Email ID"];
    }else
    {
        NSString* tempCompareString = textFieldPassword.text;
        if ([textFieldConfirmPassword.text isEqualToString:tempCompareString]) {
            lablTitleTopBar.text=@"Additional Info";
            [self animateView:viewIndividualRole forFinalFrame:CGRectMake(-471, 0, viewIndividualRole.frame.size.width, viewIndividualRole.frame.size.height)];
            [self animateView:viewAdditionalInfoGrade forFinalFrame:CGRectMake(0, 0, viewAdditionalInfoGrade.frame.size.width, viewAdditionalInfoGrade.frame.size.height)];
            
            checkingFlag=3;
        }else{
            [self error_AlertShow:@"Password mismatch. Make sure the passwords are identical."];

        }
        
   
    }
}

- (IBAction)btnActionHelp:(id)sender{
    if (!isViewHelp) {
        viewHelp.hidden=FALSE;
        isViewHelp=TRUE;
    }else{
        viewHelp.hidden=TRUE;
        isViewHelp=FALSE;
    }
}

#pragma mark Date Picker BtnAction


- (IBAction)btnActionDatePicker:(id)sender {
    
   [self animateView:viewDatePickerparent forFinalFrame:CGRectMake(viewDatePickerparent.frame.origin.x, viewDatePickerparent.frame.origin.y, viewDatePickerparent.frame.size.width, self.flatDatePicker.frame.size.height)];

    
}


#pragma mark Additional Info View BtnAction
- (IBAction)btnActionThanxYouAreAwesomeGrade:(id)sender{
    lablTitleTopBar.text=@"congrats!";
    [self animateView:viewAdditionalInfoGrade forFinalFrame:CGRectMake(-471, 0, viewAdditionalInfoGrade.frame.size.width, viewAdditionalInfoGrade.frame.size.height)];
    [self animateView:viewAdditionalInfoCourse forFinalFrame:CGRectMake(0, 0, viewAdditionalInfoCourse.frame.size.width, viewAdditionalInfoCourse.frame.size.height)];
    checkingFlag=4;
    
}
- (IBAction)btnActionSkip:(id)sender{
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeRegistrationViewController) withObject:nil afterDelay:0.3];
}

- (IBAction)btnActionThanxYouAreAwesomeCourse:(id)sender {
    
    lablTitleTopBar.text=@"congrats!";
    [self animateView:viewAdditionalInfoCourse forFinalFrame:CGRectMake(-471, 0, viewAdditionalInfoCourse.frame.size.width, viewAdditionalInfoCourse.frame.size.height)];
    [self animateView:viewCongratulation forFinalFrame:CGRectMake(0, 0, viewCongratulation.frame.size.width, viewCongratulation.frame.size.height)];
    checkingFlag=5;
}

#pragma mark Congratulation View BtnAction
- (IBAction)btnActionExitAndGetstarted:(id)sender{
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeRegistrationViewController) withObject:nil afterDelay:0.3];
}

#pragma mark ViewExitWarning Btn Action

- (IBAction)btnActionNoIwouldContinue:(id)sender{
    if ([viewRolePicking isHidden]) {
        viewRolePicking.hidden=FALSE;
        viewExitWarning.hidden=TRUE;
         viewSignUp.hidden=FALSE;
    }else if ([viewIndividualRole isHidden])
    {
        viewIndividualRole.hidden=FALSE;
         viewExitWarning.hidden=TRUE;
        viewSignUp.hidden=FALSE;
    }else if ([viewAdditionalInfoGrade isHidden]){
        viewAdditionalInfoGrade.hidden=FALSE;
         viewExitWarning.hidden=TRUE;
        viewSignUp.hidden=FALSE;
    }
}
#pragma mark - View Controller Manipulators -

- (void)presentDetailController:(UIViewController*)detailVC inMasterView:(UIView*)viewMaster{
    
    
    [self.parentViewController addChildViewController:detailVC];
    
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


#pragma mark - FlatDatePicker Delegate -

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *value = [dateFormatter stringFromDate:date];
    
    
    textFieldBirthday.text = value;
    
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    
    [self animateView:viewDatePickerparent forFinalFrame:CGRectMake(viewDatePickerparent.frame.origin.x, viewDatePickerparent.frame.origin.y, viewDatePickerparent.frame.size.width, btnCalendar.frame.size.height)];
    [textFieldBirthday setText:@""];
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *chosenDate = [cal dateFromComponents:components];
    
    NSComparisonResult result = [today compare:chosenDate];
    
    
    
    if(result!=NSOrderedDescending){
        NSLog(@"chosenDate is in the future!!!");
        [self error_AlertShow:@"chosenDate is in the future!!!"];
    }
    else{
        
        int temp = [self daysBetween:today and:chosenDate];
        NSLog(@"date interval : %d" , abs(temp) );
    
        if (abs(temp) < 4748) {
            [viewUnder13 setHidden:FALSE];
            [viewSignUp setHidden:TRUE];

        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM/dd/yyyy"];
            NSString *value = [dateFormatter stringFromDate:date];
            textFieldBirthday.text = value;
            
             [self animateView:viewDatePickerparent forFinalFrame:CGRectMake(viewDatePickerparent.frame.origin.x, viewDatePickerparent.frame.origin.y, viewDatePickerparent.frame.size.width, btnCalendar.frame.size.height)];
        }
        
       
    }
}

- (int)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2 {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:dt1 toDate:dt2 options:0];
    return [components day]+1;
}
#pragma mark error_AlertShow
- (void)error_AlertShow:(NSString *)strMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gooru" message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}


#pragma mark isEmailValid Regex

- (BOOL)isEmailValid:(NSString *)email {
	
	BOOL isValid = YES;
	
	NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	GTMRegex *regex = [GTMRegex regexWithPattern:emailRegEx];
	if(([regex matchesString:email]) == YES){
		NSLog(@"Registration Form: You have entered valid email address %@", email);
	}
	else {
		
		NSLog(@"Registration Form: You have entered INVALID email address %@", email);
		isValid = NO;
	}
	
	return isValid;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnActionTermsofUse:(id)sender {
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://google.com"];
    [self presentModalViewController:webViewController animated:YES];
}

- (IBAction)btnActionprivacyPolicy:(id)sender {
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://google.com"];
    [self presentModalViewController:webViewController animated:YES];
    
}

- (IBAction)btnActionCopyrightPolicy:(id)sender {
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://google.com"];
    [self presentModalViewController:webViewController animated:YES];
    
}
- (IBAction)btnActionPopulateGradeData:(id)sender {
    if (!isBtnGradeSelected) {
        for (UIView *aView in [scrollViewGrade subviews]){
            
            [aView removeFromSuperview];
        }
        viewGradeContents.hidden=FALSE;
        [self animateView:viewGradeContents forFinalFrame:CGRectMake(viewGradeContents.frame.origin.x, viewGradeContents.frame.origin.y, viewGradeContents.frame.size.width, 255)];
        isBtnGradeSelected=TRUE;
        int yOrdinate=15;
        for (int i=0; i<[arrayGrade count]; i++) {
            
            UIButton *btnGradeTitle=[[UIButton alloc]init];
            btnGradeTitle.frame=CGRectMake(20, yOrdinate, viewGradeContents.frame.size.width, 35);
            [btnGradeTitle.titleLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
            [btnGradeTitle setTitle:[arrayGrade objectAtIndex:i] forState:UIControlStateNormal];
            [btnGradeTitle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnGradeTitle  setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            btnGradeTitle.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            btnGradeTitle.backgroundColor=[UIColor clearColor];
            btnGradeTitle.tag=(i+1)*MULTIPLIER_GRADE;
            [btnGradeTitle addTarget:self action:@selector(btnActionSelectGrade:) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewGrade addSubview:btnGradeTitle];
            yOrdinate=yOrdinate+btnGradeTitle.frame.size.height;
            
            
        }
        scrollViewGrade.contentSize=CGSizeMake(scrollViewGrade.frame.size.width, yOrdinate);
    }else{
        isBtnGradeSelected=FALSE;
        [self animateView:viewGradeContents forFinalFrame:CGRectMake(viewGradeContents.frame.origin.x, viewGradeContents.frame.origin.y, viewGradeContents.frame.size.width, 0)];
       
       // viewGradeContents.hidden=TRUE;
        
    }
    
    
   
    
}
@end
