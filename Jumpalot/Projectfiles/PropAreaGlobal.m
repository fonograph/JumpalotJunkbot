//
//  PropAreaGlobal.m
//  Jumpalot
//
//  Created by David Fono on 2013-06-21.
//
//

#import "PropAreaGlobal.h"
#import "Asteroid.h"
#import "ActionLayer.h"
#import "Player.h"
#import "PlayerDriveConfig.h"
#import "Block.h"
#import "PropAreaTemplate.h"
#import "PropAreaTemplatesManager.h"
#import "PropAreaRandomizer.h"
#import "Junk.h"
#import "JunkType.h"

@implementation PropAreaGlobal

- (id)initWithSize:(CGSize)size
{
    self = [super init];
    if ( self )
    {
        self.contentSize = size;
        
        _asteroids = [CCArray array];

    }
    return self;
}

- (void)scroll:(CGPoint)delta
{
    for ( Asteroid *asteroid in _asteroids )
    {
        asteroid.position = ccpAdd(asteroid.position, delta);
    }
    for ( Block *block in self.blocks )
    {
        block.position = ccpAdd(block.position, delta);
    }
    for ( Junk *junk in self.junks )
    {
        junk.position = ccpAdd(junk.position, delta);
    }
}

- (void)updatePositionRelativeToTopContainer:(CGPoint)position
{
    [super updatePositionRelativeToTopContainer:position];
    
    for ( Asteroid *asteroid in _asteroids )
    {
        [asteroid updatePositionRelativeToTopContainer:ccpAdd(position, asteroid.position)];
    }
}

- (void)generateAsteroids:(int)count
{
    for ( int i=0; i<count; i++ )
    {
        // generate a single asteroid
        float angle = CCRANDOM_0_1() * 2*M_PI;
        CGPoint point = ccp(cosf(angle)*[ActionLayer sharedActionLayer].visibleRadius, sinf(angle)*[ActionLayer sharedActionLayer].visibleRadius);
        point = ccpAdd(point, ccp(self.contentSize.width/2, self.contentSize.height/2));
        
        Asteroid *asteroid = [[Asteroid alloc] init];
        asteroid.position = point;
        [asteroid setRandomVelocityWithinMinAngle:angle+M_PI-M_PI_4 maxAngle:angle+M_PI+M_PI_4];
        
        [self addChild:asteroid];
        [_asteroids addObject:asteroid];
    }
}

- (void)cleanupProps
{
    // remove props that have passed out of range
    for ( int i=_asteroids.count-1; i>=0; i-- )
    {
        Asteroid *asteroid = [_asteroids objectAtIndex:i];
        if ( !asteroid.parent || ccpDistance(ccp(self.contentSize.width/2, self.contentSize.height/2), asteroid.position) > [ActionLayer sharedActionLayer].visibleRadius*2 )
        {
            [asteroid removeFromParentAndCleanup:YES];
            [_asteroids removeObject:asteroid];
        }
    }
    for ( int i=self.blocks.count-1; i>=0; i-- )
    {
        Block *block = [self.blocks objectAtIndex:i];
        if ( !block.parent || ccpDistance(ccp(self.contentSize.width/2, self.contentSize.height/2), block.position) > [ActionLayer sharedActionLayer].visibleRadius*2 )
        {
            [block removeFromParentAndCleanup:YES];
            [self.blocks removeObject:block];
        }
    }
    for ( int i=self.junks.count-1; i>=0; i-- )
    {
        Junk *junk = [self.junks objectAtIndex:i];
        if ( !junk.parent || ccpDistance(ccp(self.contentSize.width/2, self.contentSize.height/2), junk.position) > [ActionLayer sharedActionLayer].visibleRadius*2 )
        {
            [junk removeFromParentAndCleanup:YES];
            [self.junks removeObject:junk];
        }
    }
}

