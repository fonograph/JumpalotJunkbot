//
//  Clouds.m
//  Jumpalot
//
//  Created by David Fono on 2013-09-10.
//
//

#import "Clouds.h"

@implementation Clouds


- (id)init
{
    if ( self = [super init] )
    {
        _batchClouds = [CCSpriteBatchNode batchNodeWithFile:@"bgmid1.pvr"];
        [self addChild:_batchClouds z:2];
        
        _clouds = [CCArray array];
        for ( int i=0; i<8; i++ )
        {
            CCSprite *cloud = [[CCSprite alloc] initWithFile:@"bgmid1.pvr"];
            cloud.opacity = 204;
            cloud.anchorPoint = ccp(0.5+CCRANDOM_MINUS1_1()*0.1, 0.5+CCRANDOM_MINUS1_1()*0.1);
            cloud.rotation = arc4random() % 360;
            cloud.position = CGPointZero;
            [_clouds addObject:cloud];
            [_batchClouds addChild:cloud];
        }
    }
    return self;
}

- (void)fadeIn:(ccTime)length onComplete:(void (^)())onComplete
{
    GLubyte opacity;
    for ( CCSprite *cloud in _clouds )
    {
        opacity = cloud.opacity;
        cloud.opacity = 0;
        [cloud runAction:[CCFadeTo actionWithDuration:length opacity:opacity]];
    }
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:length]
                                      two:[CCCallBlock actionWithBlock:onComplete]]];
}

- (void)zoomClouds:(ccTime)length
{
    for ( uint i=0; i<_clouds.count; i++ )
    {
        CCSprite *cloud = [_clouds objectAtIndex:i];
        ccTime d = length/_clouds.count * (_clouds.count-i);
        [cloud runAction:[CCEaseIn actionWithAction:[CCScaleBy actionWithDuration:d scale:10] rate:3]];
        [cloud runAction:[CCEaseIn actionWithAction:[CCFadeOut actionWithDuration:d] rate:3]];
    }
    
    [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:length]
                                      two:[CCCallBlock actionWithBlock:^{
        [self removeFromParentAndCleanup:YES];
    }]]];
}


@end
