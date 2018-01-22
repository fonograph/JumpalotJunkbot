//
//  MainMenuScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import "MainMenuScene.h"
#import "CollectionLayer.h"
#import "GameScene.h"
#import "LoadingScene.h"
#import "UserData.h"
#import "Background.h"
#import "SimpleAudioEngine.h"


static MainMenuScene *sharedScene;

@interface MainMenuScene()

- (void)startGame;

@end

@implementation MainMenuScene

+ (MainMenuScene *)sharedScene
{
    return sharedScene;
}

- (id)init
{
    if ( self = [super init] )
    {
        _background = [[Background alloc] init];
        [_background setBackgroundLevel:1];
        _background.position = [CCDirector sharedDirector].screenCenter;
        _background.scale = 0.3;
        [self addChild:_background];
        
        _menuLayer = [[MainMenuLayer alloc] init];
        _menuLayer.delegate = self;
        [self addChild:_menuLayer];
        
        _collectionLayer = [[CollectionLayer alloc] init];
        _collectionLayer.delegate = self;
        _collectionLayer.position = ccp(0, -[CCDirector sharedDirector].screenSize.height);
        [self addChild:_collectionLayer];
        
        _settingsLayer = [[SettingsLayer alloc] init];
        _settingsLayer.delegate = self;
        _settingsLayer.position = ccp(0, -[CCDirector sharedDirector].screenSize.height);
        [self addChild:_settingsLayer];
        
        if ( [UserData sharedData].gamesPlayed == 0 )
        {
            _menuLayer.intro = YES;
            _background.opacity = 0;
        }
        
        sharedScene = self;
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"musicMenu.caf"];
    if ( _menuLayer.intro )
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
    
    [self scheduleUpdate];
    
    [[KKGameKitHelper sharedGameKitHelper] authenticateLocalPlayer];
}

- (void)onExit
{
    [super onExit];

    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
    
    [self unscheduleUpdate];
    sharedScene = nil;
}

- (void)onIntroComplete
{
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}


- (void)update:(ccTime)delta
{
    _background.opacity = _menuLayer.title1.opacity;
    
    if ( _background.opacity > 0 )
    {
        [_background update:delta/2]; //slow it down
        [_background scrollFront:ccp(25*delta, -25*delta)];
    }
}

- (void)startGame
{
    [[UserData sharedData] addGamePlayed];
    [[CCDirector sharedDirector] replaceScene:[[LoadingScene alloc] initWithBackground:_background doIntro:YES]];
}


#pragma mark Delegate

- (void)mainMenuDidSelectPlay
{
    if ( [[UserData sharedData] gamesPlayed] == 0 && !_seenHelp )
    {
        _startGameAfterHelp = YES;
        [self mainMenuDidSelectHelp];
    }
    else
    {
        [self startGame];
    }
}

- (void)mainMenuDidSelectHelp
{
    [self removeChild:_menuLayer cleanup:YES];
    
    _seenHelp = YES;
    
    _helpLayer = [[HelpLayer alloc] init];
    _helpLayer.delegate = self;

    [self addChild:_helpLayer];
}

- (void)mainMenuDidSelectSettings
{
    float pan = [CCDirector sharedDirector].screenSize.height;
    [_menuLayer runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]
                                            two:[CCCallBlock actionWithBlock:^{ [self removeChild:_menuLayer cleanup:YES]; }]]];
    [_settingsLayer runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]];
    [_background runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan/2)]];
}

- (void)mainMenuDidSelectJunk
{
    float pan = [CCDirector sharedDirector].screenSize.height;
    [_menuLayer runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]
                                            two:[CCCallBlock actionWithBlock:^{ [self removeChild:_menuLayer cleanup:YES]; }]]];
    [_background runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan/2)]];
    
    [_collectionLayer runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]];
    [_collectionLayer willBeOnscreen];
}

- (void)mainMenuRotated:(float)rotation
{
    _background.rotation += rotation;
}
- (void)helpRotated:(float)rotation
{
    _background.rotation += rotation;
}

- (void)helpDidEnd
{
    if ( _startGameAfterHelp )
    {
        [self startGame];
    }
    else
    {
        [self removeChild:_helpLayer cleanup:YES];
        _helpLayer = nil;
        
        [self addChild:_menuLayer];
    }
}

- (void)collectionDidSelectBack
{
    [self addChild:_menuLayer];
    
    float pan = -[CCDirector sharedDirector].screenSize.height;
    [_menuLayer runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]];
    [_background runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan/2)]];
    
    [_collectionLayer runAction:[CCSequence actionOne:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]
                                                  two:[CCCallFunc actionWithTarget:_collectionLayer selector:@selector(noLongerOnscreen)]]];
}

- (void)settingsDidSelectBack
{
    [self addChild:_menuLayer];
    
    float pan = -[CCDirector sharedDirector].screenSize.height;
    [_menuLayer runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]];
    [_settingsLayer runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan)]];
    [_background runAction:[CCMoveBy actionWithDuration:0.5 position:ccp(0, pan/2)]];

}


- (void)freeMemory
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

@end
