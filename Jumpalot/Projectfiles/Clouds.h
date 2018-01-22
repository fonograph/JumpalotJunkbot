//
//  Clouds.h
//  Jumpalot
//
//  Created by David Fono on 2013-09-10.
//
//

#import "CCNode.h"

@interface Clouds : CCNode
{
    CCSpriteBatchNode *_batchClouds;
    CCArray *_clouds;
}

- (void)fadeIn:(ccTime)length onComplete:(void(^)())onComplete;
- (void)zoomClouds:(ccTime)length;

@end
