//
//  FUEViewController.h
//  Gooru
//
//  Created by Raghavendra on 18/11/13.
//  Copyright (c) 2013 Gooru Admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FUEViewController : UIViewController<UIScrollViewDelegate> {
    IBOutlet UIView *viewParent;
    
    IBOutlet UIView *viewTeach;
    IBOutlet UIView *viewGooru;
    IBOutlet UIView *viewDiscover;
    IBOutlet UIView *viewStudy;
    
    IBOutlet UIScrollView *scrollViewParent;
    
    IBOutlet UIButton *btnSkipTutorial;
    IBOutlet UIButton *btnNextView;
    IBOutlet UIButton *btnPreviousView;
    IBOutlet UIButton *btnDonetutorial;
    IBOutlet UIButton *btnDonotShow;
    
}

- (IBAction)btnActionSkipTutorial:(id)sender;
- (IBAction)btnActionNextView:(id)sender;
- (IBAction)btnActionPreviousView:(id)sender;
- (IBAction)btnActionStartStudying:(id)sender;
- (IBAction)btnActionStartTeaching:(id)sender;
- (IBAction)btnActionStartDiscovering:(id)sender;
- (IBAction)btnActionDoNotShow:(id)sender;


@end
