//
//  XJPlayerManager.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/24.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerManager.h"
#import "TCPlayerView.h"

// category
#import "XJPlayerManager+KeyValueObserver.h"

/*
 自定义的 KVO context 为了监听更加的专注于我们想要的（自我理解）
 */
NSString * const kKeyPathForAsset = @"asset";
NSString * const kKeyPathForPlayerItemStatus = @"player.currentItem.status";
NSString * const kKeyPathForPlayerItemLoadedTimeRanges = @"player.currentItem.loadedTimeRanges";
NSString * const kStopAnotherVideoPlayer = @"StopAnthorVideoPlayer";

PlayerContext TCPlayerViewKVOContext = 0;

@interface XJPlayerManager ()
{
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVURLAsset *_asset;
    NSString *_videoURL;
    NSString *_identifier;
    id<NSObject> _timeObserverToken;// 时间观察token
    __weak TCPlayerView *_playerView;
}
@end
@implementation XJPlayerManager

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self removePropertiesObserver];
}

// MARK: - manager Handling

- (instancetype)init {
    if (self = [super init]) {
        [self xj_buildingPlayerManager];
    }
    return self;
}

- (void)xj_buildingPlayerManager {
    _identifier = [NSProcessInfo processInfo].globallyUniqueString;
    [self addPropertiesObserver];
}

// MARK: - add/remove observer

- (void)addPropertiesObserver {
    // 添加监听
    [self addObserver:self forKeyPath:kKeyPathForAsset options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemLoadedTimeRanges options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAnotherVideoPlay:) name:kStopAnotherVideoPlayer object:nil];
}

- (void)removePropertiesObserver {
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeObserver:self forKeyPath:kKeyPathForAsset context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemStatus context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemLoadedTimeRanges context:&TCPlayerViewKVOContext];
}

// MARK: - Properties

+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}

- (TCPlayerView *)playerView {
    return _playerView;
}
- (void)initializePlayerView:(TCPlayerView *)playerView {
    _playerView = playerView;
//    _playerView.player = self.player;
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AVPlayerItem *)playerItem {
    return _playerItem;
}
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != playerItem) {
        _playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

-(AVURLAsset *)asset {
    return _asset;
}
- (void)setAsset:(AVURLAsset *)asset {
     _asset = asset;
}

- (NSString *)videoURL {
    return self.asset.URL.absoluteString;
}
-(void)setVideoURL:(NSString *)videoURL {
    if ([_videoURL isEqualToString:videoURL]) {
        if (!self.playerItem) {
            [self asynchronouslyLoadURLAsset:_asset];
        }
        return ;
    }
    _videoURL = [videoURL copy];
    NSURL *url = [NSURL URLWithString:videoURL];
    self.asset = [AVURLAsset assetWithURL:url];
}

- (CMTime)currentTime {
    return self.player.currentTime;
}
- (void)setCurrentTime:(CMTime)currentTime {
    // 设置到某个时间播放点， before: after: 改时间点的容错率，前后
    [self.player seekToTime:currentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (CMTime)duration {
    return self.player.currentItem ? self.player.currentItem.duration : kCMTimeZero;
}

- (CGFloat)rate {
    return self.player.rate;
}
- (void)setRate:(CGFloat)newRate {
    self.player.rate = newRate;
}

- (BOOL)isMuted {
    return self.player.muted;
}
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (NSString *)second2MinutesAndSecond:(double)second {
    int wholeMinutes = (int)trunc(second / 60);
    int remainSecond = (int)trunc(second) - wholeMinutes * 60;
    return [NSString stringWithFormat:@"%d:%02d",wholeMinutes, remainSecond];
}

// MARK: - NSNotification Observation

- (void)playerItemDidPlayToEnd:(NSNotification *)note {
    if (self.repeatPlay && note.object == self.playerItem) {
        [self.playerItem seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [self play];
        if ([self.delegate respondsToSelector:@selector(playViewDidPlayToEnd:)]) {
            [self.delegate playViewDidPlayToEnd:self.playerView];
        }
    }
}

- (void)stopAnotherVideoPlay:(NSNotification *)note {
    if (![note.object isEqualToString:_identifier]) {
        [self pause];
    }
}

// MARK: - public function

- (void)clear {
    self.playerItem = nil;
    self.playerView.player = nil;
}

- (void)play {
    // 当前layer的player 一定要在
    if (_playerView.player == nil) {
        _playerView.player = self.player;
    }
    if (self.justOnePlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStopAnotherVideoPlayer object:_identifier];
    }
    if (self.player.rate != 1.0) {
        // not playing 2 play
        if (CMTIME_COMPARE_INLINE(self.currentTime, ==, self.duration)) {
            // at end so got back to begining
            self.currentTime = kCMTimeZero;
        }
        // play will set rate 1.0
        [self.player play];
    }
}

- (void)pause {
    [self.player pause];
}


@end
