//
//  SAMIMMapModuleMAMapViewController.h
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/30.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectLocationSuccessBlock)(NSDictionary *locationDic);

@interface SAMIMMapModuleMAMapViewController : UIViewController
@property (nonatomic,copy  )  NSString  *mapKey;
@property (nonatomic,copy  )  SelectLocationSuccessBlock   successBlock;
@end
