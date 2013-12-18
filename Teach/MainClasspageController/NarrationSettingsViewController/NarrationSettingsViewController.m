//
//  NarrationSettingsViewController.m
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


#import "NarrationSettingsViewController.h"
#import "AppDelegate.h"

@interface NarrationSettingsViewController ()

@end

@implementation NarrationSettingsViewController

AppDelegate *appDelegate;
NSUserDefaults* standardUserDefaults;

// Narration Settings Fonts
UIFont* arial;
UIFont* baskerville;
UIFont* chalkboard;
UIFont* grandhotel;
UIFont* sniglet;
UIFont* tahoma;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    // Narration Fonts
    arial         = [UIFont fontWithName:@"Arial" size:15.0];
    baskerville   = [UIFont fontWithName:@"Baskerville" size:15.0];
    chalkboard    = [UIFont fontWithName:@"Chalkboard SE" size:15.0];
    grandhotel    = [UIFont fontWithName:@"GrandHotel-Regular" size:15.0];
    sniglet       = [UIFont fontWithName:@"Sniglet" size:15.0];
    tahoma        = [UIFont fontWithName:@"Tahoma" size:15.0];
    btnFontGrandHotel.titleLabel.font=grandhotel;
    btnFontSniglet.titleLabel.font=sniglet;
    [self setNarrationDefaultSettings];
    
    
}

- (void)setNarrationDefaultSettings{
  

    if ([standardUserDefaults objectForKey:@"teacherNarrationBackgroundColor"] == nil) {
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewNarrationBackgroundParent viewWithTag:9];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
   
    }else{
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewNarrationBackgroundParent viewWithTag:[[standardUserDefaults objectForKey:@"TagForNarrationBackgrnd"] intValue]];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if ([standardUserDefaults objectForKey:@"teacherNarrationTextColor"] == nil) {
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewTextColorParent viewWithTag:13];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }else{
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewTextColorParent viewWithTag:[[standardUserDefaults objectForKey:@"TagForNarrationTextColor"] intValue]];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if ([standardUserDefaults objectForKey:@"teacherNarrationFontType"] == nil) {
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewFontParent viewWithTag:7];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }else{
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewFontParent viewWithTag:[[standardUserDefaults objectForKey:@"TagForNarrationFontType"] intValue]];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    
    if ([standardUserDefaults objectForKey:@"teacherNarrationTextSize"] == nil) {
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewFontSizeParent viewWithTag:10];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }else{
          UIButton* btnDefault;
        btnDefault = (UIButton*)[viewFontSizeParent viewWithTag:[[standardUserDefaults objectForKey:@"TagForNarrationTextSize"] intValue]];
        [btnDefault sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }
    

}

#pragma mark Narration Background Color Button Action


- (IBAction)btnActionNarrationBackrgrndColor:(id)sender {
    
     [appDelegate logMixpanelforevent:@"Narration Settings Edited" and:NULL];
    
    NSLog(@"tag : %i",[sender tag]);
    UIButton* tempBtn =  (UIButton*)sender;
    
    //Unselect all buttons
    for (int i=1; i<7; i++) {
        
        UIButton* btnToDeselect = (UIButton*)[viewNarrationBackgroundParent viewWithTag:(i*9)];
        [btnToDeselect setSelected:FALSE];
    }
    
    
    [tempBtn setSelected:TRUE];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    switch ([sender tag]) {
        case 9:
            [dictionary setObject:[NSNumber numberWithFloat:36.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:36.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:36.0]   forKey:@"blue"];
            break;
        case 18:
            [dictionary setObject:[NSNumber numberWithFloat:109.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:217.0]   forKey:@"blue"];
            break;
        case 27:
            [dictionary setObject:[NSNumber numberWithFloat:0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:109.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:217.0]   forKey:@"blue"];
            break;
        case 36:
            [dictionary setObject:[NSNumber numberWithFloat:255.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:77.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:77.0]   forKey:@"blue"];
            break;
        case 45:
            [dictionary setObject:[NSNumber numberWithFloat:140.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:35.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:0]   forKey:@"blue"];
            break;
        case 54:
            [dictionary setObject:[NSNumber numberWithFloat:0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:178.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:0]   forKey:@"blue"];
            
            break;
        default:
            break;
    }
    [standardUserDefaults setObject:dictionary forKey:@"teacherNarrationBackgroundColor"];
    [standardUserDefaults setInteger:[sender tag] forKey:@"TagForNarrationBackgrnd"];
    
    [self loadNarrationPreviewBackgrnd];
    
    
}


