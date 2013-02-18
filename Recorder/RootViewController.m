/*****************************************************************************
 *
 * FILE:	RootViewController.m
 * DESCRIPTION:	Recorder: Root View Controller
 * DATE:	Mon, Feb 18 2013
 * UPDATED:	Mon, Feb 18 2013
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2013 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2013 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id: RootViewController.m,v 1.2 2013/01/22 15:23:51 kouichi Exp $
 *
 *****************************************************************************/

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RootViewController.h"

@interface RootViewController () <AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
@private
  AVAudioSession *	_audioSession;
  AVAudioRecorder *	_audioRecorder;
  AVAudioPlayer *	_audioPlayer;

  NSURL *		_audioFileURL;
  UIButton *		_recordButton;
  UIButton *		_playButton;
  UIProgressView *	_progressBar;

  NSTimeInterval	_duration;
  NSTimer *		_levelTimer;
  UILabel *		_label;
  double		_lowPassResults;
}

@property (nonatomic,assign) AVAudioSession *	audioSession;
@property (nonatomic,retain) AVAudioRecorder *	audioRecorder;
@property (nonatomic,retain) AVAudioPlayer *	audioPlayer;
@property (nonatomic,retain) NSURL *		audioFileURL;
@property (nonatomic,retain) UIProgressView *	progressBar;
@property (nonatomic,assign) NSTimeInterval	duration;
@property (nonatomic,retain) NSTimer *		levelTimer;
@property (nonatomic,retain) UILabel *		label;

@property (nonatomic,retain) UIButton *	recordButton;
-(void)recordAction:(id)sender;

@property (nonatomic,retain) UIButton *	playButton;
-(void)playAction:(id)sender;

-(void)levelTimerCallback:(NSTimer *)timer;

-(void)popupWithMessage:(NSString *)message;
-(NSURL *)applicationDocumentsDirectory;
@end

@implementation RootViewController

@synthesize	audioSession	= _audioSession;
@synthesize	audioRecorder	= _audioRecorder;
@synthesize	audioPlayer	= _audioPlayer;
@synthesize	audioFileURL	= _audioFileURL;
@synthesize	recordButton	= _recordButton;
@synthesize	playButton	= _playButton;
@synthesize	progressBar	= _progressBar;
@synthesize	duration	= _duration;
@synthesize	levelTimer	= _levelTimer;
@synthesize	label		= _label;

static NSString * const	AudioDocumentFile = @"temporary.caf";

-(id)init
{
  self = [super init];
  if (self) {
    self.title = NSLocalizedString(@"Recorder", @"");
    self.audioFileURL = [[self applicationDocumentsDirectory]
			  URLByAppendingPathComponent:AudioDocumentFile];
    self.audioSession = [AVAudioSession sharedInstance];
    _duration = 30.0f;
  }
  return self;
}

-(void)dealloc
{
  [_audioRecorder release];
  [_audioPlayer release];
  [_audioFileURL release];
  [_recordButton release];
  [_playButton release];
  [_progressBar release];
  [_levelTimer release];
  [_label release];
  [super dealloc];
}

