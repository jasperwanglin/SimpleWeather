//
//  WXController.m
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import "WXController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "WXManager.h"

#define TABLEVIEW_HEIGHT 44
#define ICON_TAG 1
#define TEMPERATURE_LABLE_TAG 2
#define HILO_LABEL_TAG 3
#define CONDITION_LABEL_TAG 4
#define CITY_LABEL_TAG 5
#define MY_ICONE_TAG 6
#define DETAIL_LABEL_TAG 7
#define SHARE_BUTTON_TAG 8

@interface WXController ()

//私有的接口
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
//注意，tableView是透明的
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;

//配置日期格式
@property (nonatomic, strong) NSDateFormatter *hourlyFormatter;
@property (nonatomic, strong) NSDateFormatter *dailyFormatter;

@property (nonatomic, assign)CGRect tempLabelRect;
@property (nonatomic, assign)CGRect iconRect;
@property (nonatomic, assign)CGRect hiloLabelRect;
@property (nonatomic, assign)CGRect conditionLabelRect;
@property (nonatomic, assign)CGRect cityLabelRect;

@end

@implementation WXController

/*
 *在-init中初始化这些日期格式化，而不是在-viewDidLoad中初始化他们。
 *因为-viewDidLoad可以在一个视图控制器的生命周期中多次调用。NSDateFormatter对象的初始化是昂贵的，
 *而将它们放置在你的-init，会确保被你的视图控制器初始化一次。
 */

