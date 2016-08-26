//
//  ListCell.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "ListCell.h"

@interface ListCell ()

@property (nonatomic, strong) XJPlayerManager *manager;

@end
@implementation ListCell

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setModel:(XJModel *)model {
    _model = model;
    self.playerView.playerManager = model.manager;
    self.manager = model.manager;
}

- (IBAction)didPlayerOrPuase:(UIButton *)tap {
    self.model.manager.videoURL = self.model.videoURL.absoluteString;
    
    if (self.manager.rate != 1.0) {
        [self.manager play];
    }else {
        [self.manager pause];
    }
}

- (void)prepareForReuse {
    [self.manager pause];
    self.playerView.player = nil;
}
@end
