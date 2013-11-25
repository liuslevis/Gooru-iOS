//
//  EditAssignmentPopupViewController.m
// Gooru
//
//  Created by Gooru on 8/13/13.
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


#import "EditAssignmentPopupViewController.h"
#import "NSString_stripHtml.h"

#define TAG_ASSIGNMENT_TITLE 13
#define TAG_ASSIGNMENT_DIRECTION 26
#define TAG_ASSIGNMENT_DUEDATE 39
#define TAG_ASSIGNMENT_DIRECTION_HELPER 65


#define TAG_POPUP_EDITASSIGNMENT 99999


@interface EditAssignmentPopupViewController ()

@end

@implementation EditAssignmentPopupViewController
@synthesize flatDatePicker;
@synthesize isYourFirstClasspageEAP;

@synthesize txtFieldEditAssignmentTitle;
@synthesize txtViewEditAssignmentDirection;
@synthesize btnEditAssignmentDueDate;
@synthesize viewEditAssignmentDatePickerParent;
@synthesize lblEditAssignmentDueDate;
@synthesize btnEditAssignmentSave;

AppDelegate *appDelegate;
NSString* sessionTokenEditAssignmentPopup;
NSUserDefaults* standardUserDefaults;

UIView* viewPopupEditAssignment;

NSString* currentAssignmentIdBeingEdited;
UIView* currentAssignmentViewBeingEdited;
UIButton* btnCurrentAssignmentBeingEdited;

NSMutableDictionary* dictAssignment;

