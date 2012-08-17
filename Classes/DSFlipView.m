/* Copyright (C) 2012 by Dongsung "Don" Kim kiding@me.com
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE. */

#import "DSFlipView.h"

// flags
BOOL isDSFlipViewOpened = NO;
BOOL isDSFlipViewAnimating = NO;

@interface DSFlipView ()

- (void) initialize;
- (id) initWithFrame: (CGRect) frame;
- (id) initWithCoder:(NSCoder *)aDecoder;

- (void) setBackView:(UIView *)backView;
- (void) setSmallView:(UIView *)smallView;
- (void) setBigView:(UIView *)bigView;

- (IBAction)open:(id)sender;
- (IBAction)close:(id)sender;

- (void) layoutSubviews;

#pragma mark - blackTapper Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;

@property (weak) UIView *superView;

@end

@implementation DSFlipView

- (void) initialize
{
    // init
    _duration = .5f;
    _bigSize = (CGSize){250,250};
    
    // shadow
    CALayer *layer = self.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(1, 1);
    layer.shadowOpacity = 0.3f;
    layer.shadowRadius = 2;
}

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) setBackView:(UIView *)backView {
    _backView = backView;
    
    if(_blackView)
        [_blackView removeFromSuperview];
    
    if(backView) {
        _blackView = [[UIView alloc] init];
        _blackView.frame = _backView.bounds;
        _blackView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        _blackView.userInteractionEnabled = NO;
        
        UITapGestureRecognizer *blackTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        blackTapper.delegate = self;
        
        // prevent user interaction behind blackView
        UIPinchGestureRecognizer *nilPinch = [[UIPinchGestureRecognizer alloc] init];
        UIRotationGestureRecognizer *nilRotation = [[UIRotationGestureRecognizer alloc] init];
        UISwipeGestureRecognizer *nilSwipe = [[UISwipeGestureRecognizer alloc] init];
        UIPanGestureRecognizer *nilPan = [[UIPanGestureRecognizer alloc] init];
        UILongPressGestureRecognizer *nilLong = [[UILongPressGestureRecognizer alloc] init];
        
        _blackView.gestureRecognizers = @[ blackTapper, nilPinch, nilRotation, nilSwipe, nilPan, nilLong ];
    } else
        _blackView = nil;
}

- (void) setSmallView:(UIView *)smallView {
    if(_smallView)
        [_smallView removeFromSuperview];
    
    _smallView = smallView;
    
    if(smallView) {
        smallView.frame = self.bounds;
        smallView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        smallView.userInteractionEnabled = YES;
        smallView.clipsToBounds = YES;
        smallView.hidden = NO;
        
        UITapGestureRecognizer *smallTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(open:)];
        smallView.gestureRecognizers = @[ smallTapper ];
        
        [self addSubview:smallView];
    }
}

- (void) setBigView:(UIView *)bigView {
    if(_bigView)
        [_bigView removeFromSuperview];
    
    _bigView = bigView;
    
    if(bigView) {
        bigView.frame = self.bounds;
        bigView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        bigView.userInteractionEnabled = NO;
        bigView.clipsToBounds = YES;
        bigView.hidden = YES;
        
        [self addSubview:bigView];
    }
}

