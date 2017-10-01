//
//  SAMIMMapViewController.m
//  SAMIMMapKit
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "SAMIMMapModuleViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AddressBookUI/AddressBookUI.h>

#import "SAMIMAMapHalfStyleTableViewCell.h"
#import "SAMIMLocationPoint.h"

#define CellIdntifier @"SAMIMAMapHalfStyleTableViewCellId"
//屏幕的宽高
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height
static NSIndexPath *signIndexPath = nil;

@interface SAMIMMapModuleViewController ()<UITableViewDelegate,UITableViewDataSource,AMapSearchDelegate>{
    BOOL  _updateUserLocation;
}

@property(nonatomic,strong) UIBarButtonItem         *sendButton;

@property(nonatomic,strong) CLLocationManager       *locationManager;

@property(nonatomic,strong) CLGeocoder              *geoCoder;

@property(nonatomic,strong) SAMIMLocationPoint      *locationPoint;

@property(nonatomic,strong) UITableView             *mapTableView;

@property(nonatomic,strong) NSMutableArray          *mapMArray;

@property(nonatomic,strong) CLPlacemark             *placemark;

@property(nonatomic,strong) AMapSearchAPI           *search;

@property(nonatomic,strong) UIActivityIndicatorView *activityView ;

@end

@implementation SAMIMMapModuleViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        _locationManager.distanceFilter  = 500.0f;
        _geoCoder = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [AMapServices sharedServices].apiKey = self.mapKey;
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;
    
    self.navigationItem.title = @"位置";
    self.mapMArray = [NSMutableArray arrayWithCapacity:10];
    signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, (UIScreenHeight)*0.5)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.mapTableView];
    self.mapTableView.hidden = YES;
    [self setUpRightNavButton];
    
    
    if (self.locationPoint) {
        MKCoordinateRegion theRegion;
        theRegion.center = self.locationPoint.coordinate;
        theRegion.span.longitudeDelta    = 0.0001f;
        theRegion.span.latitudeDelta     = 0.0001f;
        [self.mapView addAnnotation:self.locationPoint];
        [self.mapView setRegion:theRegion animated:YES];
    }
    else{
        self.locationPoint   = [[SAMIMLocationPoint alloc] init];
        if ([CLLocationManager locationServicesEnabled]) {
            [_locationManager requestWhenInUseAuthorization];
            CLAuthorizationStatus status = CLLocationManager.authorizationStatus;
            if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
//                [self.view makeToast:Localized(@"请在设置-隐私里允许程序使用地理位置服务")
//                            duration:2
//                            position:CSToastPositionCenter];
                NSLog(@"请在设置-隐私里允许程序使用地理位置服务");
            }else{
                self.mapView.showsUserLocation = YES;
            }
        }else{
            NSLog(@"请在设置-隐私里允许程序使用地理位置服务");
//            [self.view makeToast:Localized(@"请在设置-隐私里打开地理位置服务")
//                        duration:2
//                        position:CSToastPositionCenter];
        }
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self clearMapView];
}

- (void)clearMapView{
    [self.mapView removeAnnotations:_mapView.annotations];
    self.mapView.delegate = nil;
    self.mapView.showsUserLocation = NO;
    [self.mapView removeFromSuperview];
    self.mapView = nil;
    //    [self.mapView removeAnnotations:self.annotations];
    //    [self.mapView removeOverlays:self.overlays];
    //    [self.mapView setCamera:<#(MKMapCamera * _Nonnull)#>:nil];
}

- (void)setUpRightNavButton{
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onSend:)];
    self.navigationItem.rightBarButtonItem = item;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.sendButton = item;
    self.sendButton.enabled = NO;
}