- (void)updateDynamicProps
{
    Player *player = [ActionLayer sharedActionLayer].player;
    if ( _isDynamic && player.moveSpeed > 0 )
    {
        CGPoint playerPos = ccp(self.contentSize.width/2, self.contentSize.height/2);
        CGFloat horizonDist = [ActionLayer sharedActionLayer].visibleRadius;

        // are we headed for some blocks?
        BOOL blocksInPlace = NO;
        for ( Block *block in self.blocks )
        {
            CGPoint blockPt = ccpRotateByAngle(block.position, playerPos, -player.moveAngle);
            if ( fabsf(ccpToAngle(ccpSub(blockPt, playerPos))) < M_PI_4 ) // 45 degrees out
            {
                blocksInPlace = YES;
                break;
            }
        }
        
        if ( !blocksInPlace )
        {
            //make them blocks
            
            PropAreaTemplate *template = [[PropAreaTemplatesManager sharedManager] randomTemplateFromSet:0];
            PropAreaRandomizer *randomizer = [PropAreaRandomizer sharedRandomizer];
            
            CGFloat scale = 1 + 0.15*([ActionLayer sharedActionLayer].player.driveConfig.level-1);
            
            CCArray *newBlocks = [CCArray array];
            
            CGPoint startPtInTemplate = ccp(500 * scale, 0);
            CGFloat placementAngle = player.moveAngle;
            CGPoint placementPt = ccpAdd(playerPos, ccpMult(ccpForAngle(placementAngle), horizonDist*0.75));
            
            BOOL flip = NO; //bah this isn't working
            
            for ( BlockConfig *blockConfig in template.blockConfigs )
            {
                CGPoint pos = blockConfig.position;
                CGFloat angle = blockConfig.angle;
                
                if ( flip )
                {
                    pos.x = 2*startPtInTemplate.x - pos.x;
                    
                    angle = fmodf(angle, M_2_PI);
                    if ( angle < -M_PI )
                        angle += M_2_PI;
                    angle = M_PI - angle;
                }
                
                Block *block = [[Block alloc] init];
                block.position = ccpAdd(placementPt, ccpRotateByAngle(ccpSub(ccpMult(pos, scale), startPtInTemplate), ccp(0,0), -M_PI_2+placementAngle));
                block.blockSize = CGSizeMake(blockConfig.size.width * scale, blockConfig.size.height * scale);
                block.blockAngle = angle + -M_PI_2+placementAngle;
                
                [block fadeIn:0.25];
                
                [self.blocks addObject:block];
                [self addChild:block];
                
                [newBlocks addObject:block];
            }
            
            for ( JunkConfig *junkConfig in template.junkConfigs )
            {
                if ( arc4random() % 10 < 3 )
                    continue;
                
                CGPoint pos = junkConfig.position;
                
                if ( flip )
                {
                    pos.x = 2*startPtInTemplate.x - pos.x;
                }
                
                JunkType *junkType = [randomizer typeForJunk];
                Junk *junk = [[Junk alloc] initWithCategory:junkType.category type:junkType];
                junk.position = ccpAdd(placementPt, ccpRotateByAngle(ccpSub(ccpMult(pos, scale), startPtInTemplate), ccp(0,0), -M_PI_2+placementAngle));
                
                [junk fadeIn:0.25];
                
                [self.junks addObject:junk];
                [self addChild:junk];
            }
            
        }

    }
}



