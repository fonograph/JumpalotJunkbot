//
//  MainMenuScene.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-21.
//
//

#import "CCScene.h"

@protocol MainMenuDelegate <NSObject>

- (void)mainMenuDidSelectPlay;
- (void)mainMenuDidSelectJunk;
- (void)mainMenuDidSelectHelp;
- (void)mainMenuDidSelectSettings;
- (void)mainMenuRotated:(float)rotation;

@end

@interface MainMenuLayer : CCLayer
{
    CCLayer *_menuLayer;
    CCNode *_circleContainer;
    CCSprite *_circle;
    CCLabelTTF *_tap;
    CCSprite *_thumb;
    CCLabelTTF *_play;
    CCLabelTTF *_help;
    CCLabelTTF *_junk;
    CCLabelTTF *_selectedLabel;
    CCSprite *_settings;
    
    CCSprite *_outerArrow;
    CCSprite *_innerArrow;
    CCParticleSystemQuad *_introParticles;
    
    CCLabelTTF *_driveHeading;
    CCLabelTTF *_driveLabel;
    CCSprite *_driveLeft;
    CCSprite *_driveRight;
    int _maxDrive;
    
    BOOL _didPan;
    CGPoint _lastPanPoint;
}

@property (weak, nonatomic) id<MainMenuDelegate> delegate;
@property (readonly, nonatomic) int selectedDrive;
@property (readonly, nonatomic) CCLabelTTF *title1;
@property (readonly, nonatomic) CCLabelTTF *title2;
@property (nonatomic) BOOL intro;



@end
