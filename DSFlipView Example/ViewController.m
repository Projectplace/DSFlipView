#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // textView shadow
    CALayer *layer = self.textView.layer;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, -0.7f);
    layer.shadowOpacity = 0.6f;
    layer.shadowRadius = 0;
    
    // DSFlipView: Code Example
    UIImageView *smallView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    UIImageView *bigView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlock.png"]];
    DSFlipView *secondFlip = [[DSFlipView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
    secondFlip.backView = self.view;
    secondFlip.smallView = smallView;
    secondFlip.bigView = bigView;
    secondFlip.duration = 1.0f;
    secondFlip.bigSize = (CGSize){200,250};
    [self.view addSubview:secondFlip];
    self.secondFlip = secondFlip;
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setFirstFlip:nil];
    [self setSecondFlip:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Re-position bigView when orientation is changed.
    [_firstFlip setNeedsLayout];
    [_secondFlip setNeedsLayout];
    return YES;
}

@end
