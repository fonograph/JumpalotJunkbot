//
//  GameScene.m
//  Jumpalot
//
//  Created by David Fono on 12-08-28.
//
//

#import "GameScene.h"
#import "ActionLayer.h"
#import "HUDLayer.h"
#import "GameOverLayer.h"
#import "CCBReader.h"
#import "Player.h"
#import "Score.h"
#import "SimpleAudioEngine.h"
#import "UserData.h"
#import "MusicController.h"
#import "Background.h"
#import "PauseLayer.h"
#import "PlayerDriveConfig.h"

@interface GameScene()

- (void)sendScoreToServer;

@end

@implementation GameScene

static GameScene *sharedGameScene;

+ (GameScene *)sharedGameScene
{
    return sharedGameScene;
}

- (id)init
{
    return [self initWithBackground:nil doIntro:NO];
}

- (id)initWithBackground:(Background *)background doIntro:(BOOL)doIntro
{
    if ( self=[super init] )
    {
        sharedGameScene = self;
        
        _doIntro = doIntro;
        
        _score = [[Score alloc] init];
                
        _actionLayer = [[ActionLayer alloc] initWithBackground:background];
        _actionLayer.delegate = self;
        
        _hudLayer = [[HUDLayer alloc] init];
        [_hudLayer hide];
        
        [_hudLayer setPlayer:_actionLayer.player];
        [_hudLayer setScore:_score];
        
        [self addChild:_actionLayer];
        [self addChild:_hudLayer];
        
        _unlock1Achieved = [[UserData sharedData] unlock1Achieved];
        _unlock2Achieved = [[UserData sharedData] unlock2Achieved];
        _unlock3Achieved = [[UserData sharedData] unlock3Achieved];
        
        [[MusicController sharedController] startWithLevel:_score.level];
        [[MusicController sharedController] pause];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
  
    [self scheduleUpdate];
    
    [_actionLayer beginWithIntro:_doIntro];
}

- (void)onExit
{
    [super onExit];
    
    [self unscheduleUpdate];
    sharedGameScene = nil;
}

- (void)update:(ccTime)delta
{
    [_actionLayer update:delta];
    [_hudLayer update:delta];
        
    _score.time += delta;
    
    // LEVEL UP
    if ( _score.junksToLevelUp > 0 && _score.junks >= _score.junksToLevelUp )
    {
        [_score levelUp];
        [_actionLayer levelUp];
        [_hudLayer levelUp];
        
        [[MusicController sharedController] setLevel:_score.level];
    }
}

- (void)showGameOver
{
    [self unscheduleUpdate];
        
    GameOverLayer *goLayer = (GameOverLayer *)[CCBReader nodeGraphFromFile:@"GameOver.ccbi"];
    
    goLayer.showUnlock1 = !_unlock1Achieved && [[UserData sharedData] unlock1Achieved];
    goLayer.showUnlock2 = !_unlock2Achieved && [[UserData sharedData] unlock2Achieved];
    goLayer.showUnlock3 = !_unlock3Achieved && [[UserData sharedData] unlock3Achieved];
    
    if ( goLayer.showUnlock1 )
        [PlayerDriveConfig setSharedLevelSetting:2];
    else if ( goLayer.showUnlock2 )
        [PlayerDriveConfig setSharedLevelSetting:3];
    else if ( goLayer.showUnlock3 )
        [PlayerDriveConfig setSharedLevelSetting:4];
    
    goLayer.topScore = [[UserData sharedData] addScore:_score.points];
    goLayer.topTime = [[UserData sharedData] addTime:_score.time];
    goLayer.topJunks = [[UserData sharedData] addJunks:_score.junks];
    [[UserData sharedData] save];
    
    [self addChild:goLayer];

    //[self sendScoreToServer];
}

- (BOOL)canPause
{
    return _actionLayer.controlsActive;
}

- (void)pause
{
    if ( [self canPause] && !_pauseLayer )
    {
        _pauseLayer = [[PauseLayer alloc] init];
        [self addChild:_pauseLayer];
        [[CCDirector sharedDirector] pause];        
    }
}

- (void)unpause
{
    if ( _pauseLayer )
    {
        [self removeChild:_pauseLayer cleanup:YES];
        [[CCDirector sharedDirector] resume];
        _pauseLayer = nil;
    }
}

- (void)onPlayerDead
{
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:2]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(showGameOver)]]];
}

- (void)actionLayerDidCompleteLevelUp
{
    [_hudLayer endLevelUp];
}

- (void)actionLayerBecameReadyForLaunch
{
    [_hudLayer show];
}

- (void)sendScoreToServer
{
//    NSString *uid;
//    if ( [[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)] )
//        uid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    else
//        return;
//    
//    NSString *url = [NSString stringWithFormat:
//                     @"http://www.trenderizer.com/jumpalot/saveScore.php?score=%d&time=%d&junks=%d&hypers=%d&combos=%d&level=%d&collection=%@&id=%@",
//                     _score.points, (int)_score.time, _score.junks, _score.hypers, _score.combos, _score.level,
//                     [[UserData sharedData] collectionSummary], uid];
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
//    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    NSLog(@"%@", connection);
}

- (void)freeMemory
{
    [[CCTextureCache sharedTextureCache] removeUnusedTextures];
}


@end
