//
//  WXClient.h
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

@import CoreLocation;
@import Foundation;
//@import指令，它是xcode5被引入，看做一个现代的更高效的替代#import.
#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
/*WXClient的唯一职责是创建API请求，并解析它们；别人可以不用担心数据做什么以
 *及如何存储它，话分类的不同工作职责的设计模式被称为关注点分离。
 */
@interface WXClient : NSObject

/*
 *介绍ReactiveCocoa！
 *
 *ReactiveCocoa（RAC）是一个Objective-C的框架，用于函数式反应型编程，它提
 *供了组合和转化数据流的API。代替专注于编写串行的代码 – 执行有序的代码队列 – 
 *可以响应非确定性事件。
 *
 *Github上提供的a great overview of the benefits：
 *1.对未来数据的进行组合操作的能力。
 *2.减少状态和可变性。
 *3.用声明的形式来定义行为和属性之间的关系。
 *4.为异步操作带来一个统一的，高层次的接口。
 *5.在KVO的基础上建立一个优雅的API。
 *
 *例子：可以监听username属性的变化：
 *
 *[RACAble(self.username) subscribleNext:^(NSString *newName) {
 *      NSLong(@"%@", newName);
 *}];
 *
 *subscribleNext这个block会在self.username属性发生变化的时候执行.这个
 *新值会传递给这个block。
 *您还可以合并信号并组合数据到一个组合数据中。下面的示例取自于ReactiveCocoa
 *的Github页面：
 * [[RACSignal
 * combineLatest:@[ RACAble(self.password), RACAble(self.passwordConfirmation) ]
 * reduce:^(NSString *currentPassword, NSString *currentConfirmPassword) {
 * return [NSNumber numberWithBool:[currentConfirmPassword isEqualToString:currentPassword]];
 * }]
 * subscribeNext:^(NSNumber *passwordsMatch) {
 * self.createEnabled = [passwordsMatch boolValue];
 * }];
 */
/*
 *RACSignal对象捕捉当前和未来的值。信号可以被观察者链接，组合和反应。信号实际上不会执行，直到它被订阅。
 
 *这意味着调用[mySignal fetchCurrentConditionsForLocation：someLocation];
 *不会做什么，但创建并返回一个信号。你将看到之后如何订阅和反应。
 */
- (RACSignal *)fetchJSONFormURL:(NSURL *)url;
- (RACSignal *)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D) coordinate;
- (RACSignal *)fetchHourlyForecastForLocation:(CLLocationCoordinate2D) coordinate;
- (RACSignal *)fetchDailyForecastForLocation:(CLLocationCoordinate2D) coordinate;
@end
