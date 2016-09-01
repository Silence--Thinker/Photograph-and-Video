//
//  XJPresentationController.h
//  CustomPresationController
//
//  Created by Silence on 15/5/13.
//  Copyright (c) 2015年 FNWS. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XJPresentationController;
@protocol XJPresentationControllerDelegate <NSObject>

- (void)presentationControllerDidDismissed:(XJPresentationController *)controller;

@end

@interface XJPresentationController : UIPresentationController

@property (nonatomic, weak) id<XJPresentationControllerDelegate> xj_presentationDelegate ;

@end
