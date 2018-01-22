//
//  Bomb.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-24.
//
//

#define RADIUS 60

#import "Bomb.h"
#import "SimpleAudioEngine.h"
#import "ActionLayer.h"
#import "GravityAura.h"

@implementation Bomb


- (id)initWithAttract:(BOOL)attract
{
    if ( self = [super init] )
    {
        _ps = [CCParticleSystemQuad particleWithFile:@"bomb.plist"];
        _ps.positionType = kCCPositionTypeGrouped;
        [[ActionLayer sharedActionLayer] addParticlesToForeground:_ps];
        
        _sprite = [CCSprite spriteWithSpriteFrameName:!attract ? @"bomb.png" : @"bombGravity.png"];
        _sprite.rotation = arc4random() % 360;
        _sprite.opacity = 190;
        [[ActionLayer sharedActionLayer] addSpriteToForeground:_sprite z:ForegroundZBomb];
        
        self.bombSize = CGSizeMake(120, 120);
        
        if ( attract )
        {
            _attract = YES;
            _attractRange = 500;
            _attractForce = 13000;
            
            _aura = [[GravityAura alloc] initWithRadius:_attractRange color:ccc3(255, 127, 127) expands:NO];
            [self addChild:_aura];
        }
    }
    return self;
}


- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    _sprite.position = position;
    _ps.position = position;
    _aura.position = position;
}

- (void)setBombSize:(CGSize)bombSize
{
    _bombSize = bombSize;
    
    _sprite.scaleX = _bombSize.width / _sprite.contentSize.width;
    _sprite.scaleY = _bombSize.height / _sprite.contentSize.height;
    
    self.contentSize = CGSizeMake(_sprite.contentSize.width * _sprite.scaleX, _sprite.contentSize.height * _sprite.scaleY);
    
    _radius = _bombSize.width/2;
    
    _ps.posVar = ccp(_radius/sqrtf(2), _radius/sqrtf(2));
}


- (void)onExit
{
    [super onExit];
    
    [_sprite removeFromParentAndCleanup:YES];
    [_ps removeFromParentAndCleanup:YES];
    [_aura removeFromParentAndCleanup:YES];    
}

- (void)explode
{
    _exploded = YES;
    
    [_sprite removeFromParentAndCleanup:YES];
    [_ps stopSystem];
    
    if ( _aura )
    {
        _attract = NO;
        [_aura fadeOut:1];
    }

    CCParticleSystemQuad *explode = [CCParticleSystemQuad particleWithFile:@"bombExplode.plist"];
    explode.positionType = kCCPositionTypeGrouped;
    explode.position = CGPointZero;
    [self addChild:explode];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.caf" pitch:1.0f pan:0.0f gain:0.7f];
}

@end
