//
//  CustomSpinner.h
//  CustomLoadingAnimation
//
//  Created by Fraser King on 2016-12-02.
//  Copyright © 2016 Fraser King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"

@interface CustomSpinner : UIView

@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIImageView *imageViewBackground;

- (void)stopSpinner;

@end
