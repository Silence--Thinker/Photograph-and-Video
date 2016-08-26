//
//  XJPlayerManager.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/24.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kKeyPathForAsset;
extern NSString * const kKeyPathForPlayerItemStatus ;
extern NSString * const kKeyPathForPlayerItemLoadedTimeRanges;
typedef int PlayerContext;
extern PlayerContext TCPlayerViewKVOContext;

@class TCPlayerView;
@protocol XJPlayerManagerDelegate <NSObject>

@optional

- (void)playViewWillReadyToPlay:(TCPlayerView *)playView;
- (void)playViewDidPlayToEnd:(TCPlayerView *)playView;
- (void)playViewDidPlayToFailed:(TCPlayerView *)playView error:(NSError *)error;


@end
@interface XJPlayerManager : NSObject

@property (nonatomic, weak, readonly) TCPlayerView *playerView;

/** 播放器 */
@property (nonatomic, strong, readonly) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;

/** 资源路径 */
@property (nonatomic, strong, readonly) AVURLAsset *asset;
@property (nonatomic, copy) NSString *videoURL;
/** 当前时间 */
@property (nonatomic, assign) CMTime currentTime;
/** 持续时间 */
@property (nonatomic, assign, readonly) CMTime duration;
/** 播放速率 1.0 是自然播放 */
@property (nonatomic, assign) CGFloat rate;


/** 重复播放 default is NO */
@property (nonatomic, assign) BOOL repeatPlay;
/** 是否有声音播放 default is NO */
@property (nonatomic, assign, getter=isMuted) BOOL muted;
@property (nonatomic, assign) BOOL justOnePlay;


@property (nonatomic, weak) id<XJPlayerManagerDelegate> delegate;
- (void)initializePlayerView:(TCPlayerView *)playerView;
- (void)clear;
- (void)play;
- (void)pause;
+ (NSArray *)assetKeysRequiredToPlay;
@end
