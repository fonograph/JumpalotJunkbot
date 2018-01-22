//
//  Asteroid.h
//  Jumpalot
//
//  Created by David Fono on 2013-06-21.
//
//

#import "CCNode.h"

@interface Asteroid : CCNode
{
    CCSprite *_sprite;    
    CCParticleSystemQuad *_hitParticles;
}

@property (nonatomic, readonly) CGFloat radius;
@property (nonatomic, readonly) CGPoint velocity; // in prop space
@property (nonatomic, readonly) int charges;

- (void)update:(ccTime)delta;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (void)setRandomVelocityWithinMinAngle:(CGFloat)minAngle maxAngle:(CGFloat)maxAngle;
- (void)hit;

@end
