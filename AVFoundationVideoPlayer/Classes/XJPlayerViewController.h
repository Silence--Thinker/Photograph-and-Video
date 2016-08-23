//
//  XJPlayerViewController.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/23.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TCPlayerView;
@interface XJPlayerViewController : UIViewController

/** 播放器 */
@property (nonatomic, strong, readonly) AVPlayer *player;

/** 资源路径 */
@property (nonatomic, strong) AVURLAsset *asset;
/** 开始时间 */
@property (nonatomic, weak) UILabel *startTimeLabel;
/** 持续时间 总共时长 */
@property (nonatomic, weak) UILabel *durationTimeLabel;

/** 播放/暂停 */
@property (nonatomic, weak) UIButton *playPauseButton;
/** 时间轴 */
@property (nonatomic, weak) UISlider *timeSlider;


@property (nonatomic, weak) TCPlayerView *playerView;
@end