-(IBAction)open:(id)sender
{
    // DO NOT ANIMATE WHILE OTHER IS ANIMATING
    if(isDSFlipViewAnimating)
        return;

    // flags
    isDSFlipViewOpened = NO;
    isDSFlipViewAnimating = YES;
    
    // error handling
    if(!_smallView)
        NSLog(@"DSFlipView <0x%x>: smallView is nil.", (NSInteger)self);
    else if(!_bigView)
        NSLog(@"DSFlipView <0x%x>: bigView is nil.", (NSInteger)self);
    else if(!_backView)
        NSLog(@"DSFlipView <0x%x>: backView is nil.", (NSInteger)self);
    else if(!_blackView)
        NSLog(@"DSFlipView <0x%x>: blackView is nil; maybe backView is not specified.", (NSInteger)self);
    
    // dummyView init
    _dummyView = [[UIView alloc] initWithFrame:self.frame];
    _dummyView.autoresizingMask = self.autoresizingMask;
    _dummyView.userInteractionEnabled = NO;
    [[self superview] addSubview:_dummyView];
    
    // black view
    _blackView.frame = _backView.bounds;
    _blackView.userInteractionEnabled = NO;
    _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    // detach self from its superview and move to blackView
    _superView = self.superview;
    
    DSFlipView *me = self; // just to increase retain count while self is removed from superview
    [me removeFromSuperview];
    [_backView addSubview:_blackView];
    [_blackView addSubview:self];
    
    self.frame = [_superView convertRect:self.frame toView:_blackView];
    
    // smallView bigView init
    _smallView.hidden = NO;
    _smallView.userInteractionEnabled = NO;
    _bigView.hidden = YES;
    
    // outerPosition innerPosition outerFrame init
    CGPoint theCenter = (_backView ? _backView : self.superview).center;
    CGRect theBounds = (CGRect){(CGPoint){0,0}, _bigSize};
    
    CGPoint outerPosition = [_backView.superview convertPoint:theCenter toView:_backView];
    CGPoint innerPosition = (CGPoint){_bigSize.width/2, _bigSize.height/2};
    
    CGRect outerFrame = (CGRect){(CGPoint){outerPosition.x - _bigSize.width/2, outerPosition.y - _bigSize.height/2}, _bigSize};
    
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // small: rotation, position, bounds
    {
        CALayer *small = _smallView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        small.sublayerTransform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:0];
        rotationY.toValue = [NSNumber numberWithFloat:M_PI];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [small addAnimation:group forKey:@"group"];
        
        // apply to sublayers
        CAAnimationGroup *subGroup = [CAAnimationGroup animation];
        subGroup.animations = @[ position, bounds ];
        subGroup.duration = _duration;
        for(CALayer *s in small.sublayers)
            [s addAnimation:subGroup forKey:@"group"];
    }
    
    // big: rotation, position, bounds
    {
        CALayer *big = _bigView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / 850;
        big.sublayerTransform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:M_PI];
        rotationY.toValue = [NSNumber numberWithFloat:0];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [big addAnimation:group forKey:@"group"];
        
        // apply to sublayers
        CAAnimationGroup *subGroup = [CAAnimationGroup animation];
        subGroup.animations = @[ position, bounds ];
        subGroup.duration = _duration;
        for(CALayer *s in big.sublayers)
            [s addAnimation:subGroup forKey:@"group"];
    }
    
    // wrapper: position, bounds
    {
        CALayer *wrapper = self.layer;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:outerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ position, bounds ];
        group.duration = _duration;
        [wrapper addAnimation:group forKey:@"group"];
    }
    
    // tintView: black shadow: rotation, position, bounds, opacity
    UIView *tintView = [[UIView alloc] initWithFrame:self.bounds];
    tintView.userInteractionEnabled = NO;
    tintView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    tintView.backgroundColor = [UIColor blackColor];
    tintView.layer.opacity = 0;
    [self addSubview:tintView];
    
    {
        CALayer *tintLayer = tintView.layer;
        tintLayer.zPosition = 9999;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        tintLayer.sublayerTransform = transform;
        
        CAKeyframeAnimation *rotationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.keyTimes = @[ @0, @0.5, @1 ];
        rotationY.values = @[ @0, @M_PI_2, @M_PI ];
        rotationY.timingFunction = timing;
        rotationY.duration = _duration;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // opacity
        CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacity.keyTimes = @[ @0, @0.5, @1 ];
        opacity.values = @[ @0, @0.8, @0 ];
        opacity.timingFunction = timing;
        opacity.duration = _duration;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds, opacity ];
        group.duration = _duration;
        [tintLayer addAnimation:group forKey:@"group"];
    }
    
    // toggle visibility
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _duration * 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^(void){
                       _smallView.hidden = YES;
                       _bigView.hidden = NO;
                   });
    
    // blackView animation & completion
    [UIView animateWithDuration:_duration-0.05f animations:^{
        _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    } completion:^(BOOL finished) {
        if(finished) {
            self.frame = outerFrame;
            
            _bigView.userInteractionEnabled = YES;
            _blackView.userInteractionEnabled = YES;
            
            // destroy useless views
            [tintView removeFromSuperview];
            
            // flags
            isDSFlipViewOpened = YES;
            isDSFlipViewAnimating = NO;
        }
    }];
}

