//
//  BlockSprite.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-24.
//
//

#import "CCSprite.h"

@interface BlockSprite : CCSprite
{
    BOOL _repel;
}

@property (nonatomic) CGSize blockSize;
@property (nonatomic) BOOL repel;

@end
