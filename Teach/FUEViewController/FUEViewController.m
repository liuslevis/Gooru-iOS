//
//  FUEViewController.m
//  Gooru
//
//  Created by Raghavendra on 18/11/13.
//  Copyright (c) 2013 Gooru Admin. All rights reserved.
//

#import "FUEViewController.h"
#import "MainClasspageViewController.h"

@interface FUEViewController ()

@end

@implementation FUEViewController

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
    [scrollViewParent setContentSize:CGSizeMake(viewStudy.frame.size.width*4, scrollViewParent.frame.size.height)];
    [scrollViewParent setDelegate:self];
    
    [scrollViewParent.layer setCornerRadius:8.0];
    [self addLeftGestureOnPaticularView:scrollViewParent];
    [self addRightGestureOnPaticularView:scrollViewParent];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)manageScroll:(int)offset{
    
    NSLog(@"offset : %i",offset);
   
        switch (offset) {
                
            case 0:{
                [self manageButtons:25];
                [self shouldHideView:btnSkipTutorial :FALSE];
                [self shouldHideView:btnNextView :FALSE];
                [self shouldHideView:btnPreviousView :TRUE];
                [self shouldHideView:btnDonetutorial :TRUE];
                [self shouldHideView:btnDonotShow :TRUE];
                
                break;
            }
            case 824:{
                [self manageButtons:50];
                [self shouldHideView:btnSkipTutorial :TRUE];
                [self shouldHideView:btnNextView :FALSE];
                [self shouldHideView:btnPreviousView :FALSE];
                [self shouldHideView:btnDonetutorial :TRUE];
                [self shouldHideView:btnDonotShow :TRUE];
                
                break;
            }
            case 1648:{
                [self manageButtons:75];
                [self shouldHideView:btnSkipTutorial :TRUE];
                [self shouldHideView:btnNextView :FALSE];
                [self shouldHideView:btnPreviousView :FALSE];
                [self shouldHideView:btnDonetutorial :TRUE];
                [self shouldHideView:btnDonotShow :TRUE];
                
                break;
            }
            case 2472:{
                [self manageButtons:100];
                [self shouldHideView:btnSkipTutorial :TRUE];
                [self shouldHideView:btnNextView :TRUE];
                [self shouldHideView:btnPreviousView :FALSE];
                [self shouldHideView:btnDonetutorial :FALSE];
                [self shouldHideView:btnDonotShow :FALSE];
                
                break;
            }
                
            default:
                break;
        }

    
   }

-(void)manageButtons:(int)tag{
    
    for (int i = 1; i < 5; i++) {
        UIButton* btnToDeselect = (UIButton*)[viewParent viewWithTag:i*25];
        [btnToDeselect setSelected:FALSE];
    }
    UIButton* btnToSelect = (UIButton*)[viewParent viewWithTag:tag];
    [btnToSelect setSelected:TRUE];
}

- (IBAction)btnActionSkipTutorial:(id)sender {
    
    [self exitFUE];
    
}

- (IBAction)btnActionNextView:(id)sender {
    
    [self disableAllControlButtons];
    
    [self manageScroll:scrollViewParent.contentOffset.x + viewParent.frame.size.width];

    [scrollViewParent setContentOffset:CGPointMake(scrollViewParent.contentOffset.x + viewParent.frame.size.width, scrollViewParent.contentOffset.y) animated:YES];
    
    [self performSelector:@selector(enableAllControlButtons) withObject:nil afterDelay:1.0];
    
    
}

- (IBAction)btnActionPreviousView:(id)sender {
    
    [self disableAllControlButtons];
    
    [self manageScroll:scrollViewParent.contentOffset.x - viewParent.frame.size.width];
    
    [scrollViewParent setContentOffset:CGPointMake(scrollViewParent.contentOffset.x - viewParent.frame.size.width, scrollViewParent.contentOffset.y) animated:YES];

    [self performSelector:@selector(enableAllControlButtons) withObject:nil afterDelay:1.0];
}

