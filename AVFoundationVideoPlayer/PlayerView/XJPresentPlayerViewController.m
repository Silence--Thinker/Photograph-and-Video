//
//  XJPlayerViewController.m
//  TCTTraffic_IPhone
//
//  Created by Silence on 16/8/30.
//  Copyright © 2016年 www.ly.com. All rights reserved.
//

#import "XJPresentPlayerViewController.h"
#import "XJPlayerView.h"
#import "XJPlayerManager.h"

@interface XJPresentPlayerViewController () <XJPlayerManagerDelegate>

@property (nonatomic, strong) XJPlayerView *playerView;
@property (nonatomic, strong) XJPlayerManager *manager;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, assign) BOOL presentAnimationEnd;
@property (nonatomic, assign) CGFloat progressRate;
@property (nonatomic, assign, getter=isPresentation) BOOL presentation;

@end
@implementation XJPresentPlayerViewController

- (void)dealloc {
    [self clear];
    NSLog(@"%s", __func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    _presentAnimationEnd = NO;
    _progressRate = 0.0;
    
    [self xj_buildingPlayerViewSubViews];
    [self xj_initializePlayerViewLayout];
    [self xj_presentStyleAnimated];
}

- (void)xj_buildingPlayerViewSubViews {
    _manager = [XJPlayerManager new];
    _manager.repeatPlay = YES;
    _manager.justOnePlay = YES;
    _manager.muted = NO;
    _manager.delegate = self;
    
    _playerView = [[XJPlayerView alloc] initWithPlayerManager:_manager];
    _playerView.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_playerView];
    
    _deleteBtn = [[UIButton alloc] init];
    [_deleteBtn setImage:[UIImage imageNamed:@"icon_detail_trashin"] forState:UIControlStateNormal];
    [_deleteBtn addTarget:self action:@selector(didPressedDelegateVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_deleteBtn];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchPlayerViw:)];
    [_playerView addGestureRecognizer:tap];
}

- (void)xj_initializePlayerViewLayout {
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_playerView.mas_top).offset(20);
        make.trailing.equalTo(_playerView.mas_trailing).offset(-20);
    }];
    
    _manager.videoURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
}

- (void)xj_presentStyleAnimated {
    CGFloat duration = 0.35;
    self.animationDuration = duration;
    TCWeakSelf
    self.animateBlock = ^(id <UIViewControllerContextTransitioning> transitionContext, UIViewController * animateViewController, UIView *animateView, BOOL isPresentation){
        __weakSelf.presentation = isPresentation;
        UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
        CGRect onScreenFrame = [transitionContext finalFrameForViewController:animateViewController];

        animateView.frame = onScreenFrame;
        animateView.alpha = isPresentation ? 0 : 1;
        
        [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewAnimationOptionShowHideTransitionViews | UIViewAnimationOptionCurveEaseOut animations:^{
            animateView.frame = onScreenFrame;
            animateView.alpha = isPresentation ? 1 : 0;
        } completion:^(BOOL finished) {
           
            __weakSelf.presentAnimationEnd = YES;
            if (isPresentation) {
                if (__weakSelf.progressRate == 1.0) {
                    [__weakSelf play];
                }
            }else {
                [fromView removeFromSuperview];
                [__weakSelf clear];
            }
         [transitionContext completeTransition:YES];
        }];
    };
}

- (CGPoint)centerForRect:(CGRect)rect {
    CGFloat centerX = CGRectGetMidX(rect);
    CGFloat centerY = CGRectGetMidY(rect);
    return (CGPoint){centerX, centerY};
}

// MARK: - XJPlayerManagerDelegate

- (void)playViewWillReadyToPlay:(XJPlayerView *)playView {
    
}

- (void)playView:(XJPlayerView *)playView didPlayProgressRate:(CGFloat)progressRate {
    _progressRate = progressRate;
    if (self.presentation) {
        if (progressRate == 1.0 && _presentAnimationEnd) {
            [self play];
        }
    }else {
        [self pause];
    }
}

- (void)didPressedDelegateVideo:(UIButton *)sender {
    [self touchPlayerViw:nil];
    if (self.didPressedDelete) {
        self.didPressedDelete();
    }
}

- (void)touchPlayerViw:(UITapGestureRecognizer *)tap {
    [self pause];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setHiddenDelete:(BOOL)hiddenDelete {
    _hiddenDelete = hiddenDelete;
    self.deleteBtn.hidden = hiddenDelete;
}

- (void)clear {
    [self.manager pause];
    self.playerView.playerLayer = nil;
    self.playerView.player = nil;
    self.manager.playerItem = nil;
    self.manager = nil;
//    [self.playerView removeFromSuperview];
    
}

- (void)play {
    [self.manager play];
}
- (void)pause {
    [self.manager pause];
}
@end
