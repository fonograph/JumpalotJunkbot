//
//  PlayerSprite.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-15.
//
//

#import "CCNode.h"

typedef enum {
    PlayerSpriteStateLanding,
    PlayerSpriteStateJumping,
    PlayerSpriteStateHyper,
    PlayerSpriteStateFlipA,
    PlayerSpriteStateFlipB,
    PlayerSpriteStateDamage
} PlayerSpriteState;

@interface PlayerSprite : CCSprite
{
    int _type;
    PlayerSpriteState _tempState;
    ccTime _tempStateCounter;
    
    CCSpriteFrame *_landing;
    CCSpriteFrame *_jumping;
    CCSpriteFrame *_hyper;
    CCSpriteFrame *_flipA;
    CCSpriteFrame *_flipB;
    CCSpriteFrame *_damage;
}

@property (nonatomic) PlayerSpriteState state;

- (id)initWithType:(int)type;
- (void)setTempState:(PlayerSpriteState)tempState forLength:(ccTime)length;
- (void)clearTempState;
- (BOOL)hasTempState;

@end
