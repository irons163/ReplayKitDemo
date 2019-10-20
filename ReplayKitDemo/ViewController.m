//
//  ViewController.m
//  ReplayKitDemo
//
//  Created by irons on 2019/9/13.
//  Copyright © 2019年 irons. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>

@interface ViewController ()<RPPreviewViewControllerDelegate> {
    BOOL isRecording;
    RPScreenRecorder *recorder;
}

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorPicker;
@property (weak, nonatomic) IBOutlet UIView *colorDisplay;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UISwitch *micToggle;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    isRecording = NO;
    recorder = [RPScreenRecorder sharedRecorder];
    self.recordButton.layer.cornerRadius = 32.5;
    
}

- (void)viewReset {
    self.micToggle.enabled = YES;
    self.statusLabel.text = @"Ready to Record";
    self.statusLabel.textColor = UIColor.blackColor;
    self.recordButton.backgroundColor = UIColor.greenColor;
}

- (void)startRecording {
    
    if (!recorder.isAvailable) {
        NSLog(@"Recording is not available at this time.");
        return;
    }
    
    if (self.micToggle.isOn) {
        recorder.microphoneEnabled = YES;
    } else {
        recorder.microphoneEnabled = NO;
    }
    
    [recorder startRecordingWithHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"There was an error starting the recording.");
            return;
        }
        
        NSLog(@"Started Recording Successfully");
        self.micToggle.enabled = NO;
        self.recordButton.backgroundColor = UIColor.redColor;
        self.statusLabel.text = @"Recording...";
        self.statusLabel.textColor = UIColor.redColor;
        
        self->isRecording = YES;
    }];
}

- (void)stopRecording {
    [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
        NSLog(@"Stopped recording");
        
        if (!previewViewController) {
            NSLog(@"Preview controller is not available.");
            return;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Recording Finished" message:@"Would you like to edit or delete your recording?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *deleteAction =
        [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self->recorder discardRecordingWithHandler:^{
                NSLog(@"Recording suffessfully deleted.");
            }];
        }];
        
        UIAlertAction *editAction =
        [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            previewViewController.previewControllerDelegate = self;
            [self presentViewController:previewViewController animated:YES completion:nil];
        }];
        
        [alert addAction:editAction];
        [alert addAction:deleteAction];
        [self presentViewController:alert animated:YES completion:nil];
        self->isRecording = NO;
        [self viewReset];
    }];
}

- (IBAction)colors:(UISegmentedControl *)sender {
    switch(sender.selectedSegmentIndex) {
        case 0:
            self.colorDisplay.backgroundColor = UIColor.redColor;
            break;
        case 1:
            self.colorDisplay.backgroundColor = UIColor.blueColor;
            break;
        case 2:
            self.colorDisplay.backgroundColor = UIColor.orangeColor;
            break;
        case 3:
            self.colorDisplay.backgroundColor = UIColor.greenColor;
            break;
        default:
            self.colorDisplay.backgroundColor = UIColor.redColor;
            break;
    }
}

- (IBAction)recordButtonTapped:(UIButton *)sender {
    if (!isRecording) {
        [self startRecording];
    } else {
        [self stopRecording];
    }
}

- (void)previewControllerDidFinish:(RPPreviewViewController *)previewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

