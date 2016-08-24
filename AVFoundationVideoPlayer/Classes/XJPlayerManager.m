//
//  XJPlayerManager.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/24.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerManager.h"

/*
 自定义的 KVO context 为了监听更加的专注于我们想要的（自我理解）
 */
static NSString * const kKeyPathForAsset = @"asset";
static NSString * const kKeyPathForPlayerRate = @"player.rate";
static NSString * const kKeyPathForPlayerItemStatus = @"player.currentItem.status";
static NSString * const kKeyPathForPlayerItemDuration = @"player.currentItem.duration";
static NSString * const kKeyPathForPlayerItemLoadedTimeRanges = @"player.currentItem.loadedTimeRanges";

static int TCPlayerViewKVOContext = 0;

@interface XJPlayerManager ()
{
    AVPlayer *_player;
    id<NSObject> _timeObserverToken;// 时间观察token
    AVPlayerItem *_playerItem;
//    XJPlayerKeyValueObserver *_keyValueObserVer;
}
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end
@implementation XJPlayerManager

// MARK: - manager Handling

- (instancetype)init {
    if (self = [super init]) {
        [self xj_buildingPlayerManager];
    }
    return self;
}

- (void)xj_buildingPlayerManager {
    [self addPropertiesObserver];
    
    self.playerView.player = self.player;
    
    //    NSURL *moviceURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    NSURL *moviceURL = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1608/24/QZlcB4089/SD/QZlcB4089-mobile.mp4"];
    self.asset = [AVURLAsset assetWithURL:moviceURL];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
    [self removePropertiesObserver];
}

// MARK: - add/remove observer

- (void)addPropertiesObserver {
    // 添加监听
    [self addObserver:self forKeyPath:kKeyPathForAsset options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemDuration options:NSKeyValueObservingOptionNew |  NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerRate options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemLoadedTimeRanges options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
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
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemDuration context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerRate context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemStatus context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemLoadedTimeRanges context:&TCPlayerViewKVOContext];
}

// MARK: - Properties

+ (NSArray *)assetKeysRequiredToPlay {
    return @[ @"playable", @"hasProtectedContent" ];
}

- (AVPlayer *)player {
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
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

- (AVPlayerItem *)playerItem {
    return _playerItem;
}
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != playerItem) {
        _playerItem = playerItem;
        [self.player replaceCurrentItemWithPlayerItem:_playerItem];
    }
}

- (void)setAsset:(AVURLAsset *)asset
// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

// MARK: - Asset Loading

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    [newAsset loadValuesAsynchronouslyForKeys:XJPlayerManager.assetKeysRequiredToPlay completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newAsset != self.asset) {
                return ;
            }
            
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                NSError *error = nil;
                if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    return ;
                }
            }
            
            // can't play this asset
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                return;
            }
            // can play this asset
            self.playerItem = [AVPlayerItem playerItemWithAsset:newAsset];
        });
    }];
}


// MARK: - KV Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (context != &TCPlayerViewKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:kKeyPathForAsset]) {
        if (self.asset) {
            // 到这一步视频就会 加载进来了。会有默认帧图
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    } else if ([keyPath isEqualToString:kKeyPathForPlayerItemDuration]) {
        
        // update timeSlider and enable/disable controls when duration > 0.0
        // when playItem Initial or update playItem is called.resource no change no called again
        
        NSValue *newDurationAsvalue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsvalue isKindOfClass:[NSValue class]] ? newDurationAsvalue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
        
        NSLog(@"now currentTime is %0.2f", newDurationSeconds);
        
    } else if ([keyPath isEqualToString:kKeyPathForPlayerRate]) {
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        NSLog(@"the new rate is %0.2f", newRate);
        
    } else if ([keyPath isEqualToString:kKeyPathForPlayerItemStatus]) {
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(playViewDidPlayToFailed:error:)]) {
                [self.delegate playViewDidPlayToFailed:self error:self.playerItem.error];
            }
        }else if (newStatus == AVPlayerItemStatusReadyToPlay) {
            if ([self.delegate respondsToSelector:@selector(playViewWillReadyToPlay:)]) {
                [self.delegate playViewWillReadyToPlay:self];
            }
        }else if(newStatus == AVPlayerItemStatusUnknown) {
            
        }
    } else if ([keyPath isEqualToString:kKeyPathForPlayerItemLoadedTimeRanges]){
        NSArray<NSValue *> *timeRanges = self.playerItem.loadedTimeRanges;
        for (NSValue  *value in timeRanges) {
            NSLog(@"========%@=====", value);
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSString *)second2MinutesAndSecond:(double)second {
    int wholeMinutes = (int)trunc(second / 60);
    int remainSecond = (int)trunc(second) - wholeMinutes * 60;
    return [NSString stringWithFormat:@"%d:%02d",wholeMinutes, remainSecond];
}

// MARK: - NSNotification Observation

- (void)playerItemDidPlayToEnd:(NSNotification *)note {
    if (self.repeatPlay) {
        [self play];
    }
    
    if ([self.delegate respondsToSelector:@selector(playViewDidPlayToEnd:)]) {
        [self.delegate playViewDidPlayToEnd:self];
    }
}

// MARK: - public function

- (void)play {
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
    if (self.repeatPlay) {
        [self play];
        return ;
    }
    [self.player pause];
}


@end
