//
//  XJPlayerViewController.h
//  TCTTraffic_IPhone
//
//  Created by Silence on 16/8/30.
//  Copyright © 2016年 www.ly.com. All rights reserved.
//

#import "XJPresentViewController.h"


@interface XJPresentPlayerViewController : XJPresentViewController

@property (nonatomic, copy) void(^didPressedDelete)();
@property (nonatomic, assign) CGRect fromePlayViewFrame;
@property (nonatomic, assign, getter=isHiddnDelete) BOOL hiddenDelete;


- (void)play;
- (void)pause;
@end
