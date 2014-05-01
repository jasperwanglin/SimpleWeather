//
//  WXCondition.h
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

/*
 *天气的模型使用Mantle,这使得数据的映射和转变非常简单
 */
#import "MTLModel.h"
#import <Mantle.h>
//MTLJSONSerializing协议告诉Mantle序列化该对象如何从JSON映射到Objective-C的属性
@interface WXCondition : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSDate *date;//日期
@property (nonatomic, strong) NSNumber *humidity;//湿度
@property (nonatomic, strong) NSNumber *temperature;
@property (nonatomic, strong) NSNumber *tempHigh;
@property (nonatomic, strong) NSNumber *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong)NSString *icon;

//从天气状况映射到图像文件
- (NSString *)imageName;

@end