#pragma mark - Init and View Lifecycle -
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithAssignmentDetails:(NSMutableDictionary*)dictIncomingAssignment{
    
    NSLog(@"dictAssignment : %@",dictIncomingAssignment);
    
    dictAssignment = dictIncomingAssignment;
    
    appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    sessionTokenEditAssignmentPopup  = [standardUserDefaults stringForKey:@"token"];
    
        
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.flatDatePicker = [[FlatDatePicker alloc] initWithParentView:viewEditAssignmentDatePickerParent];
    self.flatDatePicker.delegate = self;
    self.flatDatePicker.title = @"Select your Due Date";
    
    currentAssignmentIdBeingEdited = [dictAssignment valueForKey:@"AssignmentId"];
    currentAssignmentViewBeingEdited = (UIView*)[dictAssignment valueForKey:@"AssignmentView"];
    
    btnCurrentAssignmentBeingEdited = (UIButton*)[dictAssignment valueForKey:@"btnAssignment"];
    
    [btnCurrentAssignmentBeingEdited sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    [txtFieldEditAssignmentTitle setText:[dictAssignment valueForKey:@"AssignmentTitle"]];
    txtFieldEditAssignmentTitle.delegate = self;
    
    [lblEditAssignmentDueDate setText:[dictAssignment valueForKey:@"AssignmentDueDate"]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    [self.flatDatePicker setDate:[dateFormatter dateFromString:[dictAssignment valueForKey:@"AssignmentDueDate"]] animated:NO];


    [txtViewEditAssignmentDirection setText:[dictAssignment valueForKey:@"AssignmentDirection"]];
    if ([txtViewEditAssignmentDirection.text isEqualToString:@"NA"]) {
        [txtViewEditAssignmentDirection setText:@""];
    }
    
    txtViewEditAssignmentDirection.delegate = self;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BA Due Date Picker -
- (IBAction)btnActionEditAssignmentDueDatePicker:(id)sender{
    
    if (![btnEditAssignmentDueDate isSelected]) {
        [btnEditAssignmentDueDate setSelected:TRUE];
        [btnEditAssignmentSave setEnabled:FALSE];
        
        [self animateView:viewEditAssignmentDatePickerParent forFinalFrame:CGRectMake(viewEditAssignmentDatePickerParent.frame.origin.x, viewEditAssignmentDatePickerParent.frame.origin.y, viewEditAssignmentDatePickerParent.frame.size.width, self.flatDatePicker.frame.size.height)];
    }else{
        
        
    }
    
    
}

#pragma mark - FlatDatePicker Delegate -

- (void)flatDatePicker:(FlatDatePicker*)datePicker dateDidChange:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    NSString *value = [dateFormatter stringFromDate:date];
    
    
    lblEditAssignmentDueDate.text = value;
    
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didCancel:(UIButton*)sender {
    
    [btnEditAssignmentDueDate setSelected:FALSE];
    [self animateView:viewEditAssignmentDatePickerParent forFinalFrame:CGRectMake(viewEditAssignmentDatePickerParent.frame.origin.x, viewEditAssignmentDatePickerParent.frame.origin.y, viewEditAssignmentDatePickerParent.frame.size.width, btnEditAssignmentDueDate.frame.size.height)];
    [lblEditAssignmentDueDate setText:@"Choose your Due Date"];
    [btnEditAssignmentSave setEnabled:TRUE];
    
}

- (void)flatDatePicker:(FlatDatePicker*)datePicker didValid:(UIButton*)sender date:(NSDate*)date {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
    NSDate *today = [cal dateFromComponents:components];
    components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:date];
    NSDate *chosenDate = [cal dateFromComponents:components];
    
    NSComparisonResult result = [today compare:chosenDate];
    
    
    if(result==NSOrderedDescending||result==NSOrderedSame){
        NSLog(@"chosenDate is in the past");
        [viewEditAssignmentPopup makeToast:@"Please select a date in the future" duration:2.0 pointPosition:CGPointMake(btnEditAssignmentDueDate.frame.origin.x, btnEditAssignmentDueDate.frame.origin.y)];
    }
    else{
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //            [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString *value = [dateFormatter stringFromDate:date];
        lblEditAssignmentDueDate.text = value;
        
        [btnEditAssignmentDueDate setSelected:FALSE];
        [btnEditAssignmentSave setEnabled:TRUE];
        [self animateView:viewEditAssignmentDatePickerParent forFinalFrame:CGRectMake(viewEditAssignmentDatePickerParent.frame.origin.x, viewEditAssignmentDatePickerParent.frame.origin.y, viewEditAssignmentDatePickerParent.frame.size.width, btnEditAssignmentDueDate.frame.size.height)];
        
    }
    
}


#pragma mark - BA Save/Cancel -
- (IBAction)btnActionEditAssignmentSave:(id)sender{
    
    
    //Validation
    BOOL areAllRequiredFieldsPopulated = TRUE;
    
    //Validate Assignment Title
    if ([txtFieldEditAssignmentTitle.text isEqualToString:@""]) {
        
        [viewEditAssignmentPopup makeToast:@"Please provide a Title" duration:2.0 pointPosition:CGPointMake(txtFieldEditAssignmentTitle.frame.origin.x, txtFieldEditAssignmentTitle.frame.origin.y+2)];
        areAllRequiredFieldsPopulated = FALSE;
    }
    
    //Validate Assignment Duedate
    
    if ([lblEditAssignmentDueDate.text isEqualToString:@"Choose your Due Date"]) {
        
        [viewEditAssignmentPopup makeToast:@"Please select a date in the future" duration:2.0 pointPosition:CGPointMake(btnEditAssignmentDueDate.frame.origin.x, btnEditAssignmentDueDate.frame.origin.y+1)];
        areAllRequiredFieldsPopulated = FALSE;
        
    }else{
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSDate *dateSelected = [dateFormatter dateFromString:lblEditAssignmentDueDate.text];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:(NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit) fromDate:dateSelected];
        NSDate *chosenDate = [cal dateFromComponents:components];
        
        NSComparisonResult result = [today compare:chosenDate];
        
        if(result==NSOrderedDescending||result==NSOrderedSame){
            NSLog(@"chosenDate is in the past");
            lblEditAssignmentDueDate.text=@"";
            //viewPopupEditAssignment
            [viewEditAssignmentPopup makeToast:@"Please select a date in the future" duration:2.0 pointPosition:CGPointMake(btnEditAssignmentDueDate.frame.origin.x, btnEditAssignmentDueDate.frame.origin.y+1)];
            areAllRequiredFieldsPopulated = FALSE;
        }
        
    }
    
    
    if (txtFieldEditAssignmentTitle.text.length >= 50) {
        
        areAllRequiredFieldsPopulated = FALSE;
        [self.view makeToast:@"Please reduce the number of characters in the Assignment title" duration:3.0 pointPosition:CGPointMake(viewEditAssignmentPopup.frame.origin.x+5, viewEditAssignmentPopup.frame.origin.y+200)];
        
    }
    
    if (txtViewEditAssignmentDirection.text.length >= 400) {
        
           areAllRequiredFieldsPopulated = FALSE;
        [self.view makeToast:@"Please reduce the number of characters" duration:3.0 pointPosition:CGPointMake(viewEditAssignmentPopup.frame.origin.x+5, viewEditAssignmentPopup.frame.origin.y+200)];

    }
    
    if (areAllRequiredFieldsPopulated) {
        if (isYourFirstClasspageEAP) {
            
           
            UILabel* lblAssignmentTitleBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_TITLE];
            [lblAssignmentTitleBeingEdited setText:txtFieldEditAssignmentTitle.text];
            lblAssignmentTitleBeingEdited.frame = [appDelegate getWLabelFrameForLabel:lblAssignmentTitleBeingEdited withString:lblAssignmentTitleBeingEdited.text];
            
            //Set Duedate
            UILabel* lblAssignmentDuedateBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_DUEDATE];
            if ([lblAssignmentDuedateBeingEdited isHidden]) {
                lblAssignmentDuedateBeingEdited.hidden=FALSE;
            }
            
            [lblAssignmentDuedateBeingEdited setText:[NSString stringWithFormat:@"Due Date: %@",lblEditAssignmentDueDate.text]];
            
            
            //Set Direction
            UILabel* lblAssignmentDirectionBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_DIRECTION];
            if ([lblAssignmentDirectionBeingEdited isHidden]) {
                lblAssignmentDirectionBeingEdited.hidden=FALSE;
            }

            [lblAssignmentDirectionBeingEdited setText:txtViewEditAssignmentDirection.text];
            lblAssignmentDirectionBeingEdited.frame = [appDelegate getHLabelFrameForLabel:lblAssignmentDirectionBeingEdited withString:lblAssignmentDirectionBeingEdited.text];
            [btnEditAssignmentCancel sendActionsForControlEvents:UIControlEventTouchUpInside];
        }else{
            [self connectionEditAssignment];
        }
    }
    
    
}

