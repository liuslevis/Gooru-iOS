//
//  AppDelegate.h
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
#import "MBProgressHUD.h"
#import "JSON.h"
#import "MainClasspageViewController.h"


@class MainClasspageViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) MainClasspageViewController *viewController;

@property (nonatomic, assign) UIView *progressHUDSuperview;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

- (void)showLibProgressOnView:(UIView *)pView andMessage:(NSString *) message;
- (void)removeLibProgressView:(UIView *)pView;
- (void)logMixpanelforevent:(NSString*)eventTitle and:(NSMutableDictionary*)properties;

#pragma mark - Display resource type icon -
- (UIImage*) imageForResourceType:(NSString*)type;

#pragma mark Get from pList
-(NSString*) getValueByKey:(NSString*)key;

#pragma mark - Create Sorted Array for Dictionary Integer Keys
-(NSArray*)sortedIntegerKeysForDictionary:(NSMutableDictionary*)dict;

#pragma mark Null Check for Strings
-(NSString*)ifNullStrReplace:(NSString*)strOriginal With:(NSString*)strToReplace;

#pragma mark Label Height Estimation
-(CGRect)getHLabelFrameForLabel:(UILabel*)label withString:(NSString*)string;

#pragma mark Label Width Estimation
-(CGRect)getWLabelFrameForLabel:(UILabel*)label withString:(NSString*)string;


@end
