//
//  Background.m
//  Jumpalot
//
//  Created by David Fono on 2012-12-18.
//
//

#define SCALE 2
#define SPRITE_SIZE 1024
#define TILES 3

#import "Background.h"
#import "ActionLayer.h"

@implementation Background

- (id)init
{
    if ( self = [super init] )
    {
//        CGFloat len = ccpLength(CGPointMake([CCDirector sharedDirector].screenSize.width, [CCDirector sharedDirector].screenSize.height));
//        len *= [ActionLayer maxZoomOut];
        
        self.anchorPoint = ccp(0.5, 0.5);
        self.contentSize = CGSizeMake((TILES-1)*SPRITE_SIZE*SCALE, (TILES-1)*SPRITE_SIZE*SCALE);
        
        _opacity = 255;
        
    }
    return self;
}

- (void)setBackgroundLevel:(int)level
{
    [_batchBack removeFromParentAndCleanup:YES];
    [_batchFront removeFromParentAndCleanup:YES];
    
    NSString *fileBack = [NSString stringWithFormat:@"bg%d.pvr", level];
    _batchBack = [CCSpriteBatchNode batchNodeWithFile:fileBack];
    [self addChild:_batchBack];
    
    NSString *fileFront = [NSString stringWithFormat:@"bgmid%d.pvr", level];
    _batchFront = [CCSpriteBatchNode batchNodeWithFile:fileFront];
    [self addChild:_batchFront];
        
    _spritesBack = [CCArray array];
    _spritesFront = [CCArray array];
    
    for ( int row=0; row<TILES; row++ )
    {
        for ( int col=0; col<TILES; col++ )
        {
            CCSprite *sprite = [[CCSprite alloc] initWithFile:fileBack];
            sprite.scale = SCALE;
            sprite.anchorPoint = CGPointZero;
            sprite.position = ccp(col * SPRITE_SIZE * SCALE, row * SPRITE_SIZE * SCALE);
            [_spritesBack addObject:sprite];
            [_batchBack addChild:sprite];
            
            for ( int layer=0; layer<=1; layer++ )
            {
                sprite = [[CCSprite alloc] initWithFile:fileFront];
                sprite.scale = SCALE;
                sprite.anchorPoint = CGPointZero;
                sprite.position = ccp(col * SPRITE_SIZE * SCALE, row * SPRITE_SIZE * SCALE);
                sprite.opacity = layer==0 ? 220 : 0;
                sprite.flipX = sprite.flipY = layer==0 ? NO : YES;
                sprite.tag = layer;
                [_spritesFront addObject:sprite];
                [_batchFront addChild:sprite];
            }
        }
    }
    
    // center
    [self scrollBack:ccp(-SPRITE_SIZE*SCALE/2, -SPRITE_SIZE*SCALE/2)];
        
    _frontFadeCounter = 0;
}

- (void)scrollBack:(CGPoint)delta
{
    for ( CCSprite *s in _spritesBack )
    {
        CGPoint pos = s.position;
        pos.x += delta.x;
        pos.y += delta.y;
        
        if ( pos.x < - SPRITE_SIZE * SCALE )
        {
            pos.x += self.contentSize.width + SPRITE_SIZE * SCALE;
        }
        else if ( pos.x > self.contentSize.width )
        {
            pos.x -= self.contentSize.width + SPRITE_SIZE * SCALE;
        }

        if ( pos.y < - SPRITE_SIZE * SCALE )
        {
            pos.y += self.contentSize.height + SPRITE_SIZE * SCALE;
        }
        else if ( pos.y > self.contentSize.height )
        {
            pos.y -= self.contentSize.height + SPRITE_SIZE * SCALE;
        }
        
        s.position = pos;
    }
}

- (void)scrollFront:(CGPoint)delta
{
    for ( CCSprite *s in _spritesFront )
    {
        CGPoint pos = s.position;
        pos.x += delta.x;
        pos.y += delta.y;
        
        if ( pos.x < - SPRITE_SIZE * SCALE )
        {
            pos.x += self.contentSize.width + SPRITE_SIZE * SCALE;
        }
        else if ( pos.x > self.contentSize.width )
        {
            pos.x -= self.contentSize.width + SPRITE_SIZE * SCALE;
        }
        
        if ( pos.y < - SPRITE_SIZE * SCALE )
        {
            pos.y += self.contentSize.height + SPRITE_SIZE * SCALE;
        }
        else if ( pos.y > self.contentSize.height )
        {
            pos.y -= self.contentSize.height + SPRITE_SIZE * SCALE;
        }
        
        s.position = pos;
    }
}

- (void)update:(ccTime)delta
{
    _frontFadeCounter += delta/4;
    
    int phase = (int)_frontFadeCounter % 2; // 0 or 1
    float perc = _frontFadeCounter - floorf(_frontFadeCounter);
    
    // update front opacity
    for ( CCSprite *sprite in _spritesFront )
    {
        if ( sprite.tag == 0 )
            sprite.opacity = phase==0 ? perc*220 : 220-(perc*220);
        else
            sprite.opacity = phase==1 ? perc*220 : 220-(perc*220);
    }
}

- (void)setOpacity:(GLubyte)opacity
{
    if ( opacity == _opacity )
        return;
    
    _opacity = opacity;    
    
    for ( CCSprite *s in _spritesBack )
    {
        s.opacity = opacity;
    }
    for ( CCSprite *s in _spritesFront )
    {
        s.opacity = opacity;
    }
}

@end
