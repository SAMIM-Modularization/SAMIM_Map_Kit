//
//  SAMIMMapModuleTextViewController.m
//  SAMIMMapModule
//
//  Created by ZIKong on 2017/9/28.
//  Copyright © 2017年 youhuikeji. All rights reserved.
//

#import "SAMIMMapModuleTextViewController.h"
#import "MJRefresh.h"
#import "SAMIMMapTextTableViewCell.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#define SelectLocation_Not_Show @"不显示位置"
//屏幕的宽高
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height

@interface SAMIMMapModuleTextViewController ()<AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>
{
    CLLocationManager *locationManager;
    
    CLLocation *currentLoction;
}

@property (nonatomic,strong) AMapSearchAPI  *search;

@property (nonatomic,strong) NSMutableArray *addressArray;

@property (nonatomic,strong) UITableView    *mTableView;

@property (nonatomic,assign) BOOL           needInsertOldAddress;
@property (nonatomic,assign) BOOL           isSelectCity;

@property (nonatomic,assign) NSInteger      pageIndex;
@property (nonatomic,assign) NSInteger      pageCount;

@property (copy, nonatomic) NSString *lat;
@property (copy, nonatomic) NSString *lng;

@property (nonatomic,strong)   AMapPOI                      *oldPoi;


@end

@implementation SAMIMMapModuleTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _lat = @"";
    _lng = @"";
    AMapPOI *first  = [[AMapPOI alloc] init];
    first.name      = SelectLocation_Not_Show;
    self.title = @"位置";
    [self.addressArray addObject:first];
    
    if (self.oldPoi) {
        AMapPOI *poi                = self.oldPoi;
        self.needInsertOldAddress   = poi.address.length > 0;
        self.isSelectCity           = poi.address.length == 0;
    }
    [self.view addSubview:self.mTableView];
    [self headRefreshing];
}
-(void)viewWillAppear:(BOOL)animated
{
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    locationManager    = [[CLLocationManager alloc] init];
    
    locationManager.delegate = (id)self;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status) {
        //用户拒绝或者未能授权
//        [self.view makeToast:@"请在隐私设置中授权定位服务" duration:1.0f position:CSToastPositionCenter];
        NSLog(@"请在隐私设置中授权定位服务");
    }
    if ([CLLocationManager locationServicesEnabled]) {
        // 启动位置更新
        if(kCLAuthorizationStatusNotDetermined== status)
        {//对于这个应用程序用户还未做出的选择
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f){
                [locationManager requestWhenInUseAuthorization];
            }
        }
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = 1000.0f;
    [locationManager startUpdatingLocation];
}



#pragma mark - CLLocationManagerDelegate
// 地理位置发生改变时触发
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
    currentLoction = newLocation;
    self.lat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    self.lng = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
    
    [self headRefreshing];
}

// 定位失误时触发
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (kCLAuthorizationStatusDenied == status || kCLAuthorizationStatusRestricted == status)
    {
//        [self.view makeToast:@"请在隐私设置中授权定位服务" duration:1.0f position:CSToastPositionCenter];
        NSLog(@"请在隐私设置中授权定位服务");
    }
    
}

#pragma mark - getData
- (void)headRefreshing{
    self.pageIndex = 0;
    self.pageCount = 10;
    [self footRefreshing];
}

- (void)footRefreshing{
    self.pageIndex += 1;
    [self sendRequest];
}