- (id)init {
    if (self = [super init]) {
        _hourlyFormatter = [[NSDateFormatter alloc] init];
        _hourlyFormatter.dateFormat = @"h a";
        
        _dailyFormatter = [[NSDateFormatter alloc] init];
        _dailyFormatter.dateFormat = @"EEEE";
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    NSLog(@"%s",__func__);
    [super viewDidLoad];
    //左侧分享
    UIImage *shareImage = [UIImage imageNamed:@"Button"];
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.tag = SHARE_BUTTON_TAG;
    [shareButton setImage:shareImage forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(10, 30, shareImage.size.width, shareImage.size.height);
    [shareButton addTarget:self action:@selector(OpenDrawer:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //获取并存储屏幕的高度，之后，将在用分页的方式显示所有天气数据的时候使用它
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIImage *background = [UIImage imageNamed:@"bgImg"];
    
    //创建一个静态的背景图，并添加到视图上
    
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
   
    //使用LBBlurredImage来创建一个模糊的背景图像，设置alpha为0，使得开始backgroundImageView是可见的
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    //创建tableView来处理所有的数据呈现，设置WXController为delegate和dataSource,以及滚动视图的delegate。注意，pagingEnable为YES
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];//这样才能显示背后的图片
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    [self.view addSubview:self.tableView];
    
    /*
     *下面都是设置布局框架和边距
     */
    //table的header大小和屏幕的大小相同，我们利用UITableView的分页来分割页面页头和每日每时的天气预报
    CGRect headerFrame = [UIScreen mainScreen].bounds;
    //创建inset变量，以便所有的标签均匀的分布并且居中
    CGFloat inset = 20;
    
    CGFloat temperatureHeight = 110;
    CGFloat hiloHeight = 40;
    CGFloat iconHeight = 30;
    
    CGRect hiloFrame = CGRectMake(inset, headerFrame.size.height - hiloHeight, headerFrame.size.width - (2 * inset), hiloHeight);
    
    CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - (temperatureHeight + hiloHeight), headerFrame.size.width - (2 * inset), temperatureHeight);
    
    CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
    
    CGRect conditionsFrame = iconFrame;
    conditionsFrame.size.width = self.view.bounds.size.width - (((2 * inset) + iconHeight) + 10);
    conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
    
    /*
     *设置各种控件
     */
    
    //设置当前view作为table header
    UIView *header = [[UIView alloc] initWithFrame:headerFrame];
    header.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = header;
    
   [self.tableView.tableHeaderView addSubview:shareButton];
    
    //构建每一个显示气象数据的标签
      //bottom left
    UILabel *temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
    _tempLabelRect = temperatureFrame;
    temperatureLabel.backgroundColor = [UIColor clearColor];
    temperatureLabel.textColor = [UIColor whiteColor];
    temperatureLabel.text = @"0˚";
    temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
    temperatureLabel.tag = TEMPERATURE_LABLE_TAG;
    [header addSubview:temperatureLabel];
    
      //botton left
    UILabel *hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
    _hiloLabelRect = hiloFrame;
    hiloLabel.backgroundColor = [UIColor clearColor];
    hiloLabel.textColor = [UIColor whiteColor];
    hiloLabel.text = @"0˚ / 0˚";
    hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
    hiloLabel.tag = HILO_LABEL_TAG;
    [header addSubview:hiloLabel];
    
      //top
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 30)];
    _cityLabelRect = cityLabel.frame;
    cityLabel.backgroundColor = [UIColor clearColor];
    cityLabel.textColor = [UIColor whiteColor];
    cityLabel.text = @"Loading...";
    cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cityLabel.textAlignment = NSTextAlignmentCenter;
    cityLabel.tag = CITY_LABEL_TAG;
    [header addSubview:cityLabel];
    
    UILabel *conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
    _conditionLabelRect = conditionsFrame;
    conditionsLabel.backgroundColor = [UIColor clearColor];
    conditionsLabel.text = @"clear";
    conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    conditionsLabel.textColor = [UIColor whiteColor];
    conditionsLabel.tag = CONDITION_LABEL_TAG;
    [header addSubview:conditionsLabel];
    
    //添加我自己的标识
    UILabel *myIcon = [[UILabel alloc] init];
    myIcon.tag = MY_ICONE_TAG;
    CGRect myIconFrame = CGRectMake(self.view.frame.size.width - 90, self.view.frame.size.height - 30, 80, 30);
    myIcon.frame = myIconFrame;
    myIcon.textAlignment = NSTextAlignmentCenter;
    myIcon.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    myIcon.textColor = [UIColor whiteColor];
    myIcon.text = @"WangLin";
    [self.view addSubview:myIcon];
    //表视图拉到尾页的时候，要展现在尾部
    UILabel *detailLabel = [[UILabel alloc] init];
    detailLabel.tag = DETAIL_LABEL_TAG;
    detailLabel.alpha = 0.0;
    CGRect detailLabelRect = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 60, [UIScreen mainScreen].bounds.size.width, 40);
    detailLabel.frame = detailLabelRect;
    detailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:30];
    detailLabel.textColor = [UIColor whiteColor];
    detailLabel.textAlignment = NSTextAlignmentCenter;
    detailLabel.text = [NSString stringWithFormat:@"Design by 王霖"];
    [self.view addSubview:detailLabel];
    
    //添加一个天气图标的图像视图
      //bottom left
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:iconFrame];
    _iconRect = iconFrame;
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.backgroundColor = [UIColor clearColor];
    iconView.tag = ICON_TAG;
    [header addSubview:iconView];
    
    //观察WXManager单例的currentCondition.
    [[RACObserve([WXManager sharedManager], currentCondition)
      // 传递在主线程上的任何变化，因为正在更新UI
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(WXCondition *newCondition) {
         // 使用气象数据更新文本标签；你为文本标签使用newCondition的数据，
         // 而不是单例。订阅者的参数保证是最新的值
         temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",newCondition.temperature.floatValue];
         conditionsLabel.text = [newCondition.condition capitalizedString];
         cityLabel.text = [newCondition.locationName capitalizedString];
         
         // 使用映射的图像文件名创建一个图像，并将其设置为视图的图标
         iconView.image = [UIImage imageNamed:[newCondition imageName]];
     }];
    //当天的最高温度和最低温度
    RAC(hiloLabel, text) = [[RACSignal combineLatest:@[
                                                       RACObserve([WXManager sharedManager], currentCondition.tempHigh),
                                                       RACObserve([WXManager sharedManager], currentCondition.tempLow)]
                                              reduce:^(NSNumber *hi, NSNumber *low) {
                                                  return [NSString  stringWithFormat:@"%.0f° / %.0f°",hi.floatValue,low.floatValue];
                                              }]
                            deliverOn:RACScheduler.mainThreadScheduler];
    
    [[RACObserve([WXManager sharedManager], hourlyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    
    [[RACObserve([WXManager sharedManager], dailyForecast)
      deliverOn:RACScheduler.mainThreadScheduler]
     subscribeNext:^(NSArray *newForecast) {
         [self.tableView reloadData];
     }];
    
    //告诉管理类，开始寻找设备当前的位置
    [[WXManager sharedManager] findCurrentLocation];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
//父视图的bounds发生变化的时候，调整子视图的布局
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    NSLog(@"%s",__func__);
    CGRect bounds = self.view.bounds;
    
    self.backgroundImageView.frame = bounds;
    self.blurredImageView.frame = bounds;
    self.tableView.frame = bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //tableView有两个部分，一个是每小时的天气预报，另一个是每日播报
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //注意：您使用表格单元格作为标题，而不是内置的、具有粘性的滚动行为的标
    //题。这个table view设置了分页，粘性滚动行为看起来会很奇怪。
    //每个分段都添加一个页眉
    if (section == 0) {
        return MIN([[WXManager sharedManager].hourlyForecast count], 6) + 1;
    }
    return MIN([[WXManager sharedManager].dailyForecast count], 6) + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //tableView的背景要clearColor，cell的背景要如下的形式
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    //
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }else{
            WXCondition *weather = [WXManager sharedManager].hourlyForecast[indexPath.row - 1];
            [self configureHourlyCell:cell weather:weather];
        }
    }else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }else{
            WXCondition *weather = [WXManager sharedManager].dailyForecast[indexPath.row - 1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    
    return self.screenHeight / (CGFloat)cellCount;
}

//配置和添加文本到作为section页眉单元格。你会重用此为每日每时的预测部分。
- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}
//格式化逐时预报的单元格。
- (void)configureHourlyCell:(UITableViewCell *)cell weather:(WXCondition *)weather {
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    
    cell.textLabel.text = [self.hourlyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f",weather.temperature.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}
//格式化每日预报的单元格。
- (void)configureDailyCell:(UITableViewCell *)cell weather:(WXCondition *)weather{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    
    cell.textLabel.text = [self.dailyFormatter stringFromDate:weather.date];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.0f / %.0f",
                                 weather.tempHigh.floatValue,
                                 weather.tempLow.floatValue];
    cell.imageView.image = [UIImage imageNamed:[weather imageName]];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    
    CGFloat percent = MIN(position / height, 1.0);
    UILabel *tempLabel = (UILabel *)[self.tableView.tableHeaderView viewWithTag:TEMPERATURE_LABLE_TAG];
    UILabel *hiloLabel = (UILabel *)[self.tableView.tableHeaderView viewWithTag:HILO_LABEL_TAG];
    UILabel *conditionLabel = (UILabel *)[self.tableView.tableHeaderView viewWithTag:CONDITION_LABEL_TAG];
    UIImageView *icon = (UIImageView *)[self.tableView.tableHeaderView viewWithTag:ICON_TAG];
    UILabel *cityLabel = (UILabel *)[self.tableView.tableHeaderView viewWithTag:CITY_LABEL_TAG];
    
    if (scrollView.contentOffset.y > 0.0f && scrollView.contentOffset.y < [UIScreen mainScreen].bounds.size.height) {
        CGRect rect = _tempLabelRect;
        rect.origin.y -= scrollView.contentOffset.y * 0.6;
        tempLabel.frame = rect;
        
        rect = _hiloLabelRect;
        rect.origin.y -= scrollView.contentOffset.y * 0.5;
        hiloLabel.frame = rect;
        
        rect = _conditionLabelRect;
        rect.origin.y -= scrollView.contentOffset.y * 0.8;
        conditionLabel.frame = rect;
        
        rect= _iconRect;
        rect.origin.y -= scrollView.contentOffset.y * 0.8;
        icon.frame = rect;
    }else if(scrollView.contentOffset.y < 0.0){
        CGRect rect = _cityLabelRect;
        rect.origin.y -= scrollView.contentOffset.y;
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:((-scrollView.contentOffset.y * 3.5) / [UIScreen mainScreen].bounds.size.height + 1) * 18];
        cityLabel.frame = rect;
        
        rect = _tempLabelRect;
        rect.origin.y += scrollView.contentOffset.y * 0.4;
        tempLabel.frame = rect;
        
        rect = _hiloLabelRect;
        rect.origin.y += scrollView.contentOffset.y * 0.2;
        hiloLabel.frame = rect;
        
        rect = _conditionLabelRect;
        rect.origin.y += scrollView.contentOffset.y * 0.8;
        conditionLabel.frame = rect;
        
        rect= _iconRect;
        rect.origin.y += scrollView.contentOffset.y * 0.8;
        icon.frame = rect;
    }else if (scrollView.contentOffset.y > [UIScreen mainScreen].bounds.size.height * 2){
        UILabel *detailLabel = (UILabel *)[self.view viewWithTag:DETAIL_LABEL_TAG];
        detailLabel.alpha = (scrollView.contentOffset.y - [UIScreen mainScreen].bounds.size.height * 2.0) / [UIScreen mainScreen].bounds.size.height * 2;
        
        UILabel *myIcon = (UILabel *)[self.view viewWithTag:MY_ICONE_TAG];
        myIcon.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:(1 - (scrollView.contentOffset.y - [UIScreen mainScreen].bounds.size.height * 2.0) / [UIScreen mainScreen].bounds.size.height) * 18];
    }
    
    self.blurredImageView.alpha = percent;
}

#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = NO;
    NSLog(@"%s",__func__);
}
- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController{
    NSLog(@"%s",__func__);
    UIButton * shareButton = (UIButton *)[self.tableView.tableHeaderView viewWithTag:SHARE_BUTTON_TAG];
    [UIView animateWithDuration:0.4 animations:^{
        shareButton.transform = CGAffineTransformMakeRotation( M_PI / 2);
    } completion:nil];
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController{
    NSLog(@"%s",__func__);
}
- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController{
    self.view.userInteractionEnabled = YES;
    NSLog(@"%s",__func__);
    UIButton * shareButton = (UIButton *)[self.tableView.tableHeaderView viewWithTag:SHARE_BUTTON_TAG];
    [UIView animateWithDuration:0.4 animations:^{
        shareButton.transform = CGAffineTransformMakeRotation( 0 );
    } completion:nil];
}


//点击抽屉视图打开按钮
- (void)OpenDrawer:(id)sender{
    [self.drawer open];
}
@end
