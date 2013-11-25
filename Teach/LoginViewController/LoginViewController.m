//
//  LoginViewController.m
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

#import "LoginViewController.h"
#import "MainClasspageViewController.h"
#import "SVWebViewController.h"


#define MAX_LENGTH 10
#define TAG_FORGOT_PASSWORD_POPUP 8975
@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize txtFldPassword;
@synthesize txtFldUsername;
@synthesize btnLogin;


//Login info
NSString* userName;
NSString* password;
NSString* forgotPasswordEmailId;
bool isGmailConnect = FALSE;
NSUserDefaults *standardUserDefaults;

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
    [super viewDidLoad];
    
     appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    [standardUserDefaults setObject:@"NA" forKey:@"gmailtoken"];

    txtFldUsername.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtFldPassword.clearButtonMode = UITextFieldViewModeWhileEditing;
    txtFldUsername.delegate = self;
    txtFldPassword.delegate = self;
    // Do any additional setup after loading the view from its nib.
}


- (void) viewWillAppear:(BOOL)animated {
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
    
  
        if ([[standardUserDefaults valueForKey:@"gmailtoken"] isEqualToString:@"NA"]) {
            viewForgotPassword.frame=CGRectMake(1024, 239, viewForgotPassword.frame.size.width, viewForgotPassword.frame.size.height);
            viewLogin.frame=CGRectMake(230, 60, viewLogin.frame.size.width, viewLogin.frame.size.height);
            [self.view addSubview:viewForgotPassword];
            [self.view addSubview:viewLogin];
        }else{
            if (isGmailConnect) {
            [appDelegate showLibProgressOnView:self.view andMessage:@""];
            [self getUserInfo];

        }
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions -


- (IBAction)btnActionPopupShade:(id)sender {
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeLoginViewController) withObject:nil afterDelay:0.3];
}

