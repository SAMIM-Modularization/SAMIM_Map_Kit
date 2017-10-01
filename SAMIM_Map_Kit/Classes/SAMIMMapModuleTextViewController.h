//
//  SAMIMMapModuleTextViewController.h
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

typedef void(^SelectLocationSuccessBlock)(NSDictionary *locationDic);

@interface SAMIMMapModuleTextViewController : UIViewController
@property (nonatomic,copy  )   SelectLocationSuccessBlock   successBlock;
@property (nonatomic, copy)    NSString *mapKey;//高德地图key

@end
