//
//  GameScene.h
//  Jumpalot
//
//  Created by David Fono on 12-08-28.
//
//

#import "CCScene.h"
#import "ActionLayer.h"

@class ActionLayer, HUDLayer, Score, Background, PauseLayer;

@interface GameScene : CCScene <ActionLayerDelegate>
{
    ActionLayer *_actionLayer;
    HUDLayer *_hudLayer;
    PauseLayer *_pauseLayer;
    
    BOOL _unlock1Achieved;
    BOOL _unlock2Achieved;
    BOOL _unlock3Achieved;
    
    BOOL _doIntro;
}

@property (strong, readonly, nonatomic) Score *score;

+ (GameScene *)sharedGameScene;

- (id)initWithBackground:(Background *)background doIntro:(BOOL)doIntro;
- (void)onPlayerDead;
- (void)showGameOver;
- (BOOL)canPause;
- (void)pause;
- (void)unpause;
- (void)freeMemory;

@end
