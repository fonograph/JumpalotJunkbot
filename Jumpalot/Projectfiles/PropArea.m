//
//  PropArea.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-23.
//
//

#import "PropArea.h"
#import "Block.h"
#import "Junk.h"
#import "Zoomer.h"
#import "Bomb.h"
#import "PropAreaTemplate.h"
#import "PropAreaTemplatesManager.h"
#import "PropAreaRandomizer.h"
#import "JunkCategory.h"
#import "JunkType.h"

@implementation PropArea

+ (CGFloat)length
{
    return [PropAreaTemplate length];
}

- (id)init
{
    if ( self = [super init] )
    {
        _blocks = [CCArray array];
        _junks = [CCArray array];
        _zoomers = [CCArray array];
        _bombs = [CCArray array];
        
        self.contentSize = CGSizeMake([PropAreaTemplate length], [PropAreaTemplate length]);
    }
    return self;
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    for ( Block *block in _blocks )
    {
        [block updatePositionRelativeToTopContainer:ccpAdd(position, block.position)];
    }
    for ( Junk *junk in _junks )
    {
        [junk updatePositionRelativeToTopContainer:ccpAdd(position, junk.position)];
    }
    for ( Zoomer *zoomer in _zoomers )
    {
        [zoomer updatePositionRelativeToTopContainer:ccpAdd(position, zoomer.position)];
    }
    for ( Bomb *bomb in _bombs )
    {
        [bomb updatePositionRelativeToTopContainer:ccpAdd(position, bomb.position)];
    }
}



- (void)repopulateWithTemplate:(PropAreaTemplate *)template randomizer:(PropAreaRandomizer *)randomizer
{
    [self reset];
    
    for ( BlockConfig *blockConfig in template.blockConfigs )
    {
        Block *block = [[Block alloc] init];
        block.position = blockConfig.position;
        block.blockSize = blockConfig.size;
        block.blockAngle = blockConfig.angle;
        
        if ( blockConfig.repel )
            [block addRepel];
        
        [_blocks addObject:block];
        [self addChild:block];
        
        [block updateIsOnScreen];
    }
    
    for ( JunkConfig *junkConfig in template.junkConfigs )
    {
        if ( arc4random() % 10 < 3 )
            continue;
        
        JunkType *junkType = [randomizer typeForJunk];
        Junk *junk = [[Junk alloc] initWithCategory:junkType.category type:junkType];
        junk.position = ccpAdd(junkConfig.position, ccp(arc4random()%20, arc4random()%20));
        
        [_junks addObject:junk];
        [self addChild:junk];
    }
    
    for ( ZoomerConfig *zoomerConfig in template.zoomerConfigs )
    {
        Zoomer *zoomer = [[Zoomer alloc] init];
        zoomer.position = zoomerConfig.position;
        zoomer.zoomerSize = zoomerConfig.size;
        [zoomer reset];
        
        [_zoomers addObject:zoomer];
        [self addChild:zoomer];
    }
    
    for ( BombConfig *bombConfig in template.bombConfigs )
    {
        Bomb *bomb = [[Bomb alloc] initWithAttract:bombConfig.attract];
        bomb.position = bombConfig.position;
        bomb.bombSize = bombConfig.size;

        [_bombs addObject:bomb];
        [self addChild:bomb];
    }
}

- (void)reset
{
    for ( Block *block in _blocks )
        [block removeFromParentAndCleanup:YES];
    for ( Junk *junk in _junks )
        [junk removeFromParentAndCleanup:YES];
    for ( Zoomer *zoomer in _zoomers )
        [zoomer removeFromParentAndCleanup:YES];
    for ( Bomb *bomb in _bombs )
        [bomb removeFromParentAndCleanup:YES];
    
    _blocks = [CCArray array];
    _junks = [CCArray array];
    _zoomers = [CCArray array];
    _bombs = [CCArray array];
}
    

- (void)removeBlock:(Block *)block
{
    [block remove];
    [_blocks removeObject:block];
}

- (void)removeJunk:(Junk *)junk
{
    [junk remove];
    [_junks removeObject:junk];
}

- (float)consumptionLevel
{
    int blocksConsumed = 0;
    for ( Block *block in _blocks )
    {
        if ( block.charges == 0 )
            blocksConsumed++;
    }
    
    int junkConsumed = 0;
    for ( Junk *junk in _junks )
    {
        if ( junk.collected )
            junkConsumed++;
    }
    
    float consumption = (float)(blocksConsumed + junkConsumed) / (float)(_blocks.count + _junks.count);
    return consumption;
}

@end
