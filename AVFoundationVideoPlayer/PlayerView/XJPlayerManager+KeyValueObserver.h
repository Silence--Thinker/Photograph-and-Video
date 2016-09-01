//
//  XJPlayerManager+KeyValueObserver.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerManager.h"

@interface XJPlayerManager (KeyValueObserver)

- (void)asynchronouslyLoadURLAsset:(AVURLAsset *)newAsset comletion:(void(^)())completion;

@end
