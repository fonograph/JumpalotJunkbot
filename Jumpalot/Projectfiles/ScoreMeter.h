//
//  ScoreMeter.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "CCNode.h"

@class Score;

@interface ScoreMeter : CCNode
{
    CCLabelTTF *_label;
}

@property (strong, nonatomic) Score *score;

- (void)update:(ccTime)delta;

@end
