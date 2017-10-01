//
//  Target_SAMIMMapModule.h
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//  SAMIMMapModule（target-action所在的模块，也就是提供服务的模块，这也是单独的repo，但无需被其他人依赖，其他人通过category调用到这里的功能）

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Target_SAMIMMapModule : NSObject

- (UIViewController *)Action_viewController:(NSDictionary *)params;

@end