- (IBAction)btnActionTextColor:(id)sender {
    
    [appDelegate logMixpanelforevent:@"Narration Settings Edited" and:NULL];
    NSLog(@"tag : %i",[sender tag]);
    UIButton* tempBtn =  (UIButton*)sender;
    
    //Unselect all buttons
    for (int i=1; i<7; i++) {
        
        UIButton* btnToDeselect = (UIButton*)[viewTextColorParent viewWithTag:(i*13)];
        [btnToDeselect setSelected:FALSE];
    }
    [tempBtn setSelected:TRUE];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    
    switch ([sender tag]) {
        case 13:
            [dictionary setObject:[NSNumber numberWithFloat:255.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:255.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:255.0]   forKey:@"blue"];
            break;
        case 26:
            [dictionary setObject:[NSNumber numberWithFloat:229.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:153.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:255.0]   forKey:@"blue"];
            break;
        case 39:
            [dictionary setObject:[NSNumber numberWithFloat:153.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:204.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:255.0]   forKey:@"blue"];
            break;
        case 52:
            [dictionary setObject:[NSNumber numberWithFloat:255.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:191.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:191.0]   forKey:@"blue"];
            break;
        case 65:
            [dictionary setObject:[NSNumber numberWithFloat:255.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:204.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:153.0]   forKey:@"blue"];
            break;
        case 78:
            [dictionary setObject:[NSNumber numberWithFloat:153.0]    forKey:@"red"];
            [dictionary setObject:[NSNumber numberWithFloat:255.0]  forKey:@"green"];
            [dictionary setObject:[NSNumber numberWithFloat:179.0]   forKey:@"blue"];
            
            break;
        default:
            break;
    }
    [standardUserDefaults setObject:dictionary forKey:@"teacherNarrationTextColor"];
    [standardUserDefaults setInteger:[sender tag] forKey:@"TagForNarrationTextColor"];
    
    [self loadNarrationPreviewText];
    
}

- (IBAction)btnActionTextFont:(id)sender {
    [appDelegate logMixpanelforevent:@"Narration Settings Edited" and:NULL];
    
    NSLog(@"tag : %i",[sender tag]);
    
    UIButton* tempBtn =  (UIButton*)sender;
    
    //Unselect all buttons
    for (int i=1; i<6; i++) {
        
        UIButton* btnToDeselect = (UIButton*)[viewFontParent viewWithTag:(i*7)];
        [btnToDeselect setSelected:FALSE];
    }
    
    
    [tempBtn setSelected:TRUE];
    
    
    UIFont* font;
    switch ([sender tag]) {
            
        case 7:
            //                lblPreviewNarrationText.font = arial;
            font = arial;
            break;
            
        case 14:
            
            //                lblPreviewNarrationText.font = baskerville;
            font = baskerville;
            
            break;
            
        case 21:
            
            //                lblPreviewNarrationText.font = chalkboard;
            font = chalkboard;
            
            
            break;
            
        case 28:
            
            //                lblPreviewNarrationText.font = grandhotel;
            font = grandhotel;
            
            break;
            
        case 35:
            
            //                lblPreviewNarrationText.font = sniglet;
            font = sniglet;
            
            
            break;
            
        default:
            break;
    }
    [standardUserDefaults setObject:font.fontName forKey:@"teacherNarrationFontType"];
    [standardUserDefaults setInteger:[sender tag] forKey:@"TagForNarrationFontType"];
    
    [self loadNarrationPreviewText];
    
}

