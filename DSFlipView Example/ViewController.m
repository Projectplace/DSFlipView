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
    
    // secondFlip: Code Example
    UIImageView *smallView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    
    UIImageView *bigView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"unlock.png"]];
    UITableView *bigTable = [[UITableView alloc] initWithFrame:bigView.bounds];
    bigTable.autoresizingMask = bigView.autoresizingMask;
    bigTable.backgroundColor = [UIColor clearColor];
    bigTable.dataSource = self;
    [bigView addSubview:bigTable];
    
    DSFlipView *secondFlip = [[DSFlipView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
    secondFlip.backView = self.view;
    secondFlip.smallView = smallView;
    secondFlip.bigView = bigView;
    secondFlip.duration = 1.0f;
    secondFlip.bigSize = (CGSize){200,250};
    [self.view addSubview:secondFlip];
    self.secondFlip = secondFlip;
    
    // thirdFlip: Code Example
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        _thirdFlip.bigSize = (CGSize){250, 250};
    else
        _thirdFlip.bigSize = (CGSize){400, 400};
    _thirdFlip.duration = 2.0f;
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setFirstFlip:nil];
    [self setSecondFlip:nil];
    [self setThirdFlip:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Re-position bigView when orientation is changed.
    [_firstFlip setNeedsLayout];
    [_secondFlip setNeedsLayout];
    [_thirdFlip setNeedsLayout];
    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.text = @"Hello.";
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

@end
