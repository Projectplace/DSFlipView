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

@interface DSFlipView ()

- (void) initialize;
- (id) initWithCoder:(NSCoder *)aDecoder;

- (void) setBackView:(UIView *)backView;
- (void) setSmallView:(UIView *)smallView;
- (void) setBigView:(UIView *)bigView;

- (IBAction)open:(id)sender;
- (IBAction)close:(id)sender;

- (void) layoutSubviews;

@end

@implementation DSFlipView

- (void) initialize
{
    // init
    _duration = .5f;
    _bigSize = (CGSize){250,250};
    _isOpened = NO;
    
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
        _blackView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        _blackView.userInteractionEnabled = NO;
        
        UITapGestureRecognizer *blackTapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
        _blackView.gestureRecognizers = @[ blackTapper ];
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
        bigView.hidden = YES;
        
        [self addSubview:bigView];
    }
}

-(IBAction)open:(id)sender
{
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
    _blackView.alpha = 0;
    
    [_backView addSubview:_blackView];
    [_backView bringSubviewToFront:self];
    
    _blackView.userInteractionEnabled = NO;
    // smallView bigView init
    _smallView.hidden = NO;
    _smallView.userInteractionEnabled = NO;
    _bigView.hidden = YES;
    
    // bigPosition bigOrigin bigFrame init
    CGRect backBounds = [(_backView ? _backView : self.superview) bounds];
    CGPoint backPosition = (CGPoint){backBounds.size.width/2, backBounds.size.height/2};
    CGPoint bigPosition = (CGPoint){_bigSize.width/2,_bigSize.height/2};
    CGPoint bigOrigin = (CGPoint){backPosition.x - bigPosition.x, backPosition.y - bigPosition.y};
    CGRect bigFrame = (CGRect){bigOrigin, _bigSize};
    
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // small: rotation, position(bigPosition), bounds
    {
        CALayer *small = _smallView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        small.transform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:0];
        rotationY.toValue = [NSNumber numberWithFloat:M_PI];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:bigPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_smallView.layer.bounds.origin, _bigSize}];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [small addAnimation:group forKey:@"group"];
    }
    
    // big: rotation, position(bigPosition), bounds
    {
        CALayer *big = _bigView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / 850;
        big.transform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:M_PI];
        rotationY.toValue = [NSNumber numberWithFloat:0];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:bigPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_bigView.layer.bounds.origin, _bigSize}];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [big addAnimation:group forKey:@"group"];
    }
    
    // wrapper: position(backPosition), bounds
    {
        CALayer *wrapper = self.layer;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:backPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){self.layer.bounds.origin, _bigSize}];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ position, bounds ];
        group.duration = _duration;
        [wrapper addAnimation:group forKey:@"group"];
    }
    
    // tintView: black shadow: rotation, position(bigPosition), bounds, opacity
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
        tintLayer.transform = transform;
        
        CAKeyframeAnimation *rotationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.keyTimes = @[ @0, @0.5, @1 ];
        rotationY.values = @[ @0, @M_PI_2, @M_PI ];
        rotationY.timingFunction = timing;
        rotationY.duration = _duration;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:bigPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_bigView.layer.bounds.origin, _bigSize}];
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
    [UIView animateWithDuration:_duration animations:^{
        _blackView.alpha = 1;
    } completion:^(BOOL finished) {
        if(finished) {
            self.frame = bigFrame;

            _bigView.userInteractionEnabled = YES;
            _blackView.userInteractionEnabled = YES;
            
            _isOpened = YES;
            
            // destroy useless views
            [tintView removeFromSuperview];
        }
    }];
}

-(IBAction)close:(id)sender
{
    _isOpened = NO;
    
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
    
    // smallPosition smallFrame smallSize init
    CGPoint smallPosition = _dummyView.layer.position;
    CGRect smallFrame = _dummyView.frame;
    CGSize smallSize = smallFrame.size;
    
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // small: rotation, position, bounds, tint
    {
        CALayer *small = _smallView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / -850;
        small.transform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:M_PI];
        rotationY.toValue = [NSNumber numberWithFloat:0];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:(CGPoint){smallSize.width/2,smallSize.height/2}];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_smallView.layer.bounds.origin, smallSize}];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [small addAnimation:group forKey:@"group"];
    }
    
    // big: rotation, position, bounds, tint
    {
        CALayer *big = _bigView.layer;
        
        // rotation
        // http://cocoaconvert.net/2009/05/24/flippin-modal-panels/
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = 1.0 / 850;
        big.transform = transform;
        
        CABasicAnimation *rotationY = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.fromValue = [NSNumber numberWithFloat:0];
        rotationY.toValue = [NSNumber numberWithFloat:M_PI];
        rotationY.duration = _duration;
        rotationY.timingFunction = timing;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:(CGPoint){smallSize.width/2,smallSize.height/2}];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_smallView.layer.bounds.origin, smallSize}];
        bounds.duration = _duration;
        bounds.timingFunction = timing;
        
        // CAAnimationGroup
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[ rotationY, position, bounds ];
        group.duration = _duration;
        [big addAnimation:group forKey:@"group"];
    }
    
    // wrapper: position, bounds
    {
        CALayer *wrapper = self.layer;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:smallPosition];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){self.layer.bounds.origin, smallSize}];
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
        tintLayer.transform = transform;
        
        CAKeyframeAnimation *rotationY = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.y"];
        rotationY.keyTimes = @[ @0, @0.5, @1 ];
        rotationY.values = @[ @M_PI, @M_PI_2, @0 ];
        rotationY.timingFunction = timing;
        rotationY.duration = _duration;
        
        // position
        CABasicAnimation *position = [CABasicAnimation animationWithKeyPath:@"position"];
        position.toValue = [NSValue valueWithCGPoint:(CGPoint){smallSize.width/2,smallSize.height/2}];
        position.duration = _duration;
        position.timingFunction = timing;
        
        // bounds
        CABasicAnimation *bounds = [CABasicAnimation animationWithKeyPath:@"bounds"];
        bounds.toValue = [NSValue valueWithCGRect:(CGRect){_smallView.layer.bounds.origin, smallSize}];
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
    [UIView animateWithDuration:_duration animations:^{
        _blackView.alpha = 0;
    } completion:^(BOOL finished) {
        self.frame = _dummyView.frame;
        
        _smallView.userInteractionEnabled = YES;
        
        // destroy useless views
        [_dummyView removeFromSuperview];
        _dummyView = nil;
        
        [_blackView removeFromSuperview];
        [tintView removeFromSuperview];
    }];
}

- (void) layoutSubviews
{
    // Re-position bigView when orientation is changed.
    if(_isOpened) {
        CGRect backBounds = [(_backView ? _backView : self.superview) bounds];
        CGPoint backPosition = (CGPoint){backBounds.size.width/2, backBounds.size.height/2};
        CGPoint bigPosition = (CGPoint){_bigSize.width/2,_bigSize.height/2};
        CGPoint bigOrigin = (CGPoint){backPosition.x - bigPosition.x, backPosition.y - bigPosition.y};
        CGRect bigFrame = (CGRect){bigOrigin, _bigSize};
        
        self.frame = bigFrame;
    }
}

@end
