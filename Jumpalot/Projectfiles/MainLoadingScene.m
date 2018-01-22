//
//  MainLoadingScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-10-09.
//
//

#import "MainLoadingScene.h"
#import "MainMenuScene.h"
#import "PropAreaTemplatesManager.h"
#import "SimpleAudioEngine.h"
#import "MusicController.h"
#import "JunkLoader.h"

@implementation MainLoadingScene

- (id)init
{
    if ( self=[super init] )
    {
        CCSprite *img;
        if ( [UIScreen mainScreen].bounds.size.height == 568.0f )
            img = [CCSprite spriteWithFile:@"Default-568h@2x.png" ];
        else if ( [UIScreen mainScreen].scale == 2.0f )
            img = [CCSprite spriteWithFile:@"Default~iphone.png"];
        else
            img = [CCSprite spriteWithFile:@"Default.png"];
        
        img.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:img];
        
        CCLabelTTF *loading = [CCLabelTTF labelWithString:@"LOADING..." fontName:FONT_D3_ALPHABET fontSize:12];
        loading.anchorPoint = ccp(1, 0);
        loading.position = ccp([CCDirector sharedDirector].screenSize.width-10, 10);
        [self addChild:loading];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    // load in next frame to allow art display
    [self scheduleOnce:@selector(load) delay:0];
}

- (void)load
{
    // LOAD
    
    [[PropAreaTemplatesManager sharedManager] loadTemplates];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"introsparkle.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"beep.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"beep2.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"collect.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"chime.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bounce.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"boost.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"zoom.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hyper.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"bomb.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"levelup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"levelupOut.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launchDoors.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launchFloor.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"launchWhoosh.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"alarm.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"gameover.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"menuWhoosh.caf"];
    
    // preloading music accomplishes nothing, only 1 is ever loaded at a time
    //[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"musicMenu.caf"];
    //[[MusicController sharedController] preload];
    
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.8f];
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f];
    
    [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
    
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"objectSprites.plist" textureFilename:@"objectSprites.pvr"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"playerSprites.plist" textureFilename:@"playerSprites.pvr"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"hudSprites.plist" textureFilename:@"hudSprites.pvr"];
    [[CCTextureCache sharedTextureCache] addImage:@"paneloutlinetex.pvr"];
    [[CCTextureCache sharedTextureCache] addImage:@"paneltex.pvr"];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"junkSprites.plist" textureFilename:@"junkSprites.pvr.ccz"];
    [[[CCTextureCache sharedTextureCache] addImage:@"junkSprites.pvr.ccz"] generateMipmap];
    ccTexParams texParams = {GL_LINEAR_MIPMAP_LINEAR, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_CLAMP_TO_EDGE};
    [[[CCTextureCache sharedTextureCache] addImage:@"junkSprites.pvr.ccz"] setTexParameters:&texParams];
    
    [JunkLoader loadJunk];
    
    
    // SCHEDULE MINIMUM DISPLAY PERIOD
    [self scheduleOnce:@selector(startGame) delay:0.5];
}

- (void)startGame
{
    [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];
}

- (void)freeMemory
{
    // do nothing, to prevent memory spikes
}


@end
