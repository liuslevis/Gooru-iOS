//
//  FirstUserExperienceViewController.m
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

#import "FirstUserExperienceViewController.h"
#import "MainClasspageViewController.h"
#import "RegistrationViewController.h"
#import "LoginViewController.h"
@interface FirstUserExperienceViewController ()

@end

@implementation FirstUserExperienceViewController
@synthesize viewFirstUser,viewStudyExperience,viewAssignHW;
@synthesize viewForGestureInFirstUser;
@synthesize viewForGestureInStudyExperience;
@synthesize viewForGestureInAssignHW;
@synthesize viewFUEforOther,viewFUEforStudy,viewFUEforTeach,viewFUEforTeachNoClasspages;
@synthesize textFieldClassCode;
@synthesize imageViewGreenHighlightAssignHW,imageViewGreenHighlightFirstUser,imageViewGreenHighlightStudyExp,imageViewGreyHighlightAssignHW,imageViewGreyHighlightFirstUser,imageViewGreyHighlightStudyExp;

NSMutableDictionary* dictStarterClasspagesFUE;
#define MULTIPLIER_CLASSPAGETABS 666

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCheckingStringForFUE:(NSString *)checkingString{
    
    stringCheckingFUE=checkingString;
    
    return self;
    
}

- (void)viewDidLoad
{
    viewFirstUser.frame=CGRectMake(0, 88,769 , 389);
    [viewFUEforOther addSubview:viewFirstUser];
    viewStudyExperience.frame=CGRectMake(769, 88, 769, 389);
    [viewFUEforOther addSubview:viewStudyExperience];
    viewAssignHW.frame=CGRectMake(769, 88, 769, 389);
    [viewFUEforOther addSubview:viewAssignHW];
    
    viewFUEforTeach.frame=CGRectMake(0, 0, viewFUEforTeach.frame.size.width, viewFUEforTeach.frame.size.height);
    [self.view addSubview:viewFUEforTeach];
    
    viewFUEforStudy.frame=CGRectMake(0, 0, viewFUEforStudy.frame.size.width, viewFUEforStudy.frame.size.height);
    [self.view addSubview:viewFUEforStudy];
    
    viewFUEforTeachNoClasspages.frame=CGRectMake(0, 0, viewFUEforTeachNoClasspages.frame.size.width, viewFUEforTeachNoClasspages.frame.size.height);
    [self.view addSubview:viewFUEforTeachNoClasspages];
    
    if ([stringCheckingFUE isEqualToString:@"Other"]) {
        viewFUEforOther.hidden=FALSE;
        viewFUEforStudy.hidden=TRUE;
        viewFUEforTeach.hidden=TRUE;
        viewFUEforTeachNoClasspages.hidden = TRUE;
        
        imageViewGreenHighlightStudyExp.hidden=TRUE;
        imageViewGreenHighlightAssignHW.hidden=TRUE;
        imageViewGreenHighlightFirstUser.hidden=FALSE;
        imageViewGreyHighlightFirstUser.hidden=TRUE;
        imageViewGreyHighlightStudyExp.hidden=FALSE;
        imageViewGreyHighlightAssignHW.hidden=FALSE;
    }else if ([stringCheckingFUE isEqualToString:@"Teach"]){
        viewFUEforOther.hidden=TRUE;
        viewFUEforStudy.hidden=TRUE;
        viewFUEforTeach.hidden=FALSE;
        viewFUEforTeachNoClasspages.hidden = TRUE;
        
    }else if ([stringCheckingFUE isEqualToString:@"Study"]){
        viewFUEforOther.hidden=TRUE;
        viewFUEforStudy.hidden=FALSE;
        viewFUEforTeach.hidden=TRUE;
        viewFUEforTeachNoClasspages.hidden = TRUE;
        
    }else if ([stringCheckingFUE isEqualToString:@"TeachNoClasspages"]){
        viewFUEforOther.hidden=TRUE;
        viewFUEforStudy.hidden=TRUE;
        viewFUEforTeach.hidden=TRUE;
        viewFUEforTeachNoClasspages.hidden = FALSE;
        
    }
    [self addLeftGestureOnPaticularView:viewForGestureInFirstUser];
    [self addLeftGestureOnPaticularView:viewForGestureInStudyExperience];
    
    [self addRightGestureOnPaticularView:viewForGestureInAssignHW];
    [self addRightGestureOnPaticularView:viewForGestureInStudyExperience];
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray* arrSuggestedClasspageTitles = [[NSArray alloc] initWithObjects:@"Welcome to Gooru!",@"Algebra 1",@"Ancient Civilizations",@"Physics",@"ELA", nil];
    
    NSArray* arrSuggestedClasspageIds = [[NSArray alloc] initWithObjects:@"0305adfe-2edc-4054-a29e-616f11f06181",@"272e9c46-c0a9-427a-9a0d-f31eb051ce3a",@"087ddf35-6b2b-4411-9832-d8e789a25888",@"6b2fbea8-b3e9-4b74-937b-28e209049eec",@"18c2e8db-ffcc-471e-960b-78b5ae30b98d", nil];
    
    
    NSArray* arrSuggestedClasspageCodes = [[NSArray alloc] initWithObjects:@"I6WAII1",@"I4VFPII",@"I4VDCII",@"I6RQYII",@"I8RCRII", nil];
    
    dictStarterClasspagesFUE = [[NSMutableDictionary alloc] init];
    for (int i=0; i<5; i++) {
        
        NSMutableDictionary* dictClasspageInstance = [[NSMutableDictionary alloc] init];
        
        [dictClasspageInstance setValue:[arrSuggestedClasspageTitles objectAtIndex:i] forKey:@"classpageTitle"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageIds objectAtIndex:i] forKey:@"classpageId"];
        [dictClasspageInstance setValue:[arrSuggestedClasspageCodes objectAtIndex:i] forKey:@"classpageCode"];
        
        NSString* keyForDictStaticClasspageAttr = [NSString stringWithFormat:@"%i",(i+1) * MULTIPLIER_CLASSPAGETABS];
        [dictStarterClasspagesFUE setValue:dictClasspageInstance forKey:keyForDictStaticClasspageAttr];
        
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//gesture recognizer method......
- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    
    NSUInteger touches = recognizer.numberOfTouches;
    
       switch (touches) {
    
           case 1:
               if (recognizer.view==viewForGestureInFirstUser) {
                   [self animateView:viewFirstUser forFinalFrame:CGRectMake(-769, 88, viewFirstUser.frame.size.width, viewFirstUser.frame.size.height)];
                   [self animateView:viewStudyExperience forFinalFrame:CGRectMake(0, 88, viewStudyExperience.frame.size.width, viewStudyExperience.frame.size.height)];
                   imageViewGreenHighlightStudyExp.hidden=FALSE;
                   imageViewGreenHighlightAssignHW.hidden=TRUE;
                   imageViewGreenHighlightFirstUser.hidden=TRUE;
                   imageViewGreyHighlightFirstUser.hidden=FALSE;
                   imageViewGreyHighlightStudyExp.hidden=TRUE;
                   imageViewGreyHighlightAssignHW.hidden=FALSE;
               }else if (recognizer.view==viewForGestureInStudyExperience){
                   [self animateView:viewStudyExperience forFinalFrame:CGRectMake(-769, 88, viewStudyExperience.frame.size.width, viewStudyExperience.frame.size.height)];
                   [self animateView:viewAssignHW forFinalFrame:CGRectMake(0, 88, viewAssignHW.frame.size.width, viewAssignHW.frame.size.height)];
                   imageViewGreenHighlightStudyExp.hidden=TRUE;
                   imageViewGreenHighlightAssignHW.hidden=FALSE;
                   imageViewGreenHighlightFirstUser.hidden=TRUE;
                   imageViewGreyHighlightFirstUser.hidden=FALSE;
                   imageViewGreyHighlightStudyExp.hidden=FALSE;
                   imageViewGreyHighlightAssignHW.hidden=TRUE;
               }
               
    
              break;
    
            case 2:
    
              break;
    
            case 3:
    
    
    
    
    
                break;
    
            default:
    
                break;
    
       }
    
    
    
}
- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    
    NSUInteger touches = recognizer.numberOfTouches;
    
    switch (touches) {
            
        case 1:
            if (recognizer.view==viewForGestureInAssignHW) {
                [self animateView:viewStudyExperience forFinalFrame:CGRectMake(0, 88, viewStudyExperience.frame.size.width, viewStudyExperience.frame.size.height)];
                [self animateView:viewAssignHW forFinalFrame:CGRectMake(769, 88, viewAssignHW.frame.size.width, viewAssignHW.frame.size.height)];
                imageViewGreenHighlightStudyExp.hidden=FALSE;
                imageViewGreenHighlightAssignHW.hidden=TRUE;
                imageViewGreenHighlightFirstUser.hidden=TRUE;
                imageViewGreyHighlightFirstUser.hidden=FALSE;
                imageViewGreyHighlightStudyExp.hidden=TRUE;
                imageViewGreyHighlightAssignHW.hidden=FALSE;
                
            }else if (recognizer.view==viewForGestureInStudyExperience){
                
                 [self animateView:viewFirstUser forFinalFrame:CGRectMake(0, 88, viewFirstUser.frame.size.width, viewFirstUser.frame.size.height)];
                [self animateView:viewStudyExperience forFinalFrame:CGRectMake(769, 88, viewStudyExperience.frame.size.width, viewStudyExperience.frame.size.height)];
                imageViewGreenHighlightStudyExp.hidden=TRUE;
                imageViewGreenHighlightAssignHW.hidden=TRUE;
                imageViewGreenHighlightFirstUser.hidden=FALSE;
                imageViewGreyHighlightFirstUser.hidden=TRUE;
                imageViewGreyHighlightStudyExp.hidden=FALSE;
                imageViewGreyHighlightAssignHW.hidden=FALSE;
            }
            
            
            break;
            
        case 2:
            
            break;
            
        case 3:
            
            
            
            
            
            break;
            
        default:
            
            break;
            
    }
    
    
    
}

