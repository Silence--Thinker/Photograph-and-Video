//
//  ListViewController.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/8/25.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "ListViewController.h"
#import "ListCell.h"


@interface ListViewController ()

@property (nonatomic, strong) NSMutableArray *dataList;

@end
@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor redColor];
    [self.tableView registerNib:[UINib nibWithNibName:@"ListCell" bundle:nil] forCellReuseIdentifier:@"ListCell"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
    XJModel *model = self.dataList[indexPath.row];
    if (indexPath.row % 3 == 1) {
        model.videoURL = [[NSBundle mainBundle] URLForResource:@"ElephantSeals" withExtension:@"mov"];
    }else if (indexPath.row % 3 == 2) {
        model.videoURL = [[NSBundle mainBundle] URLForResource:@"111111111jj" withExtension:@"mov"];
    }else {
        model.videoURL = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1608/24/QZlcB4089/SD/QZlcB4089-mobile.mp4"];
    }
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
        for (NSInteger i = 1; i < 10; i++) {
            XJModel *model = [XJModel new];
            [_dataList addObject:model];
        }
    }
    return _dataList;
}

@end

@implementation XJModel
- (XJPlayerManager *)manager {
    if (!_manager) {
        _manager = [XJPlayerManager new];
        _manager.justOnePlay = YES;
        _manager.repeatPlay = YES;
    }
    return _manager;
}

- (void)setVideoURL:(NSURL *)videoURL {
    _videoURL = videoURL;
}

@end
