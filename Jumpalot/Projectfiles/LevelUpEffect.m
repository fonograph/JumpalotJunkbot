//
//  LevelUpEffect.m
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import "LevelUpEffect.h"
#import "ActionLayer.h"
#import "SimpleAudioEngine.h"

@implementation LevelUpEffect

- (id)initWithLevel:(int)level
{
    if ( self=[super init] )
    {
        ccColor3B color;
        if ( level == 2 ) color = ccc3(159, 255, 128);
        else if ( level == 3 ) color = ccc3(255, 238, 128);
        else if ( level == 4 ) color = ccc3(255, 128, 128);
        else if ( level == 5 ) color = ccc3(255, 128, 238);
        else if ( level == 6 ) color = ccc3(128, 145, 255);
        else if ( level == 7 ) color = ccc3(128, 255, 238);
        
        
        UIColor *uic = [UIColor colorWithRed:color.r/255.0 green:color.g/255.0 blue:color.b/255.0 alpha:1];
        CGFloat h,s,b;
        [uic getHue:&h saturation:&s brightness:&b alpha:nil];
        b = 0.8;
        h += 0.2;
        if ( h > 1 ) h-=1;
//        s += 0.15;
//        if ( s > 1 ) s=1;
        uic = [UIColor colorWithHue:h saturation:s brightness:b alpha:1];
        CGFloat red,green,blue;
        [uic getRed:&red green:&green blue:&blue alpha:nil];
        ccColor3B colorFront = ccc3(red*255, green*255, blue*255);
        
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        CGPoint screenCenter = [CCDirector sharedDirector].screenCenter;
        
        
        _batch = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"hudSprites.pvr"]];
        
        _bg = [CCSprite spriteWithSpriteFrameName:@"levelup_circle.png"];
        _bg.position = screenCenter;
        [_batch addChild:_bg];
        
        _rays = [CCArray array];
        for ( int a=0; a<360; a+=20 )
        {
            CCSprite *ray = [CCSprite spriteWithSpriteFrameName:@"levelup_ray.png"];
            ray.anchorPoint = ccp(0.5, 0);
            ray.position = screenCenter;
            ray.rotation = a;
            ray.color = color;
            [_batch addChild:ray];
            [_rays addObject:ray];
        }
        
        _next = [CCSprite spriteWithSpriteFrameName:@"levelup_next.png"];
        _next.anchorPoint = ccp(0, 0);
        _next.color = colorFront;
        [_batch addChild:_next];
        
        _zone = [CCSprite spriteWithSpriteFrameName:@"levelup_zone.png"];
        _zone.anchorPoint = ccp(0, 0);
        _zone.color = colorFront;
        [_batch addChild:_zone];
        
        _number = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"levelup_%d.png", level]];
        _number.anchorPoint = ccp(0, 0);
        _number.color = colorFront;
        [_batch addChild:_number];
        
        [self addChild:_batch];
        
        // START ANIMATION
        
        _bg.scale = 0;
        [_bg runAction:[CCScaleTo actionWithDuration:0.7 scale:screenSize.height*1.5/_bg.contentSize.height]];
        
        for ( NSUInteger i=0; i<_rays.count; i++ )
        {
            CCSprite *ray = [_rays objectAtIndex:i];
            ray.scale = 0;
            [ray runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:MAX(0.03*i, 0)]
                                             two:[CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.2 scale:1.2]]]];
        }
        
        _next.position = ccp(-_next.contentSize.width, screenCenter.y+175);
        [_next runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.3]
                                           two:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:ccp(35, _next.position.y)] rate:4]]];
         
        _zone.position = ccp(screenSize.width, screenCenter.y+124);
        [_zone runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.5]
                                           two:[CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:ccp(65, _zone.position.y)] rate:4]]];
        
        _number.position = ccp(-_number.contentSize.width, screenCenter.y+36);
        [_number runAction:[CCSequence actions:
                            [CCDelayTime actionWithDuration:0.7],
                            [CCEaseOut actionWithAction:[CCMoveTo actionWithDuration:0.25 position:ccp(209, _number.position.y)] rate:4],
                            [CCDelayTime actionWithDuration:0.2],
                            [CCCallFunc actionWithTarget:[ActionLayer sharedActionLayer] selector:@selector(onLevelUpStarted)],
                            nil]];
        
        
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"levelup.caf"];
        
        
        _timeElapsed = 0;
        _canFinish = NO;
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)update:(ccTime)delta
{
    _timeElapsed += delta;
    if ( _timeElapsed > 3 && _canFinish )
    {
        [self unscheduleUpdate];
        
        CGSize screenSize = [CCDirector sharedDirector].screenSize;
        
        // END ANIMATION
        [_bg runAction:[CCScaleTo actionWithDuration:0.4 scale:0]];
        
        for ( CCSprite *ray in _rays )
        {
            [ray runAction:[CCScaleTo actionWithDuration:0.4 scale:0]];
        }
        
        [_next runAction:[CCMoveTo actionWithDuration:0.4 position:ccp(screenSize.width, _next.position.y)]];
        [_zone runAction:[CCMoveTo actionWithDuration:0.4 position:ccp(-_zone.contentSize.width, _zone.position.y)]];
        [_number runAction:[CCMoveTo actionWithDuration:0.4 position:ccp(screenSize.width, _number.position.y)]];
        
        [self runAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.4]
                                          two:[CCCallFunc actionWithTarget:self selector:@selector(finish)]]];
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"levelupOut.caf"];        
    }
}

- (void)finish
{
    [[ActionLayer sharedActionLayer] onLevelUpFinished];
}

@end