- (void)enableAllControlButtons{

        [btnSkipTutorial setEnabled:TRUE];
        [btnNextView  setEnabled:TRUE];
        [btnPreviousView setEnabled:TRUE];
        [btnDonetutorial setEnabled:TRUE];
 
}

- (void)disableAllControlButtons{
    
    [btnSkipTutorial setEnabled:FALSE];
    [btnNextView  setEnabled:FALSE];
    [btnPreviousView setEnabled:FALSE];
    [btnDonetutorial setEnabled:FALSE];
    
}

- (IBAction)btnActionStartStudying:(id)sender {
    
    MainClasspageViewController* mainClasspageViewController = (MainClasspageViewController*)[self parentViewController];
    
    [mainClasspageViewController starterClasspageIntiatior:20];
     [self exitFUE];
    
}

- (IBAction)btnActionStartTeaching:(id)sender {
    MainClasspageViewController* mainClasspageViewController = (MainClasspageViewController*)[self parentViewController];
    
    [mainClasspageViewController starterClasspageIntiatior:10];
     [self exitFUE];
}

- (IBAction)btnActionStartDiscovering:(id)sender {
    MainClasspageViewController* mainClasspageViewController = (MainClasspageViewController*)[self parentViewController];
    
    [mainClasspageViewController starterClasspageIntiatior:30];
     [self exitFUE];
}

- (IBAction)btnActionDoNotShow:(id)sender {
    
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if(![btnDonotShow isSelected]){
        [btnDonotShow setSelected:TRUE];
        [standardUserDefaults setObject:@"No" forKey:@"FUEFlagShouldShowMainFUE"];
        
    }else{
        
        [btnDonotShow setSelected:FALSE];
        [standardUserDefaults setObject:@"Yes" forKey:@"FUEFlagShouldShowMainFUE"];
        
    }
    
}

#pragma mark Hide/Unhide Animated!
-(void)shouldHideView:(UIView*)view :(BOOL)value{
    
    CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
    animation.duration = 0.4;
    [view.layer addAnimation:animation forKey:nil];
    
    [view setHidden:value];
    
}

-(void)exitFUE{
    self.view.alpha=1;
    [UIView animateWithDuration:0.3
                     animations:^{
                         // theView.center = newCenter;
                         self.view.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         // Do other things
                     }];
    
    [self performSelector:@selector(removeFUEViewController) withObject:nil afterDelay:0.3];
}

- (void)removeFUEViewController{
    [self willMoveToParentViewController:nil];
    
    //2. Remove the DetailViewController's view from the Container
    [self.view removeFromSuperview];
    
    //3. Update the hierarchy"
    //   Automatically the method didMoveToParentViewController: will be called on the detailViewController)
    [self removeFromParentViewController];
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


// gesture recognizer method

- (void)handleViewsSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    if (scrollViewParent.contentOffset.x + viewParent.frame.size.width < 3296) {
        [self disableAllControlButtons];
        
        [self manageScroll:scrollViewParent.contentOffset.x + viewParent.frame.size.width];
        
        [scrollViewParent setContentOffset:CGPointMake(scrollViewParent.contentOffset.x + viewParent.frame.size.width, scrollViewParent.contentOffset.y) animated:YES];
        
        [self performSelector:@selector(enableAllControlButtons) withObject:nil afterDelay:1.0];
    }
    
}
- (void)handleViewsSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    
    if (scrollViewParent.contentOffset.x - viewParent.frame.size.width > -824) {
        
        [self disableAllControlButtons];
        
        [self manageScroll:scrollViewParent.contentOffset.x - viewParent.frame.size.width];
        
        [scrollViewParent setContentOffset:CGPointMake(scrollViewParent.contentOffset.x - viewParent.frame.size.width, scrollViewParent.contentOffset.y) animated:YES];
        
        [self performSelector:@selector(enableAllControlButtons) withObject:nil afterDelay:1.0];
    }
}


@end
