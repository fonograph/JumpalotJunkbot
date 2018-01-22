//
//  BoostMeter.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-30.
//
//

#import "cocos2d.h"

@class Player;

@interface BoostMeter : CCNode
{
    CCProgressTimer *_display;
}

@property (strong, nonatomic) Player *player;
@property (nonatomic) float percentage;

- (void)update:(ccTime)delta;

@end
