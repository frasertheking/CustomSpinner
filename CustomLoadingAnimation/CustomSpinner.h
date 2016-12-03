#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"

@interface CustomSpinner : UIView

/* NOTE: make the storyboard view 70x70 for best results 
   when using this default animated gif */

/* Flag for if the spinner currently displayed to the user */
@property (nonatomic) BOOL isSpinning;

/* Display the custom spinner to the user */
- (void)showSpinner;

/* Hide the spinner from the user */
- (void)hideSpinner;

@end
