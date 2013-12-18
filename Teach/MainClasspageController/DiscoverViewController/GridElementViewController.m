//
//  GridElementViewController.m
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

#import "GridElementViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/UIButton+WebCache.h>

#define RESOURCE_TITLE @"title"
#define RESOURCE_CATEGORY @"category"
#define RESOURCE_THUMBNAIL @"thumbnails"
#define RESOURCE_URL @"url"
#define RESOURCE_ID @"id"
#define RESOURCE_DESCRIPTION @"description"
#define RESOURCE_SOURCE @"source"
#define RESOURCE_VIEWS @"viewCount"

@interface GridElementViewController ()

@end

BOOL isResource;

NSMutableDictionary* dictResource;

@implementation GridElementViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (id)initGridElementWithDetails:(NSMutableDictionary*)dictIncomingDetails{
    
    
    
    dictResource = [[NSMutableDictionary alloc] init];
    dictResource = dictIncomingDetails;
    
//    NSLog(@"dictResource : %@",dictResource);

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupGridElement];
    
    
}

- (void)setupGridElement{
    [scrollViewResourceGrid setContentSize:CGSizeMake(320, scrollViewResourceGrid.frame.size.height)];
    
    [imgViewThumbnail setImageWithURL:[NSURL URLWithString:[dictResource valueForKey:RESOURCE_THUMBNAIL]] placeholderImage:[UIImage imageNamed:@"default-classpage.png"]];
    
    [lblResourceTitle setText:[dictResource valueForKey:RESOURCE_TITLE]];

    [lblDescription setText:[dictResource valueForKey:RESOURCE_DESCRIPTION]];

    [lblResourceSource setText:[dictResource valueForKey:RESOURCE_SOURCE]];

//    [lblViews setText:[dictResource valueForKey:RESOURCE_VIEWS]];
    
//    return viewResourceGrid;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnActionShare:(id)sender {
    
    NSLog(@"Sharing %@",[dictResource valueForKey:RESOURCE_TITLE]);
}
@end
