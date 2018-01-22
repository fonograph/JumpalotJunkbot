//
//  PlayerStreak.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-26.
//
//

#import "PlayerStreak.h"

@implementation PlayerStreak

- (id)init
{
    if ( self = [super init] )
    {
        _streak = [CCMotionStreak streakWithFade:1 minSeg:8 width:20 color:ccc3(255, 255, 255) textureFilename:@"playertrail.png"];
        _streak.position = CGPointZero;
        _streak.blendFunc = (ccBlendFunc){GL_ONE, GL_ONE};
        [self addChild:_streak];
        
        _streakPos = CGPointZero;
        
        _active = NO;
    }
    return self;
}

- (void)start
{
    _active = YES;
    
    [_streak reset];
    _streak.position = CGPointZero;
    _streakPos = CGPointZero;
    self.position = CGPointZero;
}

- (void)stop
{
    _active = NO;
}

- (void)scroll:(CGPoint)delta
{
    self.position = ccpAdd(self.position, delta);
    
    if ( _active )
    {
        _streakPos = ccpSub(_streakPos, delta);
        _streak.position = _streakPos;
    }
}

- (void)setColor:(ccColor3B)color
{
    [_streak tintWithColor:color];
}

@end
