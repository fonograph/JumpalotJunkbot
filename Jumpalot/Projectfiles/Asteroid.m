//
//  Asteroid.m
//  Jumpalot
//
//  Created by David Fono on 2013-06-21.
//
//

#import "Asteroid.h"
#import "ActionLayer.h"

#define MIN_SPEED 75
#define MAX_SPEED 150

@implementation Asteroid

- (id)init
{
    if ( self = [super init] )
    {
        _charges = 1;
        
        _radius = 50;
        
        NSString *file = [NSString stringWithFormat:@"asteroid%d.png", arc4random()%3+1];
        _sprite = [CCSprite spriteWithSpriteFrameName:file];
        _sprite.scale = _radius / (_sprite.contentSize.width/2);
        
        _velocity = ccp(0, 0);
        
        [[ActionLayer sharedActionLayer] addSpriteToForeground:_sprite z:ForegroundZBlock];
    }
    return self;
}

- (void)update:(ccTime)delta
{
    self.position = ccpAdd(self.position, ccpMult(_velocity, delta));
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    _sprite.position = position;
}

- (void)setRandomVelocityWithinMinAngle:(CGFloat)minAngle maxAngle:(CGFloat)maxAngle
{
    CGFloat angle = minAngle + (maxAngle-minAngle) * CCRANDOM_0_1();
    CGFloat speed = MIN_SPEED + (MAX_SPEED-MIN_SPEED) * CCRANDOM_0_1();
    _velocity = ccpMult(ccpForAngle(angle), speed);
}

- (void)removeFromParentShortcut
{
    [self removeFromParentAndCleanup:YES];
}

- (void)hit
{
    _hitParticles = [CCParticleSystemQuad particleWithFile:@"blockActivate.plist"];
    _hitParticles.positionType = kCCPositionTypeGrouped;
    _hitParticles.position = CGPointZero;
    _hitParticles.posVar = CGPointZero;
    _hitParticles.angleVar = 360;
    _hitParticles.life *= 1.3;
    
    [self addChild:_hitParticles];
    
    [_sprite runAction:[CCFadeOut actionWithDuration:_hitParticles.life+_hitParticles.lifeVar]];
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:_hitParticles.life+_hitParticles.lifeVar]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(removeFromParentShortcut)]]];
}

- (void)onExit
{
    [super onExit];
    
    [_sprite removeFromParentAndCleanup:YES];
    [_hitParticles removeFromParentAndCleanup:YES];
}



@end
