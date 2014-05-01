//
//  WLJLeftViewController.h
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-19.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"

@interface WLJLeftViewController : UIViewController<ICSDrawerControllerChild,ICSDrawerControllerPresenting>
@property (nonatomic, weak) ICSDrawerController *drawer;
@end
