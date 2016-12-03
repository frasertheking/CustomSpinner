//
//  ViewController.m
//  CustomLoadingAnimation
//
//  Created by Fraser King on 2016-12-01.
//  Copyright © 2016 Fraser King. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+animatedGIF.h"

@interface ViewController ()

@property (nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIImageView *imageViewBackground;
@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSInteger count;
@property (nonatomic) UIImage *gif;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = [[NSMutableArray alloc] initWithObjects:@"puppy", @"cat", @"duck", @"trump", nil];
    self.count = 0;
    [self changePic];
    
    self.gif = [UIImage animatedImageWithAnimatedGIFURL:[NSURL URLWithString:@"https://frasertheking.com/images/newgif2.gif"]];
    self.imageView.image = self.gif;
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(changePic) userInfo:nil repeats:YES];
}

- (void)changePic {
    self.backgroundImage.image = [UIImage imageNamed:self.imageArray[self.count]];
    if (self.count == 3) {
        self.count = 0;
        [UIView animateWithDuration:1 animations:^{
            self.imageViewBackground.alpha = 1;
            self.imageView.alpha = 0;
        }];
    } else {
        self.count++;
    }
}


@end