- (void)sendRequest{
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location                    = [AMapGeoPoint locationWithLatitude: self.lat.floatValue longitude:self.lng.floatValue];
    request.keywords                    = @"";
    request.sortrule                    = 0;
    request.requireExtension            = YES;
    request.radius                      = 1000;
    request.page                        = self.pageIndex;
    request.offset                      = self.pageCount;
    request.types                       = @"120000|141200|150000|060101|060102";
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - AMapSearchDelegate
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    
    if (response.pois.count == 0){
        return;
    }
    
    if (self.addressArray.count == 1) {
        AMapPOI *poi = [[AMapPOI alloc] init];
        poi.city     = ((AMapPOI *)response.pois.firstObject).city;
        [self.addressArray addObject:poi];
    }
    
    if (self.oldPoi) {
        [self.addressArray addObject:self.oldPoi];
    }
    
    [self.addressArray addObjectsFromArray:response.pois];
    
    
    if (self.oldPoi) {
        for (NSInteger i = 0; i < self.addressArray.count; i++) {
            for (NSInteger j = i+1;j < self.addressArray.count; j++) {
                AMapPOI *temppoi = self.addressArray[i];
                AMapPOI *poi = self.addressArray[j];
                if ([temppoi.name isEqualToString:poi.name]) {
                    [self.addressArray removeObject:poi];
                }
            }
        }
    }
    
    [self.mTableView reloadData];
    
    self.mTableView.footer.hidden = response.pois.count != self.pageCount;
    
    [self.mTableView.header endRefreshing];
    [self.mTableView.footer endRefreshing];
    
}

#pragma mark TableView delegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"SAMIMMapTextTableViewCell";
    SAMIMMapTextTableViewCell *cell    = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    AMapPOI *info               = self.addressArray[indexPath.row];
    cell.textLabel.text         = info.name.length > 0 ? info.name : info.city;
    cell.detailTextLabel.text   = info.address;
    
    cell.accessoryType  = UITableViewCellAccessoryNone;
    
    if (self.oldPoi && indexPath.row == 2) {
        if (self.isSelectCity) {
            cell.accessoryType  = UITableViewCellAccessoryNone;
        }else{
            cell.accessoryType  = UITableViewCellAccessoryCheckmark;
        }
    }else if (!self.oldPoi        && indexPath.row == 0) {
        cell.accessoryType      = UITableViewCellAccessoryCheckmark;
    }else if (self.isSelectCity   && indexPath.row == 1){
        cell.accessoryType      = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.addressArray.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AMapPOI *info = self.addressArray[indexPath.row];
    if (self.successBlock) {
        NSDictionary *locationInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:info.location.latitude],@"lat",[NSNumber numberWithDouble:info.location.longitude],@"lng",info.address,@"address", nil];
        self.successBlock(locationInfo);
//        self.successBlock([info.name isEqualToString:SelectLocation_Not_Show] ? nil : info);
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - get set
- (UITableView *)mTableView{
    if (!_mTableView) {
        _mTableView = ({
            __weak __typeof(self) weakSelf = self;
            
            UITableView *mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight-20)];
            mTableView.showsHorizontalScrollIndicator = NO;
            mTableView.showsVerticalScrollIndicator   = NO;
            mTableView.rowHeight                      = 44;
            mTableView.dataSource                     = self;
            mTableView.delegate                       = self;
            mTableView.tableFooterView                = [UIView new];
            [mTableView registerClass:[SAMIMMapTextTableViewCell class] forCellReuseIdentifier:@"SAMIMMapTextTableViewCell"];
            
            
            [mTableView addLegendHeaderWithRefreshingBlock:^{
                [weakSelf headRefreshing];
            }];
            [mTableView addLegendFooterWithRefreshingBlock:^{
                [weakSelf footRefreshing];
            }];

            
            mTableView;
        });
    }
    return _mTableView;
}

- (NSMutableArray *)addressArray{
    if (!_addressArray) {
        _addressArray = ({
            [[NSMutableArray alloc] init];
        });
    }
    return _addressArray;
}

- (AMapSearchAPI *)search{
    if (!_search) {
        _search = ({
            [AMapServices sharedServices].apiKey = self.mapKey;
            AMapSearchAPI *api = [[AMapSearchAPI alloc] init];
            api.delegate       = self;
            api;
        });
    }
    return _search;
}

- (void)setSuccessBlock:(SelectLocationSuccessBlock)successBlock{
    _successBlock = successBlock;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