-(void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad
{
  [super viewDidLoad];

  self.view.autoresizesSubviews	= YES;
  self.view.autoresizingMask	= UIViewAutoresizingFlexibleLeftMargin
				| UIViewAutoresizingFlexibleRightMargin
				| UIViewAutoresizingFlexibleTopMargin
				| UIViewAutoresizingFlexibleBottomMargin;

  CGFloat	x = 20.0f;
  CGFloat	y = 100.0f;
  CGFloat	w = 130.0f;
  CGFloat	h = 60.0f;

  UIButton *	button;
  button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setFrame:CGRectMake(x, y, w, h)];
  [button setTitle:NSLocalizedString(@"Record", @"")
	  forState:UIControlStateNormal];
  [button addTarget:self
	  action:@selector(recordAction:)
	  forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  self.recordButton = button;

  x += (w + x);
  button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  [button setFrame:CGRectMake(x, y, w, h)];
  [button setTitle:NSLocalizedString(@"Play", @"")
	  forState:UIControlStateNormal];
  [button addTarget:self
	  action:@selector(playAction:)
	  forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:button];
  self.playButton = button;

  x = 20.0f;
  y += (h + 10.0f);
  w = 280.0f;
  h = 80.0f;
  UILabel *	label;
  label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
  label.lineBreakMode = NSLineBreakByWordWrapping;
  label.numberOfLines = 0;
  label.text = @"";
  [self.view addSubview:label];
  self.label = label;
  [label release];

  CALayer *	layer = [self.label layer];
  [layer setBorderColor:[UIColor darkGrayColor].CGColor];
  [layer setBorderWidth:1.0f];


  y += (h + 10.0f);
  h = 10.0f;
  UIProgressView *	progressBar;
  progressBar = [[UIProgressView alloc]
		  initWithProgressViewStyle:UIProgressViewStyleDefault];
  progressBar.frame = CGRectMake(x, y, w, h);
  progressBar.progressTintColor = [UIColor redColor];
  progressBar.trackTintColor = [UIColor lightGrayColor];
  [self.view addSubview:progressBar];
  self.progressBar = progressBar;
  [progressBar release];
}

/******************************************************************************
*
*	record
*
******************************************************************************/
#pragma mark UIButton action
-(void)recordAction:(id)sender
{
  if (!self.audioSession.isInputAvailable) {
    [self popupWithMessage:NSLocalizedString(@"NotAvailable", @"")];
    return;
  }

  if (self.audioRecorder != nil && self.audioRecorder.isRecording) {
    [self.audioRecorder stop];
    return;
  }

  NSError *	error = nil;

  [self.audioSession setCategory:AVAudioSessionCategoryRecord error:&error];
  if (error) {
    [self popupWithMessage:[error localizedDescription]];
    return;
  }

  BOOL	active = [self.audioSession setActive:YES error:&error];
  if (!active) {
    [self popupWithMessage:[error localizedDescription]];
    return;
  }


  NSDictionary *	settings = @{
#if	0
	[NSNumber numberWithInt:kAudioFormatLinearPCM] : AVFormatIDKey,
	[NSNumber numberWithInt:16] : AVLinearPCMBitDepthKey,
	[NSNumber numberWithBool:NO] : AVLinearPCMIsBigEndianKey,
	[NSNumber numberWithBool:NO] : AVLinearPCMIsFloatKey,
#else
	[NSNumber numberWithInt:kAudioFormatAppleLossless] : AVFormatIDKey,
#endif
	[NSNumber numberWithFloat:44100.0] : AVSampleRateKey,
	[NSNumber numberWithInt:1] : AVNumberOfChannelsKey,
	[NSNumber numberWithInt:AVAudioQualityMax] : AVEncoderAudioQualityKey
  };
  AVAudioRecorder *	recorder;
  recorder = [[AVAudioRecorder alloc]
	      initWithURL:self.audioFileURL
	      settings:settings
	      error:&error];
  self.audioRecorder = recorder;
  [recorder release];
  if (error) {
    self.audioRecorder = nil;
    [self popupWithMessage:[error localizedDescription]];
    return;
  }

  BOOL	ready = [recorder prepareToRecord];
  if (ready) {
    self.playButton.enabled = NO;
    [self.recordButton setTitle:NSLocalizedString(@"Stop", @"")
		       forState:UIControlStateNormal];

    [recorder setDelegate:self];
    [recorder recordForDuration:_duration];
    [recorder setMeteringEnabled:YES];
    [recorder record];

    self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.03
			       target:self
			       selector:@selector(levelTimerCallback:)
			       userInfo:nil
			       repeats:YES];
  }
}

-(void)resetRecorder
{
  if (self.levelTimer.isValid) {
    [self.levelTimer invalidate];
    self.levelTimer = nil;
  }

  [self.audioSession setActive:NO error:nil];
  self.playButton.enabled = YES;
  self.audioRecorder = nil;

  [self.recordButton setTitle:NSLocalizedString(@"Record", @"")
		     forState:UIControlStateNormal];

  [self.progressBar setProgress:0.0f animated:YES];
}

#pragma mark AVAudioRecorderDelegate
/*
 * audioRecorderDidFinishRecording:successfully: is called when a recording has
 * been finished or stopped. This method is NOT called if the recorder
 * is stopped due to an interruption.
 */
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
	successfully:(BOOL)flag
{
  [self resetRecorder];
}

#pragma mark AVAudioRecorderDelegate
/* if an error occurs while encoding it will be reported to the delegate. */
-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
	error:(NSError *)error
{
  [self popupWithMessage:[error localizedDescription]];
  [recorder stop];
  [recorder deleteRecording];
  [self resetRecorder];
}

#pragma mark AVAudioRecorderDelegate
/*
 * audioRecorderBeginInterruption: is called when the audio session has been
 * interrupted while the recorder was recording. The recorded file will be
 * closed.
 */
-(void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
}

#pragma mark AVAudioRecorderDelegate
/*
 * audioRecorderEndInterruption:withOptions: is called when the audio session
 * interruption has ended and this recorder had been interrupted while
 * recording.
 * Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume.
 */
