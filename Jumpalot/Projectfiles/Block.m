//
//  Block.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-19.
//
//

#import "Block.h"
#import "ActionLayer.h"
#import "BlockSprite.h"
#import "BlockSpriteOutline.h"
#import "GravityAura.h"

@interface Block ()

- (void)setCharges:(int)charges;

@end

@implementation Block

- (id)init
{
    if ( self = [super init] )
    {
        _sprite = [[BlockSprite alloc] init]; 
        _outline = [[BlockSpriteOutline alloc] init];
        
        [[ActionLayer sharedActionLayer] addBlockSprite:_sprite outline:_outline];

        _charges = 1;
        _boostMultiplier = 1;

        _halo = [CCSprite spriteWithSpriteFrameName:@"circle.png"];
        _halo.opacity = 40;
        _halo.visible = NO;
        //[[ActionLayer sharedActionLayer] addSpriteToForeground:_halo z:ForegroundZBlockHalo];

        //self.blockSize = _sprite.contentSize;
    }
    return self;
}

- (void)addRepel
{
    _repel = YES;
    _repelForce = 13500;
    _repelRange = 500;
    _sprite.repel = YES;
    
    _boostMultiplier = 4;
    
    _aura = [[GravityAura alloc] initWithRadius:_repelRange color:ccc3(127, 127, 255) expands:YES];
    [self addChild:_aura];
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    _sprite.position = position;
    _outline.position = position;
    _halo.position = position;
    _aura.position = position;
    //_hitParticles.position = ccpAdd(position, _hitParticlesOffset);
}

- (BOOL)updateIsOnScreen
{
    CGPoint pt = [self convertToWorldSpace:CGPointZero];
    CGFloat radius = _haloRadius / [ActionLayer sharedActionLayer].viewZoom;
    CGRect rect = CGRectMake(pt.x-radius, pt.y-radius, radius*2, radius*2);
    if ( CGRectIntersectsRect([CCDirector sharedDirector].screenRect, rect) )
        _isOnScreen = YES;
    else
        _isOnScreen = NO;
    
    return _isOnScreen;
}

- (void)onExit
{
    [super onExit];
    
    [self remove];
}

- (void)setBlockAngle:(CGFloat)blockAngle
{
    _blockAngle = blockAngle;
    
    self.rotation = -CC_RADIANS_TO_DEGREES(_blockAngle); // necessary for hit particles, which are added locally
    _sprite.rotation = -CC_RADIANS_TO_DEGREES(_blockAngle);
    _outline.rotation = _sprite.rotation;
}

- (void)setBlockSize:(CGSize)blockSize
{
    _blockSize = blockSize;
    
    _sprite.blockSize = _blockSize;
    _outline.blockSize = _blockSize;
    self.contentSize = _blockSize;
    
    _radiusW = _blockSize.width/2;
    _radiusH = _blockSize.height/2;
    _radius = MAX(_radiusW, _radiusH);
    
    _haloRadius = _radius + 30;
//    _halo.scale = _haloRadius / (_halo.contentSize.width/2);
}


- (void)hitAtAngle:(CGFloat)angle
{
    _charges = 0;
    
    _hitParticles = [CCParticleSystemQuad particleWithFile:@"blockActivate.plist"];
    _hitParticles.positionType = kCCPositionTypeGrouped;
    
    // configure particles
    if ( angle == 0 )
    {
        _hitParticles.posVar = ccp(0, _radiusH);
        _hitParticlesOffset = ccp(_radiusW, 0);
    }
    else if ( fabsf(angle-M_PI_2) < 0.1 )
    {
        _hitParticles.posVar = ccp(_radiusW, 0);
        _hitParticlesOffset = ccp(0, _radiusH);
    }
    else if ( fabsf(angle-M_PI) < 0.1 )
    {
        _hitParticles.posVar = ccp(0, _radiusH);
        _hitParticlesOffset = ccp(-_radiusW, 0);
    }
    else if ( fabsf(angle- -M_PI_2) < 0.1 )
    {
        _hitParticles.posVar = ccp(_radiusW, 0);
        _hitParticlesOffset = ccp(0, -_radiusH);
    }
    _hitParticles.position = _hitParticlesOffset;
    _hitParticles.angle = CC_RADIANS_TO_DEGREES(angle);
    
    if ( _boostMultiplier > 1 )
    {
        _hitParticles.startColor = ccc4f(_hitParticles.startColor.r+0.37, _hitParticles.startColor.g+0.37, _hitParticles.startColor.b+0.37, 1);
        _hitParticles.startSize *= 3;
        _hitParticles.endSize *= 3;
        _hitParticles.speed *= 1.5;
        _hitParticles.life *= 1.5;
        _hitParticles.duration *= 1.5;
    }
    
    [self addChild:_hitParticles];
    
    [_sprite runAction:[CCFadeOut actionWithDuration:_hitParticles.life+_hitParticles.lifeVar]];
    [_outline runAction:[CCFadeOut actionWithDuration:_hitParticles.life]];
    if ( _aura )
        [_aura fadeOut:_hitParticles.life];
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:_hitParticles.life+_hitParticles.lifeVar]
                                      two:[CCCallFunc actionWithTarget:self selector:@selector(remove)]]];
}

- (void)setCharges:(int)charges
{
    _charges = charges;
    _sprite.color = ccc3(charges/3.0*255, charges/3.0*255, charges/3.0*255);
    
    if ( charges == 0 )
        _halo.visible = NO;    
}

- (void)remove
{
    [_sprite removeFromParentAndCleanup:YES];
    [_outline removeFromParentAndCleanup:YES];
    [_halo removeFromParentAndCleanup:YES];
    [_aura removeFromParentAndCleanup:YES];
    [_hitParticles removeFromParentAndCleanup:YES];
}

- (void)highlight
{
    _sprite.color = ccc3(255, 0, 0);
}

- (void)fadeIn:(ccTime)length
{
    GLubyte spriteOpacity = _sprite.opacity;
    GLubyte outlineOpacity = _outline.opacity;
    
    _sprite.opacity = 0;
    _outline.opacity = 0;
    
    [_sprite runAction:[CCFadeTo actionWithDuration:length opacity:spriteOpacity]];
    [_outline runAction:[CCFadeTo actionWithDuration:length opacity:outlineOpacity]];
}

@end
