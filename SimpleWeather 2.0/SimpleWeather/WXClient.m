//
//  WXClient.m
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import "WXClient.h"
#import "WXCondition.h"
#import "WXDailyForecast.h"

@interface WXClient ()
//这个接口用这个属性来管理API请求的URL session.
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation WXClient

- (id)init{
    if (self = [super init]) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}


//构建信号
/*
 *1.返回信号。请记住，这将不会执行，直到这个信号被订阅。 - fetchJSONFromURL：创建一个对象给其他方法和对象使用；这种行为有时也被称为工厂模式。
 *2.创建一个NSURLSessionDataTask（在iOS7中加入）从URL取数据。你会在以后添加的数据解析。
 *3.一旦订阅了信号，启动网络请求。
 *4.创建并返回RACDisposable对象，它处理当信号摧毁时的清理工作。
 *5.增加了一个“side effect”，以记录发生的任何错误。side effect不订阅信号，相反，他们返回被连接到方法链的信号。你只需添加一个side effect来记录错误。
 */

- (RACSignal *)fetchJSONFormURL:(NSURL *)url{
    NSLog(@"Fetching %@",url.absoluteString);
    //1.返回信号。请记住，这将不会执行，直到这个信号被订阅。 - fetchJSONFromURL：创建一个对象给其他方法和对象使用；这种行为有时也被称为工厂模式。
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //2.创建一个NSURLSessionDataTask（在iOS7中加入）从URL取数据。你会在以后添加的数据解析。
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (! error) {
                NSError *jsonError = nil;
                id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonError];
                if (! jsonError) {
                    //当JSON数据存在并且没有错误，发送给订阅者序列化后的JSON数组或字典。
                    [subscriber sendNext:json];
                }else{
                    //在任一情况下如果有一个错误，通知订阅者。
                    [subscriber sendNext:jsonError];
                }
            }
            else{
                //在任一情况下如果有一个错误，通知订阅者。
                [subscriber sendError:error];
            }
            
            //3.无论该请求成功还是失败，通知订阅者请求已经完成。
            [subscriber sendCompleted];
        }];
        
        //3.一旦订阅了信号，启动网络请求。
        [dataTask resume];
        //4.创建并返回RACDisposable对象，它处理当信号摧毁时的清理工作。
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }] doError:^(NSError *error) {
        //5.增加了一个“side effect”，以记录发生的任何错误。side effect不订阅信号，相反，他们返回被连接到方法链的信号。你只需添加一个side effect来记录错误。
        NSLog(@"%@",error);
    }];
}


- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate{
    //使用CLLocationCoordinate2D对象的经纬度数据来格式化URL。
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL* url = [NSURL URLWithString:urlString];
    
    //用你刚刚建立的创建信号的方法。由于返回值是一个信号，你可以调用其他ReactiveCocoa的方法。 在这里，您将返回值映射到一个不同的值 – 一个NSDictionary实例。
    return [[self fetchJSONFormURL:url] map:^(NSDictionary *json) {
        //使用MTLJSONAdapter来转换JSON到WXCondition对象 – 使用MTLJSONSerializing协议创建的WXCondition。
        return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:json error:nil];
    }];
}

//获取逐时预报：根据坐标获取逐时预报的方法

- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    //再次使用-fetchJSONFromUR方法，映射JSON。注意：重复使用该方法节省了多少代码！
    return [[self fetchJSONFormURL:url] map:^(NSDictionary *json) {
        //使用JSON的”list”key创建RACSequence。 RACSequences让你对列表进行ReactiveCocoa操作。
        RACSequence *list = [json[@"list"] rac_sequence];
        //映射新的对象列表。调用-map：方法，针对列表中的每个对象，返回新对象的列表。
        return [[list map:^(NSDictionary *item) {
            //再次使用MTLJSONAdapter来转换JSON到WXCondition对象。
            return [MTLJSONAdapter modelOfClass:[WXCondition class] fromJSONDictionary:item error:nil];
            //
        }] array];
    }];
}

//获取每日预报
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D) coordinate{
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url  = [NSURL URLWithString:urlString];
    
    return [[self fetchJSONFormURL:url] map:^(NSDictionary *json) {
        RACSequence *list = [json[@"list"] rac_sequence];
        return [[list map:^(NSDictionary *item) {
            return [MTLJSONAdapter modelOfClass:[WXDailyForecast class] fromJSONDictionary:item error:nil];
        }] array];
    }];
}
@end
