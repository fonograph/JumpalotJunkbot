//
//  PlayerParticleTrail.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "PlayerParticleTrail.h"

@implementation PlayerParticleTrail

- (id)initWithParticleSystem:(CCParticleSystem *)ps
{
    if ( self = [super init] )
    {
        _ps = ps;
        _ps.position = CGPointZero;
        _ps.positionType = kCCPositionTypeRelative;
        _ps.autoRemoveOnFinish = YES;
        [self addChild:_ps];
    }
    return self;
}

- (void)scroll:(CGPoint)delta
{
    self.position = ccpAdd(self.position, delta);
    _ps.position = ccpSub(_ps.position, delta);
    
    _ps.angle = CC_RADIANS_TO_DEGREES(ccpToAngle(delta));
    //_ps.rotation = -CC_RADIANS_TO_DEGREES(ccpToAngle(delta));
}

- (void)stop
{
    [_ps stopSystem];
}

- (BOOL)readyToRemove
{
    return !_ps.parent;
}

@end
