//
//  JunkMeter.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-08.
//
//

#import "CCNode.h"

@class Score;

@interface JunkMeter : CCNode
{
    CCLabelTTF *_label;
}

@property (strong, nonatomic) Score *score;
//@property (readonly, nonatomic) BOOL showing;

- (void)update:(ccTime)delta;

@end