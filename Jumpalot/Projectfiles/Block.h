//
//  Block.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-19.
//
//

#import "CCNode.h"

@class BlockSprite, BlockSpriteOutline, GravityAura;

@interface Block : CCNode
{
    CCSprite *_halo;
    BlockSprite *_sprite;
    BlockSpriteOutline *_outline;
    GravityAura *_aura;
    
    CCParticleSystemQuad *_hitParticles;
    CGPoint _hitParticlesOffset;
}

@property (nonatomic) CGSize blockSize;
@property (nonatomic) CGFloat blockAngle;
@property (nonatomic, readonly) CGFloat radius;
@property (nonatomic, readonly) CGFloat radiusW;
@property (nonatomic, readonly) CGFloat radiusH;
@property (nonatomic, readonly) CGFloat haloRadius;
@property (nonatomic, readonly) int charges;
@property (nonatomic, readonly) BOOL repel;
@property (nonatomic, readonly) CGFloat repelForce;
@property (nonatomic, readonly) CGFloat repelRange;
@property (nonatomic, readonly) CGFloat boostMultiplier;
@property (nonatomic, readonly) BOOL isOnScreen;

- (void)addRepel;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (BOOL)updateIsOnScreen;
- (void)hitAtAngle:(CGFloat)angle;
- (void)remove;
- (void)highlight;
- (void)fadeIn:(ccTime)length;

@end
