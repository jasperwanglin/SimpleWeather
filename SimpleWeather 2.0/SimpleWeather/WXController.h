//
//  WXController.h
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"

@interface WXController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,ICSDrawerControllerPresenting,ICSDrawerControllerChild>
@property (nonatomic, weak)ICSDrawerController *drawer;
@property (nonatomic, strong) UIAlertView *alertView;

@end
