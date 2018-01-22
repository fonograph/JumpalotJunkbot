//
//  GravityAura.m
//  Jumpalot
//
//  Created by David Fono on 2013-07-12.
//
//

#define SPRITE_COUNT 3
#define TWEEN_LENGTH 8
#define MAX_OPACITY 200

#import "GravityAura.h"
#import "ActionLayer.h"

@interface GravityAura ()

- (void)resetAndStartSpriteTween:(CCSprite *)sprite;
- (void)startSpriteTween:(CCSprite *)sprite;

@end

@implementation GravityAura

- (id)initWithRadius:(CGFloat)radius color:(ccColor3B)color expands:(BOOL)expands
{
    if ( self = [super init] )
    {
        _radius = radius;
        _expands = expands;
        
        _sprites = [CCArray array];
        
        for ( int i=0; i<SPRITE_COUNT; i++ )
        {
            int spriteNum = arc4random() % 5 + 1;
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"gravity%d.png", spriteNum]];
            sprite.opacity = 255 - i * MAX_OPACITY/SPRITE_COUNT;
            sprite.scale = i * (_radius/(sprite.contentSize.width/2))/SPRITE_COUNT;
            sprite.color = color;
            sprite.rotation = arc4random() % 360;
            [self startSpriteTween:sprite];
            
            [_sprites addObject:sprite];
            [[ActionLayer sharedActionLayer] addSpriteToForeground:sprite z:ForegroundZGravityAura];
        }
    }
    return self;
}

- (void)fadeOut:(ccTime)duration
{
    for ( CCSprite *sprite in _sprites )
    {
        [sprite stopAllActions];
        [sprite runAction:[CCFadeTo actionWithDuration:duration opacity:0]];
    }
}

- (void)onExit
{
    [super onExit];
    
    for ( CCSprite *sprite in _sprites )
    {
        [sprite stopAllActions];
        [sprite removeFromParentAndCleanup:YES];
    }
}

- (void)resetAndStartSpriteTween:(CCSprite *)sprite
{
    CGFloat maxScale = _radius/(sprite.contentSize.width/2);
    
    sprite.scale = _expands ? 0 : maxScale;
    sprite.opacity = _expands ? MAX_OPACITY : 0;
    
    [self startSpriteTween:sprite];
}

- (void)startSpriteTween:(CCSprite *)sprite
{
    [sprite stopAllActions];
    
    CGFloat maxScale = _radius/(sprite.contentSize.width/2);
    
    CGFloat targetScale = _expands ? maxScale : 0;
    CGFloat targetOpacity = _expands ? 0 : MAX_OPACITY;
    
    ccTime time = fabsf(targetScale-sprite.scale) / maxScale * TWEEN_LENGTH;
    
    [sprite runAction:[CCSequence actionOne:[CCScaleTo actionWithDuration:time scale:targetScale]
                                        two:[CCCallFuncO actionWithTarget:self selector:@selector(resetAndStartSpriteTween:) object:sprite]]];
    [sprite runAction:[CCFadeTo actionWithDuration:time opacity:targetOpacity]];
    [sprite runAction:[CCRotateBy actionWithDuration:time angle:45]];
    
}

- (void)setPosition:(CGPoint)position
{
    super.position = position;
    
    for ( CCSprite *sprite in _sprites )
        sprite.position = position;
}

@end
