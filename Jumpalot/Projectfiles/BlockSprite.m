//
//  BlockSprite.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-24.
//
//

#import "BlockSprite.h"

@implementation BlockSprite

- (id)init
{
    self = [super initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"paneltex.pvr"]];
    if ( self )
    {

    }
    return self;
}

- (void)setBlockSize:(CGSize)blockSize
{
    _blockSize = blockSize;
    
    CGSize txSize = self.texture.contentSize;
    CGFloat txWidth = txSize.width;
    CGFloat txHeight = !_repel ? txSize.height*0.75 : txSize.height*0.25;
    CGFloat txOriginY = !_repel ? 0 : txSize.height*0.75;
    self.textureRect = CGRectMake(arc4random() % (int)(txWidth-blockSize.width),
                                  txOriginY + arc4random() % (int)(txHeight-blockSize.height),
                                  blockSize.width, blockSize.height);    
}

- (void)setRepel:(BOOL)repel
{
    _repel = repel;
    [self setBlockSize:_blockSize];
}

@end
