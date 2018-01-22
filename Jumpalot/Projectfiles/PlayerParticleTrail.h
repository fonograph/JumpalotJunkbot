//
//  PlayerParticleTrail.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "CCNode.h"

@interface PlayerParticleTrail : CCNode
{
    CCParticleSystem *_ps;
}

- (id)initWithParticleSystem:(CCParticleSystem *)ps;
- (void)scroll:(CGPoint)delta;
- (void)stop;
- (BOOL)readyToRemove;

@end
