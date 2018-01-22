//
//  PlayerSprite.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-15.
//
//

#import "PlayerSprite.h"

@implementation PlayerSprite

- (id)initWithType:(int)type
{
    if ( self = [super initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"playerSprites.pvr"]] )
    {
        _type = type;
        
        _jumping = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_jump.png", _type]];
        _landing = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_land.png", _type]];
        _hyper = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_hyper.png", _type]];
        _damage = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_damage.png", _type]];
        _flipA = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_flipA.png", _type]];
        _flipB = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"player%d_flipB.png", _type]];
        
        self.state = PlayerSpriteStateJumping;
    }
    return self;
}

- (void)updateDisplayFrame:(PlayerSpriteState)state
{
    if ( state == PlayerSpriteStateJumping )
        [self setDisplayFrame:_jumping];
    else if ( state == PlayerSpriteStateLanding )
        [self setDisplayFrame:_landing];
    else if ( state == PlayerSpriteStateHyper )
        [self setDisplayFrame:_hyper];
    else if ( state == PlayerSpriteStateDamage )
        [self setDisplayFrame:_damage];
    else if ( state == PlayerSpriteStateFlipA )
        [self setDisplayFrame:_flipA];
    else if ( state == PlayerSpriteStateFlipB )
        [self setDisplayFrame:_flipB];
}

- (void)setState:(PlayerSpriteState)state
{
    _state = state;
    
    if ( !_tempState )
        [self updateDisplayFrame:_state];
}

- (void)setTempState:(PlayerSpriteState)tempState forLength:(ccTime)length
{
    _tempState = tempState;
    _tempStateCounter = length;
    
    [self updateDisplayFrame:_tempState];
}

- (void)clearTempState
{
    _tempState = 0;
    [self updateDisplayFrame:_state];
}

- (BOOL)hasTempState
{
    return _tempState;
}

- (void)update:(ccTime)delta
{
    if ( _tempStateCounter > 0 )
    {
        _tempStateCounter -= delta;
        if ( _tempStateCounter <=0 )
        {
            [self clearTempState];
        }
    }
}

@end
