//
//  GameOverLayer.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-22.
//
//

#import "GameOverLayer.h"
#import "MainMenuScene.h"
#import "GameScene.h"
#import "Score.h"
#import "PlayerDriveConfig.h"
#import "UserData.h"
#import "JunkCategory.h"
#import "SimpleAudioEngine.h"
#import "LoadingScene.h"


@implementation GameOverLayer

- (void)didLoadFromCCB
{
//    CCLayer *bg = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200)];
//    [self addChild:bg z:-1];
    
    _scoreLabel.string = [NSString stringWithFormat:@"%d", [GameScene sharedGameScene].score.points];
    
    int minutes = (int)[GameScene sharedGameScene].score.time / 60;
    int seconds = (int)[GameScene sharedGameScene].score.time % 60;
    _timeLabel.string = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    
    _junksLabel.string = [NSString stringWithFormat:@"%d", [GameScene sharedGameScene].score.junks];
    
    CCBAnimationManager *am = self.userObject;
    am.delegate = self;
}

- (void)setTopJunks:(BOOL)topJunks
{
    _topJunksLabel.visible = _topJunks = topJunks;
}

- (void)setTopScore:(BOOL)topScore
{
    _topScoreLabel.visible = _topScore = topScore;
}

- (void)setTopTime:(BOOL)topTime
{
    _topTimeLabel.visible = _topTime = topTime;
}

- (void)onEnter
{
    [super onEnter];
    
    CCBAnimationManager *am = self.userObject;
    [am runAnimationsForSequenceNamed:@"Intro"];

    
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameover.caf"];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.83]
                                      two:[CCCallBlock actionWithBlock:^{
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuWhoosh.caf"];
    }]]];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1.16]
                                      two:[CCCallBlock actionWithBlock:^{
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuWhoosh.caf"];
    }]]];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1.5]
                                      two:[CCCallBlock actionWithBlock:^{
        [[SimpleAudioEngine sharedEngine] playEffect:@"menuWhoosh.caf"];
    }]]];
    

}

- (void)tappedRetry:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[[LoadingScene alloc] initWithBackground:nil doIntro:NO]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
}

- (void)tappedCancel:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
}

- (void)completedAnimationSequenceNamed:(NSString *)name
{
    CCBAnimationManager *am = self.userObject;
    
    if ( [name isEqualToString:@"Intro"] )
    {
        if ( _showUnlock1 || _showUnlock2 || _showUnlock3 )
        {
            [am runAnimationsForSequenceNamed:@"Unlock"];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"menuWhoosh.caf"];
            [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5]
                                              two:[CCCallBlock actionWithBlock:^{
                [[SimpleAudioEngine sharedEngine] playEffect:@"introsparkle.caf"];
            }]]];
            
            PlayerDriveConfig *unlock;
            if ( _showUnlock1 )
                unlock = [PlayerDriveConfig driveConfigWithLevel:2];
            else if ( _showUnlock2 )
                unlock = [PlayerDriveConfig driveConfigWithLevel:3];
            else if ( _showUnlock3 )
                unlock = [PlayerDriveConfig driveConfigWithLevel:4];
            
            _unlockModelLabel.string = unlock.name;
            _unlockModelLabel.color = ccc3((unlock.color.r+255)/2, (unlock.color.g+255)/2, (unlock.color.b+255)/2);
            _unlockParticles.startColor = ccc4FFromccc3B(unlock.color);
        }
        else
        {
            [am runAnimationsForSequenceNamed:@"Show Deploy"];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"menuWhoosh.caf"];
            
            //figure out progress to next unlock
            JunkCategory *junkCategory = nil;
            int remaining;
            if ( ![[UserData sharedData] unlock1Achieved] )
            {
                junkCategory = [JunkCategory categoryForIndex:2];
                remaining = [[UserData sharedData] remainingForUnlock1];
            }
            else if ( ![[UserData sharedData] unlock2Achieved] )
            {
                junkCategory = [JunkCategory categoryForIndex:3];
                remaining = [[UserData sharedData] remainingForUnlock2];
            }
            else if ( ![[UserData sharedData] unlock3Achieved] )
            {
                junkCategory = [JunkCategory categoryForIndex:4];
                remaining = [[UserData sharedData] remainingForUnlock3];
            }
            
            if ( junkCategory )
            {
                _unlockPreviewLine1.string = [NSString stringWithFormat:@"COLLECT %d MORE TYPES OF", remaining];
                _unlockPreviewLine2.string = [NSString stringWithFormat:@"%@ JUNK", junkCategory.title];
                _unlockPreviewLine2.color = ccc3((junkCategory.color.r+255)/2, (junkCategory.color.g+255)/2, (junkCategory.color.b+255)/2);
            }
            else
            {
                _unlockPreviewContainer.visible = NO;
            }
        }
    }
}

@end
