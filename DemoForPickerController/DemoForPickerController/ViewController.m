//
//  ViewController.m
//  DemoForPickerController
//
//  Created by Silence on 16/6/30.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "ViewController.h"
#import "PickerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <
UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, assign, getter=isVideoModel) BOOL videoModel;

@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"....";
    self.videoModel = YES;
    [self addTestBtn];
}

- (void)addTestBtn {
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    btn.center = self.view.center;
    btn.backgroundColor = [UIColor grayColor];
    [btn addTarget:self action:@selector(clickTestBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)clickTestBtn:(UIButton *)sender {
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        // 资源来源 -> 摄像头
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 摄像头 -> 后置
        _imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        if (_videoModel) {
            _imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
            // 视频质量 -> 1280*720
//            UIImagePickerControllerQualityTypeMedium
            _imagePicker.videoQuality = UIImagePickerControllerQualityTypeHigh;
            // 摄像头捕捉方式 -> 视频
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        }else {
            // 摄像头捕捉方式 -> 图片
            _imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        }
        _imagePicker.allowsEditing = YES;// 允许编辑
        _imagePicker.delegate = self;
        
    }
    return _imagePicker;
}

#pragma mark - 拍照 UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
//    NSLog(@"%@", info);
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"%@", videoURL);
//        NSString *path = videoURL.path;
//        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        // 转化
        ;
        NSURL *newURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@.mp4",NSTemporaryDirectory(), [NSProcessInfo processInfo].globallyUniqueString]];
        [self videoTransformation:videoURL outputURL:newURL];
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"image save is Failure %@", error);
    }else {
       NSLog(@"image save is succeed");
    }
}

#pragma mark - 录视频
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"%@", videoPath);
    NSData *data = [NSData dataWithContentsOfFile:videoPath];
    
    NSLog(@"This video is %0.3fMB", data.length / (1024.0 *1024.0) );
    if (error) {
        NSLog(@"image save is Failure %@", error);
    }else {
        NSLog(@"image save is succeed");
    }
}

#pragma mark - 视频转换
- (void)videoTransformation:(NSURL *)inputURL outputURL:(NSURL *)outputURL {
    NSData *data = [NSData dataWithContentsOfFile:inputURL.path];
    NSLog(@"This video begin %0.3fMB", data.length / (1024.0 *1024.0) );
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    session.outputURL = outputURL;
    session.outputFileType = AVFileTypeQuickTimeMovie;
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"progress %0.02f", session.progress);
        switch (session.status) {
            case AVAssetExportSessionStatusWaiting:{
                NSLog(@"等待ing");
            }break;
            case AVAssetExportSessionStatusExporting:{
                NSLog(@"转化ing");
            }break;
            case AVAssetExportSessionStatusCompleted:{
                NSData *data = [NSData dataWithContentsOfFile:outputURL.path];
                NSLog(@"This video finish %0.3fMB", data.length / (1024.0 *1024.0) );
                
                UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                NSLog(@"完成ing");
            }break;
            case AVAssetExportSessionStatusFailed:{
                NSLog(@"%@", session.error);
                NSLog(@"失败ing");
            }break;
            case AVAssetExportSessionStatusCancelled:{
                NSLog(@"取消ing");
            }break;
                
            default:
                break;
        }
    }];
}
@end
