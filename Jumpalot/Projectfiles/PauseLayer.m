//
//  PauseScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import "PauseLayer.h"
#import "CCBReader.h"
#import "MainMenuScene.h"
#import "GameScene.h"
#import "Score.h"
#import "MusicController.h"
#import "SimpleAudioEngine.h"
#import "UserData.h"

@implementation PauseLayer

- (id)init
{
    if ( self=[super init] )
    {
        CCLayerColor *dimmer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 180)];
        [self addChild:dimmer];
        
        CCLayer *layer = (CCLayer *)[CCBReader nodeGraphFromFile:@"Pause.ccbi" owner:self];
        
        _scoreLabel.string = [NSString stringWithFormat:@"%d", [GameScene sharedGameScene].score.points];
        _junksLabel.string = [NSString stringWithFormat:@"%d", [GameScene sharedGameScene].score.junks];
        _combosLabel.string = [NSString stringWithFormat:@"%d", [GameScene sharedGameScene].score.combos];
        
        int minutes = (int)[GameScene sharedGameScene].score.time / 60;
        int seconds = (int)[GameScene sharedGameScene].score.time % 60;
        _timeLabel.string = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        
        [self addChild:layer];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[MusicController sharedController] pause];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.caf"];
}

- (void)onExit
{
    [super onExit];
    
    [[MusicController sharedController] resume];
}

- (void)tappedResume:(id)sender
{
    [[GameScene sharedGameScene] unpause];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
}

- (void)tappedQuit:(id)sender
{
    [[MusicController sharedController] stop];
    [[UserData sharedData] save];
    [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];
    [[CCDirector sharedDirector] resume];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];        
}

@end
