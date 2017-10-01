//
//  SAMIMLocationObject.m
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "SAMIMLocationObject.h"

@implementation SAMIMLocationObject
-(instancetype)initWithLatitude:(double)latitude
                      longitude:(double)longitude
                          title:(NSString *)title {
    self = [super init];
    if (self) {
        _latitude = latitude;
        _longitude = longitude;
        _title = title;
    }
    return self;
}
@end
