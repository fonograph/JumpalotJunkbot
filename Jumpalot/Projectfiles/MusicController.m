//
//  MusicController.m
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import "MusicController.h"
#import "SimpleAudioEngine.h"
#import "CDAudioManager.h"

@implementation MusicController

static MusicController *sharedController;

+ (MusicController *)sharedController
{
    if ( !sharedController )
        sharedController = [[MusicController alloc] init];
    return sharedController;
}

- (void)preload
{
    [[CDAudioManager sharedManager] preloadBackgroundMusic:@"music1.caf"];
    [[CDAudioManager sharedManager] preloadBackgroundMusic:@"music2.caf"];
    [[CDAudioManager sharedManager] preloadBackgroundMusic:@"music3.caf"];
    [[CDAudioManager sharedManager] preloadBackgroundMusic:@"music4.caf"];
    [[CDAudioManager sharedManager] preloadBackgroundMusic:@"music5.caf"];
}

- (void)startWithLevel:(int)level
{
    NSString *path = [NSString stringWithFormat:@"music%d.caf", level];
    [[CDAudioManager sharedManager] playBackgroundMusic:path loop:TRUE];
    [CDAudioManager sharedManager].backgroundMusic.volume = 1;
    
    _started = YES;
}

- (void)setLevel:(int)level
{
    if ( level > 5 )
        return;
    
    NSTimeInterval time = [CDAudioManager sharedManager].backgroundMusic.audioSourcePlayer.currentTime;
    
    NSString *path = [NSString stringWithFormat:@"music%d.caf", level];
    [[CDAudioManager sharedManager] playBackgroundMusic:path loop:TRUE];
    [CDAudioManager sharedManager].backgroundMusic.audioSourcePlayer.currentTime = time;
}

- (void)stop
{
    [[CDAudioManager sharedManager] stopBackgroundMusic];
    
    _started = NO;
}

- (void)pause
{
    if ( _started )
        [[CDAudioManager sharedManager] pauseBackgroundMusic];
}

- (void)resume
{
    if ( _started )
        [[CDAudioManager sharedManager] resumeBackgroundMusic];
}

@end
