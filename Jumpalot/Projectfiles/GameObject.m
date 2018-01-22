//
//  GameObject.m
//  Jumpalot
//
//  Created by David Fono on 12-08-28.
//
//

#import "GameObject.h"
#import "SpriteBatchNodeManager.h"

@implementation GameObject
@synthesize sprite = _sprite;

+ (void)initFrameCache;
{
}

- (id)initWithSprite:(CCSprite *)sprite
{
    if ( self = [super init] )
    {
        _sprite = sprite;
    }
    return self;
}

- (id)initWithFrameName:(NSString *)frame inBatchNode:(NSString *)file
{
    if ( self = [super init] )
    {
        _sprite = [CCSprite spriteWithSpriteFrameName:frame];
        if ( file )
        {
            _batchNode = [[SpriteBatchNodeManager manager] nodeForFile:file];
            [_batchNode addChild:_sprite];
        }
    }
    return self;
}

@end
