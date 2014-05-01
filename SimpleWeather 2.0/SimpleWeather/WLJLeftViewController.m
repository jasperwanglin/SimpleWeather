//
//  WLJLeftViewController.m
//  SimpleWeather
//
//  Created by 王 霖 on 14-4-19.
//  Copyright (c) 2014年 Jasper. All rights reserved.
//

#import "WLJLeftViewController.h"
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>


@interface WLJLeftViewController ()
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) UIImageView *shareImageView;
//

@end

@implementation WLJLeftViewController

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
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *background = [UIImage imageNamed:@"LeftImg"];
    //静态背景图
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    //添加模糊效果
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.frame = [UIScreen mainScreen].bounds;
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 1;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    // Do any additional setup after loading the view.
    
    //各个分享平台
    UIImage *shareImage = [UIImage imageNamed:@"share"];
    UIImageView *shareImageView = [[UIImageView alloc] initWithImage: shareImage];
    shareImageView.frame = CGRectMake(20, 60, shareImage.size.width, shareImage.size.height);
    [self.view addSubview:shareImageView];
    
    UIImage *twitterImage = [UIImage imageNamed:@"twitter"];
    UIImageView *twitterImageView = [[UIImageView alloc] initWithImage:twitterImage];
    twitterImageView.frame = CGRectMake(88, 60, twitterImage.size.width, twitterImage.size.height);
    [self.view addSubview:twitterImageView];
    
    UIImage *weixinImage = [UIImage imageNamed:@"weixinshare"];
    UIImageView *weixinImageView = [[UIImageView alloc] initWithImage:weixinImage];
    weixinImageView.frame = CGRectMake(145, 60, weixinImage.size.width, weixinImage.size.height);
    [self.view addSubview:weixinImageView];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
