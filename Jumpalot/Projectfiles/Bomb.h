//
//  Bomb.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-24.
//
//

#import "CCNode.h"

@class GravityAura;

@interface Bomb : CCNode
{
    CCSprite *_sprite;
    CCParticleSystemQuad *_ps;
    GravityAura *_aura;
}

@property (nonatomic) CGSize bombSize;
@property (readonly, nonatomic) CGFloat radius;
@property (readonly, nonatomic) BOOL attract;
@property (readonly, nonatomic) CGFloat attractRange;
@property (readonly, nonatomic) CGFloat attractForce;
@property (readonly, nonatomic) BOOL exploded;

- (id)initWithAttract:(BOOL)attract;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (void)explode;

@end
