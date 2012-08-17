# DSFlipView

DSFlipView lets you easily make an album flip view from iPad iPod app. 

<img src="https://raw.github.com/kiding/DSFlipView/gh-pages/title.png" height=400 alt="sample">

Check out the sample video <a href="http://kiding.github.com/DSFlipView/">**here**</a>. <a href="https://raw.github.com/kiding/DSFlipView/gh-pages/example.mov">(Direct Link)</a>

## Features

* Displays two views one at a time with flip animation at user's tap gesture.
* Easy implementation with Storyboard (Interface Builder).
* Built on Core Animation.
* UITableViewCell-Ready. Yes.
* ARC(Automatic Reference Counting), Modern Objective-C syntax are used. Xcode 4.4+ is required.

## How to Use

### Using Storyboard (Interface Builder)

![Storyboard](https://raw.github.com/kiding/DSFlipView/gh-pages/storyboard.png)

You can use DSFlipView with Storyboard. 

1. Link `QuartzCore.framework` at the project summary.
2. Add `DSFlipView.h` `DSFlipView.m` to your project.
3. At storyboard, attach an empty view and change its class to `DSFlipView`.
4. Move the views you want to display inside the flip view in order to make them subviews of it.
5. Connect the outlets. `backView` is to the background (usually its super) view, `smallView` is to the view to be displayed first("closed"), and  `bigView` is to the view next("opened").

That's it. If you want to adjust some properties; check out below.

### Using Code Implementation

```
UIView *smallView = …;
UIView *bigView = …;
DSFlipView *flip = [[DSFlipView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
flip.backView = self.view;
flip.smallView = smallView;
flip.bigView = bigView;
flip.duration = 1.0f;
flip.bigSize = (CGSize){200,250};
[self.view addSubview:flip];
```

<img src="https://raw.github.com/kiding/DSFlipView/gh-pages/structure.png" alt="View Structure of Example">


| Properties | (Required)						                                                         |
| ---------- | ------------------------------------------------------------------------ |
| backView   | Background view, usually the superview.                                  |
| smallView  | Initially displayed view.                                                |
| bigView    | View to be displayed later; the position will be the center of backView. |

| Properties       | (Optional)                                                                                           |
| ---------------- | ---------------------------------------------------------------------------------------------------- |
| duration         | Duration of the flip animation.                                                                      |
| bigSize          | Size of bigView. Even if bigView is made with certain frame, it will be shrunken down/up to bigSize. |
| dummyView        | View to be returned to the original point when the view is "opened".                                 |
| blackView        | View to accept user's gesture to "close" the view.                                                   |
| openPreparation  | Block to be called just before open animation starts.                                                |
| openCompletion   | Block to be called just after open animation ends.                                                   |
| closePreparation | Block to be called just before close animation starts.                                               |
| closeCompletion  | Block to be called just after close animation ends.                                                  |

### Re-positioning

If you need to re-position the view, for example when user changed the device's orientation, just call:

```
[flip setNeedsLayout];
```

then it will automatically position itself at the center of the view.

# License

This project is under MIT License.

Copyright (C) 2012 by Dongsung "Don" Kim kiding@me.com
 
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
 THE SOFTWARE.