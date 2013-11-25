//
//  FlaggingPopupViewController.m
// Gooru
//
//  Created by Gooru on 10/18/13.
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

#import "FlaggingPopupViewController.h"
#import "CollectionPlayerV2ViewController.h"


#define COLLECTION_TITLE @"CollectionTitle"
#define COLLECTION_ID @"CollectionId"
#define COLLECTION_THUMBNAIL @"CollectionThumbnail"
#define COLLECTION_VIEWS @"CollectionViews"
#define COLLECTION_ASSETURI @"CollectionAssetURI"
#define COLLECTION_FOLDER @"CollectionFolder"
#define COLLECTION_NATIVEURL @"CollectionNativeURL"
#define COLLECTION_DESCRIPTION @"CollectionDescription"
#define SESSION_TOKEN @"SessionToken"
#define SERVER_URL @"ServerUrl"




#define RESOURCE_INSTANCE_ID @"ResourceInstanceId"
#define RESOURCE_NARRATION @"ResourceNarration"
#define RESOURCE_START @"ResourceStart"
#define RESOURCE_STOP @"ResourceStop"
#define RESOURCE_CATEGORY @"ResourceCategory"
#define RESOURCE_DESCRIPTION @"ResourceDescription"
#define RESOURCE_ACTUAL_ID @"ResourceActualId"
#define RESOURCE_TITLE @"ResourceTitle"
#define RESOURCE_THUMBNAIL @"ResourceThumbnail"
#define RESOURCE_URL @"ResourceUrl"
#define RESOURCE_TYPE @"ResourceType"

#define QUESTION_TEXT @"QuestionText"
#define QUESTION_ANSWERS @"QuestionAnswers"
#define QUESTION_HINTS @"QuestionHints"
#define QUESTION_EXPLANATION @"QuestionExplanation"
#define QUESTION_CORRECTANSWER @"CorrectAnswer"
#define QUESTION_USERANSWER @"UserAnswer"
#define QUESTION_TYPE @"Type"

#define RESOURCE_REACTION @"ResourceReaction"


@interface FlaggingPopupViewController ()

@end

@implementation FlaggingPopupViewController

NSMutableDictionary* dictCollectionInfo;
NSMutableDictionary* dictResourceInfo;
BOOL isCollection = FALSE;

NSString* strSelection;