- (void)onSend:(id)sender{
//    if ([self.delegate respondsToSelector:@selector(onSendFriendShareLocation:)]) {
//        if (signIndexPath.section == 0) {
//            [self.delegate onSendFriendShareLocation:self.locationPoint];
//        }
//        else {
//            if (self.mapMArray.count > 0 && signIndexPath.row < self.mapMArray.count) {
//                AMapPOI *mapItem = self.mapMArray[signIndexPath.row];
//                NIMKitLocationPoint *point = [[NIMKitLocationPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(mapItem.location.latitude, mapItem.location.longitude) andTitle:[NSString stringWithFormat:@"%@•%@",mapItem.name,mapItem.address]];
//                [self.delegate onSendFriendShareLocation:point];
//            }
//        }
//    }
    if (self.successBlock) {
        if (signIndexPath.section == 0) {
            NSDictionary *locationInfo =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.locationPoint.coordinate.latitude],@"lat",[NSNumber numberWithDouble:self.locationPoint.coordinate.longitude],@"lng",self.locationPoint.title,@"address", nil];
            self.successBlock(locationInfo);
        }
        else {
                        if (self.mapMArray.count > 0 && signIndexPath.row < self.mapMArray.count) {
                            AMapPOI *mapItem = self.mapMArray[signIndexPath.row];
//                            SAMIMLocationPoint *point = [[SAMIMLocationPoint alloc] initWithCoordinate:CLLocationCoordinate2DMake(mapItem.location.latitude, mapItem.location.longitude) andTitle:[NSString stringWithFormat:@"%@•%@",mapItem.name,mapItem.address]];
//                            [self.delegate onSendFriendShareLocation:point];
                            NSDictionary *locationInfo =  [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:mapItem.location.latitude],@"lat",[NSNumber numberWithDouble:mapItem.location.longitude],@"lng",[NSString stringWithFormat:@"%@•%@",mapItem.name,mapItem.address],@"address", nil];
                            self.successBlock(locationInfo);
                        }
        }
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (!_updateUserLocation) {
        return;
    }
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;
    [self reverseGeoLocation:centerCoordinate];
}


- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated

{
    if (!_updateUserLocation) {
        return;
    }
    [_mapView removeAnnotations:_mapView.annotations];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    static NSString *reusePin = @"reusePin";
    MKPinAnnotationView * pin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:reusePin];
    if (!pin) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reusePin];
    }
    pin.canShowCallout    = YES;
    return pin;
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    _updateUserLocation = YES;
    MKCoordinateRegion theRegion;
    theRegion.center = userLocation.coordinate;
    theRegion.span.longitudeDelta    = 0.01f;
    theRegion.span.latitudeDelta    = 0.01f;
    [_mapView setRegion:theRegion animated:NO];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    [_mapView selectAnnotation:self.locationPoint animated:YES];
    UIView * view = [mapView viewForAnnotation:self.mapView.userLocation];
    view.hidden = YES;
}


- (void)reverseGeoLocation:(CLLocationCoordinate2D)locationCoordinate2D{
    if (self.geoCoder.isGeocoding) {
        [self.geoCoder cancelGeocode];
    }
    CLLocation *location = [[CLLocation alloc]initWithLatitude:locationCoordinate2D.latitude
                                                     longitude:locationCoordinate2D.longitude];
//    __weak SAMIMMapModuleViewController *wself = self;
    __weak typeof(self) weakSelf = self;
    self.sendButton.enabled = NO;
    [self.geoCoder reverseGeocodeLocation:location
                        completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error == nil) {
             CLPlacemark *mark = [placemarks lastObject];
             [weakSelf search:mark.location.coordinate];//搜索周边
             NSString * title  = [weakSelf nameForPlaceMark:mark];
             weakSelf.placemark  = mark;
             SAMIMLocationPoint *ponit = [[SAMIMLocationPoint alloc] initWithCoordinate:locationCoordinate2D andTitle:title];
             weakSelf.locationPoint = ponit;
             [weakSelf.mapView addAnnotation:ponit];
             weakSelf.sendButton.enabled = YES;
         } else {
             weakSelf.locationPoint = nil;
         }
     }];
}

