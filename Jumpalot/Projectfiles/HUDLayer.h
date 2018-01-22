//
//  HUDLayer.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-30.
//
//

#import "cocos2d.h"

@class BoostMeter, EnergyMeter, ScoreMeter, JunkMeter, Player, Score;

@interface HUDLayer : CCLayer
{
    Player *_player;
    
    EnergyMeter *_energyMeter;
    ScoreMeter *_scoreMeter;
    JunkMeter *_junkMeter;
    Score *_score;
    CCSprite *_pause;
    
    CCSpriteBatchNode *_batchNode;
    CCSprite *_energyLabel;
    CCSprite *_warning;
    CCSprite *_warningGlow;
    
    BOOL _ranWarning;
    
    int _junkCountToHideJunkMeter;
    int _junkCountToShowJunkMeter;
}

- (void)setPlayer:(Player *)player;
- (void)setScore:(Score *)score;
- (void)update:(ccTime)delta;

- (void)levelUp;
- (void)endLevelUp;

- (void)hide;
- (void)show;

@end
