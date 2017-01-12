//
//  CASpringView.m
//  CASpringViewDemo
//
//  Created by chenao on 17/1/11.
//  Copyright © 2017年 chenao. All rights reserved.
//

#import "CASpringView.h"
#import "CASpringViewDemo-Swift.h"
@implementation CASpringView {
    UIView *_parentView;
    UIView *_scaleSpringView;
    UIView *_dragSpringView;
    UIBezierPath *_springPath;
    UIColor *_springPathFillColor;
    CAShapeLayer *_shapeLayer;

    CGFloat R1; //小圆半径
    CGFloat X1; //小圆圆心X坐标
    CGFloat Y1; //小圆圆心Y坐标
    
    CGFloat R2; //大圆半径
    CGFloat X2; //大圆圆心X坐标
    CGFloat Y2; //大圆圆心Y坐标

    CGFloat dragDistance; //两圆心距离
    CGFloat sinDigree;
    CGFloat cosDigree;
    
    CGPoint pointR1T; // 小圆上部点
    CGPoint pointR1B; // 小圆下部点
    CGPoint pointR2T; // 大圆上部点
    CGPoint pointR2B; // 大圆下部点
    CGPoint pointTop;    //上部控制点
    CGPoint pointBottom; //下部控制点
    
    CGRect initailFrame;
    BOOL _lock;
    BOOL _dragOut;
}

#pragma mark - initial
+ (instancetype)attachToView:(UIView *)pView withFrame:(CGRect)frame {
    CASpringView *view = [[CASpringView alloc] initWithFrame:frame];
    [pView addSubview:view];
    view -> _parentView = pView;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
     self =  [super initWithFrame:frame];
    if (self) {
        CGFloat width = MIN(frame.size.width, frame.size.height);
        if (width == 0) {
            width = 28;
        }
        self.frame = CGRectMake(frame.origin.x, frame.origin.y, width, width);
        self.width = width;
        self.dragRatio = 0.5;
        if (!_lock) {
            self.stretchRatio = 1 / self.width;
        }
        [self setUp];
    }
    return self;
}

- (void)setUp {
    self.backgroundColor = [UIColor clearColor];
    
    _scaleSpringView = [[UIView alloc]initWithFrame:initailFrame];
    [_parentView insertSubview:_scaleSpringView aboveSubview:self];
    _scaleSpringView.layer.cornerRadius = self.width / 2;
    _scaleSpringView.backgroundColor = self.color ?: [UIColor redColor];
    
    _dragSpringView = [[UIView alloc]initWithFrame:initailFrame];
    [_parentView insertSubview:_dragSpringView aboveSubview:_scaleSpringView];
    _dragSpringView.layer.cornerRadius = self.width / 2;
    _dragSpringView.backgroundColor = self.color ?: [UIColor redColor];
    
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [_dragSpringView addGestureRecognizer:pan];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [_dragSpringView addGestureRecognizer:tap];
    
    self.springLabel = [[UILabel alloc]init];
    [_dragSpringView addSubview:self.springLabel];
    self.springLabel.textAlignment = NSTextAlignmentCenter;
    self.springLabel.textColor = [UIColor whiteColor];
    [self setUpSpringViewLabel];
    
    _shapeLayer = [CAShapeLayer layer];
    R1 = R2 = initailFrame.size.width / 2;
}

- (void)setUpSpringViewLabel {
    self.springLabel.frame = CGRectMake(0, 0, self.width, self.width);
    self.springLabel.font = [UIFont systemFontOfSize:self.width / 2];
}

- (void)didMoveToSuperview {
     _parentView = self.superview;
    [self.superview insertSubview:_scaleSpringView aboveSubview:self];
    [self.superview insertSubview:_dragSpringView aboveSubview:_scaleSpringView];
}

#pragma mark - Setter

- (void)setWidth:(CGFloat)width {
    if (_width != width) {
        _width = width;
        CGRect rect = self.frame;
        rect.size.width = width;
        rect.size.height = width;
        self.frame = rect;
        initailFrame = self.frame;
        _dragSpringView.frame = initailFrame;
        _scaleSpringView.frame = initailFrame;
        _dragSpringView.layer.cornerRadius = self.width / 2;
        _scaleSpringView.layer.cornerRadius = self.width / 2;
         R1 = R2 = initailFrame.size.width / 2;
        if (!_lock) {
            self.stretchRatio = 1 / self.width;
        }
        [self setUpSpringViewLabel];
    }
}

- (void)setStretchRatio:(CGFloat)stretchRatio {
    if (_stretchRatio != stretchRatio) {
        _stretchRatio = stretchRatio;
        _lock = YES;
    }
}

- (void)setCount:(NSInteger)count {
    if (count <= 0) {
        return;
    }
    if (count > 99) {
        count = 99;
    }
    if (_count != count) {
        _count = count;
        self.springLabel .text = [NSString stringWithFormat:@"%zi",count];
    }
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _scaleSpringView.backgroundColor = _color ?: [UIColor redColor];
    _dragSpringView.backgroundColor = _color ?: [UIColor redColor];
}

