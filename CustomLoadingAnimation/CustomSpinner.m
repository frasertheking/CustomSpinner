//
//  CustomSpinner.m
//  CustomLoadingAnimation
//
//  Created by Fraser King on 2016-12-02.
//  Copyright © 2016 Fraser King. All rights reserved.
//

#import "CustomSpinner.h"

@interface CustomSpinner()

@end

@implementation CustomSpinner

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
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
    self.imageView.image = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:@"https://frasertheking.com/images/newgif2.gif"]];
}

- (void)stopSpinner {
    [UIView animateWithDuration:1.0f animations:^{
        self.imageViewBackground.alpha = 1.0f;
        self.imageView.alpha = 0.0f;
    }];
}

@end
