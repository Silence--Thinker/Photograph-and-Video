//
//  PickerViewController.m
//  DemoForPickerController
//
//  Created by Silence on 16/7/1.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "PickerViewController.h"

@implementation PickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"picker";
    self.view.backgroundColor = [UIColor redColor];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    // 视频质量 -> 1280*720
//    _imagePicker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
    // 摄像头捕捉方式 -> 视频
//    _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
}


@end
