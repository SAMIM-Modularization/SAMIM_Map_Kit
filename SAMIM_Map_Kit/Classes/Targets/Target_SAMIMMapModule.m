//
//  Target_SAMIMMapModule.m
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "Target_SAMIMMapModule.h"
#import "SAMIMMapModuleViewController.h"
#import "SAMIMMapModuleTextViewController.h"
#import "SAMIMMapModuleMAMapViewController.h"
typedef void (^MapLocationCallbackBlock)(NSDictionary *info);

@implementation Target_SAMIMMapModule

- (UIViewController *)Action_viewController:(NSDictionary *)params
{
    NSNumber *number = params[@"MapStyle"];
    if (number.integerValue == 1) {
        SAMIMMapModuleMAMapViewController *viewController = [[SAMIMMapModuleMAMapViewController alloc] init];
        viewController.mapKey = params[@"MapKey"];
        viewController.successBlock = ^(NSDictionary *locationDic) {
            MapLocationCallbackBlock callback = params[@"MapLocationBlock"];
            if (callback) {
                callback(locationDic);
            }
        };
        return viewController;
    }
    else if (number.integerValue == 0) {
        SAMIMMapModuleTextViewController *viewController = [[SAMIMMapModuleTextViewController alloc] init];
        viewController.mapKey = params[@"MapKey"];
        viewController.successBlock = ^(NSDictionary *locationDic) {
            MapLocationCallbackBlock callback = params[@"MapLocationBlock"];
            if (callback) {
                callback(locationDic);
            }
        };
        return viewController;
    }
    else {
        return nil;
    }
}

@end
