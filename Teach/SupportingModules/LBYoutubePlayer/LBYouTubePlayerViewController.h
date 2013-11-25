//
//  LBYouTubePlayerController.h
//  LBYouTubeView
//
//  Created by Marco Muccinelli on 11/06/12.
//  Copyright (c) 2012 Ednovo.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBYouTubeExtractor.h"
#import "LBYouTubePlayerController.h"

@protocol LBYouTubePlayerControllerDelegate;

@interface LBYouTubePlayerViewController : NSObject <LBYouTubeExtractorDelegate> {
    LBYouTubePlayerController* view;
    LBYouTubeExtractor* extractor;
    id <LBYouTubePlayerControllerDelegate> __unsafe_unretained delegate;
    
    float startTime;
    float endTime;
}

@property (nonatomic, strong, readonly) LBYouTubePlayerController* view;
@property (nonatomic, strong, readonly) LBYouTubeExtractor* extractor;
@property (nonatomic, unsafe_unretained) IBOutlet id <LBYouTubePlayerControllerDelegate> delegate;

@property (nonatomic) float startTime;
@property (nonatomic) float endTime;

-(id)initWithYouTubeURL:(NSURL*)youTubeURL quality:(LBYouTubeVideoQuality)quality;
-(id)initWithYouTubeID:(NSString*)youTubeID quality:(LBYouTubeVideoQuality)quality;

@end
@protocol LBYouTubePlayerControllerDelegate <NSObject>

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL;
-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error;
-(void)stopVideoPlayback;


@end
