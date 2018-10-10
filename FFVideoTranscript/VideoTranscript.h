//
//  VideoTranscript.h
//  FFVideoTranscript
//
//  Created by fengzifeng on 2018/10/10.
//  Copyright © 2018年 fengzifeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@protocol LiveVideoTranscriptDelegate <NSObject>

- (void)getLiveVideoTranscriptImages:(UIImage *)image;

@end

@interface VideoTranscript : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, weak) id <LiveVideoTranscriptDelegate> delegate;

@property(nonatomic,strong) AVCaptureSession *captureSession;
@property(nonatomic,strong) AVCaptureVideoDataOutput *captureVideoDataOutput;

@end
