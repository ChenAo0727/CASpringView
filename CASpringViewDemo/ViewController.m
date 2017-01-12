//
//  ViewController.m
//  CASpringViewDemo
//
//  Created by chenao on 17/1/11.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "ViewController.h"
#import "CASpringView.h"
@interface ViewController ()
@property (nonatomic, strong) CASpringView *springView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setUpSpringView];
}

- (IBAction)reset:(id)sender {
    [self.springView reset];
}


- (void)setUpSpringView {
    CASpringView *view = [CASpringView attachToView:self.view withFrame:CGRectMake(30,[UIScreen mainScreen].bounds.size.height - 90, 120, 200)];
    view.count = 20;
    view.stretchRatio = 1 / 20.0 ;
    view.width = 60;
    view.dragRatio = 0.6;
    view.color = [UIColor orangeColor];
    view.boomDistance = 50;
    self.springView = view;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
