//
//  PlayerStreak.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-26.
//
//

#import "CCNode.h"

@interface PlayerStreak : CCNode
{
    CCMotionStreak *_streak;
    CGPoint _streakPos;
    BOOL _active;
}

- (void)start;
- (void)stop;
- (void)scroll:(CGPoint)delta;
- (void)setColor:(ccColor3B)color;

@end
