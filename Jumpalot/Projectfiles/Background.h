//
//  Background.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-18.
//
//

#import "CCNode.h"

@interface Background : CCNode
{
    CCArray *_spritesBack;
    CCSpriteBatchNode *_batchBack;
    CCArray *_spritesFront;
    CCSpriteBatchNode *_batchFront;
    int _tiles;
    
    ccTime _frontFadeCounter;
}

@property (nonatomic) GLubyte opacity;

- (void)setBackgroundLevel:(int)level;
- (void)scrollBack:(CGPoint)delta;
- (void)scrollFront:(CGPoint)delta;


@end
