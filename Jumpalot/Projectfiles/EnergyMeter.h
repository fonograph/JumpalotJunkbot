//
//  EnergyMeter.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-18.
//
//

#import "CCNode.h"

@class Player;

@interface EnergyMeter : CCNode
{
    float _alpha;
    float _redness;
}

@property (strong, nonatomic) Player *player;
@property (nonatomic) float percentage;

- (void)update:(ccTime)delta;


@end
