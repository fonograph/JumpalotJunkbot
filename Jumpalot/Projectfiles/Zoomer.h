//
//  Zoomer.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-17.
//
//

#import "CCNode.h"

@interface Zoomer : CCNode
{
    CCSprite *_sprite;
    CCParticleSystemQuad *_ps;
}

@property (nonatomic) CGSize zoomerSize;
@property (readonly, nonatomic) BOOL active;
@property (readonly, nonatomic) CGFloat radius;

- (void)reset;
- (void)hit;
- (void)updateAngleToPlayer:(CGFloat)angle;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;

@end
