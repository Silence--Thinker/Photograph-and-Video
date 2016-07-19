//
//  PhotoViewController.m
//  AVFoundation--Video
//
//  Created by Silence on 16/7/15.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "PhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVMediaFormat.h"
@interface PhotoViewController ()

@property (nonatomic, strong) AVCaptureSession *session;

//@property (nonatomic, strong) AVCaptureDevice *device;

@end
@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self addTestBtn];
}

- (void)addTestBtn {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(clickTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)clickTestBtn:(UIButton *)sender {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    [self.session addInput:deviceInput];
    
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
}

#pragma mark - getter
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            _session.sessionPreset = AVCaptureSessionPresetHigh;
        }
    }
    return _session;
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}
@end
