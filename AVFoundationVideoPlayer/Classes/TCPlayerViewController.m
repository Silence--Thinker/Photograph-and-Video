//
//  TCPlayerViewController.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "TCPlayerViewController.h"

#import "TCPlayerView.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

/*
 自定义的 KVO context 为了监听更加的专注于我们想要的（自我理解）
 */
static NSString * const kKeyPathForAsset = @"asset";
static NSString * const kKeyPathForPlayerRate = @"player.rate";
static NSString * const kKeyPathForPlayerItemStatus = @"player.currentItem.status";
static NSString * const kKeyPathForPlayerItemDuration = @"player.currentItem.duration";

static int TCPlayerViewControllerKVOContext = 0;

@interface TCPlayerViewController ()
{
    AVPlayer *_player;
    id<NSObject> _timeObserverToken;// 时间观察token
    AVPlayerItem *_playerItem;
}
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@end
@implementation TCPlayerViewController

// MARK: - View Handling

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildingSubViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 添加监听
    [self addObserver:self forKeyPath:kKeyPathForAsset options:NSKeyValueObservingOptionNew context:&TCPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemDuration options:NSKeyValueObservingOptionNew |  NSKeyValueObservingOptionInitial context:&TCPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerRate options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewControllerKVOContext];
    [self addObserver:self forKeyPath:kKeyPathForPlayerItemStatus options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context:&TCPlayerViewControllerKVOContext];
    
    self.playerView.playerLayer.player = self.player;
    
    // 设置资源URL
    NSURL *moviceURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    self.asset = [AVURLAsset assetWithURL:moviceURL];
    
    // 每过 1s 监听时间 变化
    __weak typeof(self) weakSelf = self;
    _timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        weakSelf.timeSlider.value = CMTimeGetSeconds(time);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_timeObserverToken) {
        [self.player removeTimeObserver:_timeObserverToken];
        _timeObserverToken = nil;
    }
    
    [self.player pause];
    
    [self removeObserver:self forKeyPath:kKeyPathForAsset context:&TCPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemDuration context:&TCPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerRate context:&TCPlayerViewControllerKVOContext];
    [self removeObserver:self forKeyPath:kKeyPathForPlayerItemStatus context:&TCPlayerViewControllerKVOContext];
    
}

// MARK: - config Subviews

- (void)buildingSubViews {
    self.view.backgroundColor = [UIColor grayColor];
    TCPlayerView *playerView = [[TCPlayerView alloc] init];
    playerView.frame = CGRectInset(self.view.bounds, 20, 30);
    [self.view addSubview:playerView];
    self.playerView = playerView;
    
    CGFloat sliderX = 50;
    CGFloat sliderH = 20;
    _timeSlider = [[UISlider alloc] init];
    _timeSlider.backgroundColor = [UIColor redColor];
    [self.view addSubview:_timeSlider];
    _timeSlider.frame = CGRectMake(sliderX, SCREEN_HEIGHT - sliderH, SCREEN_WIDTH - 2 * sliderX, sliderH);
    
    _startTimeLabel = [[UILabel alloc] init];
    _startTimeLabel.font = [UIFont systemFontOfSize:11.0];
    _startTimeLabel.textColor = [UIColor blackColor];
    _startTimeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:_startTimeLabel];
    _startTimeLabel.frame = CGRectMake(sliderX, CGRectGetMinY(_timeSlider.frame) - 20, 50, 20);
    _startTimeLabel.text = @"0.00";
    
    _durationTimeLabel = [[UILabel alloc] init];
    _durationTimeLabel.font = [UIFont systemFontOfSize:11.0];
    _durationTimeLabel.textColor = [UIColor blackColor];
    _durationTimeLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:_durationTimeLabel];
    _durationTimeLabel.frame = CGRectMake(sliderX + CGRectGetWidth(_timeSlider.frame) - 50, CGRectGetMinY(_timeSlider.frame) - 20, 50, 20);
    _durationTimeLabel.text = @"0.00";
    
    
}

// MARK: - Properties

// Will attempt load and test these asset keys before playing
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

- (AVPlayerLayer *)playerLayer {
    return self.playerView.playerLayer;
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

// MARK: - Asset Loading

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset {
    [newAsset loadValuesAsynchronouslyForKeys:TCPlayerViewController.assetKeysRequiredToPlay completionHandler:^{
       
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
    
    if (context != &TCPlayerViewControllerKVOContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if ([keyPath isEqualToString:kKeyPathForAsset]) {
        if (self.asset) {
            // 到这一步视频就会 加载进来了。会有默认帧图
            [self asynchronouslyLoadURLAsset:self.asset];
        }
    }else if ([keyPath isEqualToString:kKeyPathForPlayerItemDuration]){
        // update timeSlider and enable/disable controls when duration > 0.0
        
        NSValue *newDurationAsvalue = change[NSKeyValueChangeNewKey];
        CMTime newDuration = [newDurationAsvalue isKindOfClass:[NSValue class]] ? newDurationAsvalue.CMTimeValue : kCMTimeZero;
        BOOL hasValidDuration = CMTIME_IS_NUMERIC(newDuration) && newDuration.value != 0;
        double newDurationSeconds = hasValidDuration ? CMTimeGetSeconds(newDuration) : 0.0;
        
        self.timeSlider.maximumValue = newDurationSeconds;
        self.timeSlider.value = hasValidDuration ? CMTimeGetSeconds(self.currentTime) : 0.0;
        
        self.startTimeLabel.text = [self second2MinutesAndSecond:CMTimeGetSeconds(self.currentTime)];
        self.durationTimeLabel.text = [self second2MinutesAndSecond:newDurationSeconds];
        
    }else if ([keyPath isEqualToString:kKeyPathForPlayerRate]){
        double newRate = [change[NSKeyValueChangeNewKey] doubleValue];
        NSLog(@"the new rate is %0.2f", newRate);
        
    }else if ([keyPath isEqualToString:kKeyPathForPlayerItemStatus]){
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
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
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
