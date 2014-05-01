//
//  WXCondition.m
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import "WXCondition.h"
#define MPS_TO_MPH 2.23694f

@implementation WXCondition

+ (NSDictionary *)imageMap{
    
    //创建静态的NSDictionary，因为WXCondition的每个实例都将使用相同的数据映射
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        _imageMap = @{@"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"waather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",};
    }
    return _imageMap;
}

- (NSString *)imageName {
    return [WXCondition imageMap][self.icon];
}

/*“JSON到模型属性”的映射,该方法是MTLJSONSerializing协议的require
 *dictionary的key是WXContidion属性的名称,value是JSON的路径
 *这里有一个JSON数据映射到Objective-C属性的问题。属性date是NSDate类型，
 *但是JSON有一个Unix时间类型(即从1970年1月1日0时0分0秒起至现在的总秒数)的
 *NSinteger数值。我们需要完成它们之间的转换。
 *Mantle有一个功能来解决这个问题：MTLValueTransformer。这个类允许声明一个
 *block，详细说明数值之间的相互转化。
 */

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    return @{@"date": @"dt",
             @"locationName": @"name",
             @"humidity" : @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed" : @"wind.speed"
             };
}

/*
 *Mantle的转换器的语法有点怪，要创建一个为一个特定属性的转换器，可以添加一个
 *以属性名开头和JSONTransformer结尾的类方法.
 */

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [NSDate dateWithTimeIntervalSince1970:str.floatValue];
    } reverseBlock:^(NSDate *date) {
        return [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    }];
}

+ (NSValueTransformer *)sunriseJSONTransformer{
    return [self dateJSONTransformer];
}
+ (NSValueTransformer *)sunsetJSONTransformer{
    return [self dateJSONTransformer];
}

/*
 *下一个值转型有点讨厌，但它只是使用OpenWeatherMap的API，并自己的格式化
 *JSON响应方式的结果。weather键对应的值是一个JSON数组，但你只关注单一的天气
 *状况。
 */
+ (NSValueTransformer *)conditionDescriptionJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSArray *values) {
        return [values firstObject];
    } reverseBlock:^(NSString *str){
        return @[str];
    }];
}

+ (NSValueTransformer *)conditionJSONTransformer{
    return [self conditionDescriptionJSONTransformer];
}
+ (NSValueTransformer *)iconJSONTransformer{
    return [self conditionDescriptionJSONTransformer];
}
/*
 *最后的转换器只是为了格式化。 OpenWeatherAPI使用每秒/米的风速。由于您的
 *App使用英制系统，你需要将其转换为每小时/英里。
 */
+ (NSValueTransformer *)windSpeedJSONTransformer{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSNumber *num) {
        return @(num.floatValue * MPS_TO_MPH);
    } reverseBlock:^(NSNumber *speed) {
        return @(speed.floatValue / MPS_TO_MPH);
        }];
}


@end
