//
//  LoadingScene.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-06.
//
//

#import "CCScene.h"

@class Background;

@interface LoadingScene : CCScene
{
    Background *_background;
    BOOL _doIntro;
}

- (id)initWithBackground:(Background *)background doIntro:(BOOL)doIntro;
- (void)freeMemory;

@end
