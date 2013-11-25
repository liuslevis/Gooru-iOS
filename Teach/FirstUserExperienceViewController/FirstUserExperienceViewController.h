//
//  FirstUserExperienceViewController.h
// Gooru
//
//  Created by Gooru on 8/16/13.
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

@interface FirstUserExperienceViewController : UIViewController{
    NSString *stringCheckingFUE;
}
@property (strong, nonatomic) IBOutlet UIView *viewFirstUser;
@property (strong, nonatomic) IBOutlet UIView *viewStudyExperience;
@property (strong, nonatomic) IBOutlet UIView *viewAssignHW;
@property (strong, nonatomic) IBOutlet UIView *viewForGestureInFirstUser;
@property (strong, nonatomic) IBOutlet UIView *viewForGestureInStudyExperience;
@property (strong, nonatomic) IBOutlet UIView *viewForGestureInAssignHW;
@property (strong, nonatomic) IBOutlet UIView *viewFUEforOther;
@property (strong, nonatomic) IBOutlet UIView *viewFUEforTeach;
@property (strong, nonatomic) IBOutlet UIView *viewFUEforStudy;
@property (strong, nonatomic) IBOutlet UITextField *textFieldClassCode;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreenHighlightFirstUser;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreenHighlightStudyExp;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreenHighlightAssignHW;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreyHighlightFirstUser;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreyHighlightStudyExp;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewGreyHighlightAssignHW;

- (IBAction)btnActionStarterClasspages:(id)sender;
- (IBAction)btnActionSignup:(id)sender;
- (id)initWithCheckingStringForFUE:(NSString *)checkingString;
@end