- (IBAction)btnLoginAction:(id)sender {
    
    
    NSString* tempUsername = txtFldUsername.text;
    NSString *trimmedString = [tempUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    userName = trimmedString;
    NSString* tempPassword = txtFldPassword.text;
    NSString *trimmedStringPassword = [tempPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRangePassword = [trimmedStringPassword rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    password = trimmedStringPassword;
    if (whiteSpaceRange.location != NSNotFound || whiteSpaceRangePassword.location != NSNotFound) {
        NSLog(@"Found whitespace");
        [self login_AlertShow:[appDelegate getValueByKey:@"EmptyEmailID"]];
    }else{
        
        if([txtFldUsername.text isEqualToString:@""] || txtFldUsername.text == nil)
        {
            [self login_AlertShow:[appDelegate getValueByKey:@"EmptyEmailID"]];
            return;
        }else if ([txtFldPassword.text isEqualToString:@""] || txtFldPassword.text == nil) {
            [self login_AlertShow:[appDelegate getValueByKey:@"EmptyPassword"]];
            return;
        }else {
            [self login];
        }
    }
    [txtFldUsername resignFirstResponder];
    [txtFldPassword resignFirstResponder];
}

- (IBAction)btnAction_forgotPassword:(id)sender {
    
    [self managePopup];
}

- (IBAction)btnAction_SendForgotPasswordEmail:(id)sender {
    
    NSString* tempUsername = txtFieldForgotPassword.text;
    NSString *trimmedString = [tempUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    forgotPasswordEmailId = trimmedString;
    if (whiteSpaceRange.location != NSNotFound) {
        NSLog(@"Found whitespace");
        [self login_AlertShow:[appDelegate getValueByKey:@"EmptyEmailID"]];
    }else{
        
        if([forgotPasswordEmailId isEqualToString:@""] || forgotPasswordEmailId == nil || [forgotPasswordEmailId isEqualToString:@" "])
        {
            [self login_AlertShow:@"Please enter a Username or Email"];
            
        }else{
            [self sendforgotPasswordEmail:forgotPasswordEmailId];
            
        }
    }
}


- (IBAction)btnAction_CancelForgotPasswordPopup:(id)sender {
    [self managePopup];
    
}

- (IBAction)btnAction_GmailConnect:(id)sender {
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:[NSNumber numberWithBool:TRUE] forKey:@"isLoggedIn"];
       isGmailConnect = TRUE;
  
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[appDelegate getValueByKey:@"GoogleSignInURL"]];
    [self presentModalViewController:webViewController animated:YES];
    
}

- (IBAction)btnAction_Glorg:(id)sender {
    
    SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:@"http://www.goorulearning.org/#discover"];
    [self presentModalViewController:webViewController animated:YES];

}


#pragma mark - KeyBoard delegates -

- (void) keyboardDidShow: (NSNotification *)notif {
    NSLog(@"keyboardDidShow : %f",viewLogin.frame.origin.y);

    if (viewLogin.frame.origin.y!=60) {
        
    }else{
      
    [self animateView:viewLogin forFinalFrame:CGRectMake(viewLogin.frame.origin.x, viewLogin.frame.origin.y - 160, viewLogin.frame.size.width, viewLogin.frame.size.height)];
   
     [self animateView:viewForgotPassword forFinalFrame:CGRectMake(viewForgotPassword.frame.origin.x, viewForgotPassword.frame.origin.y - 160, viewForgotPassword.frame.size.width, viewForgotPassword.frame.size.height)];
    }
    
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    NSLog(@"keyboardDidHide : %f",viewLogin.frame.origin.y);
    if (viewLogin.frame.origin.y!=-100) {
        
    }else{
    
        [self animateView:viewLogin forFinalFrame:CGRectMake(viewLogin.frame.origin.x, viewLogin.frame.origin.y + 160, viewLogin.frame.size.width, viewLogin.frame.size.height)];
      
        [self animateView:viewForgotPassword forFinalFrame:CGRectMake(viewForgotPassword.frame.origin.x, viewForgotPassword.frame.origin.y + 160, viewForgotPassword.frame.size.width, viewForgotPassword.frame.size.height)];
  
    }
    
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

#pragma mark - Textfield delegates -

- (BOOL) textFieldShouldBeginEditing:(UITextField*)textField {
    activeField = textField;
    if([txtFldPassword.text isEqualToString:@""] || txtFldPassword.text == nil)
    {
        btnforgotPassword.hidden = FALSE;
        
    }else{
        btnforgotPassword.hidden = TRUE;
        
    }
    return YES;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    if (textField==txtFldPassword){
        
        NSString* tempUsername = txtFldUsername.text;
        NSString *trimmedString = [tempUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSRange whiteSpaceRange = [trimmedString rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        userName = trimmedString;
        NSString* tempPassword = txtFldPassword.text;
        NSString *trimmedStringPassword = [tempPassword stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSRange whiteSpaceRangePassword = [trimmedStringPassword rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        password = trimmedStringPassword;
        if (whiteSpaceRange.location != NSNotFound || whiteSpaceRangePassword.location != NSNotFound) {
            NSLog(@"Found whitespace");
            [self login_AlertShow:[appDelegate getValueByKey:@"EmptyEmailID"]];
        }else{
            
            if([txtFldUsername.text isEqualToString:@""] || txtFldUsername.text == nil)
            {
                [self login_AlertShow:[appDelegate getValueByKey:@"EmptyEmailID"]];
                
            }else if ([txtFldPassword.text isEqualToString:@""] || txtFldPassword.text == nil) {
                [self login_AlertShow:[appDelegate getValueByKey:@"EmptyPassword"]];
            }else {
                [self login];
            }
        }
        [txtFldPassword resignFirstResponder];
    }else  if (textField==txtFldUsername){
        [textField resignFirstResponder];
        [self.txtFldPassword becomeFirstResponder];
    }
    return TRUE;
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == txtFldPassword){
        btnforgotPassword.hidden = TRUE;
        if ([string isEqualToString:@"\n"]) {
            [textField resignFirstResponder];
            [self login];
        }
    }
    return TRUE;
}

#pragma mark - Alerts -

- (void)login_AlertShow:(NSString *)strMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}

- (void)forgotPassword_AlertShow:(NSString *)strMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msgTitle message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert setTag:TAG_FORGOT_PASSWORD_POPUP];
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView tag]==TAG_FORGOT_PASSWORD_POPUP) {
        [self removeLoginViewController];
    }else{
        
    }
    
}
#pragma mark - Connection Classes -
#pragma mark login

