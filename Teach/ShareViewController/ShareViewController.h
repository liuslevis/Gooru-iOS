//
//  ShareViewController.h
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
#import <MessageUI/MessageUI.h>


@interface ShareViewController : UIViewController<MFMailComposeViewControllerDelegate>{
    
    
    IBOutlet UIView *viewPopup;
    
    IBOutlet UILabel *lblShareHeading;
    
    IBOutlet UIButton *btnShareFacebook;
    IBOutlet UIButton *btnShareTwitter;
    IBOutlet UIButton *btnShareEmail;
    
}
- (IBAction)btnActionShareFacebook:(id)sender;
- (IBAction)btnActionShareTwitter:(id)sender;
- (IBAction)btnActionShareEmail:(id)sender;

- (IBAction)btnActionClosePopup:(id)sender;



- (id)initToShareCollection:(BOOL)value withDetails:(NSMutableDictionary*)dictIncomingDetails shouldOccupyFullScreen:(BOOL)value1;

- (void)closeSharePopup;


@end