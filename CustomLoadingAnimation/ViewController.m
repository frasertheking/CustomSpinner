//
//  ViewController.m
//  CustomLoadingAnimation
//
//  Created by Fraser King on 2016-12-01.
//  Copyright © 2016 Fraser King. All rights reserved.
//

#import "ViewController.h"
#import "CustomSpinner.h"

@interface ViewController ()

@property (nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic) IBOutlet CustomSpinner *spinner;
@property (nonatomic) NSMutableArray *imageArray;
@property (nonatomic) NSInteger count;
@property (nonatomic) BOOL showing;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageArray = [[NSMutableArray alloc] initWithObjects:@"puppy", @"cat", @"duck", @"trump", nil];
    self.count = 0;
    [self changePic];

    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(changePic) userInfo:nil repeats:YES];
}

- (void)changePic {
    self.backgroundImage.image = [UIImage imageNamed:self.imageArray[self.count]];
    if (self.count == 3) {
        self.count = 0;
    } else {
        self.count++;
    }
}

- (IBAction)showSpinner:(id)sender {
    if (self.showing) {
        [self.spinner hideSpinner];
        self.showing = NO;
    } else {
        [self.spinner showSpinner];
        self.showing = YES;
    }
}


@end
