//
//  HelpScene.m
//  Jumpalot
//
//  Created by David Fono on 2013-01-25.
//
//

#import "HelpLayer.h"
#import "LoadingScene.h"
#import "MainMenuScene.h"
#import "EnergyMeter.h"

@interface HelpLayer()

- (void)showPage:(int)page;
- (void)end;

@end

@implementation HelpLayer

- (id)init
{
    if ( self = [super init] )
    {
        CCSprite *page1 = [CCSprite spriteWithFile:@"help1.png"];
        CCSprite *page2 = [CCSprite spriteWithFile:@"help2.png"];        
        CCSprite *page3 = [CCSprite spriteWithFile:@"help3.png"];        
//        CCSprite *page4 = [CCSprite spriteWithFile:@"help4.png"];
        
        _pages = [CCArray arrayWithNSArray:@[page1, page2, page3]];
        
        _pageContainer = [CCNode node];
        _pageContainer.position = [CCDirector sharedDirector].screenCenter;
        [self addChild:_pageContainer];
        
        int i=0;
        for ( CCSprite *page in _pages )
        {
            [_pageContainer addChild:page];
            page.opacity = 0;
            page.visible = NO;
            page.rotation = i*90;
            i++;
        }
        
        _player = [CCSprite spriteWithSpriteFrameName:@"player1_jump.png"];
        _player.position = _pageContainer.position;
        [self addChild:_player];
        
        _thumb = [CCSprite spriteWithFile:@"thumb.png"];
        _thumb.anchorPoint = ccp(0.5, 0);
        _thumb.position = ccp(_pageContainer.position.x, 0);
        [self addChild:_thumb];
        
        _curPage = -1;
        
        

        _energyMeter = [[EnergyMeter alloc] init];
        _energyMeter.position = ccp(0, [CCDirector sharedDirector].screenSize.height - _energyMeter.contentSize.height);
        _energyMeter.visible = NO;

        _energyLabel = [CCSprite spriteWithSpriteFrameName:@"hudEnergy.png"];
        _energyLabel.anchorPoint = ccp(0, 0);
        _energyLabel.position = ccp(0, _energyMeter.position.y);
        _energyLabel.visible = NO;
        
        [self addChild:_energyLabel];
        [self addChild:_energyMeter];
    }
    return self;
}

- (void)onEnter
{
    [super onEnter];
    
    [KKInput sharedInput].gesturePanEnabled = YES;
    [KKInput sharedInput].gestureTapEnabled = YES;
    
    [self showPage:0];
    
    [self scheduleUpdate];
}

- (void)onExit
{
    [super onExit];
    
    [KKInput sharedInput].gesturePanEnabled = NO;
    [KKInput sharedInput].gestureTapEnabled = NO;
    
    [self unscheduleUpdate];
}

- (void)update:(ccTime)delta
{
    if ( [KKInput sharedInput].gesturePanBegan )
    {
        CGPoint pt = [KKInput sharedInput].gesturePanLocation;
        if ( pt.y < CONTROL_AREA_HEIGHT && _lastPanPoint.x )
        {
            CGFloat pan = pt.x - _lastPanPoint.x;
            _pageContainer.rotation -= pan * 0.35;
            [_delegate helpRotated:-pan*0.35];
            
            //_pageContainer.rotation = clampf(_pageContainer.rotation, 0, 360);
            
            if ( !_didEnd )
            {
                if ( _pageContainer.rotation > -45 )
                    [self showPage:0];
                else if ( _pageContainer.rotation > -135 )
                    [self showPage:1];
                else if ( _pageContainer.rotation > -225 )
                    [self showPage:2];
//                else if ( _pageContainer.rotation < 315 )
//                    [self showPage:3];
                else
                    [self end];
            }
            
            // energy preview
            if ( _pageContainer.rotation < -45 && _pageContainer.rotation > -135 )
            {
                _energyLabel.visible = YES;
                _energyMeter.visible = YES;
                _energyMeter.percentage = 100 - 100 * (fabsf(_pageContainer.rotation)-45) / (135-45);
            }
            else
            {
                _energyLabel.visible = NO;
                _energyMeter.visible = NO;
            }
        }
        
         _lastPanPoint = pt;
    }
    else if ( _lastPanPoint.x )
    {
        if ( _pageContainer.rotation > 0 )
            [_pageContainer runAction:[CCRotateTo actionWithDuration:0.25 angle:0]];
        
        _lastPanPoint = CGPointZero;
    }

}

- (void)end
{
    [_player runAction:[CCFadeOut actionWithDuration:0.5]];
    [_thumb runAction:[CCFadeOut actionWithDuration:0.5]];
    [(CCNode *)[_pages objectAtIndex:_curPage] runAction:[CCSequence actions:
                                                [CCFadeOut actionWithDuration:0.5],
                                                [CCDelayTime actionWithDuration:0.5], // let fade display
                                                [CCCallFunc actionWithTarget:self selector:@selector(onEndComplete)],
                                                nil]];
    _didEnd = YES;
}

- (void)onEndComplete
{
    [_delegate helpDidEnd];
}

- (void)showPage:(int)page
{
    if ( _curPage == page )
        return;
    
    CCNode *oldPage = _curPage >= 0 ? [_pages objectAtIndex:_curPage] : nil;
    CCSprite *newPage = [_pages objectAtIndex:page];
    
    newPage.visible = YES;
    newPage.opacity = 0;
    
    [oldPage runAction:[CCSequence actions:
                        [CCFadeOut actionWithDuration:0.25],
                        [CCCallBlock actionWithBlock:^{ oldPage.visible=NO; }],
                        nil]];
    [newPage runAction:[CCFadeIn actionWithDuration:0.25]];
    
    _curPage = page;
}

@end
