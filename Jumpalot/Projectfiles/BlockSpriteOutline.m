//
//  BlockSpriteOutline.m
//  Jumpalot
//
//  Created by David Fono on 2013-09-03.
//
//

#import "BlockSpriteOutline.h"

@implementation BlockSpriteOutline

- (id)init
{
    self = [super initWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"paneloutlinetex.pvr"]];
    if ( self )
    {
        self.opacity = 200;
    }
    return self;
}

- (void)setBlockSize:(CGSize)blockSize
{
    CGFloat stroke = 4;
    
    self.textureRect = CGRectMake(0, 0, blockSize.width + stroke*2, blockSize.height + stroke*2);
}

@end