- (void)login{
    
    [appDelegate showLibProgressOnView:self.view andMessage:@""];
    
    NSArray* parameterKeys = [NSArray arrayWithObjects:@"userName",@"password",@"apiKey", nil];
    NSArray* parameterValues = [NSArray arrayWithObjects:userName, password, [appDelegate getValueByKey:@"APIKey"], nil];
    
    NSDictionary* dictPostParams = [NSDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/account/signin.json?"] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"login Response : %@",responseStr);
        [appDelegate removeLibProgressView:self.view];
        [self parseUserInformation:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [appDelegate removeLibProgressView:self.view];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        
        
    }];
}
- (void)parseUserInformation:(NSString*)responseString{
    
    NSString *gooruUId=@"";
    NSString *username=@"";
    NSString *firstName = @"";
	NSString *lastName=@"";
	NSString *emailId=@"";
    NSString *token=@"";
    NSString *registerToken=@"";
    NSString *usernameDisplay=@"";
    NSString *userRoleSetString=@"";
    NSString *confirmStatus=@"";
    
    NSString *description = @"";
    NSString *name = @"";
    NSString *class = @"";
    NSString *roleId = @"";
    
	//Convert responseData to readable string
    if ([responseString hasPrefix:@"error:"]){
        
        responseString = [responseString stringByReplacingOccurrencesOfString:@"error:" withString:@""];
        [self login_AlertShow:responseString];
    }else if ([responseString isEqualToString:@""] || [responseString isEqualToString:@"(null)"] || [responseString isEqualToString:@"nil"]){
        [self login_AlertShow:@"Unable to connect to Gooru."];
        return;
    }else{
        //Convert json response string to JSON object
        NSDictionary *results = [responseString JSONValue];
        
        NSLog(@"results : %@", [results description]);
        
        // create a standardUserDefaults variable
        standardUserDefaults = [NSUserDefaults standardUserDefaults];

        
        lastName		= [NSString stringWithFormat:@"%@", [results objectForKey:@"lastName"]];
        emailId         = [NSString stringWithFormat:@"%@", [results objectForKey:@"emailId"]];
        
        if (isGmailConnect) {
            token           = [NSString stringWithFormat:@"%@", [standardUserDefaults valueForKey:@"gmailtoken"]];

                    }else{
            token           = [NSString stringWithFormat:@"%@", [results objectForKey:@"token"]];
        }
        
        gooruUId        = [NSString stringWithFormat:@"%@", [results objectForKey:@"gooruUId"]];
        firstName       = [NSString stringWithFormat:@"%@", [results objectForKey:@"firstName"]];
        
        NSDictionary *userRole = [NSDictionary dictionaryWithDictionary:[results objectForKey:@"userRole"]];
        
        description     = [NSString stringWithFormat:@"%@", [userRole objectForKey:@"description"]];
        name            = [NSString stringWithFormat:@"%@", [userRole objectForKey:@"name"]];
        class           = [NSString stringWithFormat:@"%@", [userRole objectForKey:@"class"]];
        roleId           = [NSString stringWithFormat:@"%@", [userRole objectForKey:@"roleId"]];
        
        
        confirmStatus   =[NSString stringWithFormat:@"%@", [results objectForKey:@"confirmStatus"]];;
        registerToken   =[NSString stringWithFormat:@"%@", [results objectForKey:@"registerToken"]];
        username        =[NSString stringWithFormat:@"%@", [results objectForKey:@"username"]];
        userRoleSetString   =[NSString stringWithFormat:@"%@", [results objectForKey:@"userRoleSetString"]];
        usernameDisplay =[NSString stringWithFormat:@"%@", [results objectForKey:@"usernameDisplay"]];
        
        NSString *url = [NSString stringWithFormat:@"http://profile-demo.s3.amazonaws.com/profile-prod/%@-158x158.png",gooruUId];
        
        NSURL *linkUrl = [NSURL URLWithString:url];
        
        NSData *dataImage = [NSData dataWithContentsOfURL:linkUrl];
        
        //    NSLog(@"dataImage :%@ ",dataImage);
        
        if (dataImage == (NULL)){
            
            UIImage *img = [UIImage imageNamed:@"Exam_2x.png"];
            dataImage = UIImagePNGRepresentation(img);
        }
        
        //Store User information in Standard Defaults
        
               
        [standardUserDefaults setObject:[NSNumber numberWithBool:TRUE] forKey:@"isLoggedIn"];
        
        [standardUserDefaults setObject:lastName forKey:@"lastName"];
        [standardUserDefaults setObject:token forKey:@"token"];
        [standardUserDefaults setObject:gooruUId forKey:@"gooruUId"];
        [standardUserDefaults setObject:firstName forKey:@"firstName"];
        [standardUserDefaults setObject:username forKey:@"username"];
        [standardUserDefaults setObject:usernameDisplay forKey:@"usernameDisplay"];
        [standardUserDefaults setObject:dataImage forKey:@"dataImage"];
        
        
        MainClasspageViewController *mainClasspageViewController=(MainClasspageViewController *)self.parentViewController;
        
        [btnPopupShade sendActionsForControlEvents:UIControlEventTouchUpInside];
        NSLog(@"MainClasspageViewController : %@",mainClasspageViewController);

        txtFldUsername.text = @"";
        txtFldPassword.text = @"";
        [mainClasspageViewController onLogin];
        isGmailConnect = FALSE;

        //[mainClasspageViewController ]
      
    }
    
    
    
}

