//
//  MainMenuScene.h
//  Jumpalot
//
//  Created by David Fono on 2013-02-12.
//
//

#import "CCScene.h"
#import "MainMenuLayer.h"
#import "CollectionLayer.h"
#import "SettingsLayer.h"
#import "HelpLayer.h"

@class MainMenuLayer, HelpLayer, Background;

@interface MainMenuScene : CCScene <MainMenuDelegate, CollectionDelegate, SettingsDelegate, HelpDelegate>
{
    Background *_background;
    MainMenuLayer *_menuLayer;
    HelpLayer *_helpLayer;
    CollectionLayer *_collectionLayer;
    SettingsLayer *_settingsLayer;
    
    BOOL _startGameAfterHelp;
    BOOL _seenHelp;    
}

+ (MainMenuScene *)sharedScene;
- (void)onIntroComplete;
- (void)freeMemory;


@end
