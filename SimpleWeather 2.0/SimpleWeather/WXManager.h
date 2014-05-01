//
//  WXManager.h
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 201;年 Jasper. All rights reserved.
//

@import Foundation;
@import CoreLocation;
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
/*没有引入WXDailyForecast.h,我们始终使用WXCondition作为预报的类.
 *WXDailyForecast的存在是为了帮助Mantle转换JSON到Objective-C
 */

#import "WXCondition.h"

//这个类把所有的东西结合在一起
/*
 *1.它使用单例设计模式
 *2.它试图找到设备的位置
 *3.找到位置之后，它获取相应的气象数据
 */
@interface WXManager : NSObject<CLLocationManagerDelegate>

//使用instancetype而不是WXManager，子类将返回适当的类型。
+ (instancetype)sharedManager;

//这些属性将存储您的数据。由于WXManager是一个单例，这些属性可以任意访问。设
//置公共属性为只读，因为只有管理者能更改这些值。
@property (nonatomic, strong, readonly) CLLocation *currentLocation;
@property (nonatomic, strong, readonly) WXCondition *currentCondition;
@property (nonatomic, strong, readonly) NSArray *hourlyForecast;
@property (nonatomic, strong, readonly) NSArray *dailyForecast;

//这个方法移动或者刷新整个位置和天气的查找过程
- (void)findCurrentLocation;


@end
