//
//  SAMIMLocationPoint.m
//  WenMingShuo
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 Six. All rights reserved.
//

#import "SAMIMLocationPoint.h"
#import "SAMIMLocationObject.h"

@implementation SAMIMLocationPoint
- (instancetype)initWithLocationObject:(SAMIMLocationObject *)locationObject{
    self = [super init];
    if (self) {
        CLLocationCoordinate2D coordinate;
        coordinate.longitude = locationObject.longitude;
        coordinate.latitude  = locationObject.latitude;
        _coordinate = coordinate;
        _title      = locationObject.title;
    }
    return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title{
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _title      = title;
    }
    return self;
}
@end