#pragma mark - gesture
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture {
    
    CGPoint movePoint = [gesture locationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _dragSpringView.frame = initailFrame;
        _scaleSpringView.frame = initailFrame;
        _scaleSpringView.hidden = NO;
        R1 = R2 = initailFrame.size.width / 2;
    }else if (gesture.state == UIGestureRecognizerStateChanged) {
        _dragSpringView.center = movePoint;
        if (R1 <= self.dragRatio * R2) {
            _scaleSpringView.hidden = YES;
            _springPathFillColor = [UIColor clearColor];
            [_shapeLayer removeFromSuperlayer];
            _dragOut = YES;
        }else {
            _dragOut = NO;
            [self shapeChange];
        }
    }else {
    
        X2 = _dragSpringView.frame.origin.x + _dragSpringView.frame.size.width / 2;
        Y2 = _dragSpringView.frame.origin.y + _dragSpringView.frame.size.width / 2;
        
        CGFloat distance = sqrtf(pow((X1 - X2), 2) + pow((Y1 - Y2), 2));
        
        if (distance > self.boomDistance && _dragOut) {
            //boom
            [_dragSpringView boom];
            
        } else {
             //回弹
            _springPathFillColor = [UIColor clearColor];
            [_shapeLayer removeFromSuperlayer];
            [UIView animateWithDuration:0.6
                                  delay:0
                 usingSpringWithDamping:0.3
                  initialSpringVelocity:10
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 _dragSpringView.frame =  initailFrame;
                             }
                             completion:^(BOOL finished) {
                               
                             }];
        }
    }
}

- (void)shapeChange {
    X1 = initailFrame.origin.x + initailFrame.size.width / 2;
    Y1 = initailFrame.origin.y + initailFrame.size.width / 2;
    X2 = _dragSpringView.center.x;
    Y2 = _dragSpringView.center.y;
    
    R2 = initailFrame.size.width / 2;
    dragDistance = sqrtf(pow(X2 - X1, 2) + pow(Y2 - Y1, 2));
    
    R1 = MAX(0, MIN(R2, R2  - self.stretchRatio * dragDistance));
    
    sinDigree = dragDistance == 0 ? 0 : (X2 - X1) / dragDistance;
    cosDigree = dragDistance == 0 ? 1 : (Y2 - Y1) / dragDistance;
    pointR1T = CGPointMake(X1 - R1 * cosDigree, Y1 + R1 * sinDigree);
    pointR1B = CGPointMake(X1 + R1 * cosDigree, Y1 - R1 * sinDigree);
    pointR2B = CGPointMake(X2 + R2 * cosDigree, Y2 - R2 * sinDigree);
    pointR2T = CGPointMake(X2 - R2 * cosDigree, Y2 + R2 * sinDigree);
    pointTop = CGPointMake(pointR1T.x + dragDistance / 2 * sinDigree, pointR1T.y + dragDistance / 2 * cosDigree);
    pointBottom = CGPointMake(pointR1B.x + dragDistance / 2 * sinDigree, pointR1B.y + dragDistance / 2 * cosDigree);
    
    _scaleSpringView.bounds = CGRectMake(0, 0, 2 * R1, 2 * R1);
    _scaleSpringView.center = CGPointMake(X1, Y1);
    _scaleSpringView.layer.cornerRadius = R1;
    
    _springPath = [UIBezierPath bezierPath];
    [_springPath moveToPoint:pointR1T];
    [_springPath addQuadCurveToPoint:pointR2T controlPoint:pointTop];
    [_springPath addLineToPoint:pointR2B];
    [_springPath addQuadCurveToPoint:pointR1B controlPoint:pointBottom];
    [_springPath moveToPoint:pointR1T];
    _shapeLayer.path = [_springPath CGPath];
    _shapeLayer.fillColor = [self.color CGColor];
    [self.superview.layer insertSublayer:_shapeLayer
                                       below:_scaleSpringView.layer];
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)gesture {
    [self tapAnimation];
}

- (void)reset {
    _dragSpringView.frame = initailFrame;
    _scaleSpringView.frame = initailFrame;
    _dragSpringView.layer.cornerRadius = initailFrame.size.width / 2;
    _scaleSpringView.layer.cornerRadius = initailFrame.size.width / 2;
    _dragSpringView.alpha = 1.0;
}

- (void)tapAnimation {
    CAKeyframeAnimation *scale =
    [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.5;
    scale.values = @[ @1.0, @1.1,@1.2,@1.1, @1.0 ];
    scale.repeatCount = 1;
    scale.autoreverses = YES;
    
    scale.timingFunction = [CAMediaTimingFunction
                             functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_dragSpringView.layer addAnimation:scale forKey:@"scaleAnimation"];

}

@end
