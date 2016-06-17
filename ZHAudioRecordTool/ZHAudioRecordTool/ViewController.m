//
//  ViewController.m
//  ZHAudioRecordTool
//
//  Created by zhuhoulin on 16/6/17.
//  Copyright © 2016年 personal. All rights reserved.
//

#import "ViewController.h"
#import "ZHRecordAudioView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[ZHRecordAudioView initial] show];
}

@end
