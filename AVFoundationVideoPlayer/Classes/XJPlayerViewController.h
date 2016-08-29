//
//  XJPlayerViewController.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/23.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJPlayerView;
@interface XJPlayerViewController : UIViewController

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



@end
