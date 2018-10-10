//
//  ViewController.m
//  FFVideoTranscript
//
//  Created by fengzifeng on 2018/10/10.
//  Copyright © 2018年 fengzifeng. All rights reserved.
//

#import "ViewController.h"
#import "VideoTranscript.h"
#import "UIImage+FixOrientation.h"

@interface ViewController () <LiveVideoTranscriptDelegate>

@property (strong,nonatomic) VideoTranscript *videoTranscript;
@property (strong,nonatomic) UIImage *faceImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videoTranscript = [[VideoTranscript alloc] init];
    _videoTranscript.delegate = self;
    [_videoTranscript.captureSession startRunning];

}

//录制视频图片
- (void)getLiveVideoTranscriptImages:(UIImage *)image
{
    //这里录制的图片不是正方向的
    image = [image fixOrientation];
    self.faceImage = image;
}


@end
