//
//  XJPresenterStyle.h
//  CustomPresationController
//
//  Created by Silence on 15/5/14.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XJAnimatedTransitioning.h"

@interface XJPresenterStyle : NSObject <UIViewControllerTransitioningDelegate>

@property (copy, nonatomic) TransitionAnimatedBlock animateBlock;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@end