-(IBAction)close:(id)sender
{
    // DO NOT ANIMATE WHILE OTHER IS ANIMATING
    if(isDSFlipViewAnimating)
        return;

    // flags
    isDSFlipViewOpened = NO;
    isDSFlipViewAnimating = YES;
    
    // error handling
    if(!_smallView)
        NSLog(@"DSFlipView <0x%x>: smallView is nil.", (NSInteger)self);
    else if(!_bigView)
        NSLog(@"DSFlipView <0x%x>: bigView is nil.", (NSInteger)self);
    else if(!_backView)
        NSLog(@"DSFlipView <0x%x>: backView is nil.", (NSInteger)self);
    else if(!_blackView)
        NSLog(@"DSFlipView <0x%x>: blackView is nil; maybe backView is not specified.", (NSInteger)self);
    
    // black view
    _blackView.userInteractionEnabled = NO;
    
    // smallView bigView init
    _smallView.hidden = YES;
    _bigView.hidden = NO;
    _bigView.userInteractionEnabled = NO;
    
    // outerPosition innerPosition outerFrame init
    CGPoint theCenter = _dummyView.center;
    CGRect theBounds = (CGRect){(CGPoint){0,0}, _dummyView.frame.size};
    
    CGPoint outerPosition = [_dummyView.superview convertPoint:theCenter toView:_blackView];
    CGPoint innerPosition = (CGPoint){_dummyView.frame.size.width/2, _dummyView.frame.size.height/2};
    CGRect outerFrame = [_dummyView.superview convertRect:_dummyView.frame toView:_blackView];
    
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // small: rotation, position, bounds, tint
    {
        CALayer *small = _smallView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        small.sublayerTransform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:M_PI];
        rotationY.toValue = [NSNumber numberWithFloat:0];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [small addAnimation:group forKey:@"group"];
        
        // apply to sublayers
        CAAnimationGroup *subGroup = [CAAnimationGroup animation];
        subGroup.animations = @[ position, bounds ];
        subGroup.duration = _duration;
        for(CALayer *s in small.sublayers)
            [s addAnimation:subGroup forKey:@"group"];
    }
    
    // big: rotation, position, bounds, tint
    {
        CALayer *big = _bigView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / 850;
        big.sublayerTransform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:0];
        rotationY.toValue = [NSNumber numberWithFloat:M_PI];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [big addAnimation:group forKey:@"group"];
        
        // apply to sublayers
        CAAnimationGroup *subGroup = [CAAnimationGroup animation];
        subGroup.animations = @[ position, bounds ];
        subGroup.duration = _duration;
        for(CALayer *s in big.sublayers)
            [s addAnimation:subGroup forKey:@"group"];
    }
    
    // wrapper: position, bounds
    {
        CALayer *wrapper = self.layer;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:outerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ position, bounds ];
        group.duration = _duration;
        [wrapper addAnimation:group forKey:@"group"];
    }
    
    // tintView: black shadow: rotation, position(backPosition), bounds, opacity
    UIView *tintView = [[UIView alloc] initWithFrame:self.bounds];
    tintView.userInteractionEnabled = NO;
    tintView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
    tintView.backgroundColor = [UIColor blackColor];
    tintView.layer.opacity = 0;
    [self addSubview:tintView];
    
    {
        CALayer *tintLayer = tintView.layer;
        tintLayer.zPosition = 9999;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        tintLayer.sublayerTransform = transform;
        
        CAKeyframeAnimation *rotationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.keyTimes = @[ @0, @0.5, @1 ];
        rotationY.values = @[ @M_PI, @M_PI_2, @0 ];
        rotationY.timingFunction = timing;
        rotationY.duration = _duration;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:innerPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:theBounds];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // opacity
        CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacity.keyTimes = @[ @0, @0.5, @1 ];
        opacity.values = @[ @0, @0.8, @0 ];
        opacity.timingFunction = timing;
        opacity.duration = _duration;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds, opacity ];
        group.duration = _duration;
        [tintLayer addAnimation:group forKey:@"group"];
        
    }
    
    // toggle visibility
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, _duration * 0.5f * NSEC_PER_SEC), dispatch_get_main_queue(),
                   ^(void){
                       _smallView.hidden = NO;
                       _bigView.hidden = YES;
                   });
    
    // blackView animation & completion
    [UIView animateWithDuration:_duration-0.05f animations:^{
        _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        if(finished) {
            _smallView.userInteractionEnabled = YES;
            
            // detach self from blackView and move to superView
            self.frame = outerFrame;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05f * NSEC_PER_SEC), dispatch_get_main_queue(),
                           ^(void){
                               DSFlipView *me = self; // just to increase retain count while self is removed from superview
                               [me removeFromSuperview];
                               self.frame = _dummyView.frame;
                               [_superView addSubview:self];
                               
                               _superView = nil;
                               
                               // destroy useless views
                               [_dummyView removeFromSuperview];
                               _dummyView = nil;
                               
                               [_blackView removeFromSuperview];
                               [tintView removeFromSuperview];
                               
                               // flags
                               isDSFlipViewOpened = NO;
                               isDSFlipViewAnimating = NO;
                           });
            
        }
    }];
}

- (void) layoutSubviews
{
    // Re-position bigView when orientation is changed.
    if(isDSFlipViewOpened) {
        CGPoint theCenter = (_backView ? _backView : self.superview).center;
        CGPoint outerPosition = [_backView.superview convertPoint:theCenter toView:_backView];
        CGRect outerFrame = (CGRect){(CGPoint){outerPosition.x - _bigSize.width/2, outerPosition.y - _bigSize.height/2}, _bigSize};
        self.frame = outerFrame;
    }
}

#pragma mark - blackTapper Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    // blackTapper: should prevent tap events inside self
    CGPoint origin = [gestureRecognizer locationInView:self];
    if(origin.x > 0 && origin.x < self.frame.size.width && origin.y > 0 && origin.y < self.frame.size.height) // inside self
        return NO;
    else
        return YES;
}

@end
