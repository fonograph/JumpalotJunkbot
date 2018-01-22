//
//  GameObject.h
//  Jumpalot
//
//  Created by David Fono on 12-08-28.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameObject : NSObject
{
    CCSpriteBatchNode *_batchNode;
}

@property (strong, nonatomic) CCSprite *sprite;

+ (void)initFrameCache;

- (id)initWithSprite:(CCSprite *)sprite;
- (id)initWithFrameName:(NSString *)frame inBatchNode:(NSString *)file;

@end
