//
//  TCPlayerView.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "TCPlayerView.h"
#import "XJPlayerManager.h"

@interface TCPlayerView ()

@property (nonatomic, strong) AVPlayerItem *playerItem;

@end
@implementation TCPlayerView

-(void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: - View Handling

-(instancetype)initWithPlayerManager:(XJPlayerManager *)manager {
    if (self = [super init]) {
        self.playerManager = manager;
        self.playerManager.playerView = self;
    }
    return self;
}

// MARK: - Properties

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
