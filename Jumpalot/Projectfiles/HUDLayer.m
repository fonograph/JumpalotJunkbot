//
//  HUDLayer.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-30.
//
//

#import "HUDLayer.h"
#import "BoostMeter.h"
#import "EnergyMeter.h"
#import "ScoreMeter.h"
#import "JunkMeter.h"
#import "Score.h"
#import "Player.h"
#import "PauseLayer.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"

@implementation HUDLayer

- (id)init
{
    if ( self = [super init] )
    {
        self.touchEnabled = YES;
        
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        
        _energyMeter = [[EnergyMeter alloc] init];
        _energyMeter.position = ccp(0, screenSize.height - _energyMeter.contentSize.height);
        
        _scoreMeter = [[ScoreMeter alloc] init];
        _scoreMeter.position = ccp(0, _energyMeter.position.y - _scoreMeter.contentSize.height - 5);
        
        _junkMeter = [[JunkMeter alloc] init];
        _junkMeter.position = _scoreMeter.position;
        
        _batchNode = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"hudSprites.pvr"]];
        
        _energyLabel = [CCSprite spriteWithSpriteFrameName:@"hudEnergy.png"];
        _energyLabel.anchorPoint = ccp(0, 0);
        _energyLabel.position = ccp(0, _energyMeter.position.y);
        _energyLabel.opacity = 190;
        [_batchNode addChild:_energyLabel];
        
        _warning = [CCSprite spriteWithSpriteFrameName:@"hudWarning.png"];
        _warning.anchorPoint = ccp(0.5, 1);
        _warning.position = ccp(screenSize.width/2, _energyMeter.position.y - 10);
        _warning.opacity = 190;
        _warning.visible = NO;
        [_batchNode addChild:_warning];
        
        _warningGlow = [CCSprite spriteWithSpriteFrameName:@"hudWarningGlow.png"];
        _warningGlow.anchorPoint = ccp(0, 1);
        _warningGlow.position = ccp(0, screenSize.height);
        _warningGlow.scaleY = 2;
        _warningGlow.visible = NO;
        [_batchNode addChild:_warningGlow];
        
        _pause = [CCSprite spriteWithSpriteFrameName:@"hudPause.png"];
        _pause.anchorPoint = CGPointZero;
        _pause.scale = 0.65;
        _pause.opacity = 128;
        [_batchNode addChild:_pause];
        
        [self addChild:_batchNode];
        [self addChild:_energyMeter];
        [self addChild:_scoreMeter];
        [self addChild:_junkMeter];
    }
    return self;
}

- (void)registerWithTouchDispatcher
{
    [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)onExit
{
    [super onExit];
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint pt = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
    if ( CGRectContainsPoint(_pause.boundingBox, pt) )
    {
        return YES;
    }
    return NO;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if ( touch.tapCount == 1 )
    {
        CGPoint pt = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch locationInView:touch.view]]];
        if ( CGRectContainsPoint(_pause.boundingBox, pt) && _pause.visible )
        {
            [[GameScene sharedGameScene] pause];
        }
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void)setPlayer:(Player *)player
{
    _player = player;
    
    _energyMeter.player = player;
}

- (void)setScore:(Score *)score
{
    _score = score;
    _scoreMeter.score = score;
    _junkMeter.score = score;
    
    _junkCountToHideJunkMeter = 5;
    _junkCountToShowJunkMeter = _score.junksRemainingToLevelUp - 9;
}

- (void)update:(ccTime)delta
{
    [_energyMeter update:delta];
    [_scoreMeter update:delta];
    [_junkMeter update:delta];
    
    if ( _player.energyPercentage < 25 )
    {
        _warningGlow.visible = YES;
        _warningGlow.opacity = MIN(255, ( 25 - _player.energyPercentage/1.5 ) / 25 * 255);
        
        if ( !_ranWarning )
        {
            [_warning runAction:[CCBlink actionWithDuration:4 blinks:8]];
            _ranWarning = YES;
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"alarm.caf"];
        }
    }
    else
    {
        _warningGlow.visible = NO;
    }
    
//    if ( _score.junks == _junkCountToShowJunkMeter && !_junkMeter.showing )
//        [_junkMeter show];
//    if ( _score.junks == _junkCountToHideJunkMeter && _junkMeter.showing )
//        [_junkMeter hide];
}

- (void)levelUp
{
    _junkCountToHideJunkMeter = _score.junks + 5;
    _junkCountToShowJunkMeter = _score.junksToLevelUp - 9;
}

- (void)endLevelUp
{
}

- (void)hide
{
    _energyMeter.visible = NO;
    _energyLabel.visible = NO;
    _scoreMeter.visible = NO;
    _junkMeter.visible = NO;
    _pause.visible = NO;
}

- (void)show
{
    _energyMeter.visible = YES;
    _energyLabel.visible = YES;
    _scoreMeter.visible = YES;
    _junkMeter.visible = YES;
    _pause.visible = YES;
}


@end
