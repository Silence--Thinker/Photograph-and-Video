//
//  ListViewController.h
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPlayerManager.h"

@interface ListViewController : UITableViewController

@end


@interface XJModel : NSObject

@property (nonatomic, strong) XJPlayerManager *manager;

@property (nonatomic, strong) NSURL *videoURL;

@end