- (NSString *)nameForPlaceMark: (CLPlacemark *)mark
{
    NSString *name = ABCreateStringWithAddressDictionary(mark.addressDictionary,YES);
    unichar characters[1] = {0x200e};   //format之后会出现这个诡异的不可见字符，在android端显示会很诡异，需要去掉
    NSString *invalidString = [[NSString alloc]initWithCharacters:characters length:1];
    NSString *formattedName =  [[name stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
                                stringByReplacingOccurrencesOfString:invalidString withString:@""];
    return formattedName;
}

- (NSString *)nameForNoCountryPlaceMark:(CLPlacemark *)mark {
    NSString *locality        = mark.locality;
    NSString *subLocality     = mark.subLocality;
    NSString *thoroughfare    = mark.thoroughfare;
    NSString *subThoroughfare = mark.subThoroughfare;
    if (locality == nil) {
        locality = @"";
    }
    if (subLocality == nil) {
        subLocality = @"";
    }
    if (thoroughfare == nil) {
        thoroughfare = @"";
    }
    if (subThoroughfare == nil) {
        subThoroughfare = @"";
    }
    NSString *name = [NSString stringWithFormat:@"%@%@%@%@",locality,subLocality,thoroughfare,subThoroughfare];
    unichar characters[1] = {0x200e};   //format之后会出现这个诡异的不可见字符，在android端显示会很诡异，需要去掉
    NSString *invalidString = [[NSString alloc]initWithCharacters:characters length:1];
    NSString *formattedName =  [[name stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
                                stringByReplacingOccurrencesOfString:invalidString withString:@""];
    return formattedName;
    
}

- (void)dismiss:(id)sender
{
    if (self.navigationController.presentingViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - 高德地图搜索周边
- (void)search:(CLLocationCoordinate2D)toccor {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location            = [AMapGeoPoint locationWithLatitude:toccor.latitude longitude:toccor.longitude];
    //    request.keywords            = @"电影院";
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    request.radius = 100;
    
    [self.search AMapPOIAroundSearch:request];
    
}

/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [self.activityView startAnimating];
    
    if (response.pois.count == 0)
    {
        return;
    }
    if (self.mapMArray.count > 0) {
        [self.mapMArray removeAllObjects];
    }
    
    //    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        //        [self.mapMArray addObject:[[POIAnnotation alloc] initWithPOI:obj]];
        [self.mapMArray addObject:obj];
        
        
    }];
    signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    //    self.mapMArray = poiAnnotations;
    [self.mapTableView setHidden:NO];
    [self.activityView stopAnimating];
    
    [self.mapTableView reloadData];
    
    
    
    //解析response获取POI信息，具体解析见 Demo
}

#pragma mark - 搜索周边
- (void)searchAround:(CLLocationCoordinate2D)tocoor {
    
    //创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(tocoor, 50, 50);
    //初始化一个检索请求对象
    
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery = @"place";
    //初始化检索
    
    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
    //开始检索，结果返回在block中
    if (self.mapMArray.count > 0) {
        [self.mapMArray removeAllObjects];
    }
    __weak typeof(self) weakSelf = self;
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        //兴趣点节点数组
        //        weakSelf.mapMArray = (NSMutableArray *)response.mapItems;
        weakSelf.mapMArray = [NSMutableArray arrayWithArray:response.mapItems];
        signIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [weakSelf.mapTableView reloadData];
    }];
    
}

#pragma mark - UITableVeiwDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return self.mapMArray.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SAMIMAMapHalfStyleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdntifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.textLabel.text    =  [self nameForNoCountryPlaceMark:self.placemark];
        cell.detailTextLabel.text = @"";
    }
    else {
        if (self.mapMArray.count > 0) {
            //            MKMapItem *item = [self.mapMArray objectAtIndex:indexPath.row];
            //            cell.titleLabel.text = item.name;
            //            cell.subTitleLabel.text = [self nameForPlaceMark:item.placemark];
            AMapPOI *item = [self.mapMArray objectAtIndex:indexPath.row];
            cell.textLabel.text = item.name;
            cell.detailTextLabel.text = item.address;
            
        }
        
    }
    indexPath == signIndexPath ?
    (cell.accessoryType  = UITableViewCellAccessoryCheckmark ):
    (cell.accessoryType  = UITableViewCellAccessoryNone );
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == signIndexPath.row && indexPath.section == signIndexPath.section) {
        return;
    }
    SAMIMAMapHalfStyleTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    
    SAMIMAMapHalfStyleTableViewCell *signcell = [tableView cellForRowAtIndexPath:signIndexPath];
    signcell.accessoryType =  UITableViewCellAccessoryNone;
    signIndexPath = indexPath;
    
}


-(UITableView *)mapTableView {
    if (_mapTableView == nil) {
        _mapTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (UIScreenHeight)*0.5, UIScreenWidth, (UIScreenHeight)*0.5-64) style:UITableViewStylePlain];
        _mapTableView.delegate    = self;
        _mapTableView.dataSource  = self;
        [_mapTableView registerClass:[SAMIMAMapHalfStyleTableViewCell class] forCellReuseIdentifier:CellIdntifier];
//        [_mapTableView registerNib:[UINib nibWithNibName:@"SAMIMAMapHalfStyleTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdntifier];
        _mapTableView.backgroundColor = [UIColor whiteColor];
        
    }
    return _mapTableView;
}

-(UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.center = _mapTableView.center;
        [self.view addSubview:_activityView];
    }
    return _activityView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
