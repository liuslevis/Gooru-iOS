//
//  CollectionAnalyticsViewController.h
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

@interface CollectionAnalyticsViewController : UIViewController{
    
    IBOutlet UIButton *btnCollectionAnalyticsPaginating1;
    
    IBOutlet UIButton *btnCollectionAnalyticsPaginating2;
    
    NSString *tempCheckingTime;
}

@property(strong,nonatomic)NSString *collectionId;

@property (strong, nonatomic) IBOutlet UILabel *lablTotalStudentViews;

@property (strong, nonatomic) IBOutlet UILabel *lablAvgTimeSpent;

@property (strong, nonatomic) IBOutlet UILabel *lablAvgStudentGrade;

@property (strong, nonatomic) IBOutlet UILabel *lablAvgStudentReaction;

@property (strong, nonatomic) IBOutlet UIView *viewCollectionAnalytics;

@property (strong, nonatomic) IBOutlet UIView *viewMainView;

@property (strong, nonatomic) IBOutlet UIView *viewForShowingEmptyContent;

@property (strong, nonatomic) IBOutlet UIView *viewHelp;

@property (strong, nonatomic) IBOutlet UIView *viewHelpCollectionAnalytics;

-(id)initWithCollectionId:(NSString *)incomingCollectionId;
-(void)getCollectionAnalyticsDetails;
-(void)getCollectionBreakDownDetails;
-(void)parseCollectionAnalyticsDetails:(NSString *)responseString;
-(void)parseCollectionBreakDownDetails:(NSString *)responseString;
-(void)updateDataForCollectionAnalytics;
- (NSString *)getTimeFromString: (NSString*) interval;
- (IBAction)btnActionCloseCollectionAnalytics:(id)sender;
- (IBAction)btnActionCloseHelpPage:(id)sender;
- (IBAction)btnActionShowHelpPage:(id)sender;


@end
