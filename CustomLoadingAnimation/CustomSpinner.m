#import "CustomSpinner.h"

// Spinner constants
NSString *const spinnerGifURL = @"https://frasertheking.com/images/newgif2.gif";
static CGFloat kAnimationAppearDisappearDuration = 0.2f;
static CGFloat kAnimationBoundDuration = 0.1f;
static CGFloat kSpinnerTinyScale = 0.05f;
static CGFloat kSpinnerNormalScale = 1.0f;
static CGFloat kSpinnerLargeScale = 1.25f;

@interface CustomSpinner()

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIImageView *imageViewBackground;

@end

@implementation CustomSpinner

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    UIView *xibView = [[[NSBundle mainBundle] loadNibNamed:@"CustomSpinner" owner:self options:nil] objectAtIndex:0];
    xibView.frame = self.bounds;
    xibView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview: xibView];
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:spinnerGifURL]];
    self.alpha = 0;
}

- (void)showSpinner {
    if (self.isSpinning) {
        NSLog(@"WARNING: Trying to show already displayed spinner");
        return;
    }
    
    self.transform = CGAffineTransformMakeScale(kSpinnerTinyScale, kSpinnerTinyScale);
    self.alpha = 1;
    self.isSpinning = YES;
    
    // Bounce small -> large -> normal
    [UIView animateKeyframesWithDuration:kAnimationBoundDuration delay:0 options:0 animations:^{
        self.transform = CGAffineTransformMakeScale(kSpinnerLargeScale, kSpinnerLargeScale);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:kAnimationAppearDisappearDuration delay:0 options:0 animations:^{
            self.transform = CGAffineTransformMakeScale(kSpinnerNormalScale, kSpinnerNormalScale);
        } completion:nil];
    }];
}

- (void)hideSpinner {
    if (!self.isSpinning) {
        NSLog(@"WARNING: Trying to hide already hidden spinner");
        return;
    }
    self.isSpinning = NO;
    
    // Bounce normal -> large -> small
    [UIView animateKeyframesWithDuration:kAnimationBoundDuration delay:0 options:0 animations:^{
        self.transform = CGAffineTransformMakeScale(kSpinnerLargeScale, kSpinnerLargeScale);
    } completion:^(BOOL finished) {
        [UIView animateKeyframesWithDuration:kAnimationAppearDisappearDuration delay:0 options:0 animations:^{
            self.transform = CGAffineTransformMakeScale(kSpinnerTinyScale, kSpinnerTinyScale);
        } completion:^(BOOL finished) {
            self.alpha = 0;
        }];
    }];
}

@end
