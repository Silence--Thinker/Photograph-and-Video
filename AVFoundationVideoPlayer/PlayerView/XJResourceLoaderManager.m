//
//  XJResourceLoaderManager.m
//  AVFoundationVideoPlayer
//
//  Created by Silence on 16/9/1.
//  Copyright © 2016年 ___SILENCE___. All rights reserved.
//

#import "XJResourceLoaderManager.h"

@interface XJResourceLoaderManager ()



@end
@implementation XJResourceLoaderManager

- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"%s", __func__);
    
    NSURL *resourceURL = loadingRequest.request.URL;
    
    if (1) {
        
    }
    
    
    return YES;
}
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    NSLog(@"%s", __func__);
    
}

@end
