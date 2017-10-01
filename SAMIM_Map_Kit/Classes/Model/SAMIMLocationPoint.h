//
//  SAMIMLocationPoint.h
//  WenMingShuo
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 Six. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class SAMIMLocationObject;

@interface SAMIMLocationPoint : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, readonly, copy)   NSString *title;

- (instancetype)initWithLocationObject:(SAMIMLocationObject *)locationObject;

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title;

@end
