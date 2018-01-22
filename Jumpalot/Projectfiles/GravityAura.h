//
//  GravityAura.h
//  Jumpalot
//
//  Created by David Fono on 2013-07-12.
//
//

#import "CCNode.h"

@interface GravityAura : CCNode
{
    CCArray *_sprites;
    BOOL _expands;
    CGFloat _radius;
}

- (id)initWithRadius:(CGFloat)radius color:(ccColor3B)color expands:(BOOL)expands;
- (void)fadeOut:(ccTime)duration;

@end
