//
//  XJPlayerView.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerView.h"
#import "XJPlayerManager.h"

@interface XJPlayerView ()

@property (nonatomic, strong) AVPlayerItem *playerItem;

@end
@implementation XJPlayerView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: - View Handling

- (instancetype)init {
    if (self = [super init]) {
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return self;
}

- (instancetype)initWithPlayerManager:(XJPlayerManager *)manager {
    XJPlayerView *playerView = [XJPlayerView new];
    playerView.playerManager = manager;
    return playerView;
}

// MARK: - Properties

- (AVPlayer *)player {
    return self.playerLayer.player;
}
- (void)setPlayer:(AVPlayer *)player {
    self.playerLayer.player = player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayerManager:(XJPlayerManager *)playerManager {
    _playerManager = playerManager;
    [_playerManager initializePlayerView:self];
}



@end

