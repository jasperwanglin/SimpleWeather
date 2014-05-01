//
//  WLJAppDelegate.m
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-18.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import "WLJAppDelegate.h"
#import "WXController.h"
#import <TSMessage.h>
#import "ICSDrawerController.h"
#import "WLJLeftViewController.h"


@implementation WLJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //作为中心视图控制器
    WXController *centerViewController = [[WXController alloc] init];
    //作为左边视图控制器
    WLJLeftViewController *leftViewController = [[WLJLeftViewController alloc] init];
    //初始化抽屉视图控制器
    ICSDrawerController *drawerViewController = [[ICSDrawerController alloc] initWithLeftViewController:leftViewController centerViewController:centerViewController];
    
    self.window.rootViewController = drawerViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [TSMessage setDefaultViewController: self.window.rootViewController];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
