//
//  SettingsLayer.m
//  Jumpalot
//
//  Created by David Fono on 2013-02-15.
//
//

#import "SettingsLayer.h"
#import "UserData.h"
#import "MainMenuScene.h"
#import "JunkCategory.h"
#import "JunkType.h"
#import "SimpleAudioEngine.h"
#import "CCBReader.h"

@implementation SettingsLayer

- (id)init
{
    if ( self = [super init] )
    {
        CCDirector *director = [CCDirector sharedDirector];
        
        CCLayer *layer = (CCLayer *)[CCBReader nodeGraphFromFile:@"MainSettings.ccbi" owner:self];
        [self addChild:layer];
        
        _clearButton.position = ccp(director.winSize.width/2, -300);
        
        CCLabelTTF *cheatLabel = [CCLabelTTF labelWithString:@"CHEAT" fontName:FONT_D3_ALPHABET fontSize:30];
        
        CCSprite *upSprite = [CCSprite spriteWithFile:@"mainmenu_up.png"];
        CCSprite *upSpriteSel = [CCSprite spriteWithFile:@"mainmenu_up.png"];
        upSpriteSel.color = ccc3(127, 127, 127);
        
        CCMenuItemSprite *upButton = [CCMenuItemSprite itemWithNormalSprite:upSprite selectedSprite:upSpriteSel target:self selector:@selector(tappedUp:)];
        upButton.position = ccp(director.winSize.width/2, director.winSize.height-21 - _menu.position.y);
        upButton.opacity = 204;
        
        [_menu addChild:upButton];
        
        _scoreLabel.string = [NSString stringWithFormat:@"%d", [[UserData sharedData] highScore]];
        _junksLabel.string = [NSString stringWithFormat:@"%d", [[UserData sharedData] highJunks]];
        
        int minutes = (int)[[UserData sharedData] longestTime] / 60;
        int seconds = (int)[[UserData sharedData] longestTime] % 60;
        _timeLabel.string = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
    return self;
}

- (void)tappedUp:(id)sender
{
    [_delegate settingsDidSelectBack];
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"beep2.caf"];
}

- (void)tappedClear:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Clear Data"
                                                        message:@"Are you sure you want to clear all data?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Clear", nil];
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ( buttonIndex != alertView.cancelButtonIndex )
    {
        [[UserData sharedData] reset];
        [[CCDirector sharedDirector] replaceScene:[[MainMenuScene alloc] init]];
    }
}

@end