CollectionPlayerV2ViewController* collectionPlayerV2ViewController;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCollectionInfo:(NSMutableDictionary*)dictIncomingCollectionInfo andResourceInfo:(NSMutableDictionary*)dictIncomingResourceInfo forCollection:(BOOL)value andParentViewController:(UIViewController*)parentViewController{
    
    collectionPlayerV2ViewController = parentViewController;

    isCollection = value;
    
    dictCollectionInfo = dictIncomingCollectionInfo;
    dictResourceInfo = dictIncomingResourceInfo;
    
    NSLog(@"dictCollectionInfo :%@",dictCollectionInfo);
    NSLog(@"dictResourceInfo :%@",dictResourceInfo);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidShow:) name: UIKeyboardDidShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector (keyboardDidHide:) name: UIKeyboardDidHideNotification object:nil];
    
    if (isCollection) {
        [lblFlagPopupTitle setText:[NSString stringWithFormat:@"Flag this Collection"]];
        [viewCollectionFlagging setHidden:FALSE];
        [viewResourceFlagging setHidden:TRUE];
        [lblCopyright setHidden:TRUE];
        [btnCopyright setHidden:TRUE];
        
        [lblFlagPrompt setText:[NSString stringWithFormat:@"Why would you like to flag \"%@\"?",[dictCollectionInfo valueForKey:COLLECTION_TITLE]]];
        
        strSelection = [NSString stringWithFormat:@"Collection"];
        
        [lblFlaggedTitle setText:[dictCollectionInfo valueForKey:COLLECTION_TITLE]];
        
    }else{
        [lblFlagPopupTitle setText:[NSString stringWithFormat:@"Flag this Resource"]];
        [viewCollectionFlagging setHidden:TRUE];
        [viewResourceFlagging setHidden:FALSE];
        [lblCopyright setHidden:FALSE];
        [btnCopyright setHidden:FALSE];
        
        [lblFlagPrompt setText:[NSString stringWithFormat:@"Why would you like to flag \"%@\"?",[dictResourceInfo valueForKey:RESOURCE_TITLE]]];
        
        strSelection = [NSString stringWithFormat:@"Resource"];
        
        [lblFlaggedTitle setText:[dictResourceInfo valueForKey:RESOURCE_TITLE]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark BA Close

- (IBAction)btnActionCloseFlagPopup:(id)sender {
    
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


#pragma mark BA Flag Options
- (IBAction)btnActionFlagOptions:(id)sender {
    
    if ([sender isSelected]) {
        [sender setSelected:FALSE];
    }else{
        [sender setSelected:TRUE];
    }
    
    [self manageOptionSelection:sender];
    
}

#pragma mark Manage Option Selection
- (void)manageOptionSelection:(id)sender{
    
    
    
    
    
    switch ([sender tag]) {
        case 11:{
            
            if ([sender isSelected]) {
                strSelection = [NSString stringWithFormat:@"%@ - Option 1",strSelection];
            }else{
                strSelection = [strSelection stringByReplacingOccurrencesOfString:@" - Option 1" withString:@""];
            }
            
            
            
            break;
        }
            
        case 22:{
            
            if ([sender isSelected]) {
                strSelection = [NSString stringWithFormat:@"%@ - Option 2",strSelection];
            }else{
                strSelection = [strSelection stringByReplacingOccurrencesOfString:@" - Option 2" withString:@""];
            }

            break;
        }
            
        case 33:{
            
            if ([sender isSelected]) {
                strSelection = [NSString stringWithFormat:@"%@ - Option 3",strSelection];
            }else{
                strSelection = [strSelection stringByReplacingOccurrencesOfString:@" - Option 3" withString:@""];
            }

            break;
        }
            
        case 44:{
            
            if ([sender isSelected]) {
                strSelection = [NSString stringWithFormat:@"%@ - Option 4",strSelection];
            }else{
                strSelection = [strSelection stringByReplacingOccurrencesOfString:@" - Option 4" withString:@""];
            }

            break;
        }
            
            
        default:
            break;
    }
    
    //Flagging Validation
    if ([strSelection rangeOfString:@"Option"].length !=0) {
        [btnSubmitFlags setEnabled:TRUE];
    }else{
        [btnSubmitFlags setEnabled:FALSE];
    }
    
    NSLog(@"strSelection : %@",strSelection);
    
}

#pragma mark BA Submit Flags
- (IBAction)btnActionSubmitFlags:(id)sender {
    
    [collectionPlayerV2ViewController setFlaggingForCollection:isCollection];
    
    [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(-797, viewFlaggingPopup.frame.origin.y, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];
    
    [self animateView:viewFlaggingConfirmedPopup forFinalFrame:CGRectMake(287, viewFlaggingConfirmedPopup.frame.origin.y, viewFlaggingConfirmedPopup.frame.size.width, viewFlaggingConfirmedPopup.frame.size.height)];
    
}

- (IBAction)btnActionTermsAndConditions:(id)sender {
    
    if (viewTandC.frame.origin.y == 42) {
        [self animateView:viewTandC forFinalFrame:CGRectMake(0, 605, viewTandC.frame.size.width, viewTandC.frame.size.height)];
    }else{
        [self animateView:viewTandC forFinalFrame:CGRectMake(0, 42, viewTandC.frame.size.width, viewTandC.frame.size.height)];
    }
        
    [webviewTerms loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"terms" ofType:@"html"]isDirectory:NO]]];

    
    [self performSelector:@selector(renderText) withObject:nil afterDelay:0.6];

}

- (void)renderText{
    
    [webviewTerms.scrollView setContentOffset:CGPointMake(0, webviewTerms.frame.size.height + 65) animated:YES];
    
}

#pragma mark - KeyBoard delegates -

- (void) keyboardDidShow: (NSNotification *)notif {
    NSLog(@"keyboardDidShow : %f",viewFlaggingPopup.frame.origin.y);
    
    if (viewFlaggingPopup.frame.origin.y == 82) {
        
        [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(viewFlaggingPopup.frame.origin.x, viewFlaggingPopup.frame.origin.y - 180, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];
        
    }
    
}

- (void) keyboardDidHide: (NSNotification *)notif {
    
    NSLog(@"keyboardDidHide : %f",viewFlaggingPopup.frame.origin.y);
    if (viewFlaggingPopup.frame.origin.y != 82) {
        
        [self animateView:viewFlaggingPopup forFinalFrame:CGRectMake(viewFlaggingPopup.frame.origin.x, viewFlaggingPopup.frame.origin.y + 180, viewFlaggingPopup.frame.size.width, viewFlaggingPopup.frame.size.height)];

    }
    
}


#pragma mark - Animate Views -
- (void)animateView:(UIView*)view forFinalFrame:(CGRect)frame{
    
    
    [UIView animateWithDuration:0.5f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         view.frame = frame;
                         
                     } completion:^(BOOL finished){
                         
                         
                     }];
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
@end
