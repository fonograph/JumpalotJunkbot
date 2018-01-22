//
//  MainMenuScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-21.
//
//

#import "MainMenuLayer.h"
#import "CCBReader.h"
#import "GameScene.h"
#import "SimpleAudioEngine.h"
#import "UserData.h"
#import "PlayerDriveConfig.h"
#import "SimpleAudioEngine.h"
#import "MainMenuScene.h"

@interface MainMenuLayer()

- (void)showTap;
- (void)hideTap;
- (void)updateDriveDisplay;

@end

@implementation MainMenuLayer

- (id)init
{
    if ( self = [super init] )
    {
        _menuLayer = (CCLayer *)[CCBReader nodeGraphFromFile:@"MainMenu.ccbi" owner:self];
        [self addChild:_menuLayer];
                
        _play.opacity = 128;
        _help.opacity = 128;
        _junk.opacity = 128;
        
        _tap.visible = NO;
        
        _lastPanPoint = CGPointZero;
        
        [_thumb runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCFadeTo actionWithDuration:1 opacity:127]
                                                                              two:[CCFadeTo actionWithDuration:1 opacity:255]]]];
        
        if ( ![[UserData sharedData] unlock1Achieved] )
        {
            _driveHeading.visible = NO;
            _driveLabel.visible = NO;
            _driveLeft.visible = NO;
            _driveRight.visible = NO;
            
            _selectedDrive = 1;
            [self updateDriveDisplay];
        }
        else
        {
            _maxDrive = 2;
            if ( [[UserData sharedData] unlock2Achieved] )
                _maxDrive = 3;
            if ( [[UserData sharedData] unlock3Achieved] )
                _maxDrive = 4;
            
            _selectedDrive = _maxDrive;
            [self updateDriveDisplay];
        }
        
        // RUN FIRST-TIME SPLASH?
        if ( [UserData sharedData].gamesPlayed == 0 )
        {
            _innerArrow.position = [_circleContainer convertToWorldSpace:_innerArrow.position];
            [_innerArrow removeFromParent];
            [self addChild:_innerArrow];
            
            _title1.opacity = 0;
            _title2.opacity = 0;
            _play.opacity = 0;
            _help.opacity = 0;
            _junk.opacity = 0;
            _settings.opacity = 0;
            
            _circleContainer.rotation = 180;
            
            _introParticles = [CCParticleSystemQuad particleWithFile:@"introParticles.plist"];
            _introParticles.position = _circleContainer.position;
            _introParticles.autoRemoveOnFinish = YES;
            [self addChild:_introParticles];

            _intro = YES;
        }
        else
        {
            _innerArrow.visible = NO;
            _outerArrow.visible = NO;
        }
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [KKInput sharedInput].gesturePanEnabled = YES;
    [KKInput sharedInput].gestureTapEnabled = YES;
    
    [self scheduleUpdate];
}

- (void)onExit
{
    [super onExit];
    
    [KKInput sharedInput].gesturePanEnabled = NO;
    [KKInput sharedInput].gestureTapEnabled = NO;
    
    [self unscheduleUpdate];
}

