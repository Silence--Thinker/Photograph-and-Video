//
//  XJAnimatedTransitioning.h
//  CustomPresationController
//
//  Created by Silence on 15/5/13.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TransitionAnimatedBlock)(id <UIViewControllerContextTransitioning> transitionContext, UIViewController * animateViewController, UIView *animateView, BOOL isPresentation);

@interface XJAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
/**
 *  是否是present状态
 */
@property (assign, nonatomic) BOOL isPresentation;

@property (copy, nonatomic) TransitionAnimatedBlock animateBlock;

@property (nonatomic, assign) NSTimeInterval animationDuration;

@end
