//
//  XJPlayerViewController.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/23.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerViewController.h"
#import "TCPlayerView.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface XJPlayerViewController ()


@end
@implementation XJPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildingSubViews];
}
- (void)buildingSubViews {
    self.view.backgroundColor = [UIColor blackColor];
    TCPlayerView *playerView = [[TCPlayerView alloc] init];
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playerView];
    self.playerView = playerView;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:playerView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    
    UISlider *timeSlider = [[UISlider alloc] init];
    timeSlider.translatesAutoresizingMaskIntoConstraints = NO;
    timeSlider.backgroundColor = [UIColor redColor];
    [timeSlider addTarget:self action:@selector(timeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeSlider];
    self.timeSlider = timeSlider;
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeSlider
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeSlider
                                                          attribute:NSLayoutAttributeRight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeRight
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.timeSlider addConstraint:[NSLayoutConstraint constraintWithItem:timeSlider
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0
                                                           constant:20.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:timeSlider
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    
    UIButton *playPauseButton = [[UIButton alloc] init];
//    playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    playPauseButton.backgroundColor = [UIColor greenColor];
    [playPauseButton addTarget:self action:@selector(playPauseButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playPauseButton];
    self.playPauseButton = playPauseButton;
    [playPauseButton setTitle:@"播放/暂停" forState:UIControlStateNormal];
    [playPauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    playPauseButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
    playPauseButton.frame = CGRectMake(20, SCREEN_HEIGHT - 60, 60, 20);
}

// MARK: - timeSliderDidChange

- (void)timeSliderDidChange:(UISlider *)slider {

}

- (void)playPauseButtonWasPressed:(UIButton *)sender {
    if (self.player.rate != 1.0) {
        // not playing 2 play
        if (CMTIME_COMPARE_INLINE(self.playerView.currentTime, ==, self.playerView.duration)) {
            // at end so got back to begining
            self.playerView.currentTime = kCMTimeZero;
        }
        // play will set rate 1.0
        [self.player play];
    }else {
        // playing so pause
        [self.player pause];
    }
}

// MARK: - Properties

- (AVPlayer *)player {
    return self.playerView.player;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

- (BOOL)shouldAutorotate {
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;//UIInterfaceOrientationMaskLandscape;
}


@end