#pragma mark gmail Connect

- (void)getUserInfo{

    NSString *strURL = [NSString stringWithFormat:@"%@/gooruapi/rest/usertoken/user?sessionToken=%@",[appDelegate getValueByKey:@"ServerURL"],[standardUserDefaults valueForKey:@"gmailtoken"]];

    NSLog(@"StrURL : %@",strURL);
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient getPath:[NSString stringWithFormat:@"%@/gooruapi/rest/usertoken/user?sessionToken=%@",[appDelegate getValueByKey:@"ServerURL"],[standardUserDefaults valueForKey:@"gmailtoken"]] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        [appDelegate removeLibProgressView:self.view];
        [self parseUserInformation:responseStr];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
    }];    
    
}

#pragma mark - Manage UI -

#pragma mark Manage Popups
- (void)managePopup{
    
    
    if (!isBeingShown) {
        
        isBeingShown = TRUE;
        
        [self animateView:viewLogin forFinalFrame:CGRectMake(-1000,viewLogin.frame.origin.y, viewLogin.frame.size.width, viewLogin.frame.size.height)];
        [self animateView:viewForgotPassword forFinalFrame:CGRectMake(237, viewForgotPassword.frame.origin.y, viewForgotPassword.frame.size.width, viewForgotPassword.frame.size.height)];
        [txtFieldForgotPassword setText:@""];

    }else{
        
        isBeingShown = FALSE;
        [self animateView:viewForgotPassword forFinalFrame:CGRectMake(1024, viewForgotPassword.frame.origin.y, viewForgotPassword.frame.size.width, viewForgotPassword.frame.size.height)];
        [self animateView:viewLogin forFinalFrame:CGRectMake(284, viewLogin.frame.origin.y, viewLogin.frame.size.width, viewLogin.frame.size.height)];
        
  
    }

    
}

#pragma mark Forgot Password Email
- (void)sendforgotPasswordEmail:(NSString*)emailId{
    
    [appDelegate showLibProgressOnView:self.view andMessage:@""];
    
    NSArray* parameterKeys = [NSArray arrayWithObjects:@"sessionToken",@"emailId",@"gooruClassicUrl",nil];
    NSArray* parameterValues = [NSArray arrayWithObjects:[standardUserDefaults stringForKey:@"defaultGooruSessionToken"],emailId,@"http://www.goorulearning.org/#discover", nil];
    
    NSDictionary* dictPostParams = [NSDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient postPath:[NSString stringWithFormat:@"/gooruapi/rest/user/password/reset.json?"] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"sendforgotPasswordEmail Response : %@",responseStr);
        [appDelegate removeLibProgressView:self.view];
        
        NSRange range = [responseStr rangeOfString:@"gooruUid"];
        if(range.location == NSNotFound)
        {
            NSArray *results = [responseStr JSONValue];
            [self forgotPassword_AlertShow:[results valueForKey:@"error"]];
        }else{
            [self forgotPassword_AlertShow:@"Success! An email has been sent with instructions on how to reset your password.Please contact support@goorulearning.org if you run into any issues."];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [appDelegate removeLibProgressView:self.view];
        NSLog(@"[HTTPClient Error]: %@", error.localizedDescription);
        [self forgotPassword_AlertShow:error.localizedDescription];
        
        
    }];
    
}

#pragma mark  Remove Child View controller

- (void)removeLoginViewController{
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}

@end
