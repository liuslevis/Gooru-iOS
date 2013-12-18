//
//  EditAssignmentPopupViewController.h
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
#import <Foundation/Foundation.h>
#import "Toast+UIView.h"
#import "AppDelegate.h"
#import "FlatDatePicker.h"
#import "AFHTTPClient.h"

@interface EditAssignmentPopupViewController : UIViewController<FlatDatePickerDelegate,UITextFieldDelegate,UITextViewDelegate>{
    
    IBOutlet UIView *viewEditAssignmentPopup;
    //Edit Assignment Popup
    IBOutlet UITextField *txtFieldEditAssignmentTitle;
    IBOutlet UITextView *txtViewEditAssignmentDirection;
    IBOutlet UIButton *btnEditAssignmentDueDate;
    IBOutlet UIView *viewEditAssignmentDatePickerParent;
    IBOutlet UILabel *lblEditAssignmentDueDate;
    IBOutlet UIButton *btnEditAssignmentSave;
    
    IBOutlet UIButton *btnEditAssignmentCancel;
    
    FlatDatePicker *flatDatePicker;

}
@property BOOL isYourFirstClasspageEAP;

@property (nonatomic, strong) FlatDatePicker *flatDatePicker;

@property (nonatomic, strong) IBOutlet UITextField *txtFieldEditAssignmentTitle;
@property (nonatomic, strong) IBOutlet UITextView *txtViewEditAssignmentDirection;
@property (nonatomic, strong) IBOutlet UIButton *btnEditAssignmentDueDate;
@property (nonatomic, strong) IBOutlet UIView *viewEditAssignmentDatePickerParent;
@property (nonatomic, strong) IBOutlet UILabel *lblEditAssignmentDueDate;
@property (nonatomic, strong) IBOutlet UIButton *btnEditAssignmentSave;

//Edit Assignment Popup
- (IBAction)btnActionEditAssignmentDueDatePicker:(id)sender;
- (IBAction)btnActionEditAssignmentSave:(id)sender;
- (IBAction)btnActionEditAssignmentCancel:(id)sender;

//Init
- (id)initWithAssignmentDetails:(NSMutableDictionary*)dictAssignment;

- (IBAction)btnActionPopupShade:(id)sender;

@end
