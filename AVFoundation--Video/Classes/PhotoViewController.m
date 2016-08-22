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
#import "AVFoundation/AVVideoSettings.h"

@interface PhotoViewController ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;

@end
@implementation PhotoViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildingBegin2photograph];
}

- (void)buildingBegin2photograph {
    [self session];
    // device
    AVCaptureDevice *device = [self cameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (device == nil) {
        NSLog(@"获取后置摄像头失败");
        return;
    }else {
        NSLog(@"获取摄像头成功OK");
    }
    
    // input
    NSError *error = nil;
    _deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error != nil) {
        NSLog(@"获取设备输入失败，原因%@", error);
    }else {
        NSLog(@"获取设备输入成功OK");
    }
    
    // output
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSMutableDictionary *outputSetting = [NSMutableDictionary dictionary];
    [outputSetting setObject:AVVideoCodecJPEG forKey:AVVideoCodecKey];
    [outputSetting setObject:@(1) forKey:AVVideoQualityKey];
    [_stillImageOutput setOutputSettings:outputSetting];
    
    // session
    if ([self.session canAddInput:_deviceInput]) {
        [self.session addInput:_deviceInput];
    }
    if ([self.session canAddOutput:_stillImageOutput]) {
        [self.session addOutput:_stillImageOutput];
    }
    
    // capturePreviewLayer
    _capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    
    CALayer *layer = self.view.layer;
    layer.masksToBounds = YES;
    _capturePreviewLayer.frame = CGRectMake((CGRectGetWidth(self.view.frame) - 300) / 2, 80, 300, 300);
    _capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [layer insertSublayer:self.capturePreviewLayer atIndex:0];
    
    [self.session startRunning];
    
    [self addNotificationToCaptureDevice:device];
//    AVCaptureConnection *d;
//    AVAudioSessionPortBuiltInMic;AVAudioSessionOrientationFront;;
}

#pragma mark - getter
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        if ([_session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
            _session.sessionPreset = AVCaptureSessionPresetMedium;
        }
    }
    return _session;
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position {
//    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//    NSLog(@"=====%zd ", [device position]);
//    return device;
    
    NSArray *array = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in array) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

#pragma mark - function
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)device {
    [self changeDeviceProperty:^(AVCaptureDevice *device) {
        device.subjectAreaChangeMonitoringEnabled = YES;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:nil];
}

- (void)areaDidChange:(NSNotification *)note {
    NSLog(@"===区域改变===");
}

- (void)changeDeviceProperty:(void(^)(AVCaptureDevice *device))deviceChange {
    AVCaptureDevice *device = [self.deviceInput device];
    NSError *error = nil;
    if ([device lockForConfiguration:&error]) {
        deviceChange(device);
        [device unlockForConfiguration];
    }else {
        NSLog(@"设置设备属性过程发生错误，信息;%@", error);
    }
}
@end
