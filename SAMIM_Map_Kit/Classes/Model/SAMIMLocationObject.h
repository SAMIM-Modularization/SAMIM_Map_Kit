//
//  SAMIMLocationObject.h
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAMIMLocationObject : NSObject

/**
 位置实例对象初始化方法

 @param latitude  纬度
 @param longitude 经度
 @param title     地理位置描述
 @return          位置实例对象
 */
-(instancetype _Nullable )initWithLatitude:(double)latitude
                      longitude:(double)longitude
                                     title:(NSString *_Nullable)title;
/**
 *  维度
 */
@property (nonatomic, assign, readonly) double latitude;

/**
 *  经度
 */
@property (nonatomic, assign, readonly) double longitude;

/**
 *  标题
 */
@property (nullable, nonatomic, copy, readonly) NSString *title;

@end
