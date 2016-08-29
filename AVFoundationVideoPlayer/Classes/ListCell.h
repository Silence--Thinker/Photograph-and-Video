//
//  ListCell.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerView.h"
#import "XJPlayerManager.h"
#import "ListViewController.h"

@interface ListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet XJPlayerView *playerView;
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) XJModel *model;
@end
