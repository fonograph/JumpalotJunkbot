//
//  Junk.h
//  Jumpalot
//
//  Created by David Fono on 2012-12-25.
//
//

#import "CCNode.h"

@class JunkCategory, JunkType;

@interface Junk : CCNode
{
    CCSprite *_sprite;
    CCSprite *_haloSprite;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_newLabel;
    CCParticleSystemQuad *_collectParticles;
    CCParticleSystemQuad *_idleNewParticles;
}

@property (readonly, nonatomic) CGFloat radius;
@property (readonly, nonatomic) JunkCategory *category;
@property (readonly, nonatomic) JunkType *type;
@property (readonly, nonatomic) BOOL collected;

+ (CGFloat)radius;

- (id)initWithCategory:(JunkCategory *)category type:(JunkType *)type;
- (void)updatePositionRelativeToTopContainer:(CGPoint)position;
- (void)collect;
- (void)remove;
- (void)fadeIn:(ccTime)length;

@end
