//
//  LBYouTubePlayerController.m
//  LBYouTubeView
//
//  Created by Laurin Brandner on 29.06.12.
//  Copyright (c) 2012 Ednovo.org. All rights reserved.
//

#import "LBYouTubePlayerController.h"

@interface LBYouTubePlayerController () 

@property (nonatomic, strong) MPMoviePlayerController* videoController;

-(void)_setup;

@end
@implementation LBYouTubePlayerController

@synthesize videoController;

#pragma mark Initialization

-(id)init {
    self = [super init];
    if (self) {
        [self _setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setup];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _setup];
    }
    return self;
}

-(void)_setup {
    self.backgroundColor = [UIColor blackColor];
    
}

#pragma mark -
#pragma mark Other Methods

-(void)loadYouTubeVideo:(NSURL *)URL :(float)startTime :(float)endTime{
    if (self.videoController) {
        [self.videoController.view removeFromSuperview];
    }

    self.videoController = [[MPMoviePlayerController alloc] initWithContentURL:URL];
    [self.videoController setInitialPlaybackTime:startTime];
    [self.videoController setEndPlaybackTime:endTime];
    [self.videoController prepareToPlay];
    self.videoController.controlStyle = MPMovieControlStyleEmbedded;
    self.videoController.view.frame = self.bounds;
    self.videoController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.videoController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopVideo) name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoController];

}

-(void)stopVideo{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.videoController];
    [self.videoController stop];
    [self.videoController setFullscreen:FALSE animated:YES];
    [self login_AlertShow:@"End of video!!!"];
    
//    self.videoController.initialPlaybackTime = -1.0;
    
}

-(void)pauseVideo{
    
    NSLog(@"pauseVideo");
    [self.videoController pause];
//    self.videoController.initialPlaybackTime = -1.0;
    
}

-(void)playVideo{
    [self.videoController play];
    
}

#pragma mark - Alerts -

-(void)login_AlertShow:(NSString *)strMessage {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[appDelegate getValueByKey:@"MessageTitle"] message:strMessage delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
}


@end
