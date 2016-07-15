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
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:NULL];
    [session addInput:deviceInput];
    
    AVCaptureStillImageOutput *imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
}
@end
