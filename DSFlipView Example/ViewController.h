#import <UIKit/UIKit.h>
#import "DSFlipView.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet DSFlipView *firstFlip;
@property (weak, nonatomic) DSFlipView *secondFlip;
@property (weak, nonatomic) IBOutlet DSFlipView *thirdFlip;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
