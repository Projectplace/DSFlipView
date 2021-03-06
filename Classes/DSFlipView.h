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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface DSFlipView : UIView <UIGestureRecognizerDelegate>

- (id) initWithFrame: (CGRect) frame;

// Required
@property (nonatomic, weak) IBOutlet UIView *backView;
@property (nonatomic, weak) IBOutlet UIView *smallView;
@property (nonatomic, weak) IBOutlet UIView *bigView;

// Optional
@property CGFloat duration;
@property CGSize bigSize;

@property (readonly) UIView *dummyView;
@property (readonly) UIView *blackView;

@property (nonatomic, copy) void (^openPreparation) ();
@property (nonatomic, copy) void (^closePreparation) ();
@property (nonatomic, copy) void (^openCompletion) ();
@property (nonatomic, copy) void (^closeCompletion) ();

@end
