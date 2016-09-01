//
//  XJPresenterStyle.m
//  CustomPresationController
//
//  Created by Silence on 15/5/14.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import "XJPresenterStyle.h"
#import "XJPresentationController.h"

@interface XJPresenterStyle () <XJPresentationControllerDelegate>
/** presentationController控制器 */
@property (strong, nonatomic) XJPresentationController *presentationVC;

/** 过渡动画 */
@property (strong, nonatomic) XJAnimatedTransitioning *transitioning;

@end
@implementation XJPresenterStyle

#pragma mark - UIViewControllerTransitioningDelegate
- (XJPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    // 只能用这一种创建方式
    if (!self.presentationVC) {
        self.presentationVC = [[XJPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
        self.presentationVC.xj_presentationDelegate = self;
    }
    return self.presentationVC;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transitioning.isPresentation = YES;
    return self.transitioning;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transitioning.isPresentation = NO;
    return self.transitioning;
}

- (void)presentationControllerDidDismissed:(XJPresentationController *)controller {
    self.presentationVC = nil;
}

- (XJAnimatedTransitioning *)transitioning {
    if (!_transitioning) {
        _transitioning = [[XJAnimatedTransitioning alloc] init];
    }
    return _transitioning;
}

//- presentationcontr

- (void)setAnimateBlock:(TransitionAnimatedBlock)animateBlock {
    _animateBlock = [animateBlock copy];
    self.transitioning.animateBlock = animateBlock;
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration {
    self.transitioning.animationDuration = animationDuration;
}
@end
