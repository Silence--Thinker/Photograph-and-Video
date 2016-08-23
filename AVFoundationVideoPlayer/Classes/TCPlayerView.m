//
//  TCPlayerView.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "TCPlayerView.h"
#import <AVFoundation/AVFoundation.h>

/*
 自定义的 KVO context 为了监听更加的专注于我们想要的（自我理解）
 */
static NSString * const kKeyPathForAsset = @"asset";
static NSString * const kKeyPathForPlayerRate = @"player.rate";
static NSString * const kKeyPathForPlayerItemStatus = @"player.currentItem.status";
static NSString * const kKeyPathForPlayerItemDuration = @"player.currentItem.duration";

static int TCPlayerViewKVOContext = 0;

@interface TCPlayerView ()
{
    AVPlayer *_player;
    id<NSObject> _timeObserverToken;// 时间观察token
    AVPlayerItem *_playerItem;
}
@property (nonatomic, strong) AVPlayerItem *playerItem;

@end
@implementation TCPlayerView

// MARK: - View Handling

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self xj_buildingPlayer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self xj_buildingPlayer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self xj_buildingPlayer];
}

- (void)xj_buildingPlayer {
    [self addPropertiesObserver];
    
    self.playerLayer.player = self.player;
    
    // 设置资源URL
//    NSURL *moviceURL = [[NSBundle mainBundle] URLForResource:@"movie" withExtension:@"mp4"];
    NSURL *moviceURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    self.asset = [AVURLAsset assetWithURL:moviceURL];
    
    // 每过 1s 监听时间 变化
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 定时刷新时间轴 跟 滑动滑块刷新 冲突 will TO DO
    }];
}

- (void)dealloc {
    [self removePropertiesObserver];
}

// MARK: - add/remove observer

- (void)addPropertiesObserver {
    // 添加监听
    [self addObserver:self forKeyPath:kKeyPathForAsset options:NSKeyValueObservingOptionNew context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemDuration options:NSKeyValueObservingOptionNew |  NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerRate options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewKVOContext];
}
- (void)removePropertiesObserver {
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:kKeyPathForAsset context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemDuration context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerRate context:&TCPlayerViewKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemStatus context:&TCPlayerViewKVOContext];
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

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

// override UIView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}

// MARK: - Asset Loading

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    [newAsset loadValuesAsynchronouslyForKeys:TCPlayerView.assetKeysRequiredToPlay completionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (newAsset != self.asset) {
                return ;
            }
            
            for (NSString *key in self.class.assetKeysRequiredToPlay) {
                NSError *error = nil;
                if ([newAsset statusOfValueForKey:key error:&error] == AVKeyValueStatusFailed) {
                    NSString *message = [NSString localizedStringWithFormat:NSLocalizedString(@"error.asset_key_%@_failed.description", @"Can't use this AVAsset because one of it's keys failed to load"), key];
                    [self handleErrorWithMessage:message error:error];
                    return ;
                }
            }
            
            // can't play this asset
            if (!newAsset.playable || newAsset.hasProtectedContent) {
                NSString *message = NSLocalizedString(@"error.asset_not_playable.description", @"Can't use this AVAsset because it isn't playable or has protected content");
                
                [self handleErrorWithMessage:message error:nil];
                
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
            NSLog(@"now begin loading resource ");
            // 到这一步视频就会 加载进来了。会有默认帧图
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }else if ([keyPath isEqualToString:kKeyPathForPlayerItemDuration]){
        
        // update timeSlider and enable/disable controls when duration > 0.0
        // when playItem Initial or update playItem is called.resource no change no called again
        
        NSValue *newDurationAsvalue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsvalue isKindOfClass:[NSValue class]] ? newDurationAsvalue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
        
        NSLog(@"now currentTime is %0.2f", newDurationSeconds);
        
    }else if ([keyPath isEqualToString:kKeyPathForPlayerRate]){
        
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        NSLog(@"the new rate is %0.2f", newRate);
        
    }else if ([keyPath isEqualToString:kKeyPathForPlayerItemStatus]){
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        NSLog(@"playItem status have change new status : %zd", newStatus);
        if (newStatus == AVPlayerItemStatusFailed) {
            [self handleErrorWithMessage:self.player.currentItem.error.localizedDescription error:self.player.currentItem.error];
        }
    }else {
        
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (NSString *)second2MinutesAndSecond:(double)second {
    int wholeMinutes = (int)trunc(second / 60);
    int remainSecond = (int)trunc(second) - wholeMinutes * 60;
    return [NSString stringWithFormat:@"%d:%02d",wholeMinutes, remainSecond];
}

// MARK: - Error Handling

- (void)handleErrorWithMessage:(NSString *)message error:(NSError *)error {
    NSLog(@"Error occured with message: %@, error: %@.", message, error);
    
    NSString *alertTitle = NSLocalizedString(@"alert.error.title", @"Alert title for errors");
    NSString *defaultAlertMesssage = NSLocalizedString(@"error.default.description", @"Default error message when no NSError provided");
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle message:message ?: defaultAlertMesssage preferredStyle:UIAlertControllerStyleAlert];
    
    NSString *alertActionTitle = NSLocalizedString(@"alert.error.actions.OK", @"OK on error alert");
    UIAlertAction *action = [UIAlertAction actionWithTitle:alertActionTitle style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:action];
    
    [self.superVC presentViewController:controller animated:YES completion:nil];
}

@end
