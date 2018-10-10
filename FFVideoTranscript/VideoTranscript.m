//
//  VideoTranscript.m
//  FFVideoTranscript
//
//  Created by fengzifeng on 2018/10/10.
//  Copyright © 2018年 fengzifeng. All rights reserved.
//

#import "VideoTranscript.h"
#import <UIKit/UIKit.h>

@implementation VideoTranscript 

- (instancetype)init
{
    if (self = [super init]) {
        [self initDevice];
    }
    return self;
}

-(AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position]==position) {
            return camera;
        }
    }
    return nil;
}

- (void)initDevice
{
    _captureSession = [[AVCaptureSession alloc] init];
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    //设备
    AVCaptureDevice *captureDevice=[self getCameraDeviceWithPosition:AVCaptureDevicePositionFront];
    //视频输入
    AVCaptureDeviceInput *videoCaptureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    [_captureSession addInput:videoCaptureDeviceInput];
    
    [captureDevice lockForConfiguration:nil];
    [captureDevice setActiveVideoMaxFrameDuration:CMTimeMake(1,15)];
    [captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1,15)];
    [captureDevice unlockForConfiguration];
    
    // 视频输出
    _captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureVideoDataOutput.videoSettings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                             
                                                                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    [_captureSession addOutput:_captureVideoDataOutput];
    dispatch_queue_t my_Queue = dispatch_queue_create("myqueue", NULL);
    [_captureVideoDataOutput setSampleBufferDelegate:self queue:my_Queue];
    _captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    /// 视频连接
    AVCaptureConnection *videoConnection = [_captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //    [_captureSession startRunning];
}

//实现代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    //需要过会才会有视频帧
    if (captureOutput == _captureVideoDataOutput) { // 只有是视频帧 过来才操作
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        CFRetain(sampleBuffer);
        if (self.delegate && [self.delegate respondsToSelector:@selector(getLiveVideoTranscriptImages:)]) {
            [self.delegate getLiveVideoTranscriptImages:image];
        }
        
        CFRelease(sampleBuffer);
    }
}

// 通过抽样缓存数据创建一个UIImage对象
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    if (width == 0 || height == 0) {
        return nil;
    }
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGContextConcatCTM(context, transform);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 裁剪 图片
    struct CGImage *cgImage = CGImageCreateWithImageInRect(quartzImage, CGRectMake(0, 0, height, height));
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [[UIImage alloc] initWithCGImage:quartzImage];
//    UIImage *image = [[UIImage alloc] initWithCGImage:quartzImage scale:1 orientation:UIImageOrientationLeftMirrored];
    // 释放Quartz image对象
    CGImageRelease(cgImage);
    CGImageRelease(quartzImage);
    return (image);
}

@end
