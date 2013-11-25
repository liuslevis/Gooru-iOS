//
//  LoginViewController.h
// Gooru
//
//  Created by Gooru on 13/08/13.
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
#import "AppDelegate.h"
#import "AFHTTPClient.h"

@interface LoginViewController : UIViewController{
    
    //App Delegate
    
    AppDelegate *appDelegate;
    
    // textfield
    IBOutlet UITextField *txtFldPassword;
    IBOutlet UITextField *txtFldUsername;
    UITextField *activeField;
    
    // uiview
     IBOutlet UIView *viewLogin;
    
    // button
    IBOutlet UIButton *btnforgotPassword;
    
     //~~~~~~~~~~~~~~ Connection Variables ~~~~~~~~~~~
     NSString *msgTitle;
    
    //Forgot Password Popup
    
    IBOutlet UIView *viewForgotPassword;
    IBOutlet UITextField *txtFieldForgotPassword;
    IBOutlet UIView *viewpopupShade;
    
    IBOutlet UIButton *btnPopupShade;
    
    // checking login/forgot Password View
    BOOL isBeingShown;
}

@property (strong, nonatomic) IBOutlet UITextField *txtFldUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtFldPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
- (IBAction)btnActionPopupShade:(id)sender;
- (IBAction)btnLoginAction:(id)sender;
- (IBAction)btnAction_forgotPassword:(id)sender;

//Forgot Password Popup
- (IBAction)btnAction_SendForgotPasswordEmail:(id)sender;
- (IBAction)btnAction_CancelForgotPasswordPopup:(id)sender;


- (IBAction)btnAction_GmailConnect:(id)sender;
- (IBAction)btnAction_Glorg:(id)sender;

@end
