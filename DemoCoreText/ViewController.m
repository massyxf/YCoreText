//
//  ViewController.m
//  DemoCoreText
//
//  Created by yxf on 2017/6/12.
//  Copyright © 2017年 yxf. All rights reserved.
//

#import "ViewController.h"
#import "YCTView.h"
#import "YCTModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    NSString *text = [NSString stringWithFormat:@"汗牛充栋→%@栋梁之才→%@才轻德薄→%@薄暮冥冥→%@冥顽不灵→%@灵心%@慧齿→齿牙%@余论→论千%@论万→%@万里长城",YCEmoji,YCEmoji,YCEmoji,YCUrl,YCEmoji,YCEmoji,YCEmoji,YCUrl,YCEmoji];
    YCTModel *model = [YCTModel initWithText:text containerWith:200];
    
    YCTView *view = [[YCTView alloc] initWithFrame:CGRectMake(20, 50, 200, model.height)];
    [self.view addSubview:view];
    view.model = model;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
