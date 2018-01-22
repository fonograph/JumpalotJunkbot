//
//  LaunchShip.h
//  Jumpalot
//
//  Created by David Fono on 2013-09-08.
//
//

#import "CCNode.h"


@class Player;

@interface LaunchShip : CCNode
{
    CCSprite *_spriteBack;
    CCSprite *_spriteFrontTop;
    CCSprite *_spriteFrontBottom;
    CCSprite *_spriteDoorLeft;
    CCSprite *_spriteDoorRight;
    CCSprite *_spriteFloor;
    CCNode *_spritePlayer;
    CCArray *_zzz;
}

@property (readonly, nonatomic) BOOL started;

- (id)initWithPlayer:(Player *)player;
- (void)startSequence;
- (void)hidePlayer;
- (void)scrollInAndStartSequence;
- (void)skipScrollInAndStartSequence;
- (void)scrollOut;

@end