- (IBAction)btnActionTextSize:(id)sender {
    [appDelegate logMixpanelforevent:@"Narration Settings Edited" and:NULL];
    NSLog(@"tag : %i",[sender tag]);
    UIButton* tempBtn =  (UIButton*)sender;
    
    //Unselect all buttons
    for (int i=1; i<4; i++) {
        
        UIButton* btnToDeselect = (UIButton*)[viewFontSizeParent viewWithTag:(i*10)];
        [btnToDeselect setSelected:FALSE];
    }
    
    
    [tempBtn setSelected:TRUE];
    
    UIFont *font;
    switch ([sender tag]) {
            
        case 10:{
            font = [UIFont fontWithName:lblPreviewNarrationText.font.fontName size:20.0];
            break;
        }
            
        case 20:{
            font = [UIFont fontWithName:lblPreviewNarrationText.font.fontName size:26.0];
            break;
        }
            
            
            
        case 30:{
            font = [UIFont fontWithName:lblPreviewNarrationText.font.fontName size:38.0];
            break;
        }
            
            
        default:{
            font = [UIFont fontWithName:lblPreviewNarrationText.font.fontName size:20.0];
            break;
        }
            
    }
    
    [standardUserDefaults setObject:[NSString stringWithFormat:@"%f",[font pointSize]] forKey:@"teacherNarrationTextSize"];
    [standardUserDefaults setInteger:[sender tag] forKey:@"TagForNarrationTextSize"];
    
    
    [self loadNarrationPreviewText];
    
}

#pragma mark load load Narration Preview Text from userdefaults

- (void) loadNarrationPreviewText {
    
    
    float red,green,blue;
    
    NSDictionary *dictionaryText  = [standardUserDefaults objectForKey:@"teacherNarrationTextColor"];
    
    red = [[dictionaryText objectForKey:@"red"] floatValue];
    green = [[dictionaryText objectForKey:@"green"] floatValue];
    blue = [[dictionaryText objectForKey:@"blue"] floatValue];
    
    UIColor *textColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    lblPreviewNarrationText.textColor = textColor;
    
    NSString* fontForType = [standardUserDefaults objectForKey:@"teacherNarrationFontType"];
    NSLog(@"fontForType : %@",fontForType);
    
    NSString* fontForSize = [standardUserDefaults objectForKey:@"teacherNarrationTextSize"];
    NSLog(@"fontForSize : %@",fontForSize);
    
    
    [lblPreviewNarrationText setFont:[UIFont fontWithName:fontForType size:(CGFloat)[fontForSize floatValue]]];
    
}

#pragma mark load loadNarrationPreviewBackgrnd from userdefaults

- (void) loadNarrationPreviewBackgrnd {
    
    
    float red,green,blue;
    
    NSDictionary *dictionary  = [standardUserDefaults objectForKey:@"teacherNarrationBackgroundColor"];
    
    red = [[dictionary objectForKey:@"red"] floatValue];
    green = [[dictionary objectForKey:@"green"] floatValue];
    blue = [[dictionary objectForKey:@"blue"] floatValue];
    
    
    UIColor *backgrndColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    [viewPreviewNarrationBackgrnd setBackgroundColor:backgrndColor];
}

- (void)restoreButtonState:(UIButton*)button {
    button.selected = [standardUserDefaults boolForKey:[NSString stringWithFormat:@"isSelected%d",button.tag]];
}

- (void)closeNarrationSettings{
    
    //Mixpanel track closeNarrationSetting
    [appDelegate logMixpanelforevent:@"Narration Setting Closed" and:nil];
    [self removeCurrentDetailViewController];
}

#pragma mark - Remove ViewController -

- (void)removeCurrentDetailViewController{
    
    //1. Call the willMoveToParentViewController with nil
    //   This is the last method where your detailViewController can perform some operations before neing removed
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
