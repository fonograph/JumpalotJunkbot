//
//  LoadingScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-06.
//
//

#import "LoadingScene.h"
#import "GameScene.h"
#import "Background.h"

@interface LoadingScene()

- (void)loadScene;

@end

@implementation LoadingScene

- (id)initWithBackground:(Background *)background doIntro:(BOOL)doIntro
{
    if ( self=[super init] )
    {
        _background = background;        
        if ( _background )
        {
            [_background removeFromParent];
            [self addChild:_background];
            
            CCLabelTTF *loading = [CCLabelTTF labelWithString:@"LOADING..." fontName:FONT_D3_ALPHABET fontSize:12];
            loading.anchorPoint = ccp(1, 0);
            loading.position = ccp([CCDirector sharedDirector].screenSize.width-10, 10);
            [self addChild:loading];
        }
        
        _doIntro = doIntro;
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [self scheduleOnce:@selector(loadScene) delay:0.0f];
}

- (void)loadScene
{
    [[CCDirector sharedDirector] replaceScene:[[GameScene alloc] initWithBackground:_background doIntro:_doIntro]];
}

- (void)freeMemory
{
    // do nothing, to prevent memory spikes
}


@end
