//
//  XJPlayerView.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJPlayerManager;
@interface XJPlayerView : UIView

-(instancetype)initWithPlayerManager:(XJPlayerManager *)manager;

/** 播放器 */
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) XJPlayerManager *playerManager;
@end