/*
 
 
 CGFloat radius1 = 60 + CCRANDOM_0_1()*50;
 CGFloat dist1 = horizonDist*0.8 + radius1;
 CGFloat angle1 = M_PI / (9 + CCRANDOM_0_1()+2);
 CGPoint pos1 = ccpAdd(playerPos, ccpMult(ccpRotateByAngle(ccpNormalize(player.velocity), CGPointZero, angle1), dist1));
 
 Block *block1 = [[Block alloc] init];
 block1.blockSize = CGSizeMake(radius1*2, radius1*(CCRANDOM_0_1()+1));
 block1.blockAngle = CCRANDOM_0_1() * M_2_PI;
 block1.position = pos1;
 
 [self.blocks addObject:block1];
 [self addChild:block1];
 
 CGFloat radius2 = 60 + CCRANDOM_0_1()*50;;
 CGFloat dist2 = horizonDist*0.8 + radius2;
 CGFloat angle2 = -M_PI / (9 + CCRANDOM_0_1()+2);
 CGPoint pos2 = ccpAdd(playerPos, ccpMult(ccpRotateByAngle(ccpNormalize(player.velocity), CGPointZero, angle2), dist2));
 
 Block *block2 = [[Block alloc] init];
 block2.blockSize = CGSizeMake(radius2*2, radius2*(CCRANDOM_0_1()+1));
 block2.blockAngle = CCRANDOM_0_1() * M_2_PI;
 block2.position = pos2;
 
 [self.blocks addObject:block2];
 [self addChild:block2];
 
 CGFloat radius3 = 60 + CCRANDOM_0_1()*50;
 CGFloat dist3 = dist1 + radius1 + 100 + radius3 + 200*CCRANDOM_0_1();;
 CGFloat angle3 = M_PI / (12 + CCRANDOM_0_1()+4);
 CGPoint pos3 = ccpAdd(playerPos, ccpMult(ccpRotateByAngle(ccpNormalize(player.velocity), CGPointZero, angle3), dist3));
 
 Block *block3 = [[Block alloc] init];
 block3.blockSize = CGSizeMake(radius3*2, radius3*(CCRANDOM_0_1()+1));
 block3.blockAngle = CCRANDOM_0_1() * M_2_PI;
 block3.position = pos3;
 
 [self.blocks addObject:block3];
 [self addChild:block3];
 
 CGFloat radius4 = 60 + CCRANDOM_0_1()*50;
 CGFloat dist4 = dist2 + radius2 + 100 + radius4 + 200*CCRANDOM_0_1();;
 CGFloat angle4 = -M_PI / (12 + CCRANDOM_0_1()+4);
 CGPoint pos4 = ccpAdd(playerPos, ccpMult(ccpRotateByAngle(ccpNormalize(player.velocity), CGPointZero, angle4), dist4));
 
 Block *block4 = [[Block alloc] init];
 block4.blockSize = CGSizeMake(radius4*2, radius4*(CCRANDOM_0_1()+1));
 block4.blockAngle = CCRANDOM_0_1() * M_2_PI;
 block4.position = pos4;
 
 [self.blocks addObject:block4];
 [self addChild:block4];
 
 
 // add junk
 while ( self.junks.count < 15 )
 {
 CGPoint junkPos = ccp(arc4random() % (int)self.contentSize.width, arc4random() % (int)self.contentSize.height);
 if ( ccpDistance(junkPos, playerPos) >= horizonDist + [Junk radius] ) // not in view
 {
 BOOL overlapsBlock = NO;
 for ( Block *block in self.blocks )
 {
 if ( ccpDistance(block.position, junkPos) < block.radius + [Junk radius] )
 overlapsBlock = YES;
 }
 if ( !overlapsBlock )
 {
 JunkType *junkType = [[PropAreaRandomizer sharedRandomizer] typeForJunk];
 Junk *junk = [[Junk alloc] initWithCategory:junkType.category type:junkType];
 junk.position = junkPos;
 
 [self.junks addObject:junk];
 [self addChild:junk];
 }
 }
 }
 
 // remove overlapping junk
 for ( Block *block in newBlocks )
 {
 for ( int i=self.junks.count-1; i>=0; i-- )
 {
 Junk *junk = [self.junks objectAtIndex:i];
 if ( ccpDistance(block.position, junk.position) < block.radius + junk.radius*2 )
 {
 [self removeJunk:junk];
 }
 }
 }

*/


@end
