//
//  LevelUpEffect.h
//  Jumpalot
//
//  Created by David Fono on 2013-10-04.
//
//

#import "CCNode.h"

@interface LevelUpEffect : CCNode
{
    CCSpriteBatchNode *_batch;
    CCSprite *_bg;
    CCArray *_rays;
    CCSprite *_next;
    CCSprite *_zone;
    CCSprite *_number;
    
    ccTime _timeElapsed;
}

@property (nonatomic) BOOL canFinish;

- (id)initWithLevel:(int)level;

@end
