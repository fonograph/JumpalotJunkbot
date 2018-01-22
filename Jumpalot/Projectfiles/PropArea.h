//
//  PropArea.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-23.
//
//

#import "CCNode.h"

@class Block, Junk, PropAreaTemplate, PropAreaRandomizer;

@interface PropArea : CCNode
{
}

@property (readonly, strong, nonatomic) CCArray *blocks;
@property (readonly, strong, nonatomic) CCArray *junks;
@property (readonly, strong, nonatomic) CCArray *zoomers;
@property (readonly, strong, nonatomic) CCArray *bombs;

+ (CGFloat)length;

- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (void)removeBlock:(Block *)block;
- (void)removeJunk:(Junk *)junk;
- (void)repopulateWithTemplate:(PropAreaTemplate *)template randomizer:(PropAreaRandomizer *)randomizer;
- (void)reset;
- (float)consumptionLevel;

@end
