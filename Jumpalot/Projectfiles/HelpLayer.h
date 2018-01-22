//
//  HelpScene.h
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "CCScene.h"

@protocol HelpDelegate <NSObject>

- (void)helpDidEnd;
- (void)helpRotated:(float)rotation;

@end

@class EnergyMeter;

@interface HelpLayer : CCLayer
{
    CCArray *_pages;
    CCNode *_pageContainer;
    int _curPage;
    
    CCSprite *_player;
    CCSprite *_thumb;
    
    CGPoint _lastPanPoint;
    
    BOOL _didEnd;
    
    CCSprite *_energyLabel;
    EnergyMeter *_energyMeter;
}

@property (weak, nonatomic) id<HelpDelegate> delegate;

@end
