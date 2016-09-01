//
//  XJPresentationController.m
//  CustomPresationController
//
//  Created by Silence on 15/5/13.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import "XJPresentationController.h"

@interface XJPresentationController ()

@property (nonatomic, strong) UIView *customContainerView;

@end
@implementation XJPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        _customContainerView = [UIView new];
        _customContainerView.alpha = 0.0;
    }
    return self;
}


/** 自定义动画必须写的添加视图 */ //Transition 过渡
- (void)presentationTransitionWillBegin {
    // 添加视图
    self.customContainerView.frame = self.containerView.bounds;
    [self.containerView insertSubview:self.customContainerView atIndex:0];
    
    self.customContainerView.alpha = 0.0;
    
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.customContainerView.alpha = 1.0;
        } completion:nil];
    }else {
        self.customContainerView.alpha = 1.0;
    }
}

- (void)dismissalTransitionWillBegin {
    id<UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            self.customContainerView.alpha = 0.0;
        } completion:nil];
    }else {
        self.customContainerView.alpha = 0.0;
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.presentedView removeFromSuperview];
    }
    if (self.xj_presentationDelegate && [self.xj_presentationDelegate respondsToSelector:@selector(presentationControllerDidDismissed:)]) {
        [self.xj_presentationDelegate presentationControllerDidDismissed:self];
    }
}

- (void)containerViewWillLayoutSubviews {
    self.customContainerView.frame = self.containerView.bounds;
    self.presentedView.frame = self.containerView.bounds;
}

- (BOOL)shouldPresentInFullscreen {
    return YES;
}

- (UIModalPresentationStyle)adaptivePresentationStyle {
    return UIModalPresentationCustom;
}
@end
