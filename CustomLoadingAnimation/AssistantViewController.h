#import <UIKit/UIKit.h>
#import <Speech/Speech.h>
#import <ApiAI/ApiAI.h>
#import "SCSiriWaveformView.h"

@interface AssistantViewController : UIViewController <SFSpeechRecognizerDelegate>

@property (nonatomic) IBOutlet UIButton *audioButton;
@property (nonatomic) IBOutlet UIButton *closeButton;
@property (nonatomic) IBOutlet UITextView *textView;
@property (nonatomic) IBOutlet SCSiriWaveformView *waveformView;
@property (nonatomic) ApiAI *apiAI;

@end
