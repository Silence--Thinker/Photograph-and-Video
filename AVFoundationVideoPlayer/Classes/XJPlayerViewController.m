//
//  XJPlayerViewController.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/23.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJPlayerViewController.h"
#import "TCPlayerView.h"
#import "XJPlayerManager.h"


#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface XJPlayerViewController ()

@property (nonatomic, weak) TCPlayerView *playerView;
@property (nonatomic, weak) XJPlayerManager *manager;


@end
@implementation XJPlayerViewController

// MARK: - View Handling

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildingPlayerControllerSubViews];
    [self initializePlayerViewLayout];
    [self initializePlayerVariablesValue];
}

- (void)buildingPlayerControllerSubViews {
    self.view.backgroundColor = [UIColor blackColor];
    XJPlayerManager *manager = [XJPlayerManager new];
    TCPlayerView *playerView = [[TCPlayerView alloc] initWithPlayerManager:manager];
    playerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:playerView];
    self.playerView = playerView;
    self.manager = manager;
    
    UISlider *timeSlider = [[UISlider alloc] init];
    timeSlider.translatesAutoresizingMaskIntoConstraints = NO;
    timeSlider.backgroundColor = [UIColor redColor];
    [timeSlider addTarget:self action:@selector(timeSliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timeSlider];
    self.timeSlider = timeSlider;
    
    
    UIButton *playPauseButton = [[UIButton alloc] init];
    playPauseButton.translatesAutoresizingMaskIntoConstraints = NO;
    playPauseButton.backgroundColor = [UIColor greenColor];
    [playPauseButton addTarget:self action:@selector(playPauseButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playPauseButton];
    self.playPauseButton = playPauseButton;
    [playPauseButton setTitle:@"播放/暂停" forState:UIControlStateNormal];
    [playPauseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    playPauseButton.titleLabel.font = [UIFont systemFontOfSize:10.0];
}

- (void)initializePlayerViewLayout {
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.timeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view);
        make.trailing.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(20);
    }];
    
    [self.playPauseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerView);
    }];
}

- (void)initializePlayerVariablesValue {
//    self.playerView.repeatPlay = YES;
//    [self.playerView play];
//    self.manager.videoURL = @"";
    NSURL *moviceURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    //    NSURL *moviceURL = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1608/24/QZlcB4089/SD/QZlcB4089-mobile.mp4"];
    self.manager.videoURL = moviceURL.absoluteString;
    self.manager.muted = YES;
    self.manager.repeatPlay = YES;
}

// MARK: - timeSliderDidChange

- (void)timeSliderDidChange:(UISlider *)slider {

}

- (void)playPauseButtonWasPressed:(UIButton *)sender {
    if (self.manager.rate != 1.0) {
        [self.manager play];
    }else {
        // playing so pause
        [self.manager pause];
    }
}

// MARK: - Properties

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