- (void)update:(ccTime)delta
{
    if ( [KKInput sharedInput].gesturePanBegan )
    {
        if ( !_didPan && !_intro )
        {
            [_thumb stopAllActions];
            [_thumb runAction:[CCFadeOut actionWithDuration:0.5]];
            _didPan = YES;            
        }
        
        CGPoint pt = [KKInput sharedInput].gesturePanLocation;
        if ( pt.y < CONTROL_AREA_HEIGHT && _lastPanPoint.x )
        {
            CGFloat pan = pt.x - _lastPanPoint.x;
            
            _circleContainer.rotation -= pan * 0.5;
            [_delegate mainMenuRotated:-pan*0.5];
            
            if ( _circleContainer.rotation > 360 )
                _circleContainer.rotation -= 360;
            else if ( _circleContainer.rotation < 0 )
                _circleContainer.rotation += 360;
        
            if ( !_intro )
            {
                if ( abs(_circleContainer.rotation-90) < 25 )
                {
                    // JUNK
                    if ( _selectedLabel != _junk )
                    {
                        _selectedLabel = _junk;
                        _selectedLabel.opacity = 255;
                        
                        [self showTap];
                    }
                }
                else if ( abs(_circleContainer.rotation-180) < 25 )
                {
                    // HELP
                    if ( _selectedLabel != _help )
                    {
                        _selectedLabel = _help;
                        _selectedLabel.opacity = 255;
                        
                        [self showTap];
                    }
                }
                else if ( abs(_circleContainer.rotation-270) < 25 )
                {
                    // PLAY
                    if ( _selectedLabel != _play )
                    {
                        _selectedLabel = _play;
                        _selectedLabel.opacity = 255;
                        
                        [self showTap];
                    }
                }
                else if ( _selectedLabel )
                {
                    _selectedLabel.opacity = 128;
                    _selectedLabel = nil;
                    [self hideTap];
                }
            }
            
            if ( _intro )
            {
                CGFloat distance = fabsf(_circleContainer.rotation - 180) / 180.0f;
                _introParticles.startSize = 10*(1-distance) + 40*distance;
                _introParticles.speed = 40*(1-distance) + 100*distance;
            }
        }
        
        _lastPanPoint = pt;
    }
    else if ( _lastPanPoint.x )
    {
        // PAN ENDED
        _lastPanPoint = CGPointZero;
        
        if ( _intro )
        {
            if ( (_circleContainer.rotation < 5 || _circleContainer.rotation > 355) )
            {
                [KKInput sharedInput].gesturePanEnabled = NO;
                
                [[SimpleAudioEngine sharedEngine] playEffect:@"introsparkle.caf"];
                
                [_circleContainer runAction:[CCSequence actionOne:[CCRotateTo actionWithDuration:0.5 angle:0]
                                                              two:[CCCallBlock actionWithBlock:^{
                    
                    [_innerArrow runAction:[CCFadeOut actionWithDuration:1]];
                    [_outerArrow runAction:[CCFadeOut actionWithDuration:1]];
                    
                    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                                      two:[CCCallBlock actionWithBlock:^{
                        
                        CCSprite *shockwave = [CCSprite spriteWithFile:@"mainmenu_circle.png"];
                        shockwave.position = _circleContainer.position;
                        shockwave.scale = 0;
                        [self addChild:shockwave];
                        [shockwave runAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:0.5 scale:2.5]
                                                               two:[CCCallBlock actionWithBlock:^{
                            [shockwave removeFromParentAndCleanup:YES];
                        }]]];
                        
                        [_introParticles stopSystem];
                        CCParticleSystemQuad *explosion = [CCParticleSystemQuad particleWithFile:@"deathExplosion.plist"];
                        explosion.position = shockwave.position;
                        explosion.autoRemoveOnFinish = YES;
                        explosion.speed *= 1.5;
                        [self addChild:explosion];
                        
                        [[SimpleAudioEngine sharedEngine] playEffect:@"boost.caf"];                        
                        
                        [_title1 runAction:[CCFadeIn actionWithDuration:1]];
                        [_title2 runAction:[CCFadeIn actionWithDuration:1]];
                        
                        [_play runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                                           two:[CCFadeTo actionWithDuration:1 opacity:128]]];
                        [_help runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                                           two:[CCFadeTo actionWithDuration:1 opacity:128]]];
                        [_junk runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:1]
                                                           two:[CCFadeTo actionWithDuration:1 opacity:128]]];
                        
                        [_settings runAction:[CCFadeIn actionWithDuration:1]];
                        
                        [KKInput sharedInput].gesturePanEnabled = YES;
                        _intro = NO;
                        
                        [[MainMenuScene sharedScene] onIntroComplete];
                        
                    }]]];
                    
                }]]];
                

            }
        }
    }
    
    if ( [KKInput sharedInput].gestureTapRecognizedThisFrame )
    {
        CGPoint pt = [self convertToNodeSpace:[KKInput sharedInput].gestureTapLocation];
        
        // BUTTONS
        if ( CGRectContainsPoint(_settings.boundingBox, pt) )
        {
            [_delegate mainMenuDidSelectSettings];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
        }
        else if ( CGRectContainsPoint(_driveLeft.boundingBox, pt) )
        {
            if ( _selectedDrive > 1 )
            {
                _selectedDrive--;
                [self updateDriveDisplay];
                [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
            }
        }
        else if ( CGRectContainsPoint(_driveRight.boundingBox, pt) )
        {
            if ( _selectedDrive < _maxDrive )
            {
                _selectedDrive++;
                [self updateDriveDisplay];
                [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
            }
        }
        
        // MENU OPTIONS
        else if ( _selectedLabel == _help )
        {
            // HELP
            [_delegate mainMenuDidSelectHelp];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
        }
        else if ( _selectedLabel == _play )
        {
            // PLAY
            [_delegate mainMenuDidSelectPlay];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
        }
        else if ( _selectedLabel == _junk )
        {
            [_delegate mainMenuDidSelectJunk];
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
        }
    }
}

- (void)showTap
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep.caf"];
    
    _tap.visible = YES;
}

- (void)hideTap
{
    _tap.visible = NO;
}

- (void)updateDriveDisplay
{
    [PlayerDriveConfig setSharedLevelSetting:_selectedDrive];
    
    PlayerDriveConfig *drive = [PlayerDriveConfig driveConfigWithLevel:_selectedDrive];
    _driveLabel.string = drive.name;
    _driveLabel.color = ccc3((drive.color.r+255)/2, (drive.color.g+255)/2, (drive.color.b+255)/2);

    if ( _selectedDrive == 1 )
        _driveLeft.color = ccc3(100, 100, 100);
    else
        _driveLeft.color = ccc3(200, 200, 200);
    
    if ( _selectedDrive == _maxDrive )
        _driveRight.color = ccc3(100, 100, 100);
    else
        _driveRight.color = ccc3(200, 200, 200);
    
}

@end
