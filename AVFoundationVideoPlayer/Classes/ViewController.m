//
//  ViewController.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/22.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "ViewController.h"

#import "XJPlayerViewController.h"
#import "TCPlayerViewController.h"

#import "ListViewController.h"


static NSString * const kIdentifier = @"identifier";
@interface ViewController () <UITableViewDataSource, UITableViewDelegate>


@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    cell.textLabel.text = indexPath.row == 0 ? @"VC" :@"视频播放";
    if (indexPath.row == 2) {
        cell.textLabel.text = @"列表播放";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        XJPlayerViewController *newVC = [[XJPlayerViewController alloc] init];
        [self.navigationController presentViewController:newVC animated:YES completion:nil];
        return;
    } else if (indexPath.row == 2) {
        ListViewController *newVC = [[ListViewController alloc] init];
        [self.navigationController pushViewController:newVC animated:YES];
        return;
    }
    TCPlayerViewController *newVC = [[TCPlayerViewController alloc] init];
    [self.navigationController pushViewController:newVC animated:YES];
}
@end
