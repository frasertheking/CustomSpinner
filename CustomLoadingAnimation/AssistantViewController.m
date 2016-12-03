#import "AssistantViewController.h"

@interface AssistantViewController ()

@property (nonatomic) SFSpeechRecognizer *speechRecognizer;
@property (nonatomic) SFSpeechAudioBufferRecognitionRequest *recognitionRequest;
@property (nonatomic) SFSpeechRecognitionTask *recognitionTask;
@property (nonatomic) AVAudioEngine *audioEngine;
@property (nonatomic) AVAudioRecorder *psudoRecorder;
@property (nonatomic) CADisplayLink *displaylink;
@property (nonatomic) BOOL spoken;

@end

@implementation AssistantViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Assistant";
    UIImage *image = [[UIImage imageNamed:@"cancel"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.closeButton setImage:image forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor whiteColor];
    self.displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
    [self.displaylink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.audioButton.tintColor = [UIColor whiteColor];
    self.audioButton.alpha = 0;
    self.waveformView.alpha = 0;
    self.textView.alpha = 0;
    [self.audioButton setImage:[[UIImage imageNamed:@"microphone-large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.textView.text = @"How can I help?\n\nTap the microphone to begin";
    
    [self setupRecorder];
    [self setupSpeechKit];
    [self setupAPIAI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.4 delay:0.3 options:0 animations:^{
        self.audioButton.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.4 delay:0.15 options:0 animations:^{
        self.textView.alpha = 1;
    } completion:nil];
    
    [UIView animateWithDuration:0.4 delay:0 options:0 animations:^{
        self.waveformView.alpha = 1;
    } completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopListening];
    [self.displaylink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setupRecorder {
    NSDictionary *settings = @{AVSampleRateKey:          [NSNumber numberWithFloat: 44100.0],
                               AVFormatIDKey:            [NSNumber numberWithInt: kAudioFormatAppleLossless],
                               AVNumberOfChannelsKey:    [NSNumber numberWithInt: 2],
                               AVEncoderAudioQualityKey: [NSNumber numberWithInt: AVAudioQualityMin]};
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    self.psudoRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
}

- (void)setupSpeechKit {
    self.speechRecognizer = [[SFSpeechRecognizer alloc] initWithLocale:[NSLocale currentLocale]];
    self.audioEngine = [[AVAudioEngine alloc] init];
    self.speechRecognizer.delegate = self;
    
    [SFSpeechRecognizer requestAuthorization:^(SFSpeechRecognizerAuthorizationStatus status) {
        BOOL isButtonEnabled = NO;
        
        switch (status) {
            case SFSpeechRecognizerAuthorizationStatusAuthorized:
                isButtonEnabled = YES;
                break;
            case SFSpeechRecognizerAuthorizationStatusDenied:
                isButtonEnabled = NO;
                break;
            case SFSpeechRecognizerAuthorizationStatusRestricted:
                isButtonEnabled = NO;
                break;
            case SFSpeechRecognizerAuthorizationStatusNotDetermined:
                isButtonEnabled = NO;
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.audioButton.enabled = isButtonEnabled;
        });
    }];
}

- (void)setupAPIAI {
    // Setting up API.ai client
    self.apiAI = [[ApiAI alloc] init];
    id <AIConfiguration> configuration = [[AIDefaultConfiguration alloc] init];
    configuration.clientAccessToken = @"afd41e39550e4f77bec38f0e1209117c";
    
    self.apiAI.configuration = configuration;
}

- (IBAction)listenPressed:(id)sender {
    if (self.audioEngine.isRunning) {
        [self stopListening];
    } else {
        [self startListening];
    }
}

- (IBAction)closePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helpers 

- (void)startListening {
    [self startRecording];
    [self.audioButton setImage:[[UIImage imageNamed:@"microphone-large-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)stopListening {
    [self.psudoRecorder stop];
    [self.audioEngine stop];
    [self.recognitionRequest endAudio];
    self.spoken = NO;
}

#pragma mark - Audio Recording

- (void)startRecording {
    
    if (self.recognitionTask != nil) {
        [self.recognitionTask cancel];
        self.recognitionTask = nil;
    }
    
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    [self.psudoRecorder prepareToRecord];
    [self.psudoRecorder setMeteringEnabled:YES];
    [self.psudoRecorder record];
    
    self.recognitionRequest = [[SFSpeechAudioBufferRecognitionRequest alloc] init];
    AVAudioInputNode *inputNode = self.audioEngine.inputNode;
    SFSpeechAudioBufferRecognitionRequest *recognitionRequest = self.recognitionRequest;
    recognitionRequest.shouldReportPartialResults = YES;
    
    self.recognitionTask = [self.speechRecognizer recognitionTaskWithRequest:recognitionRequest resultHandler:^(SFSpeechRecognitionResult * _Nullable result, NSError * _Nullable error) {
        
        BOOL isFinal = NO;
        
        if (result != nil) {
            self.textView.textColor = [UIColor whiteColor];
            self.textView.text = result.bestTranscription.formattedString;
            isFinal = result.isFinal;
        }
        
        if (error != nil || isFinal) {
            [self.psudoRecorder stop];
            [self.audioEngine stop];
            [inputNode removeTapOnBus:0];
            self.recognitionRequest = nil;
            self.recognitionTask = nil;
            
            [self getVoiceCommandMeaning];
        }
    }];
    
    AVAudioFormat *recordingFormat = [inputNode outputFormatForBus:0];
    [inputNode installTapOnBus:0 bufferSize:1024 format:recordingFormat block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        [self.recognitionRequest appendAudioPCMBuffer:buffer];
    }];
    
    [self.audioEngine prepare];
    [self.audioEngine startAndReturnError:&error];
    self.textView.text = @"";
}

#pragma mark - SFSpeechRecognitionDelegate

- (void)speechRecognizer:(SFSpeechRecognizer *)speechRecognizer availabilityDidChange:(BOOL)available {
    self.audioButton.enabled = available;
}

#pragma mark - API.ai

- (void)getVoiceCommandMeaning {
    self.audioButton.enabled = NO;
    AITextRequest *request = [self.apiAI textRequest];
    request.query = @[self.textView.text];
    [request setCompletionBlockSuccess:^(AIRequest *request, id response) {
        if (response) {
            [self handleResponse:response];
        }
    } failure:^(AIRequest *request, NSError *error) {
        [self handleError:error];
    }];
    
    [self.apiAI enqueue:request];
}

- (void)handleResponse:(id)response {
    self.audioButton.enabled = YES;
    NSString *action = [[response valueForKey:@"result"] valueForKey:@"action"];
    NSString *track = [[[response valueForKey:@"result"] valueForKey:@"parameters"] valueForKey:@"track"];
    NSString *speech = [[[response valueForKey:@"result"] valueForKey:@"fulfillment"] valueForKey:@"speech"];
//    NSInteger item = [self.objectManager.audioInfoArray indexOfObject:[self.objectManager getObjectByName:track]];

//    if ([action isEqualToString:@"play"] && item < [self.objectManager.audioInfoArray count]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangePlaylistNotification" object:nil];
//        [self.mainTabController playAudio:item completion:^{
//            // TODO
//        }];
//    } else if ([action isEqualToString:@"pause"]) {
//        [self.mainTabController pausePlayingAudio];
//    } else if ([action isEqualToString:@"add"]) {
//        if (![GlobalHelpers alreadyInPlaylist:item]) {
//            [GlobalHelpers addOrRemoveFromPlaylist:item];
//        }
//    } else if ([action isEqualToString:@"remove"]) {
//        if ([GlobalHelpers alreadyInPlaylist:item]) {
//            [GlobalHelpers addOrRemoveFromPlaylist:item];
//        }
//    } else if ([action isEqualToString:@"randomize-playlist"]) {
//        [GlobalHelpers shufflePlaylist];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"PlaylistUpdate" object:nil];
//    } else if ([action isEqualToString:@"play-playlist"]) {
//        NSMutableArray *playlistArray = [GlobalHelpers getPlaylist];
//        if ([playlistArray count] > 0) {
//            [self.mainTabController playlistAudio:[playlistArray[0] integerValue] completion:^{
//                // TODO
//            }];
//        }
//    } else if ([action isEqualToString:@"empty-playlist"]) {
//        [GlobalHelpers removeAllFromPlaylist];
//    }
    
    self.textView.text = speech;
//    self.textView.textColor = UIColorFromRGB(PRIMARY);
    [self.audioButton setImage:[[UIImage imageNamed:@"microphone-large"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
}

- (void)handleError:(NSError *)error {
    self.audioButton.enabled = YES;
    self.textView.text = error.localizedDescription;
}

#pragma mark - Waveform delegate

- (void)updateMeters {
    CGFloat normalizedValue;
    [self.psudoRecorder updateMeters];
    normalizedValue = [self _normalizedPowerLevelFromDecibels:[self.psudoRecorder averagePowerForChannel:0]];
    [self.waveformView updateWithLevel:normalizedValue*2];
    
    if (normalizedValue > 0.2) {
        self.spoken = YES;
    }
    
    if (normalizedValue < 0.05 && self.spoken) {
        [self stopListening];
    }
}

- (CGFloat)_normalizedPowerLevelFromDecibels:(CGFloat)decibels {
    if (decibels < -60.0f || decibels == 0.0f) {
        return 0.1f;
    }
    
    return powf((powf(10.0f, 0.05f * decibels) - powf(10.0f, 0.05f * -60.0f)) * (1.0f / (1.0f - powf(10.0f, 0.05f * -60.0f))), 1.0f / 2.0f);
}


@end
