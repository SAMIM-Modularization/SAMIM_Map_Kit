//
//  SAMIMMapModuleMAMapViewController.m
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/30.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "SAMIMMapModuleMAMapViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

static NSIndexPath *signIndexPath = nil;
@interface SAMIMMapModuleMAMapViewController ()<MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
{
    MAMapView *_mapView;
}
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) AMapReGeocodeSearchRequest *regeo;
@property (nonatomic, strong) UITableView  *tableView;
@property (nonatomic, strong) NSMutableArray *dataMArray;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic, strong) CLLocation *location;
@property(nonatomic,strong) UIBarButtonItem         *sendButton;
@property (nonatomic, strong) AMapPOI *selectedPoi;
@end

@implementation SAMIMMapModuleMAMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    self.title = @"位置";
    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = self.mapKey;
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height/2+50-64)];
    ///把地图添加至view
    _mapView.delegate = self;
    _mapView.zoomLevel = 18;
    [self.view addSubview:_mapView];
    
    UIImageView *centerPin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"redPin"]];
    centerPin.frame = CGRectMake(CGRectGetMidX(_mapView.frame)-22, CGRectGetMidY(_mapView.frame)-36-64, 44, 72);
    [_mapView addSubview:centerPin];
    
    [self.view addSubview:self.tableView];
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode  = MAUserTrackingModeFollow;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(_mapView.frame.size.width-60, _mapView.frame.size.height-70, 40, 40)];
    [_mapView addSubview:button];
    [button setImage:[UIImage imageNamed:@"loc"] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    [button addTarget:self action:@selector(maptocenter) forControlEvents:UIControlEventTouchUpInside];
    _mapView.logoCenter = CGPointMake(CGRectGetMidX(button.frame), CGRectGetMidY(button.frame)+40-10);
    
    //逆地理编码（坐标转地址）
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    
    //    regeo.location                    = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    regeo.requireExtension            = YES;
    self.regeo = regeo;
    
    [self setUpRightNavButton];
    
}
- (void)setUpRightNavButton{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.sendButton = item;
    self.sendButton.enabled = YES;
}

- (void)onSend:(id)sender{
    if (self.successBlock) {
        NSDictionary *locationInfo =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.selectedPoi.location.latitude],@"lat",[NSNumber numberWithDouble:self.selectedPoi.location.longitude],@"lng",self.selectedPoi.address,@"address", nil];
        self.successBlock(locationInfo);
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
- (void)maptocenter {
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.location.coordinate.latitude, self.location.coordinate.longitude) animated:YES];
}
/**
 * @brief 位置或者设备方向更新后调用此接口
 * @param mapView 地图View
 * @param userLocation 用户定位信息(包括位置与设备方向等数据)
 * @param updatingLocation 标示是否是location数据更新, YES:location数据更新 NO:heading数据更新
 */
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if (updatingLocation) {
        NSLog(@"%@",userLocation.description);
        NSLog(@"%@",userLocation.location);
        NSLog(@"%@",userLocation.title);
        NSLog(@"%@",userLocation.subtitle);
        NSLog(@"%@",userLocation.heading);
        self.regeo.location = [AMapGeoPoint locationWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
        [self.search AMapReGoecodeSearch:self.regeo];
        self.location = userLocation.location;
        signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
    }
}

/**
 * @brief 定位失败后调用此接口
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
}

/**
 * @brief 地图移动结束后调用此接口
 * @param mapView 地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if(wasUserAction) {
        CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
        //        [self reverseGeoLocation:centerCoordinate];
        self.regeo.location = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
        [self.search AMapReGoecodeSearch:self.regeo];
    }
}

//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
//{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]])
//    {
//        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
//        MAPinAnnotationView *annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
//        }
//        annotationView.canShowCallout = YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop   = YES;        //设置标注动画显示，默认为NO
//        annotationView.draggable      = YES;           //设置标注可以拖动，默认为NO
//        annotationView.pinColor       = MAPinAnnotationColorPurple;
//        annotationView.selected       = YES;
//        return annotationView;
//    }
//    return nil;
//}


/* 逆地理编码回调. */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil)
    {
        //解析response获取地址描述，具体解析见 Demo
        NSLog(@"%@",response.regeocode);
        signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        //        if(_pointAnnotation){
        //            [_mapView removeAnnotation:_pointAnnotation];
        //        }
        //        _pointAnnotation = [[MAPointAnnotation alloc] init];
        //        _pointAnnotation.coordinate = CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude);
        //        _pointAnnotation.title = response.regeocode.formattedAddress;
        ////        pointAnnotation.subtitle = @"阜通东大街6号";
        //
        //        [_mapView addAnnotation:_pointAnnotation];
        self.dataMArray = (NSMutableArray *)response.regeocode.pois;
        [self.tableView reloadData];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", error);
}

#pragma mark - tableview
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataMArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"gaodecellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellid];
        cell.textLabel.font  = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    if(self.dataMArray.count > 0) {
        
        AMapPOI *poi = self.dataMArray[indexPath.row];
        cell.textLabel.text = poi.name;
        cell.detailTextLabel.text = poi.address;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
        if(indexPath.row == 0 && signIndexPath.row == 0){
            cell.textLabel.text = @"[位置]";
            cell.textLabel.textColor = [UIColor blueColor];
            cell.detailTextLabel.textColor = [UIColor blueColor];
        }
        if(indexPath == signIndexPath) {
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
            self.selectedPoi = poi;
        }
        else {
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }
    }
  
//    indexPath == signIndexPath ?
//    (cell.accessoryType  = UITableViewCellAccessoryCheckmark ):
//    (cell.accessoryType  = UITableViewCellAccessoryNone );
   return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == signIndexPath.row && indexPath.section == signIndexPath.section) {
        return;
    }
    AMapPOI *poi = self.dataMArray[indexPath.row];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    
    if (indexPath.row != 0) {
        UITableViewCell *zeroCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        zeroCell.textLabel.textColor = [UIColor darkGrayColor];
        zeroCell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else {
        cell.textLabel.textColor = [UIColor blueColor];
        cell.detailTextLabel.textColor = [UIColor blueColor];
    }
    
    UITableViewCell *signcell = [tableView cellForRowAtIndexPath:signIndexPath];
    signcell.accessoryType =  UITableViewCellAccessoryNone;
    signIndexPath = indexPath;
    
    self.selectedPoi = poi;
}

#pragma mark - 懒加载
-(NSMutableArray *)dataMArray {
    if (!_dataMArray) {
        _dataMArray = [NSMutableArray arrayWithCapacity:30];
    }
    return _dataMArray;
}
-(UITableView *)tableView {
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height/2+50, self.view.frame.size.width, self.view.frame.size.height/2-50) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
