//
//  SAMIMMapViewController.h
//  SAMIMMapKit
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

typedef void(^SelectLocationSuccessBlock)(NSDictionary *locationDic);

@interface SAMIMMapModuleViewController : UIViewController<MKMapViewDelegate>
@property (nonatomic,strong)  MKMapView *mapView;
@property (nonatomic,copy  )  NSString  *mapKey;
@property (nonatomic,copy  )  SelectLocationSuccessBlock   successBlock;

@end
