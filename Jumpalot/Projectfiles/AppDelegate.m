/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "AppDelegate.h"
#import "PropAreaTemplatesManager.h"
#import "SimpleAudioEngine.h"
#import "JunkLoader.h"
#import "UserData.h"
#import "MusicController.h"
#import "GameScene.h"
#include <sys/utsname.h>
#include <string.h>

@implementation AppDelegate

-(void) initializationComplete
{
#ifdef KK_ARC_ENABLED
	CCLOG(@"ARC is enabled");
#else
	CCLOG(@"ARC is either not available or not enabled");
#endif
    
    // IPHONE/IPOD 4 DETECTION
    struct utsname platform;
    int rc = uname(&platform);
    if(rc == -1)
    {
        /* handle error */
    }
    else
    {
        //fprintf(stdout, "hardware platform: %s", platform.machine);
        if (
            strncmp(platform.machine, "iPhone2,1", 9) == 0
            || strncmp(platform.machine, "iPhone3,1", 9) == 0
            || strncmp(platform.machine, "iPhone3,2", 9) == 0
            || strncmp(platform.machine, "iPhone3,3", 9) == 0
            || strncmp(platform.machine, "iPod3,1", 9) == 0
            || strncmp(platform.machine, "iPod4,1", 9) == 0
        )
        {
            [[CCDirector sharedDirector] setAnimationInterval:1.0/30];
        }
    }    
    
    #if defined (DEBUG)
    [[CCDirector sharedDirector] setDisplayStats:NO];
    #endif
    
    srand(arc4random());
    
//    [[UserData sharedData] reset];
}

-(id) alternateView
{
	return nil;
}

-(void) applicationWillResignActive:(UIApplication *)application
{
	if (navController.visibleViewController == director)
	{
        if ( [director.runningScene isKindOfClass:[GameScene class]] )
        {
            GameScene *scene = (GameScene *)director.runningScene;
            if ( [scene canPause] )
            {
                [scene pause];
                return;
            }
        }
		[director pause];
	}
}

-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if (navController.visibleViewController == director)
	{
        if ( [director.runningScene isKindOfClass:[GameScene class]] )
        {
            GameScene *scene = (GameScene *)director.runningScene;
            if ( [scene canPause] )
            {
                // do nothing, because the pause menu should be up and the player will dismiss it to continue
                return;
            }
        }
		[director resume];
	}
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    id curScene = [CCDirector sharedDirector].runningScene;
    if ( [curScene respondsToSelector:@selector(freeMemory)] )
    {
        [curScene freeMemory];
    }
}

@end
