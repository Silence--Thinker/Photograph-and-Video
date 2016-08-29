//
//  TCPlayerViewController.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJPlayerView;
@interface TCPlayerViewController : UIViewController

/** 播放器 */
@property (nonatomic, strong, readonly) AVPlayer *player;
/** 资源路径 */
@property (nonatomic, strong) AVURLAsset *asset;

/** 时间轴 */
@property (nonatomic, assign) CMTime currentTime;
/** 持续时间 */
@property (nonatomic, assign, readonly) CMTime duration;
/** 播放速率 1.0 是自然播放 */
@property (nonatomic, assign) CGFloat rate;


/** 时间轴 */
@property (nonatomic, strong) UISlider *timeSlider;
/** 开始时间 */
@property (nonatomic, strong) UILabel *startTimeLabel;
/** 持续时间 总共时长 */
@property (nonatomic, strong) UILabel *durationTimeLabel;
/** 倒带 */
@property (nonatomic, strong) UIButton *rewindButton;
/** 暂停 */
@property (nonatomic, strong) UIButton *playPauseButton;
/** 快进 */
@property (nonatomic, strong) UIButton *fastForwardButton;


/** 播放器视图 */
@property (nonatomic, weak) XJPlayerView *playerView;

@end
