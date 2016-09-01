//
//  XJPlayerManager.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/24.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerManager.h"
#import "XJPlayerView.h"

// category
#import "XJPlayerManager+KeyValueObserver.h"

#import "XJResourceLoaderManager.h"

/*
 自定义的 KVO context 为了监听更加的专注于我们想要的（自我理解）
 */
NSString * const kKeyPathForAsset = @"asset";
NSString * const kKeyPathForPlayerItemStatus = @"player.currentItem.status";
NSString * const kKeyPathForPlayerItemLoadedTimeRanges = @"player.currentItem.loadedTimeRanges";
NSString * const kKeyPathForPlayerItemBufferEmpty = @"player.currentItem.playbackBufferEmpty";
NSString * const kKeyPathForPlayerItemLikelyToKeepUp = @"player.currentItem.playbackLikelyToKeepUp";
NSString * const kStopAnotherVideoPlayer = @"StopAnthorVideoPlayer";
NSString * const kCustomScheme = @"customScheme";

PlayerContext TCPlayerViewKVOContext = 0;

@interface XJPlayerManager ()
{
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVURLAsset *_asset;
    NSURL *_videoURL;
    NSString *_videoURLStr;
    NSString *_identifier;
    id<NSObject> _timeObserverToken;// 时间观察token
    __weak XJPlayerView *_playerView;
    XJResourceLoaderManager *_resourceManager;
}
@end
@implementation XJPlayerManager

- (void)dealloc {
    NSLog(@"%s", __func__);
    self.playerView.player = nil;
    self.playerItem = nil;
    self.playerView.playerLayer = nil;
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
    // 资源
    [self addObserver:self forKeyPath:kKeyPathForAsset options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    // 播放器状态
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    // 加载的进度
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemLoadedTimeRanges options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    // 缓存区为空
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemBufferEmpty options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    // 缓存足够去播放
     [self addObserver:self forKeyPath:kKeyPathForPlayerItemLikelyToKeepUp options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    
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
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemBufferEmpty context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemLikelyToKeepUp context:&TCPlayerViewKVOContext];
    
}

// MARK: - Properties

+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}

- (XJPlayerView *)playerView {
    return _playerView;
}
- (void)initializePlayerView:(XJPlayerView *)playerView {
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
    if (_playerView.player == nil) {
        _playerView.player = self.player;
    }
    
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

- (NSURL *)videoURL {
    return _videoURL;
}
- (void)setVideoURL:(NSURL *)videoURL {
    if ([_videoURL.absoluteString isEqualToString:videoURL.absoluteString]) {
        if (!self.playerItem) {
            [self asynchronouslyLoadURLAsset:_asset comletion:nil];
        }
        return;
    }
    _videoURL = videoURL;
    //    self.asset = [AVURLAsset assetWithURL:_videoURL];
    
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:videoURL resolvingAgainstBaseURL:NO];
    components.scheme = kCustomScheme;
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:components.URL options:nil];
    [urlAsset.resourceLoader setDelegate:_resourceManager queue:dispatch_get_main_queue()];
    self.asset = urlAsset;
}

- (NSString *)videoURLStr {
    return self.asset.URL.absoluteString;
}
-(void)setVideoURLStr:(NSString *)videoURLStr {
    if ([_videoURLStr isEqualToString:videoURLStr]) {
        if (!self.playerItem) {
            [self asynchronouslyLoadURLAsset:_asset comletion:nil];
        }
        return ;
    }
    _videoURLStr = [videoURLStr copy];
    NSURL *url = [NSURL URLWithString:videoURLStr];
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
    if (self.justOnePlay) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStopAnotherVideoPlayer object:_identifier];
    }
    
    // 当前layer的player 一定要在
    if (_playerView.player == nil) {
        _playerView.player = self.player;
    }
    // 播放item还没有
    if (self.playerItem == nil) {
        __weak typeof(self) weakSelf = self;
        [self asynchronouslyLoadURLAsset:_asset comletion:^{
            [weakSelf play];
        }];
        return ;
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
