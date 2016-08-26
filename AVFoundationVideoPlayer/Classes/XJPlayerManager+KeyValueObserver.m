//
//  XJPlayerManager+KeyValueObserver.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerManager+KeyValueObserver.h"

extern NSString * const kKeyPathForAsset;
extern NSString * const kKeyPathForPlayerItemStatus ;
extern NSString * const kKeyPathForPlayerItemLoadedTimeRanges;

extern PlayerContext TCPlayerViewKVOContext;


@implementation XJPlayerManager (KeyValueObserver)

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
    } else if ([keyPath isEqualToString:kKeyPathForPlayerItemStatus]) {
        
        NSNumber *newStatusAsNumber = change[NSKeyValueChangeNewKey];
        AVPlayerItemStatus newStatus = [newStatusAsNumber isKindOfClass:[NSNumber class]] ? newStatusAsNumber.integerValue : AVPlayerItemStatusUnknown;
        
        if (newStatus == AVPlayerItemStatusFailed) {
//            [self clear];
            if ([self.delegate respondsToSelector:@selector(playViewDidPlayToFailed:error:)]) {
                [self.delegate playViewDidPlayToFailed:self.playerView error:self.playerItem.error];
            }
        }else if (newStatus == AVPlayerItemStatusReadyToPlay) {
            
            if ([self.delegate respondsToSelector:@selector(playViewWillReadyToPlay:)]) {
                [self.delegate playViewWillReadyToPlay:self.playerView];
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


@end
