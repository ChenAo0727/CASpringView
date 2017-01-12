//
//  CASpringView.h
//  CASpringViewDemo
//
//  Created by chenao on 17/1/11.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CASpringView : UIView

//弹性视图宽度 默认28
@property (nonatomic, assign) CGFloat width;

//弹性视图显示数字 默认不显示 必须大于0
@property (nonatomic, assign) NSInteger count;

//弹性视图 Label
@property (nonatomic, strong) UILabel *springLabel;

//弹性视图背景色 默认 redColor
@property (nonatomic, strong) UIColor *color;

//弹性视图拉伸变化系数 默认 1 / width 
@property (nonatomic, assign) CGFloat stretchRatio;

//弹性视图拽出系数 默认 0.5
@property (nonatomic, assign) CGFloat dragRatio;

//弹性视图爆破时与初始中心距离 大于该值时才会爆破 默认 10
@property (nonatomic, assign) CGFloat boomDistance;

+ (instancetype)attachToView:(UIView *)pView withFrame:(CGRect)frame;
- (void)reset;

@end