-(void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
	withOptions:(NSUInteger)flags
{
}

#if	0
#pragma mark AVAudioRecorderDelegate
-(void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
	withFlags:(NSUInteger)flags
{
}

#pragma mark AVAudioRecorderDelegate
/*
 * audioRecorderEndInterruption: is called when the preferred method,
 * audioRecorderEndInterruption:withFlags:, is not implemented.
 */
-(void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
}
#endif

/*
 * See the following web page for this code.
 * http://mobileorchard.com/tutorial-detecting-when-a-user-blows-into-the-mic/
 */
-(void)levelTimerCallback:(NSTimer *)timer
{
  [self.audioRecorder updateMeters];

  const double	ALPHA = 0.05;
  double	peekPowerForChannel = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
  _lowPassResults = ALPHA * peekPowerForChannel + (1.0 - ALPHA) * _lowPassResults;

  self.label.text = [NSString stringWithFormat:@" Ave: %.2f\n Peek: %.2f\n Low Pass: %.2f",
			      [self.audioRecorder averagePowerForChannel:0],
			      [self.audioRecorder peakPowerForChannel:0],
			      _lowPassResults];

  __block RootViewController *	weakSelf = self;

  dispatch_block_t	block = ^{
    [weakSelf.progressBar setProgress:(float)(weakSelf.audioRecorder.currentTime / weakSelf.duration) animated:YES];

  };
  dispatch_async(dispatch_get_main_queue(), block);
}

/******************************************************************************
*
*	Playback
*
******************************************************************************/
#pragma mark UIButton action
-(void)playAction:(id)sender
{
  if (![[NSFileManager defaultManager] fileExistsAtPath:[self.audioFileURL path]]) {
    [self popupWithMessage:NSLocalizedString(@"NotFound", @"")];
    return;
  }

  if (self.audioPlayer != nil && self.audioPlayer.isPlaying) {
    [self.audioPlayer stop];
    return;
  }

  NSError *	error = nil;

  [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
  if (error) {
    [self popupWithMessage:[error localizedDescription]];
    return;
  }

  AVAudioPlayer *	player;
  player = [[AVAudioPlayer alloc]
	    initWithContentsOfURL:self.audioFileURL
	    error:&error];
  self.audioPlayer = player;
  [player release];
  if (error) {
    self.audioPlayer = nil;
    [self popupWithMessage:[error localizedDescription]];
    return;
  }

  BOOL	ready = [player prepareToPlay];
  if (ready) {
    [player setDelegate:self];
    [player setMeteringEnabled:YES];
    [player play];
    self.recordButton.enabled = NO;
    [self.playButton setTitle:NSLocalizedString(@"Stop", @"")
		     forState:UIControlStateNormal];
  }
}

-(void)resetPlayer
{
  [self.audioSession setActive:NO error:nil];
  self.recordButton.enabled = YES;
  self.audioPlayer = nil;

  [self.playButton setTitle:NSLocalizedString(@"Play", @"")
		   forState:UIControlStateNormal];
}

#pragma mark AVAudioPlayerDelegate
/*
 * audioPlayerDidFinishPlaying:successfully: is called when a sound has finished
 * playing. This method is NOT called if the player is stopped due to an
 * interruption.
 */
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
	successfully:(BOOL)flag
{
  [self resetPlayer];
}

#pragma mark AVAudioPlayerDelegate
// if an error occurs while decoding it will be reported to the delegate.
-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
	error:(NSError *)error
{
  [self popupWithMessage:[error localizedDescription]];
  [self resetPlayer];
}

#pragma mark AVAudioPlayerDelegate
/*
 * audioPlayerBeginInterruption: is called when the audio session has been
 * interrupted while the player was playing. The player will have been paused.
 */
-(void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
}

#pragma mark AVAudioPlayerDelegate
/*
 * audioPlayerEndInterruption:withOptions: is called when the audio session
 * interruption has ended and this player had been interrupted while playing.
 * Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume.
 */
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
	withOptions:(NSUInteger)flags
{
}

#if	0
#pragma mark AVAudioPlayerDelegate
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
	withFlags:(NSUInteger)flags
{
}

#pragma mark AVAudioPlayerDelegate
/*
 * audioPlayerEndInterruption: is called when the preferred method,
 * audioPlayerEndInterruption:withFlags:, is not implemented.
 */
-(void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
}
#endif

/*****************************************************************************/

-(void)popupWithMessage:(NSString *)message
{
  UIAlertView *	alertView;
  alertView = [[UIAlertView alloc]
		initWithTitle:NSLocalizedString(@"Error", @"")
		message:message
		delegate:nil
		cancelButtonTitle:NSLocalizedString(@"Close", @"")
		otherButtonTitles:nil];
  [alertView show];
  [alertView release];
}

/*****************************************************************************/

#pragma mark - Application's Documents directory
// Returns the URL to the application's Documents directory.
-(NSURL *)applicationDocumentsDirectory
{
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