#pragma mark Add Gesture to particular View

- (void)addLeftGestureOnPaticularView:(UIView *)tempView{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewsSwipeLeft:)];
    
    swipe.numberOfTouchesRequired = 1;
    
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    swipe.delaysTouchesBegan = YES;
     [tempView addGestureRecognizer:swipe];
}
- (void)addRightGestureOnPaticularView:(UIView *)tempView{
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewsSwipeRight:)];
    
    swipe.numberOfTouchesRequired = 1;
    
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    swipe.delaysTouchesBegan = YES;
    [tempView addGestureRecognizer:swipe];
}

#pragma mark Manage Login View Animation

- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark FUEOther BtnAction

- (IBAction)btnActionStarterClasspages:(id)sender {
    
    MainClasspageViewController* controller = (MainClasspageViewController*)self.parentViewController;
    [controller btnActionStarterClasspageFUE:sender];


}


- (IBAction)btnActionSignup:(id)sender {
    
    LoginViewController *loginViewController=[[LoginViewController alloc]init];
    [self presentDetailController:loginViewController inMasterView:self.parentViewController.view];
}

#pragma mark FUEStudy BtnAction

- (IBAction)btnActionStudyNow:(id)sender{
    
    MainClasspageViewController* controller = (MainClasspageViewController*)self.parentViewController;
    [controller verifyClasscode:textFieldClassCode.text];
    
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
#pragma mark - Alertview delegates -
- (void)alertShow:(NSString *)strMessage withTag:(int)tag{
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Gooru" message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:tag];
    
	[alert show];
}

@end
