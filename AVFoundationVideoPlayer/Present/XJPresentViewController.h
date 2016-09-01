//
//  XJPresentViewController.h
//  CustomPresationController
//
//  Created by Silence on 15/5/14.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJPresenterStyle.h"

@interface XJPresentViewController : UIViewController

/**
 *  动画的回调
 */
@property (copy, nonatomic) TransitionAnimatedBlock animateBlock;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@end