- (IBAction)btnActionEditAssignmentCancel:(id)sender{
    
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeCurrentDetailViewController) withObject:nil afterDelay:0.3];
    
   
    
}

#pragma mark - Connection Methods -
- (void)connectionEditAssignment{
    
    NSURL *url = [NSURL URLWithString:[appDelegate getValueByKey:@"ServerURL"]];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableArray* parameterKeys = [NSMutableArray arrayWithObjects:@"data", nil];
    
    NSString* assignmentDirection = txtViewEditAssignmentDirection.text;
    NSString *strippedContent = [assignmentDirection stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSCharacterSet *doNotWant = [NSCharacterSet characterSetWithCharactersInString:@"\\\n"];
    strippedContent = [[strippedContent componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
    strippedContent = [strippedContent  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
   
    NSLog(@"strippedContent : %@", strippedContent);

    NSString* strFields = [NSString stringWithFormat:@"{\"task\":{\"title\":\"%@\",\"status\":\"open\",\"description\":\"%@\"},\"plannedEndDate\":\"%@\"}",txtFieldEditAssignmentTitle.text,strippedContent,lblEditAssignmentDueDate.text];
    
	NSMutableArray* parameterValues =  [NSMutableArray arrayWithObjects:strFields, nil];
	NSMutableDictionary* dictPostParams = [NSMutableDictionary dictionaryWithObjects:parameterValues forKeys:parameterKeys];
    
    httpClient.parameterEncoding = AFJSONParameterEncoding;
    
    [httpClient putPath:[NSString stringWithFormat:@"/gooruapi/rest/v2/assignment/%@?sessionToken=%@",currentAssignmentIdBeingEdited, sessionTokenEditAssignmentPopup] parameters:dictPostParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"updateClasspage Response : %@",responseStr);
        
        NSArray *results = [responseStr JSONValue];
        
        
        //Set Title
        UILabel* lblAssignmentTitleBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_TITLE];
        [lblAssignmentTitleBeingEdited setText:[results valueForKey:@"title"]];
        lblAssignmentTitleBeingEdited.frame = [appDelegate getWLabelFrameForLabel:lblAssignmentTitleBeingEdited withString:lblAssignmentTitleBeingEdited.text];
        
        //Set Duedate
        UILabel* lblAssignmentDuedateBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_DUEDATE];
        
        NSDate *plannedEndDate = [NSDate dateWithTimeIntervalSince1970:(([[results valueForKey:@"plannedEndDate"] doubleValue])/ 1000)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        NSString* strPlannedEndDate = [dateFormatter stringFromDate:plannedEndDate];
        
        [lblAssignmentDuedateBeingEdited setText:[NSString stringWithFormat:@"Due Date: %@",strPlannedEndDate]];
        
        if ([lblAssignmentDuedateBeingEdited isHidden]) {
            [lblAssignmentDuedateBeingEdited setHidden:FALSE];
             
        }
        
        
        //Set Direction
        UILabel* lblAssignmentDirectionBeingEdited = (UILabel*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_DIRECTION];
        [lblAssignmentDirectionBeingEdited setText:[[results valueForKey:@"description"] stripHtml]];
        if (![[results valueForKey:@"description"] isEqualToString:@""]) {
            if ([lblAssignmentDirectionBeingEdited isHidden]) {
                [lblAssignmentDirectionBeingEdited setHidden:FALSE];
                
                UIImageView* imgViewAssignmentDirectionHelper = (UIImageView*)[currentAssignmentViewBeingEdited viewWithTag:TAG_ASSIGNMENT_DIRECTION_HELPER];
                if ([imgViewAssignmentDirectionHelper isHidden]) {
                    [imgViewAssignmentDirectionHelper setHidden:FALSE];
                }
            }
        }
        
        lblAssignmentDirectionBeingEdited.frame = [appDelegate getHLabelFrameForLabel:lblAssignmentDirectionBeingEdited withString:lblAssignmentDirectionBeingEdited.text];
        
        NSDictionary* dictReturn = [[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%i",TAG_POPUP_EDITASSIGNMENT], @"PopupTag", nil];
        
        NSLog(@"dictReturn : %@",[dictReturn description]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationEditAssignmentReturn" object:self userInfo:dictReturn];
        [btnEditAssignmentCancel sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"[HTTPClient Error]: %@", [error description]);
        [viewEditAssignmentPopup makeToast:@"Oh No! Something went wrong. Please check the text and retry again!!" duration:2.0 pointPosition:CGPointMake(viewEditAssignmentDatePickerParent.frame.origin.x-35, viewEditAssignmentDatePickerParent.frame.origin.y+10)];

        
    }];
    
}



#pragma mark - Animate View -
- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
}

#pragma mark - BA Popup Shade -
- (IBAction)btnActionPopupShade:(id)sender {
    
    [btnEditAssignmentCancel sendActionsForControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Remove ViewController -

- (void)removeCurrentDetailViewController{
    
    [btnCurrentAssignmentBeingEdited sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}



#pragma mark - UITextField delegates -


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int allowedLength;
    switch(textField.tag) {
        case 1:
            allowedLength = 50;      // triggered for input fields with tag = 1
            break;
        case 2:
            allowedLength = 400;   // triggered for input fields with tag = 2
            break;
        default:
            allowedLength = 700;   // length default when no tag (=0) value =255
            break;
    }
    
    if (textField.text.length >= allowedLength && range.length == 0) {
        return NO; // Change not allowed
    } else {
        return YES; // Change allowed
    }
}

#pragma mark - UITextView delegates -

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    int allowedLength;
    switch(textView.tag) {
        case 1:
            allowedLength = 50;      // triggered for input fields with tag = 1
            break;
        case 2:
            allowedLength = 400;   // triggered for input fields with tag = 2
            break;
        default:
            allowedLength = 700;   // length default when no tag (=0) value =255
            break;
    }
    
    if (textView.text.length >= allowedLength && range.length == 0) {
         [self.view makeToast:@"Character limit reached!" duration:3.0 pointPosition:viewEditAssignmentPopup.center];
        return NO; // Change not allowed
    } else {
        return YES; // Change allowed
    }
}


#pragma mark - KeyBoard delegates -

- (void) keyboardDidShow: (NSNotification *)notif {
    
    [self animateView:viewEditAssignmentPopup forFinalFrame:CGRectMake(viewEditAssignmentPopup.frame.origin.x, viewEditAssignmentPopup.frame.origin.y - 160, viewEditAssignmentPopup.frame.size.width, viewEditAssignmentPopup.frame.size.height)];

    
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    [self animateView:viewEditAssignmentPopup forFinalFrame:CGRectMake(viewEditAssignmentPopup.frame.origin.x, viewEditAssignmentPopup.frame.origin.y + 160, viewEditAssignmentPopup.frame.size.width, viewEditAssignmentPopup.frame.size.height)];
    
}
@end
